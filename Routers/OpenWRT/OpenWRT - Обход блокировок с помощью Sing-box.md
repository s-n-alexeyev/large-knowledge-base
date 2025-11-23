
2023-08-22
[Оригинальная статья: Автор - Andrevich](https://habr.com/ru/articles/756178/)
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Обход блокировок на OpenWRT с помощью Sing-box (vless, vmess, trojan, ss2022) и баз GeoIP, Geosite

В данном гайде будем устанавливать пакет **sing-box** на OpenWRT на примере стабильной **22.03.5 и 23.05.0**. Рекомендуется роутер **минимум с 128 МБ RAM (256 предпочтительно) и памятью более 16 Мб, так же будет описан способ установки sing-box в оперативную память (подходит для устройств с малым количеством ПЗУ <16 Мб)**

[Sing-Box](https://sing-box.sagernet.org/) — это бесплатная прокси-платформа с открытым исходным кодом, которая позволяет пользователям обходить интернет-цензуру и получать доступ к заблокированным веб-сайтам. Это альтернатива v2ray-core и xray-core. Его можно использовать с различными клиентами таких платформах, как Windows, macOS, Linux, Android и iOS.

Помимо поддержки протоколов Shadowsocks (в т.ч. 2022), Trojan, Vless, Vmess и Socks, он также поддерживает ShadowTLS, Hysteria и NaiveProxy.

Руководство будет включать:

1. **Установку из репозитория**  
2. **Настройку sing-box для shadowsocks, vless, vmess, trojan и обход блокировок с помощью SagerNet GeoIP, Geosite**  
3. **Настройку обхода блокировок с помощью GeoIP, Geosite от L11R**  
4. **Установку sing-box в оперативную память и настройку автозапуска**
## 1. Установка sing-box

UPD 13.10.2023 **Репозиторий** [**lrdrdn/my-opkg-repo**](https://github.com/lrdrdn/my-opkg-repo) **переориентировался на версию 23.05.0, претерпел изменения, потеряв большую часть пакетов необходимых для установки на 22.03.5, включая sing-box, поэтому заменил репозиторий.**

Для версии OpenWRT **22.03.5** необходимо скачать и установить актуальную версию sing-box:

```shell
cd /tmp
wget https://downloads.openwrt.org/releases/23.05.0/packages/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')/packages/sing-box_1.6.0-1_$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}').ipk
opkg install sing-box_*.ipk
rm sing-box_*.ipk
```

_Начиная с версии_ **_23.05.0_** _sing-box есть в стандартном репозитории OpenWRT._

Обновляем список пакетов:

```shell
opkg update
```

Далее устанавливаем необходимые для работы **sing-box** модули ядра и пакет совместимости с **iptables**:

```shell
opkg install kmod-inet-diag kmod-netlink-diag kmod-tun iptables-nft
```

Ждём завершения установки, пакеты заняли около 1Мб памяти.

Далее переходим к установке **sing-box**

```shell
opkg install sing-box
```

Пакет занимает около 10Мб, поэтому установить его на устройства с 16 Мб ПЗУ не удастся без дополнительных манипуляций (об этом в **п.3** этой статьи).

Если пакет успешно установлен, переходим к настройке соединения, если нет - переходим к **п.3**.

## 2. Настройка sing-box для shadowsocks, reality, vmess, trojan и обход блокировок с помощью SagerNet GeoIP, Geosite

UPD 12.11.2023 ~~Далее переходим к файлу конфигурации, по умолчанию это~~ **~~/etc/sing-box/config.json~~**~~, но при установке доступен~~ **~~/etc/sing-box/config.json.example~~** В версии 1.6.0 доступен **/etc/sing-box/config.json** по умолчанию, файла **/etc/sing-box/config.json.example** при установке больше нету

Удаляем дефолтный **/etc/sing-box/config.json**:

```shell
> /etc/sing-box/config.json
```

Я приведу пример файла **config.json** для настройки как Outline VPN (выпуск ключей и их расшифровку на пароль и тип шифрования из формата base64 я рассматривал [**здесь**](https://habr.com/ru/articles/748408/)) так и XTLS-Reality, VMess TLS и Trojan Websocket. В конфигурации используется selector выбирающий только рабочие прокси с помощью urltest. На [сайте проекта sing-box](https://sing-box.sagernet.org/), [Github юзера malikshi](https://github.com/malikshi/sing-box-examples) и [vpnrouter.homes](https://vpnrouter.homes/singbox/) доступны многочисленные примеры конфигураций для различных протоколов.

Пример **config.json**:

```json
{
    "log": {
        "disabled": false,
        "level": "warn",
        "output": "/tmp/sing-box.log",
        "timestamp": true
    },
    "dns": {
        "servers": [
            {
                "tag": "google",
                "address": "tls://8.8.8.8"
            },
            {
                "tag": "block",
                "address": "rcode://success"
            }
        ],
        "final": "google",
        "strategy": "prefer_ipv4",
        "disable_cache": false,
        "disable_expire": false
    },
    "inbounds": [
        {
            "type": "mixed",
            "tag": "mixed-in",
            "listen": "127.0.0.1",
            "listen_port": 1080,
            "tcp_fast_open": false,
            "sniff": true,
            "sniff_override_destination": true,
            "set_system_proxy": false
        },
        {
            "type": "tun",
            "tag": "tun-in",
            "interface_name": "singtun0",
            "inet4_address": "172.19.16.1/30",
            "stack": "gvisor",
            "mtu": 9000,
            "auto_route": true,
            "strict_route": false,
            "endpoint_independent_nat": false,
            "sniff": true,
            "sniff_override_destination": true
        }
    ],
    "outbounds": [
        {
            "type": "selector",
            "tag": "Proxy-out",
            "outbounds": [
                "URL-Test",
                "direct",
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "default": "URL-Test"
        },
        {
            "type": "urltest",
            "tag": "URL-Test",
            "outbounds": [
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "url": "http://www.gstatic.com/generate_204",
            "interval": "1m",
            "tolerance": 50
        },
        {
            "type": "shadowsocks",
            "tag": "shadowsocks-out",
            "server": "IP",
            "server_port": 15000,
            "method": "chacha20-ietf-poly1305",
            "password": "password"
        },
        {
            "type": "vless",
            "tag": "reality-out",
            "server": "IP",
            "server_port": 8442,
            "uuid": "UUID",
            "flow": "xtls-rprx-vision",
            "network": "tcp",
            "tls": {
                "enabled": true,
                "insecure": false,
                "server_name": "SERVERNAME",
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                },
                "reality": {
                    "enabled": true,
                    "public_key": "AP24JYROAB8odK5glVW_KLnsWl3UZ-voaGq_9ihQgTL"
                }
            }
        },
        {
            "type": "trojan",
            "tag": "trojan-WebSocket-out",
            "server": "IP",
            "server_port": 8443,
            "password": "PASSWORD",
            "transport": {
                "type": "ws",
                "path": "/",
                "early_data_header_name": "Sec-WebSocket-Protocol"
            },
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "d43f429a97e4ea6d.gstatic.com"
            },
            "multiplex": {
                "enabled": true,
                "max_connections": 4,
                "min_streams": 4,
                "max_streams": 0
            }
        },
        {
            "type": "vmess",
            "tag": "vmess-tls-out",
            "server": "IP",
            "server_port": 8444,
            "uuid": "UUID",
            "security": "auto",
            "alter_id": 0,
            "global_padding": false,
            "authenticated_length": true,
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "google.com",
                "insecure": false,
                "alpn": [
                    "http/1.1"
                ]
            },
            "multiplex": {
                "enabled": true,
                "protocol": "smux",
                "max_connections": 5,
                "min_streams": 4,
                "max_streams": 0
            },
            "connect_timeout": "5s"
        },
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        },
        {
            "type": "dns",
            "tag": "dns-out"
        }
    ],
    "route": {
        "geoip": {
            "path": "/tmp/geoip.db",
            "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
            "download_detour": "Proxy-out"
        },
        "geosite": {
            "path": "/tmp/geosite.db",
            "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
            "download_detour": "Proxy-out"
        },
        "rules": [
            {
                "protocol": "dns",
                "outbound": "dns-out"
            },
            {
                "protocol": [
                    "quic"
                ],
                "outbound": "block"
            },
            {
                "geosite": [
                    "private",
                    "youtube",
                    "google",
					"yandex"
                ],
                "geoip": [
                    "private",
                    "ru"
                ],
                "ip_cidr": [
                    "94.100.180.201/32",
                    "94.100.180.202/32"
                ],
                "domain_keyword": [
                    "mail.ru",
                    "vk.com"
                ],
				"domain_suffix": [
                    ".ru"
                  ],
                "outbound": "direct"
            }
        ],
        "final": "Proxy-out",
        "auto_detect_interface": true
    }
}
```

Конфигурация пишет в лог /tmp/sing-box.log предупреждения и ошибки, поднимает socks5 proxy на порту **1080**, поднимает туннель **singtun0** с помощью kmod-tun и gvisor.

Раздел outbounds содержит конфигурации для XTLS-Reality, VMess TLS и Trojan Websocket:

```json
{
  "type": "shadowsocks",
  "tag": "shadowsocks-out",
....
},
{
  "type": "vless",
  "tag": "reality-out",
....
},
{
"type": "trojan", 
"tag": "trojan-WebSocket-out",
....
},
{
  "type": "vmess",
  "tag": "vmess-tls-out",
.....
},
```

При необходимости замените или удалите лишние записи, не забыв убрать или добавить их в разделах selector и urltest

```json
            "type": "selector",
            "tag": "Proxy-out",
            "outbounds": [
                "URL-Test",
                "direct",
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "default": "URL-Test"
        },
        {
            "type": "urltest",
            "tag": "URL-Test",
            "outbounds": [
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
```

В разделе "**route**" "**rules**" прописаны правила для **прямого подключения к сайтам в зоне .ru и другим незаблокированным ресурсам**:

"geosite": "private", "youtube", "google", "yandex" - обозначает домены: частных адресов (включая .local), YouTube и поддомены, сервисы Google, сервисы Яндекса.

"geoip": "private", "ru" - обозначает диапазоны IP адресов: частные адреса, диапазоны IP адресов сегмента .RU

"ip_cidr" - в этом разделе можно указать диапазоны IP адресов которые должны подключаться напрямую минуя прокси

"domain_suffix"  
Правило соответствует, если домен запроса соответствует суффиксу. Например: «[google.com](http://google.com)» соответствует «[www.google.com](http://www.google.com)», «[mail.google.com](http://mail.google.com)» и «[google.com](http://google.com)», но не соответствует «[content-google.com](http://content-google.com)».

"domain_keyword"  
Правило соответствует, если домен запроса содержит ключевое слово.

_При редактировании json файлов можно пользоваться инструментами вроде_ [_JSON Online Validator_](https://jsonlint.com/) _для проверки форматирования_

В раздел **outbounds** нужно ввести параметры вашего (ваших) прокси: **IP, порт, пароль, uuid, public key** (если применимо).

параметр **download_detour** используется для указания способа скачивания баз, в случае конфигурации - через прокси

**Для работы используются списки SagerNet от разработчика sing-box, они не содержат списков заблокированных в РФ ресурсов и поэтому многие незаблокированные сайты могут открываться через прокси.**

Для работы sing-box необходимо прописать настройки файрволла, для этого:

В файл **/etc/config/network** добавим:

```q
config interface 'proxy'
	option proto 'none'
	option device 'singtun0'
```

В файл **/etc/config/firewall** :

```q
config zone
    option name 'proxy'
    list network 'tunnel'
    option forward 'REJECT'
    option output 'ACCEPT'
    option input 'REJECT'
    option masq '1'
    option mtu_fix '1'
    option device 'singtun0'
    option family 'ipv4'

config forwarding
    option name 'lan-proxy'
    option dest 'proxy'
    option src 'lan'
    option family 'ipv4'
```

После чего перезагружаем сеть:

```shell
/etc/init.d/network restart
```

Далее проверяем работоспособность конфигурации:

```shell
sing-box check -c /etc/sing-box/config.json
```

Если всё правильно команда не выдаст ошибок.

Далее проверяем работу прокси:

```shell
sing-box run -c /etc/sing-box/config.json
```

Работоспособность можно проверить открыв нужный вам сайт.

Если всё сработало, можем добавить **sing-box** в автозапуск, для этого вводим команды:

Добавим sing-box в автозапуск:

```shell
/etc/init.d/sing-box enable
/etc/init.d/sing-box start
```

На этом настройка **sing-box** завершена.

В случае настройки sing-box на маршрутизацию с помощью firewall4, то есть классическими маршрутами к singtun0, конфигурация **/etc/sing-box/config.json** будет упрощена и выглядеть так:

```json
{
    "log": {
        "disabled": false,
        "level": "warn",
        "output": "/tmp/sing-box.log",
        "timestamp": true
    },
    "dns": {
        "servers": []
    },
    "inbounds": [
        {
            "type": "tun",
            "tag": "tun-in",
            "interface_name": "singtun0",
            "inet4_address": "172.19.16.1/30",
            "stack": "gvisor",
            "mtu": 9000,
            "auto_route": false,
            "strict_route": false,
            "endpoint_independent_nat": false,
            "sniff": true,
            "sniff_override_destination": true
        }
    ],
    "outbounds": [
        {
            "type": "selector",
            "tag": "Proxy-out",
            "outbounds": [
                "URL-Test",
                "direct",
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "default": "URL-Test"
        },
        {
            "type": "urltest",
            "tag": "URL-Test",
            "outbounds": [
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "url": "http://www.gstatic.com/generate_204",
            "interval": "1m",
            "tolerance": 50
        },
        {
            "type": "shadowsocks",
            "tag": "shadowsocks-out",
            "server": "IP",
            "server_port": 15000,
            "method": "chacha20-ietf-poly1305",
            "password": "password"
        },
        {
            "type": "vless",
            "tag": "reality-out",
            "server": "IP",
            "server_port": 8442,
            "uuid": "UUID",
            "flow": "xtls-rprx-vision",
            "network": "tcp",
            "tls": {
                "enabled": true,
                "insecure": false,
                "server_name": "SERVERNAME",
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                },
                "reality": {
                    "enabled": true,
                    "public_key": "AP24JYROAB8odK5glVW_KLnsWl3UZ-voaGq_9ihQgTL"
                }
            }
        },
        {
            "type": "trojan",
            "tag": "trojan-WebSocket-out",
            "server": "IP",
            "server_port": 8443,
            "password": "PASSWORD",
            "transport": {
                "type": "ws",
                "path": "/",
                "early_data_header_name": "Sec-WebSocket-Protocol"
            },
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "d43f429a97e4ea6d.gstatic.com"
            },
            "multiplex": {
                "enabled": true,
                "max_connections": 4,
                "min_streams": 4,
                "max_streams": 0
            }
        },
        {
            "type": "vmess",
            "tag": "vmess-tls-out",
            "server": "IP",
            "server_port": 8444,
            "uuid": "UUID",
            "security": "auto",
            "alter_id": 0,
            "global_padding": false,
            "authenticated_length": true,
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "google.com",
                "insecure": false,
                "alpn": [
                    "http/1.1"
                ]
            },
            "multiplex": {
                "enabled": true,
                "protocol": "smux",
                "max_connections": 5,
                "min_streams": 4,
                "max_streams": 0
            },
            "connect_timeout": "5s"
        },
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        }
    ],
    "route": {
        "rules": [],
        "final": "Proxy-out",
        "auto_detect_interface": true
    }
}
```

Для настройки самих маршрутов или BGP рекомендую статьи:  
[Точечный обход блокировок на роутере OpenWrt c помощью BGP / Хабр (habr.com)](https://habr.com/ru/articles/743572/) С помощью BGP (bird2).  
[Точечный обход блокировок PKH на роутере с OpenWrt с помощью WireGuard и DNSCrypt / Хабр (habr.com)](https://habr.com/ru/articles/440030/) (путём скачивания списков и настройкой маршрутов в iptables, nftables).
## 3. Настройка обхода блокировок с помощью GeoIP, Geosite от L11R

Данный способ с GeoIP и Geosite содержащие весь дамп базы РКН (автор данных файлов [@L11R](https://habr.com/users/l11r), огромная ему за это благодарность). К сожалению данный способ требователен к количеству ОЗУ, у меня запустилось минимум с 384 МБ, иначе срабатывал memory killer. Удобство способа в том, что является заменой BGP (или скачивания списков), трафик на адреса из баз идёт через прокси, всё остальное напрямую.

Пример такого **config.json**:

```json
{
    "log": {
        "disabled": false,
        "level": "warn",
        "output": "/tmp/sing-box.log",
        "timestamp": true
    },
    "dns": {
        "servers": [
            {
                "tag": "google",
                "address": "tls://8.8.8.8"
            },
            {
                "tag": "block",
                "address": "rcode://success"
            }
        ],
        "final": "google",
        "strategy": "prefer_ipv4",
        "disable_cache": false,
        "disable_expire": false
    },
    "inbounds": [
        {
            "type": "mixed",
            "tag": "mixed-in",
            "listen": "127.0.0.1",
            "listen_port": 1080,
            "tcp_fast_open": false,
            "sniff": true,
            "sniff_override_destination": true,
            "set_system_proxy": false
        },
        {
            "type": "tun",
            "tag": "tun-in",
            "interface_name": "singtun0",
            "inet4_address": "172.19.16.1/30",
            "stack": "gvisor",
            "mtu": 9000,
            "auto_route": true,
            "strict_route": false,
            "endpoint_independent_nat": false,
            "sniff": true,
            "sniff_override_destination": true
        }
    ],
    "outbounds": [
        {
            "type": "selector",
            "tag": "Proxy-out",
            "outbounds": [
                "URL-Test",
                "direct",
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "default": "URL-Test"
        },
        {
            "type": "urltest",
            "tag": "URL-Test",
            "outbounds": [
                "shadowsocks-out",
                "vmess-tls-out",
                "trojan-WebSocket-out",
                "reality-out"
            ],
            "url": "http://www.gstatic.com/generate_204",
            "interval": "1m",
            "tolerance": 50
        },
        {
            "type": "shadowsocks",
            "tag": "shadowsocks-out",
            "server": "IP",
            "server_port": 15000,
            "method": "chacha20-ietf-poly1305",
            "password": "password"
        },
        {
            "type": "vless",
            "tag": "reality-out",
            "server": "IP",
            "server_port": 8442,
            "uuid": "UUID",
            "flow": "xtls-rprx-vision",
            "network": "tcp",
            "tls": {
                "enabled": true,
                "insecure": false,
                "server_name": "SERVERNAME",
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                },
                "reality": {
                    "enabled": true,
                    "public_key": "AP24JYROAB8odK5glVW_KLnsWl3UZ-voaGq_9ihQgTL"
                }
            }
        },
        {
            "type": "trojan",
            "tag": "trojan-WebSocket-out",
            "server": "IP",
            "server_port": 8443,
            "password": "PASSWORD",
            "transport": {
                "type": "ws",
                "path": "/",
                "early_data_header_name": "Sec-WebSocket-Protocol"
            },
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "d43f429a97e4ea6d.gstatic.com"
            },
            "multiplex": {
                "enabled": true,
                "max_connections": 4,
                "min_streams": 4,
                "max_streams": 0
            }
        },
        {
            "type": "vmess",
            "tag": "vmess-tls-out",
            "server": "IP",
            "server_port": 8444,
            "uuid": "UUID",
            "security": "auto",
            "alter_id": 0,
            "global_padding": false,
            "authenticated_length": true,
            "tls": {
                "enabled": true,
                "disable_sni": false,
                "server_name": "google.com",
                "insecure": false,
                "alpn": [
                    "http/1.1"
                ]
            },
            "multiplex": {
                "enabled": true,
                "protocol": "smux",
                "max_connections": 5,
                "min_streams": 4,
                "max_streams": 0
            },
            "connect_timeout": "5s"
        },
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        },
        {
            "type": "dns",
            "tag": "dns-out"
        }
    ],
     "route": {
        "geoip": {
            "path": "/etc/sing-box/geoip.db",
            "download_url": "https://github.com/L11R/antizapret-sing-geosite/releases/latest/download/geoip.db",
            "download_detour": "Proxy-out"
        },
        "geosite": {
            "path": "/etc/sing-box/geosite.db",
            "download_url": "https://github.com/L11R/antizapret-sing-geosite/releases/latest/download/geosite.db",
            "download_detour": "Proxy-out"
        },
        "rules": [
            {
                "protocol": "dns",
                "outbound": "dns-out"
            },
            {
                "geoip": "antizapret",
                "geosite": "antizapret",
                "outbound": "Proxy-out"
            },
			{
                "protocol": "quic",
                "outbound": "block"
            }
        ],
        "final": "direct",
        "auto_detect_interface": true
    }
}
```

Если из конфигурации убрать строки:

```json
        {
            "type": "mixed",
            "tag": "mixed-in",
            "listen": "127.0.0.1",
            "listen_port": 1080,
            "tcp_fast_open": false,
            "sniff": true,
            "sniff_override_destination": true,
            "set_system_proxy": false
        },
```

и *"path": "/etc/sing-box/geoip.db" , "path": "/etc/sing-box/geosite.db",*

То конфигурацию можно использовать и в клиенте sing-box на Android и других платформах

## 4. Установка sing-box в оперативную память

Если установить sing-box в ПЗУ не удалось (а это вполне вероятный сценарий для большинства роутеров среднего ценового сегмента), возможно произвести установку в ОЗУ и подгружать пакет при запуске устройства.

_Установленный и запущенный sing-box занимает около_ **_35 Мб ОЗУ_**.

Для начала нам необходимо установить в ПЗУ **модули ядра** и **iptables-nft**

```shell
opkg install kmod-inet-diag kmod-netlink-diag kmod-tun iptables-nft
```

Это должно занять около 1Мб памяти, после чего установим **sing-box** в ОЗУ:

```shell
opkg install sing-box -d ram
```

Если всё успешно установилось, далее нужно будет создать папку конфигурации:

```shell
mkdir /etc/sing-box
```

После чего помещаете ваш файл **config.json** из **п.2** в **/etc/sing-box/config.json**

Проверяем работу прокси (более подробно в **п.2**):

```shell
 /tmp/usr/bin/sing-box run -c /etc/sing-box/config.json
```

Если всё заработало, далее настраиваем автозапуск **sing-box**.

Для автоматической установки пакета при загрузке системы в файл **/etc/rc.local** добавляем строки перед exit 0

```shell
opkg update
opkg install sing-box -d ram
exit 0
```

при помощи текстового редактора, либо через Luci

![|800](../..../../Media/Pictures/OpenWRT_Sing-box/image_1.png)

Сохраняем изменения и создаём службу автозапуска для **sing-box**.

Создаём файл **/etc/init.d/sing-box** следующего содержания:

```shell
#!/bin/sh /etc/rc.common
#
# Copyright (C) 2022 by nekohasekai <contact-sagernet@sekai.icu>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

START=99
USE_PROCD=1

#####  ONLY CHANGE THIS BLOCK  ######
PROG=/tmp/usr/bin/sing-box # Положение sing-box в ОЗУ
RES_DIR=/etc/sing-box/ # resource dir / working dir / the dir where you store ip/domain lists
CONF=./config.json   # where is the config file, it can be a relative path to $RES_DIR
#####  ONLY CHANGE THIS BLOCK  ######

start_service() {
  sleep 10 # Ожидание скачивания пакета sing-box при загрузке системы
  procd_open_instance
  procd_set_param command $PROG run -D $RES_DIR -c $CONF

  procd_set_param user root
  procd_set_param limits core="unlimited"
  procd_set_param limits nofile="1000000 1000000"
  procd_set_param stdout 1
  procd_set_param stderr 1
  procd_set_param respawn "${respawn_threshold:-3600}" "${respawn_timeout:-5}" "${respawn_retry:-5}"
  procd_close_instance
  iptables -I FORWARD -o singtun+ -j ACCEPT #Эта строка будет выдавать ошибку, если iptables-nft не установлен
  echo "sing-box is started!"
}

stop_service() {
  service_stop $PROG
  iptables -D FORWARD -o singtun+ -j ACCEPT
  echo "sing-box is stopped!"
}

reload_service() {
  stop
  sleep 5s
  echo "sing-box is restarted!"
  start
}
```

Делаем файл исполняемым:

```shell
chmod +x /etc/init.d/sing-box
```

После чего добавляем в автозапуск:

```shell
/etc/init.d/sing-box enable
/etc/init.d/sing-box start
```

На этом настройка окончена.

