# [Базовый мониторинг. Prometheus и node_exporter.](https://devops.spb.ru/instrumenty-devops/monitoring/monitoring/ "Постоянная ссылка на: Базовый мониторинг. Prometheus и node_exporter.")

Мониторинг. Мониторинг очень важен в работе DevOps инженера. Ведь всегда необходимо отслеживать состояние серверов, их загрузку. Это позволит вовремя исправлять ошибки и оптимизировать настройки и ресурсы сервера. Сегодня поговорим про Prometheus и конечно же node_exporter.
## Prometheus

Начнём с установки самого Prometheus.  
Т. к. у меня на работе все контуры закрытые, то и установка будет производится не через пакетный менеджер, а через скаченные пакеты.

>Идем в репозиторий Prometheus на [GitHub](https://github.com/prometheus/prometheus/releases/) и скачиваем оттуда пакет. Затем копируем его на сервер (например в папку /tmp) и начинаем установку и настройку.
```shell
# переходим в папку с архивом
cd /tmp
# разархивируем его
tar xvzf prometheus-2.45.0.linux-amd64.tar.gz
# и копируем исполняемые файлы в необходимые папки
sudo cp /prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin
sudo cp /prometheus-2.45.0.linux-amd64/promtool /usr/local/bin
# теперь создаем папку для конфигов
sudo mkdir /etc/prometheus
# и копируем туда необходимые папки и файлы
sudo cp -r /prometheus-2.45.0.linux-amd64/consoles /etc/prometheus
sudo cp -r /prometheus-2.45.0.linux-amd64/console_libraries /etc/prometheus
```

>Создаем конфигурационный файл, пользователя и файл службы.
```shell
# я люблю использовать nano
sudo nano /etc/prometheus/prometheus.yml
# содержимое файла
global:
  scrape_interval: 15s # по умолчанию сбор данных каждые 15 секунд
scrape_configs:
  - job_name: 'prometheus' # задача по сбору данных работы prometheus
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
# теперь создадим пользователя
sudo useradd --no-create-home --shell /bin/false prometheus
# и наконец создаем файл systemd службы
sudo systemctl edit --full --force prometheus.service
```

```q
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
[Install]
WantedBy=multi-user.target
```

>Теперь мы можем запускать службу Prometheus.
```shell
sudo systemctl start prometheus
sudo systemctl status prometheus
# В строке Active должно быть значение active (running)
```

Теперь проверяем, что у нас все в порядке. Откройте на сервере порт 9090 и попробуйте зайти в веб-интерфейс. Проверить что все ок можно перейдя в меню веб-интерфейса “Status” -> “Targets”. Там должен быть endpoint с именем prometheus.

Теперь переходим к установке экспортера, а именно node_exporter.
## node_exporter

Сейчас мы установим и запустим самый базовый экспортер, он предоставляет общие сведения о сервере.

Существует огромное количество экспортеров. Для Apache, MySQL, Nginx, Kafka и т.д. Выбор огромен. Но сейчас нам нужна “база”. Кстати, в следующей статье мы будем устанавливать blackbox_exporter. Он интересен с точки зрения проверки endpoint'ов.

>По традиции начнем со скачивания архива и копирования (в папку /tmp) его на сервер. Идем в [GitHub](https://github.com/prometheus/node_exporter/releases) и скачиваем необходимую версию.
```shell
# переходим в папку с архивом
cd /tmp
# разархивируем его
tar xvzf node_exporter-1.6.0.linux-amd64.tar.gz
# и копируем исполняемые файлы в необходимые папки
cp /node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin
# и наконец создаем файл systemd службы
sudo systemctl edit --full --force node_exporter.service
```

```q
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
```

```shell
# создаем пользователя
sudo useradd --no-create-home --shell /bin/false node_exporter
# стартуем сервис
systemctl start node_exporter.service
# включаем автозагрузку
systemctl enable node_exporter.service
```

node_exporter по умолчанию использует порт 9100. Проверяем что все работает, открываем на сервере порт 9100 и в веб-браузере открываем url /metrics.

>Далее сообщаем Prometheus о новом экспортере. Для этого возвращаемся на сервер с установленным prometheus и правим конфигурационный файл.
```shell
sudo nano /etc/prometheus/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  # добавляем новую задачу для prometheus
  - job_name: 'prometheus_node'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100'] # в данном случае подразумевается, что prometheus и экспортер установлены на одном сервере
```

```shell
# перезапускаем prometheus
systemctl restart prometheus
```

В следующих статьях мы установим и настроим Grafana для отображения данных собираемых Prometheus, а так же установим и настроим blackbox_exporter.