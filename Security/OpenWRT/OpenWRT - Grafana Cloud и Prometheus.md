

2021-02-09  
[Оригинальная статья](https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/)  
[Автор - Matthew Helmke](https://grafana.com/author/mhelmke/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

# Как отслеживать свой маршрутизатор OpenWrt с помощью Grafana Cloud и Prometheus

---

Я являюсь поклонником и пользователем программного обеспечения с открытым исходным кодом уже много-много лет, еще до того, как мы определили термин « [открытый исходный код](https://opensource.org/osd) » и назвали его « [свободным программным обеспечением](https://www.debian.org/social_contract.html#guidelines) ». Когда и где это возможно, я предпочитаю иметь контроль над программным обеспечением, которое я запускаю на своих устройствах.

Показательный пример: мой интернет-маршрутизатор работает под управлением [OpenWrt](https://openwrt.org/) , бесплатной операционной системы Linux с открытым исходным кодом, разработанной для замены программного обеспечения, предоставляемого производителем маршрутизатора. Вы можете установить OpenWrt на широкий спектр [поддерживаемых устройств](https://openwrt.org/toh/start) . Когда вы это делаете, вы часто получаете улучшенную стабильность вместе с дополнительными параметрами конфигурации, недоступными в стандартном программном обеспечении.

В этой статье я опишу, как контролировать работоспособность моего маршрутизатора Linksys WRT1900AC под управлением OpenWrt с помощью [Grafana Cloud](https://grafana.com/products/cloud/) .
## Предпосылки

Чтобы отправить свои метрики в Grafana Cloud, мне сначала пришлось зарегистрироваться для учетной записи [Grafana Cloud](https://grafana.com/docs/grafana-cloud/quickstart/) и настроить ее. Есть [бесплатный план](https://grafana.com/auth/sign-up/create-user?pg=blog) , который идеально подходит для такого проекта. Я сделал это некоторое время назад, так что сегодня все, что мне действительно нужно было сделать, это подготовиться к созданию файла конфигурации Prometheus YAML, записав свое имя пользователя Grafana Cloud и вместо пароля — ключ API.

Вам также понадобится правильно настроенный интернет-маршрутизатор с операционной системой OpenWrt, а также система в вашей локальной сети, поддерживающая Prometheus для сбора показателей с вашего маршрутизатора и пересылки их в Grafana Cloud.

## Взаимодействие с OpenWrt

Наряду с базовой операционной системой, проект OpenWrt предоставляет большой набор программных [пакетов,](https://openwrt.org/packages/start) которые вы можете установить для настройки того, как вы используете свое оборудование и что делает программное обеспечение. Большинство этих пакетов предоставляют значительные возможности конфигурации. Вот как мы достигнем сегодняшней цели.

Существует два способа взаимодействия с OpenWrt для установки пакетов. Вы можете войти в маршрутизатор напрямую с помощью ssh или, если он у вас установлен, вы можете использовать веб-интерфейс Luci. Подключение ssh предоставляет вам оболочку [Busybox](https://busybox.net/about.html) , которая включает полезный подмножество стандартных утилит UNIX.


![](/Media/OpenWrt_Grafana/openwrt1.png)

Если вы предпочитаете использовать графический интерфейс, [Luci](https://openwrt.org/docs/guide-user/luci/luci.essentials) предоставляет интерфейс, аналогичный стандартной прошивке и простой в навигации.

![](/Media/OpenWrt_Grafana/openwrt2.png)
## Предоставление метрик с маршрутизатора OpenWrt 

Первое, что нужно выяснить, — как экспортировать полезные метрики с маршрутизатора. Я хочу их в  формате [Prometheus](http://grafana.com/oss/prometheus/) , чтобы упростить визуализацию в Grafana Cloud. К счастью, в менеджере пакетов OpenWrt есть пакеты экспортера узлов Prometheus.

Мы будем использовать интерфейс командной строки. Есть несколько пакетов, которые мы хотим установить, включая экспортер узлов Prometheus и набор определенных экспортеров метрик. Пакеты следующие:

- prometheus-node-exporter-lua
- prometheus-node-exporter-lua-nat_traffic
- prometheus-node-exporter-lua-netstat
- prometheus-node-exporter-lua-openwrt
- prometheus-node-exporter-lua-wifi
- prometheus-node-exporter-lua-wifi_stations

Для установки пакетов мы используем [менеджер пакетов Opkg](https://openwrt.org/docs/guide-user/additional-software/opkg) , который идет в комплекте с OpenWrt. Сначала обновим список пакетов:

```bash
opkg update
```

Затем устанавливаем нужные нам пакеты:
```bash
opkg install prometheus-node-exporter-lua \
prometheus-node-exporter-lua-nat_traffic \
prometheus-node-exporter-lua-netstat \
prometheus-node-exporter-lua-openwrt \
prometheus-node-exporter-lua-wifi \
prometheus-node-exporter-lua-wifi_stations
```

Доступны и другие пакеты экспортеров Prometheus, даже пакет самого Prometheus, если у вас есть маршрутизатор с хранилищем и памятью достаточного размера для запуска полной версии (в этом случае вы могли бы выполнять remote_write в Grafana Cloud непосредственно с вашего маршрутизатора!). Я выбрал их, потому что нашел [эту дополнительную панель мониторинга](https://grafana.com/grafana/dashboards/11147) , которая предварительно настроена для использования метрик из этого набора экспортеров.

По умолчанию экспортер узлов, который мы установили, будет экспортировать данные на локальный хост через порт 9100 в /metrics. Давайте проверим, экспортирует ли экспортер узлов данные так, как должен. Возможно, вам придется установить утилиту curl, прежде чем эта команда заработает. Если это так, вы увидите несколько экранов структурированных метрик, прокручивающихся мимо.

`curl localhost:9100/metrics`

Это хорошо, но мы не можем получить это извне, и у большинства из нас нет достаточного места на маршрутизаторе для запуска экземпляра Prometheus. Поэтому нам нужно сделать эти метрики доступными через IP-адрес, доступный по локальной сети.

Для этого мы отредактируем `/etc/config/prometheus-node-exporter-lua`. Примечание: редактор, который устанавливается вместе с OpenWrt, — это версия vi для BusyBox, так что освежите знания, если не помните, как им пользоваться (хотя все хорошие SRE должны знать хотя бы основы, верно?).

Отредактируйте файл так, чтобы его содержимое было следующим:
```yaml
config prometheus-node-exporter-lua 'main'
        option listen_ipv6 '0'
        option listen_port '9100'
        option listen_interface 'lan'
```

Возникает соблазн попробовать указать IP-адрес в listen_interface, но это не сработает. Интерфейс должен быть именем интерфейса OpenWrt. Список доступных именованных интерфейсов можно найти в файле `/etc/config/network`.

После редактирования `/etc/config/prometheus-node-exporter-lua` необходимо перезапустить службу, чтобы загрузить новую конфигурацию, например:

```bash
/etc/init.d/prometheus-node-exporter-lua restart
```

IP-адрес моего маршрутизатора в моей локальной сети — 192.168.1.1. Метрики теперь доступны всем в моей локальной сети по адресу 192.168.1.1:9100/metrics. Вот отрывок того, как это выглядит в моем браузере:

![](/Media/OpenWrt_Grafana/openwrt3.png)
## Сбор метрик OpenWrt с помощью Prometheus

В конечном итоге нам нужно отправить метрики в Grafana Cloud. Для этого нам нужно сначала извлечь метрики из внутреннего URL-адреса, доступного в локальной сети. Как я уже упоминал [в своем личном блоге](https://matthewhelmke.net/2020/12/monitoring-my-ups-with-grafana-cloud/) , я уже запускаю Prometheus на рабочей станции Linux в своей локальной сети и использую его для отправки других метрик в свой экземпляр Grafana Cloud.

Prometheus можно настроить для отправки метрик в удаленное местоположение с помощью функции, называемой удаленной записью. Чтобы настроить удаленную запись для отправки моих метрик в Grafana Cloud, мне сначала пришлось зарегистрироваться для учетной записи [Grafana Cloud](https://grafana.com/docs/grafana-cloud/quickstart/) и настроить ее. Я сделал это некоторое время назад, так что сегодня все, что мне действительно нужно было сделать, это отредактировать файл конфигурации Prometheus YAML, вставив этот фрагмент кода. Конечно, я отредактировал его, включив свое имя пользователя Grafana Cloud и вместо пароля — ключ API.

Это код, который нужно было добавить в конец файла конфигурации prometheus.yaml для отправки метрик через функцию remote_write в мою учетную запись Grafana Cloud:
```yaml
  remote_write:
        - url: https://prometheus-us-central1.grafana.net/api/prom/push
          basic_auth:
            username: [Your Grafana Cloud UserID]
            password: [Your Grafana Cloud API Key]
```

В то же время я добавил новый раздел job_name:
```yaml
  - job_name: OpenWrt
    static_configs:
      - targets: [192.168.1.1:9100']
```

## Просмотр метрик в Grafana Cloud

Через несколько мгновений метрики стали доступны в Grafana Cloud. Я вошел в систему и перешел в Dashboards->Manage. Оттуда я нажал Import и ввел этот URL для панели мониторинга OpenWrt, о которой я упоминал ранее: [https://grafana.com/grafana/dashboards/11147](https://grafana.com/grafana/dashboards/11147) .

Это фрагмент этой панели в действии.

![](/Media/OpenWrt_Grafana/openwrt4.png)

## Постскриптум

Весь процесс занял у меня пару часов. Это было бы быстрее, но мне пришлось разобраться с некоторыми деталями самостоятельно, что я документирую и делюсь в этом посте в блоге.

После написания этого я узнал, что [Том Уилки](https://grafana.com/author/tom/) из Grafana Labs создал [скрипт init.d](https://github.com/prometheus/node_exporter/pull/1680) для OpenWrt, чтобы упростить запуск полного [Prometheus node_exporter](https://github.com/prometheus/node_exporter) на вашем маршрутизаторе вместо версий Lua, использованных выше. Кроме того, он создал [аналогичный скрипт](https://github.com/google/dnsmasq_exporter/pull/8) для [dnsmasq_exporter](https://github.com/google/dnsmasq_exporter) , поскольку в OpenWrt уже установлен и запущен [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) . 

Единственная загвоздка в методе Уилки заключается в том, что большинство устройств потребительского уровня, таких как мой шестилетний [Linksys WRT-1900ac v1](https://openwrt.org/toh/hwdata/linksys/linksys_wrt1900ac_v1) , не имеют достаточного дискового пространства или памяти для запуска полных версий экспортеров Prometheus. Однако для тех, кто использует OpenWrt на устройствах с большим объемом доступной памяти и памяти, это, безусловно, более мощный и заслуживает изучения.