# Monitor OpenWrt nodes with Prometheus

2020-12-28

![](https://www.cloudrocket.at/images/2020/openwrt_prometheus.png)

# Настройка openwrt

## Установка пакетов

Если вы приверженец консоли, то можете пропустить установку пакетов через web-интерфейс, перейдя непосредственно к пункту [Вход в консоль OpenWrt]

![[pacman.png|400]]


Как не сложно догадаться откроется страница **Software**, на ней нас для начала интересует кнопка **Update lists...**, нажимаем на неё.

![[paclist.png|800]]

Появится модальное окно, а в нём отладочные данные о процессе обновления списка пакетов, смотрим что всё хорошо, далее справа снизу жмём кнопку **Dismiss**.

![[modal.png|800]]

Теперь найдём необходимые пакеты, для этого в поле **Filter** пишем слово **exporter** и смотрим что получилось.
![[filter.png|800]]


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

![[pacset.png|800]]

## Вход в консоль OpenWrt

>[!warning] `192.168.1.1`- IP-адрес роутера по-умолчанию на роутерах OpenWRT, но может быть другим если вы его меняли на своём роутере.

>Входим на роутер по ssh, в windows ssh можно запустить внутри powershell.
```bash
ssh root@192.168.1.1
```

>[!summary] Удачный вход
>```
>BusyBox v1.36.1 (2024-03-22 22:09:42 UTC) built-in shell (ash)
>
> _______                     ________        __
>|       |.-----.-----.-----.|  |  |  |.----.|  |_
>|   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
>|_______||   __|_____|__|__||________||__|  |____|
>         |__| W I R E L E S S   F R E E D O M
>-----------------------------------------------------
>OpenWrt 23.05.2, r23809-234f1a2efa
>-----------------------------------------------------
>root@OpenWrt:~#
>```

> Установка необходимых пакетов, если вы устанавливали их через web-интерфейс, то пропускаем:
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

>Пишем в консоли следующую команду, которая отредактирует файл _/etc/config/prometheus-node-exporter-lua_ и заменит в нём слово _localhost_ на слово _lan_.
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

>[!summary] В ответе должно быть примерно похожее это
>```
># TYPE node_scrape_collector_duration_seconds gauge
># TYPE node_scrape_collector_success gauge
># TYPE node_nf_conntrack_entries gauge
>node_nf_conntrack_entries 806
># TYPE node_nf_conntrack_entries_limit gauge
>node_nf_conntrack_entries_limit 31744
>node_scrape_collector_duration_seconds{collector="conntrack"} 0.0016260147094727
>node_scrape_collector_success{collector="conntrack"} 1
># TYPE node_boot_time_seconds gauge
>node_boot_time_seconds 1721742742
># TYPE node_context_switches_total counter
>node_context_switches_total 80612070
># TYPE node_cpu_seconds_total counter
>node_cpu_seconds_total{cpu="cpu0",mode="user"} 292.93
>node_cpu_seconds_total{cpu="cpu0",mode="nice"} 0
>node_cpu_seconds_total{cpu="cpu0",mode="system"} 498.31
>node_cpu_seconds_total{cpu="cpu0",mode="idle"} 68699.17
>```

	## Как запустить сервер Prometheus?

>[!info] Назначение Prometheus
>Проект Prometheus - это специальный сервис по сбору метрик и аналитических данных с различных удалённых и не очень удалённых систем.
>Основная его задача в том чтобы собирать данные из экспортеров сформированные в виде временных рядов, которые затем можно визуализировать и проанализировать для получения информации о производительности и состоянии инфраструктуры в целом или отдельных подсистем в частности.

Переходим на наш Linux сервер на котором будем разворачивать Prometheus и Grafana.
На сервере уже должен быть развернут `Docker` c `Docker Compose`


>И так, создадим пустую папку, назовём её скажем _docker-monitoring_, после чего перейдём в неё.
```bash
mkdir docker-monitoring  
cd docker-monitoring
```

>Теперь создадим в ней файл _docker-compose.yml_ и откроем его в редакторе _nano_ (хотя лично я предпочитаю _mcedit_).
```bash
touch docker-compose.yml  
nano docker-compose.yml
```

>Заполняем его следующими содержимым:
```yaml
services:

  prometheus:
    image: prom/prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus_data:/prometheus
    networks:
      - monitoring
    ports:
      - 9090:9090

networks:
  monitoring:
    driver: bridge

```
Далее жмём комбинацию клавиш `CTRL+X`, затем клавишу `Y`, затем клавишу `Enter`, сохраняя изменения.

>Возможно вы уже обратили внимание на файл _prometheus.yml_ упомянутий в конфигурации, в нём содержатся настройки сервиса Prometheus, создим его, после чего откроем в редакторе:
```bash
touch prometheus.yml  
nano prometheus.yml
```

>Наполним его следующим содержимым:
```yaml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: prometheus
    static_configs:
     - targets:
        - prometheus:9090
  - job_name: node
    static_configs:
     - targets:
        - 192.168.1.1:9100
```
Сохраним и выйдем.

>Далее создадим пустую папку _prometheus_data_ в которую сервис Prometheus будет сохранять своё состояние.
```bash
mkdir ./prometheus_data  
sudo chown 65534:65534 ./prometheus_data
```

>Теперь запустим контейнер с сервисом Prometheus и посмотрим что получилось:

```bash
docker compose up -d
```

>[!summary] Успешная установка
```
user@ubuntu24:~/docker-monitoring$
docker compose up -d  
[+] Running 13/13  
✔ prometheus Pulled                                                                                                                                                     16.0s    
  ✔ 9fa9226be034 Pull complete                                                                                                                                           1.6s    
  ✔ 1617e25568b2 Pull complete                                                                                                                                           2.1s    
  ✔ ec307c9fbf62 Pull complete                                                                                                                                          10.2s    
  ✔ d4e715947f0e Pull complete                                                                                                                                          11.5s    
  ✔ c522420720c6 Pull complete                                                                                                                                          11.6s    
  ✔ 18d28937c421 Pull complete                                                                                                                                          11.7s    
  ✔ 873361efd54d Pull complete                                                                                                                                          11.7s    
  ✔ dd44465db85c Pull complete                                                                                                                                          11.8s    
  ✔ 0636908550c9 Pull complete                                                                                                                                          11.9s    
  ✔ cd795675b8a2 Pull complete                                                                                                                                          12.0s    
  ✔ 407f3c6e3260 Pull complete                                                                                                                                          12.0s    
  ✔ 67fb76c620a2 Pull complete                                                                                                                                          12.1s    
[+] Running 2/2  
✔ Network docker-monitoring_monitoring      Created                                                                                                                      0.2s    
✔ Container docker-monitoring-prometheus-1  Started
```

Контейнер запущен и поэтому теперь можно зайти на web-интерфейс и убедиться в том, что Prometheus корректно работает, откроем следующую страницу в браузере по вашему IP например http://192.168.1.35:9090
![|700](/media/OpenWRT_Grafana_Prometeus_Docker/prometheus.png)

Выбрав `status` -> `targets` видим что наш node имеет статус `UP`

![|800](/media/OpenWRT_Grafana_Prometeus_Docker/targets.png)

# Grafana

Прежде чем продолжим давайте немного поговорим о проекте Grafana, если в двух словах то этот проект представляет из себя мощный и интуитивно понятной инструмент для визуализации данных и аналитики.  
Grafana позволяет создавать красивые и информативные диаграммы, таблицы, графики и другие представления на основе данных из различных источников, включая Prometheus, InfluxDB, Elasticsearch и многих других.  

>Установку Grafana также будем осуществлять с использованием Docker, для этого снова откроем _docker-compose.yml_ через редактор и добавим в него сервис _grafana_.
```bash
nano prometheus.yml
```

```yaml
services:

  prometheus:
    image: prom/prometheus:main
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus_data:/prometheus
    networks:
      - monitoring
    ports:
      - 9090:9090

  grafana:
    image: grafana/grafana
    restart: unless-stopped
    volumes:
      - ./grafana_data:/var/lib/grafana
    networks:
      - monitoring
    ports:
      - 3000:3000

networks:
  monitoring:
    driver: bridge
```

>Далее создадим пустую папку _grafana_data_ в которую сервис Grafana будет сохранять своё состояние.
```bash
mkdir ./grafana_data  
sudo chown 472:0 ./grafana_data
```

>Затем запустим контейнер с Grafana:
```bash
docker compose up -d
```

>[!summary] Успешная установка
```
 [+] Running 11/11
 ✔ grafana Pulled                                                                                                                                                        32.0s 
   ✔ 4abcf2066143 Pull complete                                                                                                                                          11.4s 
   ✔ 98999a963eb1 Pull complete                                                                                                                                          11.6s 
   ✔ b180e2ca9e8f Pull complete                                                                                                                                          13.0s 
   ✔ cac1080c172a Pull complete                                                                                                                                          13.5s 
   ✔ bd82675e0b18 Pull complete                                                                                                                                          13.9s 
   ✔ 738e7aa6d1a7 Pull complete                                                                                                                                          14.1s 
   ✔ 23dc5704465b Pull complete                                                                                                                                          24.5s 
   ✔ dacdf2ddd5ed Pull complete                                                                                                                                          28.4s 
   ✔ 44e45a199224 Pull complete                                                                                                                                          28.5s 
   ✔ 52722462a4a0 Pull complete                                                                                                                                          28.6s 
[+] Running 2/2
 ✔ Container docker-monitoring-grafana-1     Created   
 ✔ Container docker-monitoring-prometheus-1  Running
```

Теперь давайте подождём пару минут и откроем в браузере страницу по нашему IP адресу, например http://192.168.1.35:3000
![|800](/media/OpenWRT_Grafana_Prometeus_Docker/grafana.png)



## Добавить источник данных Prometheus

Теперь добавьте новый экземпляр Prometheus в качестве источника данных в Grafana. Перейдите в [раздел «Конфигурация/Источники данных»](http://localhost:3000/datasources/new) , выберите источник данных Prometheus и настройте URL-адрес. Мы можем использовать здесь имя контейнера докеров, поскольку мы находимся в одной сети докеров. Если вы запускаете другую настройку, добавьте сюда IP-адрес вашего основного сервера Prometheus:
Подключаем Prometheus: `Connections` -> `Data source` -> `Add data source` =-> `Prometheus` => `URL` <- `адрес устройства и порт` -> `Save & test`

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
