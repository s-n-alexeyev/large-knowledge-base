# Обход блокировок на  с помощью Passwall (v2ray, xray, trojan) и tun2socks

В данном гайде будем собирать OpenWRT на базе стабильной **23.05.0 (ранее 22.03.5)** с дополнительными репозиториями [**Passwall**](https://github.com/xiaorouji/openwrt-passwall) и [**badvpn**](https://github.com/helmiau/helmiwrt-packages/tree/main/badvpn) **(badvpn-tun2socks)**. Рекомендуется роутер **минимум с 128 МБ RAM (256 предпочтительно) и памятью более 16 МБ**. (Можно использовать внешнюю память, например usb флэшку, об этом в конце статьи)

**UPD 13.10.2023** рекомендую рассмотреть установку [HomeProxy](https://habr.com/ru/articles/760622/), пакет имеет схожий функционал, но требует меньше памяти для установки и поддерживает TUN

**luci-app-passwall** это пакет позволяющий настроить в Luci прокси, поддерживающий протоколы v2ray, xray, vless, vmess, hysteria, naiveproxy, shadowsocks, trojan и др. (Есть очень похожий по функционалу пакет - **luci-app-bypass**, занимающий около **80Мб** при установке через opkg)

**badvpn-tun2socks** это пакет позволяющий направлять трафик (в первую очередь TCP) в прокси при помощи kmod-tun и использовать традиционные настройки маршрутизации.

**UPD. 23.08.2023**

**badvpn-tun2socks** по умолчанию работает **только с** **TCP** трафиком, версия tun2socks способная работать с **TCP и UDP** это [**xjasonlyu/tun2socks**](https://github.com/xjasonlyu/tun2socks). (его настройки касался [**здесь**](https://habr.com/ru/articles/748408/))

Руководство будет включать:

1. **1.1 Установку из репозитория (требует много свободной памяти)** или **1.2** **Сборку прошивки под ваш роутер с необходимыми пакетами**  
2. **Настройку Passwall**  
3. **Настройку badvpn-tun2socks**

## 1.1 Установка пакетов на текущую прошивку

[Источник](https://tos.wiki/how-to-install-the-latest-luci-app-passwall/)

Способ самый простой, но требует много памяти (больше 90 МБ), у меня при свободных 86 Мб выдал ошибку по нехватки памяти.

UPD 13.10.2023 **Репозиторий** [**lrdrdn/my-opkg-repo**](https://github.com/lrdrdn/my-opkg-repo) **переориентировался на версию 23.05.0, претерпел изменения, потеряв большую часть пакетов необходимых для установки на 22.03.5, включая sing-box, поэтому заменил репозиторий.**

**Для 22.03.5:**

>в консоли ввести команду:
```shell
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz custom_generic https://raw.githubusercontent.com/1andrevich/andrevichwrt/main/generic" >> /etc/opkg/customfeeds.conf
echo "src/gz custom_arch https://raw.githubusercontent.com/1andrevich/andrevichwrt/main/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf
```

>**Для 23.05 и выше:**
```shell
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz custom_generic https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/generic" >> /etc/opkg/customfeeds.conf
echo "src/gz custom_arch https://raw.githubusercontent.com/lrdrdn/my-opkg-repo/main/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')" >> /etc/opkg/customfeeds.conf
```

>Далее для всех версий:
```shell
opkg update
```

>Далее установка **luci-app-passwall** и **badvpn**
```
opkg install luci-app-passwall badvpn kmod-tun
```

При успешном завершении переходим в пункт 2, при неуспешном в пункт 1.2.
## 1.2 Сборка прошивки

Подробно сборка описана в [wiki проекта openwrt.org](https://oldwiki.archive.openwrt.org/ru/doc/howto/build), я опишу только необходимые шаги для сборки.  
Моя среда сборки это виртуальная машина [Debian 11](https://www.osboxes.org/debian/) в VirtualBox, рекомендуется не менее 10 Гб свободного места на диске и не менее 4 Гб RAM  

>Устанавливаем необходимые для сборки пакеты:
```
sudo apt install binutils bzip2 diffutils flex libc-dev libz-dev perl python3.7 rsync subversion unzip ncurses-dev git-core build-essential libssl-dev libncurses5-dev gawk zlib1g-dev subversion mercurial
```

>Далее скачиваем исходный код OpenWRT версии 23.05.0
```shell
git clone https://github.com/openwrt/openwrt.git -b v23.05.0
```

>Добавляем репозитории и обновляем списки:
```shell
cd openwrt
```

```shell
echo -e "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main \nsrc-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git" >> feeds.conf.default
```

```shell
./scripts/feeds update -a./scripts/feeds install -a
```

Далее OpenWrt проверит отсутствующие пакеты в вашей системе сборки и предложит выбрать архитектуру вашего устройства и модель, а также пакеты для сборки.

```shell
make menuconfig
```

В меню необходимо выбрать ваше устройство и сохранить конфигурацию (кнопка Save).

В сборку необходимо добавить пакеты:

1. **luci**  
2. **luci-app-passwall2**  
3. **badvpn**  
4. **kmod-tun**

и удалить пакет **dnsmasq**, т.к. luci-app-passwall2 имеет зависимость **dnsmasq-full**, а это конфликтующие зависимости.

>Это можно сделать при помощи конфигуратора либо следующей командой:
```shell
echo -e "CONFIG_PACKAGE_dnsmasq=n \nCONFIG_PACKAGE_luci=y \nCONFIG_PACKAGE_luci-app-passwall2=y \nCONFIG_PACKAGE_luci-app-passwall2_INCLUDE_Shadowsocks_Rust_Client=y \nCONFIG_PACKAGE_kmod-tun=y \nCONFIG_PACKAGE_badvpn=y" >> .config
```

>Так же для последующего использования BGP для получения маршрутов от [antifilter.download](https://antifilter.download/), [antifilter.network](https://antifilter.network/) добавим пакеты **bird2** и **bird2c**
```shell
echo -e "CONFIG_PACKAGE_bird2=y \nCONFIG_PACKAGE_bird2c=y" >> .config
```

>после чего повторно запустить проверку:
```shell
make menuconfig
```

Убедиться что устройство выбрано правильно и настройки не потеряны и сохранить конфигурацию повторно (Save).

На этом этапе сборка не включает дополнительных пакетов как **OpenVPN, Wireguard, UPnP, QoS**. Их добавление увеличит размер образа. Для их добавление введите команду:

```shell
echo -e "CONFIG_PACKAGE_luci-app-openvpn=y \nCONFIG_PACKAGE_luci-app-wireguard=y \nCONFIG_PACKAGE_openvpn-openssl=y \nCONFIG_PACKAGE_luci-app-qos=y \nCONFIG_PACKAGE_luci-app-upnp=y " >> .config
```

После чего повторно запустите проверку и сохраните конфигурацию:

```shell
make menuconfig
```

После чего запускаем сборку образа (на 8 потоках):

```shell
make -j9 V=s
```

Команда запускает сборку на 8 потоках (ядрах) (8+1) с трассировкой каталогов (путей)., можете ввести нужное вам количество вместо **-j9** (например **-j5** для сборки на 4 потоках)  
Ждём окончания сборки (около 1 часа), после чего скачиваем файлы из папки ~/openwrt/bin/targets/**$платформа**/**$архитектура**/  
Для обновления существующей прошивки OpenWRT понадобится файл оканчивающийся на ***-sysupgrade.bin**  
После чего заходим в интерфейс вашего роутера, переходим в **Система** - **Восстановление/обновление**  

![](/Media/Passwall/d108e60a6fa09f1b0d930da9469853ea.png)

И загружаем собранный образ, галку сохранить настройки **убрать** (можно настройки сохранить, но возможно проблемы, не рекомендую).  
**В случае вашего роутера могут быть отличия по способу прошивки, рекомендую посетить тему по вашему устройству на сайте OpenWRT** [**[OpenWrt Wiki] Table of Hardware**](https://openwrt.org/toh/start?dataflt%5BBrand*%7E%5D=mikrotik) **дабы случайно не получить кирпич вместо роутера.**

Ждём окончания обновления роутера.

**Далее потребуется первичная настройка роутера, необходимо обеспечить подключение к интернету согласно настройкам вашего провайдера.**

Разобравшись с интернетом, переходим к пункту 2.

## 2. Настройка Passwall

Переходим в пункт **Службы (Services) - PassWall 2 или Pass Wall**

![](/Media/Passwall/32dc2b0dab28306ef726106cdff84720.png)

Далее **Node List**

![](/Media/Passwall/b2befe68671b2b70512c1befce6a301b.png)

Здесь добавляем свою конфигурацию в виде ссылки через **Add the node via the link**

![Passwall распознаёт ссылки почти всех форматов](/Media/Passwall/Passwall_распознаёт_ссылки_почти_всех_форматов.png)

Passwall распознаёт ссылки почти всех форматов

Ссылки из **Outline VPN** так же работают (shadowsocks), его настройку разбирал [тут](https://habr.com/ru/articles/748408/).

При добавлении нескольких нодов можно настроить резервирование во вкладке **Auto Switch**

![](/Media/Passwall/d0b3106509e5bfdb74115e4bffa314bf.png)

**How often to test** определяет периодичность проверки доступности прокси в минутах.

В **List of backup nodes** вносятся резервные прокси в порядке очереди перебора.

Галка **Restore Switch** определяет будет ли происходить обратное переключение при восстановлении доступа к главному прокси.

Переходим в **Basic Settings**

![](/Media/Passwall/ac756d55546607e2550ba41cd1c7cbe0.png)

Здесь выбираем главный нод (прокси) и активируем подключение галкой **Main Switch**.

Так же активируем **Localhost Proxy** и при необходимости меняем **Node Socks порт для входящих соединений** (он понадобится для настройки tun2socks).

Проверяем соединение нажатием на кнопки: Baidu Connection, Google и Github

![](/Media/Passwall/45e8ceb7a3a881730abbc8ae8653a6e4.png)

Далее переходим к настройке tun2socks.

## 3.Настройка badvpn-tun2socks

Для проверки работы туннеля введём команду:

```
badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:1070
```

Запустится туннель с логированием:

![](/Media/Passwall/15ca3bfcad520d258e18ef65a2acbc5a.png)

Где tun0 наименование туннеля (если у вас запущен OpenVPN или другой туннель использующий kmod-tun, измените значение на tun1, tun2 и т.д.).

netif-ipaddr - адрес интерфейса (не должен совпадать с диапазоном адресов локальной сети).

netif-netmask- сетевая маска /24.

socks-server-addr - адрес socks указывающий на Passwall на порту 1070 **(если вы меняли порт в п.2 укажите свой)**.

UPD 13.10.2023 Добавил команду ifconfig, т.к. без неё не всегда добавлялся маршрут для проверки работы (спасибо [@kiberlis-ru](https://habr.com/ru/users/kiberlis-ru/) )

Для проверки работоспособности можно временно добавить маршрут к сайту ipecho.net (не закрывая badvpn-tun2socks, в параллельной вкладке) и

_Подробная документация на badvpn-tun2socks есть на сайте_ [_проекта_](https://www.mankier.com/8/badvpn-tun2socks)

```
ifconfig tun0 10.0.0.1 netmask 255.255.255.252ip route add 34.160.111.0/24 dev tun0
```

Обращаемся к сайту и смотрим логи:

```
wget -qO- http://ipecho.net/plain | xargs echo
```

Если всё работает, команда вернёт IP вашего прокси.

Можно закрывать badvpn-tun2socks и удалить маршрут:

```
ip route del 34.160.111.0/24
```

Теперь настроим службу, чтобы интерфейс начинал работать при загрузке роутера.

_Здесь хочу выразить огромную благодарность пользователю_ [_itdog_](https://habr.com/ru/users/itdog/) _за информацию по настройке службы tun2socks (и за обзор темы впринципе)_.

В файл **/etc/init.d/tun2socks** вносим следующее содержание, например при помощи **vi**:

```
#!/bin/sh /etc/rc.commonUSE_PROCD=1# starts after network startsSTART=40# stops before networking stopsSTOP=89PROG=/usr/bin/badvpn-tun2socksIF="tun2"HOST="127.0.0.1"PORT="1070"IPADDR="10.0.0.2"SUBNETADDR="10.0.0.1"NETMASK="255.255.255.252"start_program() {    procd_open_instance    procd_set_param command "$PROG" --tundev "$IF" --netif-ipaddr "$IPADDR" --netif-netmask "$NETMASK" --socks-server-addr "$HOST":"$PORT"    procd_set_param stdout 1    procd_set_param stderr 1    procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}    procd_close_instance}configure_interface() {    procd_open_instance    echo "Setting 10.0.0.0/30 as subnet for tun2socks..."    # Set the IP and netmask    procd_set_param command ifconfig "$IF" "$SUBNETADDR" netmask "$NETMASK"	procd_set_param stdout 1    procd_set_param stderr 1    procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}    procd_close_instance    echo "Set 10.0.0.0/30 as subnet for tun2socks!"}start_service() {    echo "Starting service..."    start_program	echo "badvpn-tun2socks service started."	configure_interface}stop_service() {    echo "Stopping service..."    service_stop /usr/bin/badvpn-tun2socks    echo "badvpn-tun2socks service stopped."}restart_service() {    stop_service    start_service}
```

Где IF - интерфейс, в данном примере tun2 (вместо tun0) чтобы избежать конфликтов с существующими туннелями.

Port - порт Socks Passwall из п.2.

Делаем файлы исполняемым:

```
chmod +x /etc/init.d/tun2socks
```

Делаем автозапуск:

```
ln -s /etc/init.d/tun2socks /etc/rc.d/S90tun2socks
```

Запускаем:

```
/etc/init.d/tun2socks start
```

Проверяем что интерфейс появился:

```
 ip a | grep 'tun2'
```

Если заработал, выдаст подобный результат:

```
tun2: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
```

Если нет, ответ будет пустым.

Далее необходимо настроить маршруты к которым роутер будет обращаться через прокси.

Здесь я дам ссылки на известные мне способы настройки таких маршрутов:

[Точечный обход блокировок на роутере OpenWrt c помощью BGP / Хабр (habr.com)](https://habr.com/ru/articles/743572/) С помощью BGP (bird2).

[Точечный обход блокировок PKH на роутере с OpenWrt с помощью WireGuard и DNSCrypt / Хабр (habr.com)](https://habr.com/ru/articles/440030/) (путём скачивания списков и настройкой маршрутов в iptables, nftables).

**Для роутеров с малым количеством постоянной памяти (ROM) и портом USB можно воспользоваться инструкцией** [**[OpenWrt Wiki] Корневая файловая система на внешнем устройстве (extroot)**](https://openwrt.org/ru/docs/guide-user/additional-software/extroot_configuration) **, после чего попробовать установку из пункта 1.1**.