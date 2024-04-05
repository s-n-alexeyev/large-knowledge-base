# Поднимаем на OpenWrt клиент прокси VLESS, Shadowsocks, Shadowsocks2022. Настройка sing-box и tun2socks

14 October 2023 · 10 min

Table of Contents

- [tun2socks](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#tun2socks)
    - [Установка](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d1%83%d1%81%d1%82%d0%b0%d0%bd%d0%be%d0%b2%d0%ba%d0%b0)
    - [Автозапуск](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d0%b0%d0%b2%d1%82%d0%be%d0%b7%d0%b0%d0%bf%d1%83%d1%81%d0%ba)
    - [Тестирование работоспособности и поиск ошибок](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d1%82%d0%b5%d1%81%d1%82%d0%b8%d1%80%d0%be%d0%b2%d0%b0%d0%bd%d0%b8%d0%b5-%d1%80%d0%b0%d0%b1%d0%be%d1%82%d0%be%d1%81%d0%bf%d0%be%d1%81%d0%be%d0%b1%d0%bd%d0%be%d1%81%d1%82%d0%b8-%d0%b8-%d0%bf%d0%be%d0%b8%d1%81%d0%ba-%d0%be%d1%88%d0%b8%d0%b1%d0%be%d0%ba)
- [Sing-box](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#sing-box)
    - [Установка](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d1%83%d1%81%d1%82%d0%b0%d0%bd%d0%be%d0%b2%d0%ba%d0%b0-1)
    - [Настройка](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d0%bd%d0%b0%d1%81%d1%82%d1%80%d0%be%d0%b9%d0%ba%d0%b0)
    - [Тестирование работоспособности и поиск ошибок](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d1%82%d0%b5%d1%81%d1%82%d0%b8%d1%80%d0%be%d0%b2%d0%b0%d0%bd%d0%b8%d0%b5-%d1%80%d0%b0%d0%b1%d0%be%d1%82%d0%be%d1%81%d0%bf%d0%be%d1%81%d0%be%d0%b1%d0%bd%d0%be%d1%81%d1%82%d0%b8-%d0%b8-%d0%bf%d0%be%d0%b8%d1%81%d0%ba-%d0%be%d1%88%d0%b8%d0%b1%d0%be%d0%ba-1)
- [Применение на роутерах](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d0%bf%d1%80%d0%b8%d0%bc%d0%b5%d0%bd%d0%b5%d0%bd%d0%b8%d0%b5-%d0%bd%d0%b0-%d1%80%d0%be%d1%83%d1%82%d0%b5%d1%80%d0%b0%d1%85)
    - [Pbr](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#pbr)
    - [Ручная настройка](https://itdog.info/podnimaem-na-openwrt-klient-proksi-vless-shadowsocks-shadowsocks2022-nastrojka-sing-box-i-tun2socks/#%d1%80%d1%83%d1%87%d0%bd%d0%b0%d1%8f-%d0%bd%d0%b0%d1%81%d1%82%d1%80%d0%be%d0%b9%d0%ba%d0%b0)

Обучающее руководство описывающее, как поднять на роутере Shadowsocks, VMess, VLESS, Trojan и даже SOCKS5 proxy и ходить к нему через сетевой интерфейс.

Трафиком на роутере удобно управлять, когда у туннеля есть свой интерфейс. С одной стороны, есть Wireguard и OpenVPN, которые предоставляют сетевые интерфейсы. C другой стороны есть, например, SOCKS5 прокси и вытекший из него Shadowsocks, которые работают на другом уровне. Настраивая их мы [получаем порт](https://github.com/openwrt/packages/blob/master/net/shadowsocks-libev/README.md#recipes) , а не интерфейс.

Здесь разобраны два инструмента, которые могут предоставить сетевой интерфейс на роутере и пересылать трафик с него во всевозможные прокси.

Sing-box умеет всё то, что умеет tun2socks и даже больше. Но вероятно, по каким-то причинам (размер пакета) вам может не подойти sing-box, поэтому также рассматривается tun2socks.

Настройка технологий сокрытия туннеля отличается от настройки стандартных туннелей. Она сложнее, пакеты занимают много места, информации меньше или она вообще отсутствует. Поэтому если у вас работают стандартные WG и OpenVPN, то рекомендую остановиться на них.

Всё производится в консоли, для tun2socks и sing-box нет специальных пакетов для настройки через LuCi.

# tun2socks

[https://github.com/xjasonlyu/tun2socks](https://github.com/xjasonlyu/tun2socks)

Поддерживает следующие типы прокси:

- HTTP
- SOCKS4/SOCKS5
- Shadowsocks (“старая” версия)

Объем распакованного пакета 8.8M.

Он цепляется к сетевому интерфейсу tun и переводит трафик в прокси. Что только не сделаешь, чтобы обойти китайский firewall.

## Установка

Пакета tun2socks нет в репозиториях OpenWrt, поэтому его нужно скачивать с [гитхаба проекта](https://github.com/xjasonlyu/tun2socks/releases) . Благо он собирается под множество архитектур, в том числе MIPS и ARM.

Глянуть архитектуру процессора на вашем роутере

```shell
opkg print-architecture
```

Вывод Xioami mi3g v1 для примера:

```shell
arch all 1
arch noarch 1
arch mipsel_24kc 10
```

Это архитектура mipsle. На роутерах в большинстве случаев будет либо mips, либо mipsle.

Скачиваем архив с нужной архитектурой на компьютер, разархивируем и перекидываем на роутер в /tmp.

Пример для mipsle:

```shell
wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.5.1/tun2socks-linux-mipsle-softfloat.zip
unzip tun2socks-linux-mipsle-softfloat.zip
scp tun2socks-linux-mipsle-softfloat root@192.168.1.1:/tmp/
```

После этого заходим на роутер и проверяем, что точно скачали подходящий под вашу архитектуру бинарник

```shell
root@OpenWrt:~# /tmp/tun2socks-linux-mipsle-softfloat --help
Usage of ./tun2socks-linux-mipsle-softfloat:
  -config string
```

Help вывелся, значит, всё ок. Но если выводится такая ошибка

```shell
/tmp/tun2socks-linux-mips-softfloat: line 1: syntax error: unexpected "("
```

значит, архитектура выбрана неверно.

Перекидываем в `/usr/bin/` и заодно переименовываем

```shell
mv tun2socks-linux-mipsle-softfloat /usr/bin/tun2socks
```

Для работы tun интерфейса понадобится пакет kmod-tun

```shell
opkg update && opkg install kmod-tun
```

Настройка интерфейса и firewall

tun2socks не создаёт интерфейс сам, поэтому нужно самим создать интерфейс и присвоить ему ip. Добавляем в `/etc/config/network`

```ini
config interface 'tun0'
        option device 'tun0'
        option proto 'static'
        option ipaddr '172.16.250.1'
        option netmask '255.255.255.0'
```

Имейте в виду, что `ip a` покажет его только при запуске tun2socks.

Учтите, что если у вас настроен какой-нибудь VPN, то tun0 может быть занят. Можно поменять на tun1 тут и далее.

Создаём зону и правило в /etc/config/firewall

```ini
config zone
        option name 'tun'
        option forward 'REJECT'
        option output 'ACCEPT'
        option input 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option device 'tun0'
        option family 'ipv4'

config forwarding
        option name 'lan-tun'
        option dest 'tun'
        option src 'lan'
        option family 'ipv4'
```

Обратите внимание, что требуется указывать `device`, а не `network`.

Рестартуем сеть

```shell
service network restart
```

## Автозапуск

Накидал простой сценарий, кладём его в `/etc/init.d/tun2socks`

```shell
#!/bin/sh /etc/rc.common

USE_PROCD=1

# starts after network starts
START=40
# stops before networking stops
STOP=89

PROG=/usr/bin/tun2socks
IF="tun0"
PROTO="$PROTO"
METHOD_USER="$METHOD/USER"
PASS="$PASS"
HOST="$HOST"
PORT="$PORT"

start_service() {
        procd_open_instance
        procd_set_param command "$PROG" -device "$IF" -proxy "$PROTO"://"$METHOD_USER":"$PASS"@"$HOST":"$PORT"
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance
}
```

Надо подставить свои переменные, примеры:

Shadowsocks

```ini
METHOD_USER="aes-256-gcm"
PASS="ochslozniyparol"
HOST="domain.com"
PORT="8388"
```

Socks5 прокси без пароля

```ini
PROTO="socks5"
#METHOD_USER="aes-256-gcm"
#PASS="ochslozniyparol"
HOST="domain.com"
PORT="46202"
```

Socks5 прокси с логином и паролем

```
PROTO="socks5"
METHOD_USER="user"
PASS="ochslozniyparol"
HOST="domain.com
PORT="1080"
```

Переменную METHOD_USER назвал так, потому что для SS - это метод шифрования, а в socks5 - это логин.

Для HTTP и SOCKS4 логика та же.

Не советую использовать бесплатные публичные прокси. Перенаправлять даже часть своего трафика на такие прокси опасно.

Делаем исполняемым, помещаем в автозапуск и стартуем

```shell
chmod +x /etc/init.d/tun2socks
ln -s ../init.d/tun2socks /etc/rc.d/S40tun2socks
service tun2socks start
```

## Тестирование работоспособности и поиск ошибок

Глянуть логи приложения

```shell
logread -f -e tun2socks
```

Потестить без сценария инициализации можно так

```shell
tun2socks -device tun0 -proxy ss://aes-256-gcm:ochslozniyparol@domain.com:8388 -loglevel debug
```

При `-loglevel debug` выводится трафик, который ходит через tun2socks. Но показывается только TCP и UDP. loglevel можно и в сценарий закинуть.

Если будет кушать много памяти, то у проекта есть [целая страница](https://github.com/xjasonlyu/tun2socks/wiki/Memory-Optimization) с описанием флагов, которые можно подкрутить.

`ping -I` ничего не скажет о работоспособности. Пакеты будут “ходить” (по итогу до хоста они не доходят) даже если соединение не установлено.

Для проверки прокси лучше всего использовать curl и какой-нибудь сервис, определяющий IP-адрес.

Curl умеет направлять запрос через сетевой интерфейс.

```shell
curl --interface tun0 ifconfig.me
```

Curl должен отдать IP-адрес вашего прокси-сервера.

# Sing-box

В OpenWrt 23.05 [добавлен](https://github.com/openwrt/packages/pull/20069) пакет sing-box. Он умеет работать с tun интерфейсом. Поддерживает кучу протоколов:

- SOCKS5 proxy
- HTTP proxy
- Shadowsocks версии 2022-* и старые aes-*
- VMess и VLESS
- Trojan И [другие](https://sing-box.sagernet.org/configuration/outbound/#fields)

Объем распакованного пакета 21.5MB.

## Установка

Для OpenWrt 23.05 всё просто

```shell
opkg update && opkg install sing-box
```

Для версии 22.03 можно установить пакет вручную:

- Узнать архитектуру роутера `opkg print-architecture`
- Найти её в [https://downloads.openwrt.org/releases/23.05.0/packages/](https://downloads.openwrt.org/releases/23.05.0/packages/)
- Перейти в каталог packages, найти пакет sing-box
- Скачать в /tmp
- Установить `opkg install sing-box_1.3.0-1_mips_24kc.ipk`

На 21.02 установить не получится, пакет зависит от модуля ядра `kmod-netlink-diag`, которого в 21.02 нет.

```
 * pkg_hash_check_unresolved: cannot find dependency kmod-inet-diag for sing-box
```

## Настройка

Если до этого вы использовали интерфейс tun0 (например, OpenVPN использует tun), то остановите сначала другой туннель, либо используйте tun1 в конфигурации.

По дефолту сервис sing-box запускается от юзера sing-box. Но у этого юзера [нет прав](https://github.com/openwrt/packages/issues/21408) для управления `/dev/net/tun`. Поэтому запускать sing-box надо от root.

Без root получите такую ошибку

```
Fri Jun  9 06:43:41 2023 daemon.err sing-box[9272]: FATAL[0000] start service: initialize inbound/tun[0]: configure tun interface: permission denied
```

Настраивается это в `/etc/config/sing-box`. Там же сервис надо включить, проставив 1 параметру `enabled`. Этот параметр проверяется при старте сервиса в `../init.d/sing-box`, при 0 сервис не запускается.

По итогу должно выглядеть так:

```ini
config sing-box 'main'
	option enabled '1'
	option user 'root'
	option conffile '/etc/sing-box/config.json'
	option workdir '/usr/share/sing-box'
```

Сам файл конфигурации находится в `/etc/sing-box/config.json`. Нам от sing-box нужен tun интерфейс, который будет перенаправлять трафик, например, в shadowsocks:

```json
{
  "log": {
    "level": "debug"
  },
  "inbounds": [
    {
      "type": "tun",
      "interface_name": "tun0",
      "domain_strategy": "ipv4_only",
      "inet4_address": "172.16.250.1/30",
      "auto_route": false,
      "strict_route": false,
      "sniff": true 
   }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "server": "$HOST",
      "server_port": $PORT,
      "method": "2022-blake3-aes-128-gcm",
      "password": "$PASS"
    }
  ],
  "route": {
    "auto_detect_interface": true
  }
}
```

VLESS (xtls-rprx-vision, reality)

```json
{
    "log": {
      "level": "debug"
    },
    "inbounds": [
      {
        "type": "tun",
        "interface_name": "tun0",
        "domain_strategy": "ipv4_only",
        "inet4_address": "172.16.250.1/30",
        "auto_route": false,
        "strict_route": false,
        "sniff": true 
     }
    ],
      "outbounds": [
        {
          "type": "vless",
          "server": "$HOST",
          "server_port": $PORT,
          "uuid": "$UUID",
          "flow": "xtls-rprx-vision",
          "network": "tcp",
          "tls": {
            "enabled": true,
            "insecure": false,
            "server_name": "$FAKE_SERVER",
            "utls": {
              "enabled": true,
              "fingerprint": "chrome"
            },
            "reality": {
              "enabled": true,
              "public_key": "$PUBLIC_KEY",
              "short_id": "$SHORT_ID"
            }
          }
        }
      ],
    "route": {
      "auto_detect_interface": true
    }
  }
```

“Обычный” Shadowsocks, разница только в методе шифрования

```json
{
  "log": {
    "level": "debug"
  },
  "inbounds": [
    {
      "type": "tun",
      "interface_name": "tun0",
      "domain_strategy": "ipv4_only",
      "inet4_address": "172.16.250.1/30",
      "auto_route": false,
      "strict_route": false,
      "sniff": true 
   }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "server": "$HOST",
      "server_port": $PORT,
      "method": "aes-256-gcm",
      "password": "$PASS"
    }
  ],
  "route": {
    "auto_detect_interface": true
  }
}
```

**inbounds** - здесь это то, что поднято на роутере. Эта часть отвечает за “входящий” трафик. Вы можете поднять сервер с SS, например. Но в вашем случае роутер является клиентом. Нам нужно, чтобы роутер отправлял часть трафика в сетевой интерфейс. Поэтому здесь описываем интерфейс **tun**.

Важное про параметр `auto_route`, его включение перенаправляет весь трафик в tun. В данной конфигурации он работать не будет, плюс автор sing-box [рекоменудет](https://github.com/SagerNet/sing-box/issues/100) не использовать его на роутерах, а использовать для этого стандартные средства роутера. Он должен быть `false`. Как перенаправлять весь трафик через tun описано в конце статьи.

Sing-box также поддерживает TLS DNS, но работает это только с включенным auto_route. Если вам нужно шифровать DNS трафик, то используйте [dnscrypt-proxy2 или stubby](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/#%d0%bf%d1%80%d0%be%d0%b2%d0%b0%d0%b9%d0%b4%d0%b5%d1%80-%d0%bd%d0%b0%d1%80%d1%83%d1%88%d0%b0%d0%b5%d1%82-%d1%80%d0%b0%d0%b1%d0%be%d1%82%d1%83-dns) .

**outbounds** - это “исходящий” трафик. Здесь как раз настраивается клиент с нужным типом прокси или туннеля. В примере это shadowsocks2022. Описывается протокол, сервер, порт сервера, метод шифрования и пароль. В общем, всё стандартно, но можно ещё подкрутить [другими параметрами](https://sing-box.sagernet.org/configuration/outbound/shadowsocks/) . Настройка других протоколов описана в [Outbound разделе документации](https://sing-box.sagernet.org/configuration/outbound/) .

Чтобы трафик ходил, нужно настроить firewall. Настраиваем зону и forwading для неё в `/etc/config/firewall`

```ini
config zone
        option name 'tun'
        option forward 'ACCEPT'
        option output 'ACCEPT'
        option input 'ACCEPT'
        option masq '1'
        option mtu_fix '1'
        option device 'tun0'
        option family 'ipv4'

config forwarding
        option name 'lan-tun'
        option dest 'tun'
        option src 'lan'
        option family 'ipv4'
```

Здесь следует обратить внимание на то, что разрешён не только output трафик, как у всех других туннелей, но и весь остальной. Без полного разрешения туннель не заработает.

Осталось рестартануть firewall и запустить sing-box

```shell
service firewall restart
service sing-box start
```

При рестарте роутера туннель будет подниматься автоматически: при установке пакета автоматически проставляется симлинк в `/etc/rc.d/`.

## Тестирование работоспособности и поиск ошибок

Глянуть логи приложения

```shell
logread -f -e sing-box
```

После этого в соседнем терминале

```shell
service sing-box restart
```

Если есть какая-то грубая ошибка в конфигурации, то sing-box просто не запустится и интерфейс через `ip a` не будет видно. Ошибку будет видно в логе.

Проверить хождение трафика через интерфейс здесь можно точно так же, как для tun2socks.

`ping -I` ничего не скажет о работоспособности. Пакеты будут “ходить” (по итогу до хоста они не доходят) даже если соединение не установлено.

Для проверки прокси лучше всего использовать curl и какой-нибудь сервис, определяющий IP-адрес.

Curl умеет направлять запрос через сетевой интерфейс.

```shell
curl --interface tun0 ifconfig.me
```

Curl должен отдать IP-адрес вашего прокси-сервера.

# Применение на роутерах

После настройки туннеля его нужно как-то использовать. Приведу самые востребованные примеры.

1. [Точечный роутинг по доменам](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/) . Вся настройка описана там, есть скрипт для автоматической настройки. В маршруте нужно указать интерфейс `tun0`
    
2. Временный вариант. Весь трафик (и с роутера, и с клиентов роутера), который идёт к подсети `172.64.195.0/24`, будет идти через туннель. Может пригодиться для тестов туннеля, для проверки доступности ресурса через туннель или если провайдер что-то вытворяет
    

```shell
ip route add 172.64.195.0/24 via 172.16.250.1 dev tun0
```

3. Постоянный вариант. Если нужно:

- Направить **весь** трафик клиентов роутера в туннель
- Направить трафик в туннель только для одного клиента роутера (Вашей приставке или холодильнику надо прикинуться иностранцем)
- Направлять трафик в туннель только для определенного IP-адреса или подсети

Для этого нужно маркировать пакеты. Это можно реализовать вручную или через пакет pbr.

## Pbr

Пакет [pbr](https://docs.openwrt.melmac.net/pbr/) создаёт правила маркировки сам. У него даже есть интерфейс для LuCi.

```shell
opkg update && opkg install pbr luci-app-pbr
```

Я лично пакет не использовал, но видел неоднократное его упоминание. Поэтому на его счёт больше ничего сказать не могу.

## Ручная настройка

Ну а если вы хотите настроить всё вручную без лишних пакетов, всё точно так же как [раньше](https://itdog.info/tochechnaya-marshrutizaciya-na-routere-s-openwrt-wireguard-i-dnscrypt/) .

Если у вас уже настроена [маркировка пакетов](https://itdog.info/tochechnaya-marshrutizaciya-po-domenam-na-routere-s-openwrt/#%d0%bd%d0%b0%d1%81%d1%82%d1%80%d0%be%d0%b9%d0%ba%d0%b0-%d0%bc%d0%b0%d1%80%d1%88%d1%80%d1%83%d1%82%d0%b8%d0%b7%d0%b0%d1%86%d0%b8%d0%b8) , то пропустите эту часть и переходите к правилам firewall.

Добавляем новую таблицу в конец файла `/etc/iproute2/rt_tables`

```
99 vpn
```

Делаем маршрут в `/etc/config/network`. Все маркированные пакеты слать в таблицу VPN

```ini
config rule
        option priority '100'
        option lookup 'vpn'
        option mark '0x1'
```

Там же создаём маршрут: всё, что попадает в таблицу vpn, отправляется в интерфейс tun0.

Создаём файл `/etc/hotplug.d/iface/30-vpnroute` со скриптом внутри:

```shell
#!/bin/sh

sleep 5
ip route add table vpn default dev tun0
```

Требуется рестарт сети

```shell
service network restart
```

Теперь всё готово, чтобы создавать необходимые правила в firewall. Для этого нужно лишь проставлять этим правилам `set_mark '0x1'`.

Пару примеров:

1. Весь трафик с клиента роутера с IP-адресом 192.168.56.242 отправлять в туннель

```ini
config rule
	option name 'From IP through tun'
	option src 'lan'
	option dest '*'
	option proto 'all'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
        option src_ip '192.168.56.242'
```

2. Трафик от **всех** клиентов роутера отправляется в туннель

```ini
config rule
        option name 'All lan through tun'
        option src 'lan'
        option dest '*'
        option proto 'all'
        option set_mark '0x1'
        option target 'MARK'
        option family 'ipv4'
```

3. Всё, что идёт к IP-адресу 1.1.1.1, отправлять в туннель

```ini
config rule
        option name 'To IP through tun'
        option src 'lan'
        option dest '*'
        option proto 'all'
        option set_mark '0x1'
        option target 'MARK'
        option family 'ipv4'
        option dest_ip '1.1.1.1'
```

4. То же самое, но уже загоняем целую подсеть. Используется также `dest_ip`

```ini
config rule
        option name 'To subnet through tun'
        option src 'lan'
        option dest '*'
        option proto 'all'
        option set_mark '0x1'
        option target 'MARK'
        option family 'ipv4'
        option dest_ip '172.64.194.0/24'
```