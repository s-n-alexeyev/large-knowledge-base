# Monitor OpenWrt nodes with Prometheus

December 28, 2020 · 3 min · rainer

![promwrt](/Media/OpenWRT_Grafana_Prometeus_Docker/promwrt.png)

Оглавление

# мотивация

Я использую OpenWrt уже давно, и отслеживать их всегда было немного сложно. Это становится сложнее, если вы собираетесь использовать больше точек доступа. Это несложно, поскольку [существуют сценарии prometheus-node-exporter](https://openwrt.org/packages/table/start?dataflt%5BName_pkg-dependencies*~%5D=prometheus-node) .

# настройка openwrt

## установить скрипты

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

## Как запустить сервер Prometheus?

Начнём с небольшого вступления, проект Prometheus - это специальный сервис по сбору метрик и аналитических данных с различных удалённых и не очень удалённых систем.

Основная его задача в том чтобы собирать данные из экспортеров сформированные в виде временных рядов, которые затем можно визуализировать и проанализировать для получения информации о производительности и состоянии инфраструктуры в целом или отдельных подсистем в частности.

В официальной [документации](https://dzen.ru/away?to=https%3A%2F%2Fprometheus.io%2Fdocs%2Fintroduction%2Foverview%2F) Prometheus можно почитать о данном проекте чуть подробнее.

Существует множество вариантов установки Prometheus, со всеми ими можете ознакомиться в официальной документации Prometheus, в главе [Installation](https://dzen.ru/away?to=https%3A%2F%2Fprometheus.io%2Fdocs%2Fprometheus%2Flatest%2Finstallation%2F), но а лично я предпочитаю Docker-way.

Кстати ранее я написал публикацию под названием "[Большая экскурсия в мир Docker](https://dzen.ru/a/YwlUoB1mJGQJf3Az)" и если вы не очень знакомы с тем как пользоваться Docker то рекомендую с ней ознакомиться, так как подробности установки [Docker Engine](https://dzen.ru/away?to=https%3A%2F%2Fdocs.docker.com%2Fengine%2Finstall%2F) и [Docker Compose](https://dzen.ru/away?to=https%3A%2F%2Fdocs.docker.com%2Fcompose%2Finstall%2F) я пропущу.

При описании конфигураций прометеуса буду использовать конфигурации Docker Compose, так как с моей скромной точки зрения это намного удобнее чем ванильный Docker.
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
