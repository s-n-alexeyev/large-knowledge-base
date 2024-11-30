2022-12-28
[Оригинальная статья](https://forum.keenetic.com/topic/15533-prometheus/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# [Prometheus](https://prometheus.io/)  
[Обзор](https://prometheus.io/docs/introduction/overview/)

>[!info]
> Все команды для манипулирования пакетами необходимо производить из консоли ssh, подключаясь по IP адресу вашего [Entware](https://help.keenetic.com/hc/ru/articles/360021214160-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B-%D0%BF%D0%B0%D0%BA%D0%B5%D1%82%D0%BE%D0%B2-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F-Entware-%D0%BD%D0%B0-USB-%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) роутера Keenetic.
>Команды telnet можно производить через [CLI Keenetic](https://help.keenetic.com/hc/ru/articles/213965889-%D0%98%D0%BD%D1%82%D0%B5%D1%80%D1%84%D0%B5%D0%B9%D1%81-%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%BD%D0%BE%D0%B9-%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B8-CLI-%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82-%D1%86%D0%B5%D0%BD%D1%82%D1%80%D0%B0)? (например http://192.168.1.1/a).

>Обновляем репозиторй Entware
```bash
opkg update
```

>Устанавливаем текстовый редактор
```bash
opkg install nano
```

> Устанавливаем пакет
```bash
opkg install prometheus
```

> Редактируем конфигурационный файл `prometheus.yml` (меняем `- targets: ["localhost:9090"]` на адрес устройства):
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["192.168.1.1:9090"]
```

>Запускаем сервис:
```bash
 /opt/etc/init.d/S70prometheus start
```

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_16:42:44-prom-stat.png|600](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!42!44-prom-stat.png)
>[!info]- Остальные изображения
>![screen_2022-12-28_16:48:51-prom-targ.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!48!51-prom-targ.png)
>
>![screen_2022-12-28_16:44:56-prom-metr.png|500](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!44!56-prom-metr.png)

Prometheus умеет в отображать графики:

![screen_2022-12-28_16:53:20-prom-graf-w.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!53!20-prom-graf-w.png)

>[!info]- Остальные изображения
>![screen_2022-12-28_16:56:42-prom-graf-b.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!56!42-prom-graf-b.png)
>
>или (IP:9090/consoles/prometheus.html):
>
>![screen_2022-12-28_16:59:53-prom-graf-con.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_16!59!53-prom-graf-con.png)

## [snmp_exporter](https://github.com/prometheus/snmp_exporter)

Keenetic умеет работать с snmp (если компонент "Сервер SNMP" установлен):

>[!warning] Если компонент не установлен и захотите его добавить, прошивка обновиться до актуальной версии (в зависимости от канала обновлений).

>Активируем сервис, если не активен, в CLI (telnet|SSH) или web:
```telnet
service snmp
```

>Сохраняем настройки:
```telnet
system configuration save
```

>Устанавливаем пакет: 
```bash
opkg install prometheus-snmp-exporter
```

>Добавляем в конфигурационный файл `prometheus.yml`:
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
  # snmp
  - job_name: "snmp"
    static_configs:
    - targets: ["192.168.1.1"]
    metrics_path: /snmp
    params:
      module: [if_mib]
    relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: 192.168.1.1:9116
```

>[!example]- Готовый конфигурационный файл
>```yaml
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # snmp
>  - job_name: "snmp"
>    static_configs:
>    - targets: ["192.168.1.1"]
>    metrics_path: /snmp
>    params:
>      module: [if_mib]
>    relabel_configs:
>    - source_labels: [__address__]
>      target_label: __param_target
>    - source_labels: [__param_target]
>      target_label: instance
>    - target_label: __address__
>      replacement: 192.168.1.1:9116
>```

>[!warning] После правок конфигурационного файла рrometheus, сервис перезапускать обязательно !!!
```
/opt/etc/init.d/S70prometheus restart
```

>Запускаем сервис:
```bash
/opt/etc/init.d/S99snmp_exporter start
```

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_17:25:54-snmp-targ.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_17!25!54-snmp-targ.png)

![screen_2022-12-28_17:37:07-snmp-graf.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_17!37!07-snmp-graf.png)

## [node_exporter](https://github.com/prometheus/node_exporter)

>Устанавливаем пакет:
```bash
opkg install prometheus-node-exporter
```

>Добавляем в конфигурационный файл `prometheus.yml`:
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
  # node
  - job_name: "node"
    static_configs:
    - targets: ["192.168.1.1:9100"]
```

>[!example]- Готовый конфигурационный файл
>```yaml
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # node
>  - job_name: "node"
>    static_configs:
>    - targets: ["192.168.1.1:9100"]
>```

>[!warning] После правок конфигурационного файла рrometheus, сервис перезапускать обязательно !!!
```
/opt/etc/init.d/S70prometheus restart
```

>Запускаем сервис:
```bash
/opt/etc/init.d/S99node_exporter start
```

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_17:52:16-node-targ.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_17!52!16-node-targ.png)

>[!info]- Остальные изображения
>![screen_2022-12-28_17:56:00-node-graf.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_17!56!00-node-graf.png)
>
>или (IP:9090/consoles/node.html)
>
>![screen_2022-12-28_18:00:22-node-cons.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_18!00!22-node-cons.png)

## [haproxy_exporter](https://github.com/prometheus/haproxy_exporter)

>Устанавливаем пакет:
```bash
opkg install prometheus-haproxy-exporter
```

>Добавляем в конфигурационный файл `prometheus.yml`:
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
  # haproxy
  - job_name: "haproxy"
    static_configs:
    - targets: ["192.168.1.1:8404"]
```

>[!example]- Готовый конфигурационный файл
>```yaml
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # haproxy
>  - job_name: "haproxy"
>    static_configs:
>    - targets: ["192.168.1.1:8404"]
>```

>[!warning] После правок конфигурационного файла рrometheus, сервис перезапускать обязательно !!!
```bash
/opt/etc/init.d/S70prometheus restart
```

>Изменяем конфигурационный файл `haproxy.cfg` и закомментировав или удалив строку "mode health":
```bash
nano /opt/etc/haproxy.cfg
```

```config
# Prometheus
frontend stats
  mode http
  bind *:8404
  http-request use-service prometheus-exporter if { path /metrics }
  stats enable
  stats uri /stats
  stats refresh 10s
```

>[!example]- Готовый конфигурационный файл
>```config
># Example configuration file for HAProxy 2.0, refer to the url below for
># a full documentation and examples for configuration:
># https://cbonte.github.io/haproxy-dconv/2.0/configuration.html
>
>
># Global parameters
>global
>
>	# Log events to a remote syslog server at given address using the
>	# specified facility and verbosity level. Multiple log options
>	# are allowed.
>	#log 10.0.0.1 daemon info
>
>	# Specifiy the maximum number of allowed connections.
>	maxconn 32000
>
>	# Raise the ulimit for the maximum allowed number of open socket
>	# descriptors per process. This is usually at least twice the
>	# number of allowed connections (maxconn * 2 + nb_servers + 1) .
>	ulimit-n 65535
>
>	# Drop privileges (setuid, setgid), default is "root" on OpenWrt.
>	uid 0
>	gid 0
>
>	# Perform chroot into the specified directory.
>	#chroot /var/run/haproxy/
>
>	# Daemonize on startup
>	daemon
>
>	nosplice
>	# Enable debugging
>	#debug
>
>	# Spawn given number of processes and distribute load among them,
>	# used for multi-core environments or to circumvent per-process
>	# limits like number of open file descriptors. Default is 1.
>	#nbproc 2
>
># Default parameters
>defaults
>	# Default timeouts
>	timeout connect 5000ms
>	timeout client 50000ms
>	timeout server 50000ms
>
>
># Example HTTP proxy listener
>listen my_http_proxy
>
>	# Bind to port 81 and 444 on all interfaces (0.0.0.0)
>	bind :81,:444
>
>	# We're proxying HTTP here...
>	mode http
>
>	# Simple HTTP round robin over two servers using the specified
>	# source ip 192.168.1.1 .
>	balance roundrobin
>	server server01 192.168.1.10:80 source 192.168.1.1
>	server server02 192.168.1.20:80 source 192.168.1.1
>
>	# Serve an internal statistics page on /stats:
>	stats enable
>	stats uri /stats
>
>	# Enable HTTP basic auth for the statistics:
>	stats realm HA_Stats
>	stats auth username:password
>
>
># Example SMTP proxy listener
>listen my_smtp_proxy
>
>	# Disable this instance without commenting out the section.
>	disabled
>
>	# Bind to port 26 and 588 on localhost
>	bind 127.0.0.1:26,127.0.0.1:588
>
>	# This is a TCP proxy
>	mode tcp
>
>	# Round robin load balancing over two servers on port 123 forcing
>	# the address 192.168.1.1 and port 25 as source.
>	balance roundrobin
>	#use next line for transparent proxy, so the servers can see the
>	#original ip-address and remove source keyword in server definition
>	#source 0.0.0.0 usesrc clientip
>	server server01 192.168.1.10:123 source 192.168.1.1:25
>	server server02 192.168.1.20:123 source 192.168.1.1:25
>
>
># Special health check listener for integration with external load
># balancers.
>listen local_health_check
>
>	# Listen on port 60000
>	bind :60000
>
>	# This is a health check
>	#mode health <= или удалить
>
>	# Enable HTTP-style responses: "HTTP/1.0 200 OK"
>	# else just print "OK".
>	#option httpchk
>
># Prometheus
>frontend stats
>  mode http
>  bind *:8404
>  http-request use-service prometheus-exporter if { path /metrics }
>  stats enable
>  stats uri /stats
>  stats refresh 10s
>```

>Запускаем сервисы:
```bash
/opt/etc/init.d/S99haproxy start 
/opt/etc/init.d/S99haproxy_exporter start
```

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_18:38:36-hap-targ.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_18!38!36-hap-targ.png)

![screen_2022-12-28_18:44:11-hap-graf.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_18!44!11-hap-graf.png)

## [collectd_exporter](https://github.com/prometheus/collectd_exporter/)

>Устанавливаем пакет
```bash
opkg install prometheus-collectd-exporter
```

>Добавляем в конфигурационный файл `prometheus.yml`:
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
  # collectd
  - job_name: "collectd"
    static_configs:
    - targets: ["192.168.1.1:9103"]
```

>[!example]- Готовый конфигурационный файл
>```yaml
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # collectd
>  - job_name: "collectd"
>    static_configs:
>    - targets: ["192.168.1.1:9103"]
>```

>[!warning] После правок конфигурационного файла рrometheus, сервис перезапускать обязательно !!!
```
/opt/etc/init.d/S70prometheus restart
```

>Изменяем конфигурационный файл `collectd.conf`:
```bash
nano /opt/etc/collecd.conf
```

```config
LoadPlugin network
<Plugin network>
  Server "127.0.0.1" "25826"
</Plugin>
```

>Запускаем сервисы:
```bash
/opt/etc/init.d/S70collectd start
/opt/etc/init.d/S99collectd_exporter start
````

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_18:59:16-coll-targ.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_18!59!16-coll-targ.png)

![screen_2022-12-28_19:02:29-coll-graf.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!02!29-coll-graf.png)

# [Grafana](https://grafana.com/)

>Устанавливаем пакет
```bash
opkg install grafana
```

>Запускаем сервис:
```bash
/opt/etc/init.d/S80grafana start
```

В браузере переходим на адрес устройства и порт `3000`:

Подключаем Prometheus: `Connections` -> `Data source` -> `Add data source` =-> `Prometheus` => `URL` <- `адрес устройства и порт` -> `Save & test`

![screen_2022-12-28_19:22:48-grafa-prom.png|400](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!22!48-grafa-prom.png)

![screen_2022-12-28_19:23:54-grafa-prom-s.png|400](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!23!54-grafa-prom-s.png)

Встроенный Dashboard очень простой

![screen_2022-12-28_19:58:15-grafa-stub.png|700](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!58!15-grafa-stub.png)

![screen_2022-12-28_19:55:54-grafa-stub2.png|800](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!55!54-grafa-stub2.png)
 
 Дальше, строим самостоятельно или импортируем готовые Dashboard [https://grafana.com/grafana/dashboards/](https://grafana.com/grafana/dashboards/)

>[!info]- SNMP - ID: 11169
>
>![screen_2022-12-28_19:36:37-grafa-snmp.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!36!37-grafa-snmp.png)
>
>![screen_2022-12-28_19:37:32-grafa-snmp.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!37!32-grafa-snmp.png)

>[!info]- SNMP - ID: 10523
>
>![screen_2022-12-28_19:43:36-grafa-snmp.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!43!36-grafa-snmp.png)

>[!info]- node - ID: 1860
>
>![screen_2022-12-28_19:47:13-grafa-node.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!47!13-grafa-node.png)
>
>![screen_2022-12-28_19:52:02-grafa-node.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!52!02-grafa-node.png)
>
>![screen_2022-12-28_19:53:32-grafa-node.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_19!53!32-grafa-node.png)
# [Goflow](https://github.com/cloudflare/goflow)

## [netflow-exporter](https://github.com/AlfredArouna/netflow_exporter)

Keenetic может работать с netflow (если компонент "Сенсор NetFlow" установлен):

>[!warning] Если компонент не установлен и захотите его добавить, прошивка обновиться до актуальной версии (в зависимости от канала обновлений).

>Активируем сервис, если не активен, в CLI (telnet|SSH) или web:

>Выбираем интерфейс (напр., "Bridge0") и вариант прослушки (входяший(ingress)|исходящий(egress)|оба-два(both)): 
```telnet
interface Bridge0 ip flow both
```

>Указываем адрес (напр., 127.0.0.1) и порт - `2055` сервера для приёма:
```telnet
ip flow-export destination 127.0.0.1 2055
```

>Указываем версию протокола netflow (для cnflegacy|csflow - 5 , для остальных - 9):
```telnet
ip flow-export version 9
```

>Сохраняем настройки: 
```telnet
system configuration save
```

>Устанавливаем один из пакетов:
```bash
opkg install cnetflow

#или
opkg install cnflegacy

#или
opkg install csflow

#или
opkg install goflow

#или
opkg install netflow-exporter
```

>Добавляем в конфигурационный файл `prometheus.yml`:
```bash
nano /opt/etc/prometheus/prometheus.yml
```

```yaml
  # goflow
  - job_name: "goflow"
    static_configs:
    - targets: ["192.168.1.1:8080"]
```

>[!example]- Готовый конфигурационный файл
>```
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # goflow
>  - job_name: "goflow"
>    static_configs:
>    - targets: ["192.168.1.1:8080"]
>```

>или
```yaml
  # netflow
  - job_name: "netflow"
    static_configs:
    - targets: ["192.168.1.1:9191"]
```

>[!example]- Готовый конфигурационный файл
>```
># my global config
>global:
>  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
>  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
>  # scrape_timeout is set to the global default (10s).
>
># Alertmanager configuration
>alerting:
>  alertmanagers:
>    - static_configs:
>        - targets:
>          # - alertmanager:9093
>
># Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
>rule_files:
>  # - "first_rules.yml"
>  # - "second_rules.yml"
>
># A scrape configuration containing exactly one endpoint to scrape:
># Here it's Prometheus itself.
>scrape_configs:
>  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
>  - job_name: "prometheus"
>
>    # metrics_path defaults to '/metrics'
>    # scheme defaults to 'http'.
>
>    static_configs:
>      - targets: ["192.168.1.1:9090"]
>
>  # netflow
>  - job_name: "netflow"
>    static_configs:
>    - targets: ["192.168.1.1:9191"]
>```


>[!warning] После правок конфигурационного файла рrometheus, сервис перезапускать обязательно !!!
```
/opt/etc/init.d/S70prometheus restart
```

>Запускаем сервис (в зависимости от установленного пакета):
```bash
/opt/etc/init.d/S99cnetflow start

#или
/opt/etc/init.d/S99cnflegacy start

#или
/opt/etc/init.d/S99csflow start

#или
/opt/etc/init.d/S99goflow start

#или
/opt/etc/init.d/S99netflow_exporter start
```

В браузере переходим на адрес устройства и порт `9090`:

![screen_2022-12-28_20:44:20-goflow-targ.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_20!44!20-goflow-targ.png)

>[!info]- Остальные изображения
>![screen_2022-12-28_20:47:18-goflow-graf.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_20!47!18-goflow-graf.png)
>
>![screen_2022-12-28_20:42:32-flow-targ.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_20!42!32-flow-targ.png)
>
>![screen_2022-12-28_20:40:28-flow-graf.png](/Media/Pictures/Keenetic_Prometeus_Grafana/screen_2022-12-28_20!40!28-flow-graf.png)