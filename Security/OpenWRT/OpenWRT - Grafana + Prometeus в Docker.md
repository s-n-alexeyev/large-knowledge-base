# Monitor OpenWrt nodes with Prometheus

2020-12-28

![](https://www.cloudrocket.at/images/2020/openwrt_prometheus.png)

# Настройка openwrt

## Установка пакетов

![[pacman.png]]


Как не сложно догадаться откроется страница **Software**, на ней нас для начала интересует кнопка **Update lists...**, нажимаем на неё.

![[paclist.png]]

Появится модальное окно, а в нём отладочные данные о процессе обновления списка пакетов, смотрим что всё хорошо, далее справа снизу жмём кнопку **Dismiss**.

![[modal.png]]

Теперь найдём необходимые пакеты, для этого в поле **Filter** пишем слово **exporter** и смотрим что получилось.
![[filter.png]]


Тут нам потребуется установить несколько пакетов:

|Пакет|Назначение|
| --- | --- |
|prometheus-node-exporter-lua |основной пакет, содержит HTTP сервер, представляет облегченную версию node_exporter|
|prometheus-node-exporter-lua-nat_traffic |сбор информации о работе цепочек NAT|
|prometheus-node-exporter-lua-netstat |сетевая статистика|
|prometheus-node-exporter-lua-openwrt |сбор общей информации об инсталляции OpenWRT|
|prometheus-node-exporter-lua-uci_dhcp_host |получает информацию об IP-адресах выданных DHCP сервером|
|prometheus-node-exporter-lua-wifi |информации о wi-fi адаптерах|
|prometheus-node-exporter-lua-wifi_stations |инорфмация о пользователях подключенных по wi-fi|
Нажимаем **Install...** возле каждого пакета из списка выше.

![[pacset.png]]


> Установка тех же пакетов через консоль:

```bash
opkg update
opkg install \
prometheus-node-exporter-lua \
prometheus-node-exporter-lua-nat_traffic \
prometheus-node-exporter-lua-netstat \
prometheus-node-exporter-lua-openwrt \
prometheus-node-exporter-lua-uci_dhcp_host \
prometheus-node-exporter-lua-wifi \
prometheus-node-exporter-lua-wifi_stations
```

Далее потребуется настроить _node_exporter_, по умолчанию он запускается только на интерфейсе _localhost_, но нам будет необходимо поменять это на интерфейс на _lan_.
Но этот раз нам в любом случае потребуется либо подключиться через ssh, либо установить расширение для web-интерфейса _luci-app-ttyd_, которое позволяет подключиться к консоли через браузер.
В windows ssh можно запустить внутри powershell.

>[!warning] `192.168.1.1`- IP-адрес роутера по-умолчанию на роутерах OpenWRT, но может быть другим если вы его меняли на своём роутере.

```bash
ssh root@192.168.1.1
```

![[terminal.png]]

>Далее пишем в консоли следующую команду, которая отредактирует файл _/etc/config/prometheus-node-exporter-lua_ и заменит в нём слово _localhost_ на слово _lan_.
```bash
sed -r 's/loopback/lan/g' -i /etc/config/prometheus-node-exporter-lua
```

>Перезапускаем node-exporter, выполнив следующую команду:
```bash
/etc/init.d/prometheus-node-exporter-lua restart
```

>Теперь проверим, что всё работает как надо, для этого выполним команду:
```bash
curl http://192.168.1.1:9100/metrics
```

 >В ответе должно быть что-то типа примера ниже
![[metrics.png]]


#### - запущен интерфейс экспортера

```bash
root@OpenWrt:/etc/config# netstat -tulpn | grep 9100
tcp        0      0 YOUR_ROUTER_IP:9100        0.0.0.0:*               LISTEN      3469/lua
```

#### - запуск конфигурации экспортера

```bash
root@OpenWrt:/etc/config# ps | grep prometheus
 3469 root      1920 S    {prometheus-node} /usr/bin/lua /usr/bin/prometheus-node-exporter-lua --bind YOUR_ROUTER_IP --port 9100
```

#### - открыть порт с хоста в локальной сети

```bash
[user@HOST-IN-LAN ~]$ nmap YOUR_ROUTER_IP -p 9100
9100/tcp open  jetdirect
```

#### - метрики от хоста в локальной сети

```bash
[user@HOST-IN-LAN ~]$ curl YOUR_ROUTER_IP:9100/metrics
```

И вы должны увидеть здесь много показателей…

# (необязательно) настройка prometheus

Теперь вы готовы настроить Prometheus. Если у вас уже есть экземпляр, вам просто нужно добавить [Scrape_config](https://www.cloudrocket.at/posts/monitor-openwrt-nodes-with-prometheus/#prometheus-config) . Если у вас его нет, не проблема =>

## запустить новый экземпляр

Если вы знакомы с Docker и Compose, вы можете просто запустить новые экземпляры prometheus/grafana. **Используйте эту конфигурацию только для временного использования** :

```yaml
version: '2.1'

networks:
  monitor-net:
    driver: bridge

volumes:
    prometheus_data: {}
    grafana_data: {}

services:

  prometheus:
    image: prom/prometheus:v2.23.0
    container_name: prometheus
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    expose:
      - 9090
    ports:
      - 9090:9090
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  grafana:
    image: grafana/grafana:7.3.6
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=${ADMIN_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    expose:
      - 3000
    ports:
      - 3000:3000
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"
```

Это урезанная и модифицированная версия от [Стефанпродана.](https://raw.githubusercontent.com/stefanprodan/dockprom/master/docker-compose.yml)

## Конфигурация прометея

Прежде чем запустить prometheus, вам необходимо изменить/добавить конфиг. Замените YOUR_ROUTER_IP, OpenWRT-ASUS_RT-AX53U в качестве примера:

```bash
nano prometheus/prometheus.yml 
```

```yaml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: prometheus
    static_configs:
     - targets:
        - prometheus:9090
  - job_name: OpenWRT-ASUS_RT-AX53U
    static_configs:
     - targets:
        - YOUR_ROUTER_IP:9100
```

Структура каталогов должна быть примерно такой:

```bash
[user@HOST-IN-LAN dockprom]$ tree
.
├── docker-compose.yml
├── grafana
│   └── provisioning
└── prometheus
    └── prometheus.yml
```

## запустить контейнеры

Теперь запустите докер-контейнеры в отключенном режиме:

```bash
[user@HOST-IN-LAN dockprom]$ docker-compose up -d
```

После получения изображений они должны запуститься через несколько секунд.

```bash
[user@HOST-IN-LAN dockprom]$ docker ps -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS                       PORTS                    NAMES
ea8419f267e5        prom/prometheus:v2.23.0     "/bin/prometheus --c…"   3 hours ago         Up 3 hours                   0.0.0.0:9090->9090/tcp   prometheus
f17822ba6bcf        grafana/grafana:7.3.6       "/run.sh"                3 hours ago         Up 3 hours                   0.0.0.0:3000->3000/tcp   grafana
```

Откройте панель управления Grafana в браузере => [http://localhost:3000](http://localhost:3000) . Учетные данные по умолчанию — admin/admin. Вам будет предложено изменить его.

# настроить графану

## добавить источник данных Прометея

Теперь добавьте новый экземпляр Prometheus в качестве источника данных в Grafana. Перейдите в [раздел «Конфигурация/Источники данных»](http://localhost:3000/datasources/new) , выберите источник данных Prometheus и настройте URL-адрес. Мы можем использовать здесь имя контейнера докеров, поскольку мы находимся в одной сети докеров. Если вы запускаете другую настройку, добавьте сюда IP-адрес вашего основного сервера Prometheus:

![Источник данных](https://www.cloudrocket.at/images/2020/openwrt_grafana_datasource.png "Источник данных Prometheus в Grafana")

## добавить панель управления OpenWrt

Теперь вы можете [импортировать панель мониторинга](http://localhost:3000/dashboard/import) . Вы можете использовать мою [панель управления Grafana для OpenWrt (11147)](https://grafana.com/grafana/dashboards/11147) .

[![Панель управления Графана](https://www.cloudrocket.at/images/2020/openwrt_grafana_dash1.png "Панель управления Графана")](https://grafana.com/grafana/dashboards/11147)

Выберите вновь созданный источник данных Prometheus.

![Панель управления Графана](https://www.cloudrocket.at/images/2020/openwrt_grafana_dash2.png "Панель управления Графана")

# смотри волшебство

[![Магия](https://www.cloudrocket.at/images/2020/openwrt_magic.gif "Это магия")](http://localhost:3000/d/fLi0yXAWk/openwrt?orgId=1&refresh=30s)

- [openwrt](https://www.cloudrocket.at/tags/openwrt/)
- [Прометей](https://www.cloudrocket.at/tags/prometheus/)
- [графана](https://www.cloudrocket.at/tags/grafana/)

[](https://twitter.com/intent/tweet/?text=Monitor%20OpenWrt%20nodes%20with%20Prometheus&url=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f&hashtags=openwrt%2cprometheus%2cgrafana)

[](https://www.linkedin.com/shareArticle?mini=true&url=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f&title=Monitor%20OpenWrt%20nodes%20with%20Prometheus&summary=Monitor%20OpenWrt%20nodes%20with%20Prometheus&source=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f)[](https://reddit.com/submit?url=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f&title=Monitor%20OpenWrt%20nodes%20with%20Prometheus)[](https://facebook.com/sharer/sharer.php?u=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f)[](https://api.whatsapp.com/send?text=Monitor%20OpenWrt%20nodes%20with%20Prometheus%20-%20https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f)[](https://telegram.me/share/url?text=Monitor%20OpenWrt%20nodes%20with%20Prometheus&url=https%3a%2f%2fwww.cloudrocket.at%2fposts%2fmonitor-openwrt-nodes-with-prometheus%2f)

© 2021 [Cloudrocket](https://www.cloudrocket.at/) · Создано [Hugo](https://gohugo.io/) · Theme [PaperMod](https://git.io/hugopapermod)

[](https://www.cloudrocket.at/posts/monitor-openwrt-nodes-with-prometheus/#top)
