# Monitor OpenWrt nodes with Prometheus

December 28, 2020 · 3 min · rainer

![promwrt](https://www.cloudrocket.at/images/2020/openwrt_prometheus.png)

Оглавление

# мотивация

Я использую OpenWrt уже давно, и отслеживать их всегда было немного сложно. Это становится сложнее, если вы собираетесь использовать больше точек доступа. Это несложно, поскольку [существуют сценарии prometheus-node-exporter](https://openwrt.org/packages/table/start?dataflt%5BName_pkg-dependencies*~%5D=prometheus-node) .

# настройка openwrt

## установить скрипты

Вам следует начать с обновленного маршрутизатора OpenWrt. Установите скрипты экспорта узлов Prometheus:

- prometheus-node-exporter-lua
- prometheus-node-exporter-lua-nat_traffic
- prometheus-node-exporter-lua-netstat
- prometheus-node-exporter-lua-openwrt
- prometheus-node-exporter-lua-wifi
- prometheus-node-exporter-lua-wifi_stations

[![пакеты](https://www.cloudrocket.at/images/2020/openwrt_prometheus_node_pkgs.png "Список пакетов OpenWrt")](https://openwrt.org/packages/table/start?dataflt%5BName_pkg-dependencies*~%5D=prometheus-node)


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

## изменить интерфейс прослушивания

Если вы используете конфигурацию по умолчанию, экспортер узлов можно запросить только из интерфейса обратной связи.

```bash
root@OpenWrt:/etc/config# cat prometheus-node-exporter-lua
config prometheus-node-exporter-lua 'main'
	option listen_interface 'loopback'
	option listen_ipv6 '0'
	option listen_port '9100'
```

Для моей настройки я изменю его на сетевой интерфейс локальной сети:

```bash
root@OpenWrt:/etc/config# sed -i.bak 's#loopback#lan#g' /etc/config/prometheus-node-exporter-lua
```

и перезапустите экспортер

```bash
root@OpenWrt:/etc/config# /etc/init.d/prometheus-node-exporter-lua restart
```

## (необязательно) отметьте

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