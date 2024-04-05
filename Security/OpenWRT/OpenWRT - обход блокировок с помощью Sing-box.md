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

```sh
cd /tmp
wget https://downloads.openwrt.org/releases/23.05.0/packages/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')/packages/sing-box_1.6.0-1_$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}').ipk
opkg install sing-box_*.ipk
rm sing-box_*.ipk
```

_Начиная с версии_ **_23.05.0_** _sing-box есть в стандартном репозитории OpenWRT._

Обновляем список пакетов:

```sh
opkg update
```

Далее устанавливаем необходимые для работы **sing-box** модули ядра и пакет совместимости с **iptables**:

```sh
opkg install kmod-inet-diag kmod-netlink-diag kmod-tun iptables-nft
```

Ждём завершения установки, пакеты заняли около 1Мб памяти.

Далее переходим к установке **sing-box**

```sh
opkg install sing-box
```

Пакет занимает около 10Мб, поэтому установить его на устройства с 16 Мб ПЗУ не удастся без дополнительных манипуляций (об этом в **п.3** этой статьи).

Если пакет успешно установлен, переходим к настройке соединения, если нет - переходим к **п.3**.

## 2. Настройка sing-box для shadowsocks, reality, vmess, trojan и обход блокировок с помощью SagerNet GeoIP, Geosite

UPD 12.11.2023 ~~Далее переходим к файлу конфигурации, по умолчанию это~~ **~~/etc/sing-box/config.json~~**~~, но при установке доступен~~ **~~/etc/sing-box/config.json.example~~** В версии 1.6.0 доступен **/etc/sing-box/config.json** по умолчанию, файла **/etc/sing-box/config.json.example** при установке больше нету

Удаляем дефолтный **/etc/sing-box/config.json**:

```sh
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

```
config interface 'proxy'
	option proto 'none'
	option device 'singtun0'
```

В файл **/etc/config/firewall** :

```
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

```sh
/etc/init.d/network restart
```

Далее проверяем работоспособность конфигурации:

```sh
sing-box check -c /etc/sing-box/config.json
```

Если всё правильно команда не выдаст ошибок.

Далее проверяем работу прокси:

```sh
sing-box run -c /etc/sing-box/config.json
```

Работоспособность можно проверить открыв нужный вам сайт.

Если всё сработало, можем добавить **sing-box** в автозапуск, для этого вводим команды:

Добавим sing-box в автозапуск:

```sh
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

```sh
opkg install kmod-inet-diag kmod-netlink-diag kmod-tun iptables-nft
```

Это должно занять около 1Мб памяти, после чего установим **sing-box** в ОЗУ:

```sh
opkg install sing-box -d ram
```

Если всё успешно установилось, далее нужно будет создать папку конфигурации:

```sh
mkdir /etc/sing-box
```

После чего помещаете ваш файл **config.json** из **п.2** в **/etc/sing-box/config.json**

Проверяем работу прокси (более подробно в **п.2**):

```sh
 /tmp/usr/bin/sing-box run -c /etc/sing-box/config.json
```

Если всё заработало, далее настраиваем автозапуск **sing-box**.

Для автоматической установки пакета при загрузке системы в файл **/etc/rc.local** добавляем строки перед exit 0

```sh
opkg update
opkg install sing-box -d ram
exit 0
```

при помощи текстового редактора, либо через Luci

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA8sAAAIkCAYAAAAplLlMAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAJACSURBVHhe7d0FuBVV24fxha1YiI0tomJgd3d3KxZ26+tnd7e+KjZ2N3Z3iy02qK+iqNgCNt+5H/c6DuNpOIHcv+ua6+yYvffM7Djzn2etNe3mn3/+YUmSJEmSJFUbo/JXkiRJkiRVtJtvvvmsLEuSJEmSVGBlWZIkSZKkknbdunWzsixJkiRJUoGVZUmSJEmSStrNO++8VpYlSZIkSSposbA8xhhjpKrXqlyr3wcffJB++umnyrWRY4IJJkjjjTde+uabbyq3pDTWWGOlueeeu3Ltb3/++Wf6/fff048//pi++uqr9PPPP1fuaV0dOnRI0003XRpzzDHT66+/HstZE7b31FNPnSaddNJYR9bl22+/TQMHDkzDhjXuLW/oa04++eRpsskmS+OOO27M88svv6Qvv/wy/fDDD5U5/sZzMj/ztmvXLublfRk0aFBlDkmSJElqPS0Wlscff/z03HPPVa7Vb/fdd09PPfVU5drIsdJKK6XZZpstnX/++ZVbUpp22mnTvffeW7n2t99++y3C5XvvvZfuvvvu9Mgjj7RqYCb8Tj/99Gn11VdP22yzTQT/JZZYIg0ePLgyx9+Yd5555klbbrllWmCBBSIwf/311+nFF19MV111VXr33Xcrc9atMa/ZuXPntN5666WllloqTTXVVOnXX3+NYH7fffelu+66Kw44ZDPMMENaa6210nLLLZemmWaaeJ0vvvgiPh+9e/du8PJJkiRJUnNpVxWqWiQsU93cb7/9Ktf+Mssss0T4IpC+8MILlVv/csMNN6SPP/64cm3kOP3009NMM82UNtxww8otf4VlAh0VzTvuuKNya0oTTjhhmmOOOaIaTtVz//33T48//njl3pbXrVu3tMsuu8T2IrRz8GHxxRevMbjOPPPM6Zxzzolq8D333JM++uijqJ4TTl9++eW08847xzrVp6GvOckkk6SzzjorLbjggumtt95KzzzzTMy75pprRlC/9tpr00knnRTzUkk+44wz0tJLL52efPLJ9Oijj6Y//vgjXmPVVVdNffv2TTvuuONIb1UgSZIkSY3RYmG5Juuuu2469thj04033piOO+64yq1/I2hNMcUUEbxyU12qvVQhi7ifaiaVz7HHHjuaHBPomG/o0KFx/+yzzx6vxX1HH310NK/u169fdVgmpG2++eaVZ/zbnnvuGeHtwQcfTP/5z38qt/6FJsc0JaZpd23LR8W1ffv2US0tVqZZVqrcLEf//v0rt9bu+uuvj3U85JBDIsDOP//8tYZltuU666yTDjzwwOGq5kceeWRafvnlo0rckAMRDX3N/D4+9NBDwx0QoRk4lWIQ1Hkv5pprrnTdddelN954IyrfRT179owQvffee0eIliRJkqTWMuaUU055VOVyiyPArrDCCunNN99MTzzxROXWv1QtV9poo43SDjvskLbeeuto4kv1kWa7n332WTQrBpVKKpLMR/jaZJNNork1oYzwSlWVwHrNNddE+Cbgrr/++mnWWWeNIDfRRBOl7t27RzPhm2++OZ6ziL63hEEC8J133lm5NcVyEK579OiRttpqq1i+JZdcMsL3gAEDqpePKipBkzD+4Ycfxm30GWaZzz333Kh0F5+3Nsx38MEHRxWe5ef1L7nkkmjuXERFnFBMn+8TTzwxbqOZM6/52GOPpcsvvzx99913cXt9GvqaVOA5IHH22WdXrzeoDhN+acp96623Rt/lOeecM62xxhrxfpcr9bQ0oDpNKwMq1K2Jz8mMM84YgZ/PIp8d1jtX5DnYQR9uDr7Uh8fSrL+2vt6jivq2SVP8W7ZNEQfP6AYBDoYVccCJfvz1rW9jPl9NwUFFWs18/vnnlVvaDg6QdurUabjfktbE+8D/ibYyboUkSWo5bfLUUTTZ3mmnndIee+wRwe60006LaimBkybURxxxROy8gFBMOGQnnool81ERJXgxH3+polKtpLkvQZvLBLuyccYZp3oi/FE1Jrzhtddei7/gfirOBHR2hk855ZRoZkwY3mCDDYZbvsMOOyzCAOtC2ABhgwA9ZMiQmLch2AYN2XlkB5jA/PTTT8fr0PyaajA76TTPZts2VENf8/bbb4/3i1BdRGhgOxIMckAnxBPcWRaq1hzsYHt27NgxbsM777wTf1sL248KPAcIOCDCQRgOhiyzzDIRMsB25YBLQ3DAIH8eRlUN2SZN8W/YNmUcMNt+++3joBDfgYyDVtxOS5P6NObz1Vh8/xhgj2VhmdqaRRddNA6UthUcJFxooYUq1yRJ0uhkzCmmmKJVK8srrrhihOBilZFKJSGSAb4Y6IsqI82YaeZL4OQxVIzffvvt2KlaZJFF0jHHHBMhmdv69OkTVVT63BLOCF8EWfrqUtUh2DL4FNhRp7JM6KXfMoGNiQoor7PZZpvFax111FHVFVUCeq64UlWmMs46MBAY60Q4pWk1r0s1lecmZPB4QjfNupdddtlousygW42Vq7wXX3zxP6q8NHdmkC0qt1Tt99lnnzjAwIBabFcq5J9++mmjR8Su6zVrQihfeeWV06abbhrLQqAG24OqJPcRGghaDPjFdSr4DKR25ZVXxrytZb755kurrLJKuuiii9Jtt92WHn744agqsQ2effbZ+MxwPwcCOAiQ14kDNlTF+IxyIISDJFTnWS9G+uZzwDoTpvKI7IQVXi9XG6mo0dc8jyyen6e11bdNaD3AuhSb6PM9oek9lTm+U2wjtg/vOduivG14vly9Zv0JdDwf1VUeQ4BkW7D9+CyyvQjxXObAEPe1heofy832Yh1YN75voKsGg+Wx7ajG8x3JlXrm5Trbge1U/HzxeWA7sH5sY37XOPCXtzW/VWxnvtPF5+NAFM/H7XzH2FZsOwI8247fILppcD/z81iWt76qd3PjN5QDaeXWRlleVv7yeeE9z79JXOezxn18Znge1o/tw/Xatg+fLb5r+XnYThNPPHFsCw7o0GWG/w/5eytJkkYPrdoMm/CWw3Jxx4iARQC+//77Y8eOHZw8sfNCGGTHhvDMc9D8mcBC1ZgdInZ+aFbNTn1u+gyquex8MnhYlsMyO1nsoOaJKloO2wREno/XBMtHpaFXr17p1VdfjdsydmAJpuzAsXwgTLM+POcnn3wSVWZGfqZym+VTKbGDlid2qNkpLsvBlSbR5SDFjt3CCy8c9zPwFvMQ4nkuwjPLQX/g77//fqS9Zhk7+bwOVXWea6+99oqd0uz999+P7U5lkuboTFS+OcBB0/TW3iHNO+v0q+azRFijaT2Do9EnfbHFFouJ4If//e9/8Z6z7Wl+y+NZb1o0cDCHzy073wRidrp5H6j8g+a2BxxwQAx2xs47LROorBE0mZem7HyuW1t924TuCHye+C6D95fWFxw0Yj14j9k2hBJaEXCgiaBc3DZ8h/nusR1Zf7pPEDDZjjw3B37YHhyMYuLzynvAZ41tRtgst25oDSwrn2fGQuDgFQf7+O0oh2W2BweJGLGewMu68F7zu1P8fK222moR1GgyzfeV7QAODLLO/J7wGWQ7sv14vq5du8Z1frf4rnPQj0o1vw0csGGb5rDMe0XXFbY7B+/q+343t/xZ4ztRRuDns8T/AD4jXbp0id98DmhyUIZqPt8vnoN5mY/PKvezXWvbPgzgyG9zHm+C7yGfPz7bfE55T/n9a8wZHSRJ0qivTTbDZgcaNO0lPBWngw46KO5jRxmMYM1OO9XTU089NXYc11577WiOnHc2G4IdpX333bd64nUY4ZkmwjSz3nbbbaubVFJFA6GvLA/WxY5Y0aGHHho7tlTACVI0HS9iQC5CU3EiZDQWO4xgx5ymsrfcckvstBNc6bfNTijBFyPrNYt4XzgAcvzxx8dOLO9hMeyxY04zeHZAOaXU//3f/8X2Ztlo0nv44YdH5ac1cS5p1oMdb0IZTfHZ+SZE8N5xEISdaqrgHJBhm7IjTv90WkTweHbYcemll8ZfKrIEy7pQaeWzf95550V3Aj7b+bNWRODZbbfdapy4rznUt00I/wQQDpSAIEiopnUFB7M4YMTBIVpTMD/ho7xteAwh8cILL4z1Z1A9wiUHfXgMn21CJ10obrrpppiXEMl1+v0TmGvSGtuL7x8HfwhqfB/47hexLowWTwsXtgm/MXzuCazlzxe/M4RCsI35rcq/kXz2+E5xUJDnIwTzG3PCCSfE7RygA8tBxZXP1o033hi3geDMa3IQg9/XfEAwa41tVxe+Z4RdBgNku9FihQDMQQRaZRCO+Vzx+WE7sX34HLL969o+tWHb89lkMMgzzzyzcqskSRpdjMGORGtNWfl2Kmzg9Ec0na5pYseOeTnyv/HGG8dOIKhWEgy5nqtd+XmzfL14O9WFBx54oHpi55uKMiGcyhCDjOUAkJeP6lD5uXIzUIJ18XaqZlSCuD1Xmor307eagFWc2JEtzpOnrKb78imXqMoQZIr3EZxBRYbrI+s188S2ZnvRZJ3l2GKLLSIkFeeh0sZOK2GHpuyc2ortzc7rf//73whhPEfxMS09UW1iR5zmsxx04aADlSaWnR1s5iluC6pW7LyzY87BBj5LBLx8f3HeLF8v3k91lc8WIZDtwPvHgY7ivEwMgFY+1Rry7eX5R8ZU3zahIkmYJswxP82QX3rppWgJQiDks0a44n4qq8WuAPk1uI/Qx0EuKq25SSwhL3vllVdiXqqsNEnmNfL12j67bJOaujtwW3Nsr4x1v/rqq6MVCmE338dfthUH1Fhf1pWqbw7FxfmYqObTjJrno9rJd5vqPL8ltKzh80cLBcI2AZvHEI5ZP7Zdfj7CI6028vOCAwwETM49z29pvi9PLb3t8oSabucADV1y8nrwm8pvLtuPdWUd2B7cxwEcthmX2d71bR/+5ikrX3ZycnJycnIavaY2WVnOTXbZIaLfcnniPL65uScIJ4QVKqU0J+TUUNxGf+IRHSiGihY7WOyY09wTOZAykm8ZgRF5HvBYqt1URGjWzfMQGLk9oyJJiC1OTWnyl5udlytZyNs1V8hH1muCcMj2pkpMFZJmn1RxyvKAaTWdszo3u6R61JoIf+yAU9ml4kf1m4BHBY73sIwqH587DtRQMWe+2vClK8otAUDgo8pKn1U+txw0oIpbkxxWstpCzchS3zbhPg6MEIj5XhBCclNzWg1QmWNd6PJAs2IOLJQR+Hgcn508ofg94QAV8nYsXqeaW5vy9ilvv+ZCQH3++eej6TCBLcsVeH4X8rrSdLv8+QAH1ziAwHeM/sv89lFRJyASntnu+fnywTpwOd+O4m9SxsEOAiXPXZvW2nY14TNSXEfk9WQq35d/8+rbPuXtXtdnSZIkjT5atbLMlBVvY+cQ7Dyyo1y8j51FdsjZyeE6QSVXY5ho8kufZM4lzHVON5Xvy/L14m0o3p4nXp/+zMX782jNNF0szstE1Q1UifJtVBvpL01QZqeY/oW77rpr7OgWH9vQKavpPpoMsvNLtYo+e8X7qIyDSl/x9oZMWU33EcwJdwxcRoDiLwcrapo3B59ixT9PNKUEO6rl+1py4j0kAObWAexUE0ho7k9Fj9uQP5s0H+czQrN9mhqzDZCfD3mdqGjlbcD13OScy2wTAg0tGmgSz0B1hKz8POWJwEIQY+JyTfOMrKkh24RxBwhwfOcYGyBXj/mO0qSa1gNMNC0vBsO8bahe872hmSzN8flLxTNXj8HfPNV3vTzl7ZS3W03zjKypuCycoo7PdvG3KPfL51RurCsTzclpgp4fnz9fjINAOOZ3j9v4brGd+I7ze8iggfn5qEDnx3NAghYt+Tq4nCfQeoffM5q75/expqkltx0Tarqd9eR7wm8O1/mNI0DTbJ2qMp9PWmdwH99JDvKgvu3DRJcb/nIAi1YKyPcVLzs5OTk5OTmNPlObrCwzsBcVXfqTUYmkqsKODzvdnK7pggsuqO5bu99++0VIIbiy88N8BBAqVGAU1IwQyc4UA7WU+zOzE0qzyDzR/40+pFSB6RMHRv0FzYZ5Lm6nWSA7mbwur0llETQvBtUk+uhSbaN5OM2v2TFm55mBr/LOXF3o+1tcthy2WM98W66QsMNI1ZbqLJVOdg6Zj+WkWTQILvVpzGsSpAj/DK5EWGTbFh9bnJedbVBdpGku24Htx3Kyw448T2thHRl4iXDCujFxmdsJiKCiSQWYz0gOMKwPAYYKPbflJsl8Vtj+bBfCJe859xEs+QsCI5fpE8xBDZ6H7wCPrQtVvmLVr7k0ZJvQPJbtQrU5t1Ag1FAh53vMduGzQPhjKm8b3ne2J0GabUE45zPBZ3FkyYGvJbFNOIBHc+f8fvI7wPeFbcV24feL3zu2BYqfL9DcmMo8FXpwQJF5+dzQfJ/tycE45mHb8Xx8hjjgUhdCJmcRoLJM64j8Pa1JS247vj805S9O/Jby+vxWcJ31ZH2Zl4MHTPwO0+yd5ul8Ptk+qG/7cIo8vr/8X+HgKwchMh5LeM4HRyVJ0uijVU8dlUfDZme72CyXnRP6K9JEkLDKjhw7KvSRJGQRDmiuilzVZMeIsJx3oBiQi1By4oknRiUXjFhM4Ca4slNE+GUHjP7I7HARkOkvysRzUNXjXKRUMm699dZoTgqa9rETRlgm2PB8hAfCKDtqVJLoq8hzEhRoeso5oOmnC6rfhAaCADurNKusayeMZWbgsrxs7OSx88brsn24jbBGk0/QDJpm3vRBZseSZaSJNH9pws7Bhfo05jUZDI0dd5qAs/3zY4pTrjSys0+Fjefg/Wc7sO1oQs97S9Ntmofn/qqtgUoboYFww3Lm95gmyPQfBZ87wg2VLQ7usE58RtnevP/seLN+NC0n9PBcbC92zpmHzysVVgImBzY4gMH2YTtTqSZA8Tg+N1QVW1tDtgn4rhA2rrjiingPCYdU7/guEXBYLz4D9MXmvuK2oVUE331COc/PNmT78f2l6keYY/RmHkf1kM83I72DZSN48rytje8JQZ/uGxmtOWhJwoE6Pi/0RycA897zW8P6Uq3nMWy34ueLftrcxjZk/Wiuz/ZioD6q7sWDFbwu7w+fI94zDtrlAxIcOOQ1kbcf99PagfeE3ypG9y+OXN8aCKqsA58X1idPhGHWiQMJfBb4vhGOr7rqqmiVwAEI7uN3mW3NNufzyO8Svyt1bR/CMqOD87vHgRsew8Eqti3vC/fxGAZtkyRJo492VTv0rXaonJ0aBnWi2SkjCZexc0iQJXQQTqnKsXPMKZvY2cwI3Aw4xE464ZcdHwIo87GjmTEqL4MUEb7ZCaKpNgG7ph0gwis7+exQMTAWA36VUbklIBO8WT52sJiXUM3j2dHNjyO8FkeaZRnYUWPnjqBYU3/CjB1qqj91oVp98803V66lCP6cYoZ1ZjkI6Iw+TTPP4rarTWNe88orr4zwV5dDDjkkRvYF1X0OQhCOCY4cVOC95ZRWtBpgu2vUQwWY7wQBmDEEpJbEbzAHHRjgi98Qfvc4CwEHnDiAKEmS1FitGpYl/TtQMeXAB2GZg1Q0eZVaEq0PaElEKw1avPCZpDURB/Vau1ouSZJGTe1mn312w7KkEUIoodtEPvWa1Bro0kF3HVo50HyaLhFWlSVJUlMZliVJkiRJKmnXpUsXw7IkSZIkSQVt8tRRkiRJkiS1JsOyJEmSJEkl7WabbTabYUuSJEmSVGBlWZIkSZKkknadO3e2sixJkiRJUoGVZUmSJEmSStrNOuusVpYlSZIkSSqwsixJkiRJUomVZWk0NWyYX321nnbt2lUuSZIktU3tZpllFveYpdGIIVltiaFZkiS1VZ5nWRqN1BaUDdBqCbUFYwOzJElqi9r9/vvv7iVLowECMdOff/4Z05tvvpl23XXXyr1Syzn//PPT3HPPncYYY4yYCMsG5qZxu0mS1Hza/fHHH4ZlaTSQg3LVdz6mt956y7CsVkFY7tq1axpzzDFjyoFZkiSpLWlXtfNsWJb+5YpV5d9//z2m9957L+28886VOaSWc+GFF6YuXbqkscYaKyary5IkqS1qV7UDbViW/uVyUGb67bffYvrggw8My2oVhOXOnTunscceO6Zic2xJkqS2wvMsS6ORHJpphi21Jj6DfBY9XitJktoqw7I0GiGY5MAstaYclA3LkiSprTIsS6OJYjAxoKi1FT+Lfh4lSVJbZFiWRjMGE7UVfhYlSVJbZliWJEmSJKnEsCxJkiRJUolhWZIkSZKkEsOyJEmSJEklhmVJkiRJkkoMy5IkSZIklRiWJUmSJEkqMSxLGiGzzz572nDDDdNWW22Vtt5667Teeuul6aefvnJv08wyyyxp3HHHrVyTJEmSWp5hWVKTTTvttGmRRRZJt912WzrttNPSKaeckp555pm06qqrpgknnLAyV+MttNBCaZxxxqlckyRJklremEdVqVyW9C82bNiw9Oeff6Y//vgjpu+//z7dddddlXubplOnTmm88cZLffv2TZNMMklq3759GjRoUHrppZfSb7/9ltZff/001lhjpS+//LLyiJS23HLL9O2338bjVl555TTvvPOmeeaZJ0000URpwIABaaWVVkrTTDNNmmGGGdLQoUNjXqrXyy+/fJprrrnSrLPOmr7++uu4j9fr3r17+vnnn9Niiy0WIZt1JMQvvPDCaYEFFkhDhgyJ51Dbsfbaa8fnhc/GmGOOmcYYY4yY2rVrV5lDkiSp9VlZltRk/fr1S5NPPnlUkmecccYIwBNMMEF18OnTp0/q0qVLZe6Upp566gizPG7RRRdNL7zwQjr33HNTz549Y/4OHTqkm266Kea9+uqrI4TzGKrX1113XcyXK9e8BoGcwEVYvuKKKyL8E5q/++67dPnll6f7778/LbjggvF8kiRJUmMYliU1GdXd8847L6rJ3bp1iyrvBhtsEJVgwu+HH34YFUQCNWaeeeb05ptvRhNrqr1Uiueee+7UsWPHdM8996QvvvgiAjMmnXTSNP7440cIf/vtt+P5ppxyyvTpp59GZZzL2QcffBDP8csvv0Slkuu8JiF6RJqDS5IkafRlWJbUZFR1CbRPPfVU6tWrVzr55JOj8rv00kunmWaaKYIrQbdz584RdmlC/d5778Vlqr6fffZZWmqppWJgMKrFNQ3qxW2EaoL45ptvnrbffvs09thjD9enmeUA1WbwusjXJUmSpMZyT1JSk0033XRR0Z144onTFFNMEVXh/v37R0WZy4TVt956K8IyI2T/8MMP6aefforHErKfffbZdOGFF8ZEP2Uq0mXM/9prr6WzzjqremIwsXfffbcyR4rwXZRDcvl2SZIkqaEMy5KajIG0VlxxxTTZZJPFdUIqwZjBuT766KO47auvvkq//vpr9CV+4403oirMfJxuiuozIZsq8eDBg6MPch6ILFeZqUTngb2mmmqqeH4GCWNAMEmSJKm5GJYlNdlDDz0UfZAZwXrbbbeN5tQMqHX33XengQMHxjwEYSrDhFsG9gJ9jh9//PEY4XqzzTaL8MugXIRp8JcRk+nP/M0336SHH344mmkzL3+pVhPAJUmSpObSbhhlnFbAqWUefPDB9M4778RpZRiYh51qKlRUjtiJXmaZZexzKI0EfM0JqL///nuETL5v//vf/9LOO+9cmaNpeF6aSTPQF9Vg0H+YUzrRzDqjgky1+dFHH63uT8xjfvzxx3gOUElmMDCaTjP4F4NzEbAZoIvTP+Xm2+A2Rt1mnRgUjCbcPI714/eEije4TmWb+9V20OyezwPvOb/7+RRSNpuXJEltSYuHZZpZnnDCCemxxx6r3FI7zpnKvDTbLKLPYu/evSNQH3HEEZVbW8Z2220XzUv33XfftM4661Ruldq25grLDUGopUrMaZ1oai0ZliVJ0qigxcu211xzzXBBmX6IG220UTThJHwyWFDGOVo5V2oR1asnnniicq1lMWhR7ocpqX40yaZv8osvvhjNqSVJkqRRRYuHZc6lmq2wwgrpkksuSbvvvnvaZpttolp79dVXp65du1bmSOmOO+6obt6JV155JZpotoZHHnmkcklSQ3Bg7NRTT02vv/569YBdkiRJ0qigRZthE3oZOTc76KCDYrCeMvoxc65W+hnS95CRcBkYaJdddqnM8U933nln9GMEfRRvvPHGqGYxyBBNT+kLvcACC6Qtttgimv8VHXvssdVBmHO5rr/++un4449Pr776aurWrVtaZJFF0gUXXBD3l1EZJ/DTB3v//fev3JriHLI0L8zob0lT1Ozss89O88wzT1wuvj7V9T333DNdf/31MXjS559/nsYbb7xokr7TTjvFaMBSY7VmM2ypzGbYkiRpVNCilWUG65p00kkr1/6q1NKHuWyOOeZI22+/fVp99dUjrLIj1VCce5XH3nzzzenjjz+OUEBIIEATYHfccceochUVByJiICHO4Ur45XEtofj69OmkH3avXr1i+Qk2nJuWbbXbbrvF4EWSJEmSpObV4s2wqdJmL7zwQtpqq62iykAVuK7Bf6hCUI1dcsklK7ekqBRzGxODCOGkk06qHjWXyu25556bzj///DT//PPHbYTP008/PS5nxTD+/vvvR1Wb52NUbkbnpRrOa0w55ZSVuVLadNNN4zaq4yOq+PrPPvtsNDXv0aNHOvroo4cbRIw+nxdddFHlmiRJkiSpubR4WN5hhx2qT+sCKqU0OT7ggAOimTJV4Z49e8a5W4uovhJ+aU6dEWS5jYmqNX2Zp5566rTYYovFtOuuu0YTbirVXM5ofvrZZ59VrqXhmv5RdSaQ33777eniiy+OKu/kk08er1Hsc8k6cBuBekQVX5/K9n777RcHETh1Fv2411prrcq9Kc5N64jCkiRJktS8WjwsTzHFFFHp3XzzzeMcqkX0q2TEaZpQ0293n332aVSz4w4dOqQTTzyxeppzzjkr96R/9PWtbZAwQvdee+31j9NVtRS2yXLLLVe59pc11lijcumv88ZS/ZYkSZIkNZ8WD8uYeOKJY7AqqrfnnHNONDlefPHFqwfoyl577bX0f//3fxEQG4om2Ay4RYV6tdVWi3MxM6277rqVOf5SHGG7aLrpphuuuXVLo7l5OaiXByT74osvKpckSZIkSc2hVcJyRhV37rnnjibHJ5xwQurdu3c644wzhqsI02T6ySefrFyrGwNhMWI253KmQs3gXlSUZ5pppn8EztoUm3m3Bg4klBUHAAPrJUmSJElqPq0WlmsaBZvwzEBcBOZilbmhzY5pvj1gwIC4TMA877zzoj/0ZZddFhXshhhZza/L1fA86Fh9appv6NChlUt/4VRSkiRJkqTm06JhmXMf0x+YJtH0Sa4NYbB9+/aVa8MPgFWXN954o3Lpr5GyixXqHKKbS/n0VoxcXcRpoBrik08++UcT8fJjGcRMkiRJktR8WjQsEwIJtDSX5nzIF1xwQY0V5rvvvnu4frmzzjpr5dLwwfn777+vXPpLsZpbft477rijcukvnEKqsep6bUbMLnr++ecrl/5y6623Vi7V7bvvvvtHs/N77723cimlccYZJ3Xp0qVyTZIkSZLUHFo0LK+33nrDnTbqhhtuSBtssEE68MADY/Tqww47LEbJPu200ypzpNSpU6e01FJLVa4N36eYAcB4jkceeSRGt5555pkr96T08ssvpyeeeCL169cvzrV83333xeBdGadgoj90YxRfm/B9//33pwcffDCus17FgcE47dQtt9wS548++eST0wcffDBcE29G/q4JYfjUU09NN910U3ruueei+fhdd91VuTellVde2WbYkiRJktTMWjQsE/IIgsVQSx/dF154IT3wwAPp6aefTgMHDqzc89co0CeddFIEyGyRRRapXErpjz/+iOr0scceG6eYInjneakyH3nkkXFeZ0Jr9+7d0yabbBL34c4770zbbLNN5VrDFF970KBBsWz0rwZV5x133DEug0G4COmcP5pAzajeE0wwQeXev5a9JvTZpnJMf+uDDz54uIr0NNNME+sjSZIkSWpeLT7AFxVYqq6HH354WnbZZaNyPO6440bYJExz/zLLLJMOOeSQdOmllw5XDQb9kAmePI5+wowePc8886RJJpkkRr0+66yz0oILLhgDfDExP6/FqaRWX331qMwSWgnVPK4xNtpoo5ioMPPa/C0G6JVWWikdffTRafbZZ4/nZ5AyluX0009Piy222HDnlS4P2pVRcSaEM0I44ZjX6dixY1p77bVTz54906STTlqZU5IkSZLUXNpVhbOa2wOrxfz3v/+Nc05j4YUXTqecckpclkYWvua0ZqDFBf31aflAN4Sdd965MseI4eDQxhtvHH35i90GakJ3jDfffDO6JjQGXTToWlHfYH0Nna9r167prbfeqlxrnOJjl1tuuWgh06dPn7iu+l144YXRcogDpXx2OCg45phjDjcuhCRJUmtr8cqypH+f2WabLb366qvRL7+mc4UXMfheUwbYu+iii9JHH31UuVa7hsxH65Ju3bpVrg2vvsBWfuw999zT4HPBS5IkadQx5lFVKpfVShg5+5133onLNC+nqbg0slFdZkR6KsxMDakCNxRdJ5555pnoXjD99NOnzz77rHJPij74fKbpEkE3ArpHMMYAr7/pppvG+dUXWmihmKaYYopYNgb1owsDp5DLFeJtt902RotnHRiDgGou3Rvmm2++NNVUU1UH5Dzfjz/+GF0iVlhhhehyQTWYx3If4xsQejt37hyna6N7BSGZrhQ8LyP2001k8cUXT/POO290D8nLUX4s687p3D7//PPoerH88svHss8111yxvtzO6+b52A5zzz13PC8DE9Z0bvV/O7qV0HUmV5T5DDBZWZYkSW2JlWVJI4S+9UOGDInp/fffjxBJ8AGhcumll45zrNPn/r333ov5M6rMBMqrrroqmuYy+B9hm+u9evWKkMtzIDcj5zGELCbmYwwEwixTcT7u57WvueaaGFX+yiuvjDEQCK69e/eOkMoyEVhplk7gPvvss1Pfvn0jzBLUeRzjIPCchHJeu/zYYqWcoMyBAgb3O//88yM85yr0zz//HOvHqfEYj4ER+zkfvCRJktomw7KkEULlmNO45VOjffrppzHYHqikfvPNNxEUObUa91G1LaJVBYPlESwHDx4c52BnUDsG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443KHH9Zf/310yyzzJI233zztN1228VO/8QTT5zOO++8dP7556c55pgjvfLKKzHv2WefHfNecskl6dBDD00XXXRR+t///pfGGWec9M4776SVVlopnX766TFvxo7bb7/9FstyzDHHpJNPPjmaixPSy69NMOe1eJ2ePXumzTbbLD3zzDOVZ2p+T37wUzrjoS/SdT1mTk/93+zpoNWmTttXheNvhlQFoqF/pG2v+DgdtuY06bXD50w9luyYtrvio/T7nyldVBVcPxz0S3r6gNnT8wfNkf74c1j67yNfVp61dut2myTtd9Mn8fi+n/+cqh6WJms/ZppiwrHS+GO3S2dsPF1cfnL/LhHY63qdccdqF2F+80UmSw/sPVu6YMsZ4/brdpg5XqcuY1btVz/V76e0yYId0u27zpou3GqGdNBtA9Jn3/9WmUMtYfbZZ08bbrhh2mqrrdLWW2+d1ltvvTT99NNX7q3bdNNNl7p3757WWWeduM73atxx/zoII0mSJLWmNtsMe5lllom/VHannnrq9NVXdTfrpYr7/vvvp5deein98ssvsfO+/PLLpx9++CG9+eababXVVouqBTvnF154YerUqVNc5/kXXHDByrP8U14OquJUlXmuso4dO6bvvvsuPf744/GX5yNEt5R73vwhrTbXJKnTpGPH9eW6TJg6TDBmhFCC9ORVwXXpSoV4wwU6pIf37RJBc9dlJo+APU7VlbGqPglUkfsP+jXmq8tJ63dKx6wzbXrho8Fps4v7p65H9U373vRp+uKH3ytzDK+u1+E9mGT8MaMC3RQzVoXxhWacIC7POfV4Ec77fDwkrqv5TTvttGmRRRaJlhennXZadGPgQBGtNCac8J+tEsr4Pr799tvp0ksvjesLLbRQHMRqDlYtJUmS1BhtNiwTYjOqvDQhrQthmOpU7969o/k0lWCaXxNeMdFEf4cxKtBUsEFTwLoUH8cy/fTTT5Vrf5thhhnSAQcckF5++eW05557pgMPPDAq1i3lqx9/Sx3b/7U+2WTtx0qDfvw9fVk1EZyzMaryAvOSGz7++tcIuauf80EMHnb5s1/Xu52zteaZJF3Sfcb0xhFd0227zpq+Gfx72vLSmvtw1/c6k5eWvTGK64aJxhsjfefgYC2G79LXX38dB6g4qDXVVFOljz76KFp4cKAK00wzTVSbN9lkk5jmmmuuuJ3u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VGKfZWk0UFuf5S233LIyh9RyrrnmGvssS5KkNs/KsjQaI5w4ObX0JEmSNCowLEujMSrOTk4tPUmSJI0KDMvSaKymIOPk1NyTJEnSqMCwLEmSJElSiWFZGo3VVPVzcmruSZIkaVRgWJYkSZIkqcSwLI3Gaqr6OTk19yRJkjQqMCxLo7GagoyTU3NPkiRJowLDsqQRstFGG6W77rorPf/88+mFF15IN998c1p22WUr96a05pprpkkmmaRyrXG6deuW5pprrso1SZIkqeUYlqXRWE1Vv8ZMiy++eDrggAPSbrvtlrp06RLTBRdcENO0004b8+y7775pookm+sdj65ryshHE55hjjn/c7zRqT5IkSaMCw7I0GqspyDRmmnnmmVO/fv3SBx98ENVjQjFVZkL0gAED0rnnnptmmmmmdOWVV6Y11lgjHrPDDjukRx99ND3xxBOpd+/ead55543bO3XqlN58883Uo0eP9NJLL0XIXm+99dJ//vOfdPDBB6fNN988XXvttdWvPeGEE8ZrTzrppGn66adPb7/9durevXu6+uqr0wMPPJCOPPLI1K5du+r5ndrOJEmSNCowLEtqsoceeigqvz179kwrrrhiBNdxxhknffXVV+nPP/9M22+/fcy3wQYbpNtuuy3NP//8aY899kirrbZahGSC9QknnBDzDB06NI0//vjxeEL4cccdl1577bV0/PHHp8MOOyz9/vvv6Y8//oh5kUMXr/Pbb7/F48Yee+y0zjrrpBVWWCEtt9xy8TqSJElSUxiWpdFYueLX2OnTTz9Niy66aOrfv3+EYPos33HHHWn99deP559gggniLyGYIMv9c889dxo8eHCaeOKJ0+OPPx6V5/x8oM8z9/EYKsM8jsv5/uK8KF7msVScedwjjzySFl544er5ndrOJEmSNCowLEtqsjHHHDOC74knnhiV5VlmmSWdf/75UQ1eZZVVKnP9jRB8zDHHRKCm0nzmmWemMcYY/mfo+++/j7DbFCwLePxPP/3U5IHFJEmSJMOyNBqrqerXmGmppZZKs802WxpvvPGiokvwJQRTMaaCzDwZl/fZZ58YBGzttdeOcL333ntX31eeN1/Pl3MT7Hy9ffv2w11Hx44dq6936NAhff3119XXndrOJEmSNCowLEujsZqCTGOmZZZZJp1zzjlp9tlnj+tUdDlt1BJLLJGefPLJCLhMVJS5n0rve++9F6891VRTxSjaY401VjS15n7k52b69ddfox80lz/77LNosk3fZK7npt55Xmy66aZxmdchjLMM+X6ntjNJkiSNCgzLkprsiCOOSLfffns0vX7jjTfSyy+/nPbff/+03377paeeeiqC0S233JKuv/76GOzrvPPOiz7OjIZ9xRVXpLPOOitGsaZZdk0YLZvRsBlVm9GzOZcz81511VXpk08+ieenKXhGoL7//vtjosL94IMPVu6RJEmSGqdd1c6mh/mlfzm+5lR4GVGaau0vv/yS/ve//1VXZ5uK5+W5GI06/5TQFHvccceNajGGDBkSr8ttVJG5DqrQDNzFKNhgMLAff/wxqtC5zzLPzcTj8ryMfs39PD/XOV3VdNNNl5577rk4t/PPP/8cy8JjaB6en0ttBwcyZphhhvhM0FKA94qDHr5XkiSpLWmxyjJNL2kWmafll19+uOtUhM4444yoUNXkvvvuS3vuuWflWsM05TGgmpVtvfXW6dlnn61ca1uoyOUmrSPi22+/japdU3BOW86fe+GFF1ZuGd4FF1yQrrvuusq12lFp/OGHHyrX6tbQ56zLZpttFufybQ4DBw6Mz3fxNEe12XnnnWutqjYX3mtC6chAuCGQElgJuUz0Xc5BGYRgbicYEYiYl4n5uM7f3N+Z5tPFwMRjeCzPwe38ZV76KxOymL84QBi3cT/Pn0fTVtvDAQ/Og82pxzgndu673hiDBg2K32cO+HB5ZGrM71FRXct09tlnR8uKpir/rhT/T5Xxf2GXXXaJ3+YtttgiRoYH68Rz8JfR6+v73a/rNUYVTV2H4v/Xb775JrZbPrDXFtT1GW3ry85ZEbbccsvKtYar7ztffK/r2p9sjJNOOin16tWrcm3kGVn7b5KaX4uFZQb1efjhh2O68sor47Zbb721+jYqQnXhx54RdhujKY/hB/iaa66pXGvb7r777vT+++9XrjUdoZG+nU3Be7fvvvtG6KsJzWZpdlsf/hk1NMDV9JzsfKtueRvRhJmRokEF9t8y/dvW5988EZA5qLHSSitFH/djjz023r/G6Nu3b3ym+T8y+eSTV279y4j+HjTm96iormXiQA9TU0055ZTRpYEDTHX9n6KVx6GHHprWXHPNOI/5IYcckk477bRoSZJfn4NJhx9+eAQKwlRNRqX/hbUZkXUYWf9fm0tdn9G2vuxNVdf3a1T7vI6M92hEf+ckNUyrNMMeMGBA2mqrraKvY/HULvzjZkeAEWzp/8g/9gMOOCB169YtqsT8uDCYED+Y/GWHn6PsSy65ZNp1113jsUWNfQzNNzlqyc4D4f3kk09OBx54YIzcy1FczilL08GjjjoqfqjZKbn44ouj8kwFi9PmEByL65R99dVXsX4cSaRats0226RVV1017mM70CyRHz7WmeC5wAILpC+//DJ17949npO+l/wz4KADOz/0Ab388stjh5PKPAMlvfXWW6lnz55xtJkKGxUF7gOXN9544/TMM8/E/VT+WA/WiQoPzWRnnXXWqH6U1bZ87GzR9JVRh1deeeW04447Vh7xF5af6sWNN94Y1++555500003xfZnG+21114xkjKvT4VjmmmmiefgvaF6/PTTT8dyrbDCCvFeUUEsPue9996bHnvssVhXqi68F6+//nr0b+UzxHvE6MtzzjlnvH4RleX/+7//SwsuuGB67bXX4gg0nw0+D+uss07acMMNY7663jfeA6rCeX14n3gtlmXzzTePqln5M1nGtmSnltckQPA+8zl655134v3eYIMNYlnY9qwX25vtQGWV7TfXXHPV+TnM24j3+/PPP09TTz11bOspppgi1qMpIaUtYvvw/hECrCa3fTPPPHP81vCbw+eTPuZ8vvn81/YdKKJv/AknnBBhgYHi+I7uvvvuUXHiXNv8HubfkT59+kRA79SpU/we8DtT13et/HvEQdeiL774Iv33v/+N8Mlnjd9Cfp/4/S0vU3GHnt8/fg/43vF6PMdHH30U32dGladPP9/lHXbYIfXo0SNel+vczv9L/g/yu0IA3m677Yb7P8WyZqwvp2QrBofjjjsuTT/99PH7RRWf1wZjBvDbwLYrqul/IctZ03rTsqSsKevHdqnrf1htv8X8BlM5Z13A7wD/s/l9pmVZcR14PxryP5uWS8X/r/y/4LPBQQgONvL/hUEMDzrooFi/2taX9/uUU06J32s+N/y/Zb347eb94Td5sskmi/enpu1Y2/+Yuj6jI3PZy5qyj8E2/+677+L0grwG68t3k/9NNYXbpny/avq8sh1Yh5r2J1Hb/kgZlWU+b7R+7NevXww4yb5D3q+obf8Ite1blN8jfq+KWE/uY1uwTuwHMXbHHHPMUeN+T1P3YWrbBnXtbzR0/1v6VyEst7SqfxjDlltuuWFVP6CVW/5y+umnD6v6gg+r+pGM6xdeeOGwqn92cbnqB2JYVUiKy1U/LMOqQnBc/uWXX4ZV/QgPe//99+N6UVMeU7WjMWyjjTaqXBs2rCqsDqv6BzWs6odhWNU/9lieXr16xX1VP3bxvEOGDInrVT/ww6r+OcTlsqqdtHhc1Y/QsI8//nhY1Y/VsP79+w976aWXhq233nrDqn4UY74XXnhh2BprrDHs+++/H1b1Ix/b6dprr437Bg8ePGzdddeNx4B1q9pxistV/0CGVe0gDHv88cfj+oABA4attdZawz788MO4znocfPDBw6p+dON61T+N6vW45JJLhlX9s47LZXUtH3jeqn+Ocbmsd+/ew0499dS4XPVjHsvDcoHlrPrHOuzXX3+NZWI9+VzgsssuG1b1jyHeJ9a56h/3sKp/RnFf8Tmrwuiw1VdffVjVjk9cZxvwGnn73HfffcOqdoCr17lo0003jfea9agKq7FeqArjsY25D7W9b2+++WZsh6odjZiPzwLLiaodoFifml63bKeddop1wsMPPzys6h/nsKrAH9erdg6GrbTSSrEdWL4tt9wythdY56p/ZnG5rs9h3ka8R3x++RxX7QzF+8E6VgUIJ6cWn/hN4bvG94/PP59fvmN1fQfKmJfvT1YVuOJ3Lc/L95bvb75+0UUXVf8/qOt1yr9HZfwP4LnA95HX4DcU5WWqDf9Tzj777FjnoUOHxvpX7XTHffy28D+I37NLL7102GGHHRa3F39Xyv+nim6++eb4rS+64ooravzf9Oqrr8ZvZE3Kr1HXepc1Zf3q+x9W228xn5+999475gHPw3Zi/6K8Do35n138/5r/F1cFkmFVASF+94v/a+paX/Zr+D/J/zLurwpTw3r06BHzcX277baL3+myuv7H1PcZHVnLXlTf+1PXPkZVWBtWFdbj9auCbXyWqsJ13FfW1O9X+b2ua3+yrv2RMvYV+b3Kz8P7UBU443Jd+0f17VsU36MyXpN1yftZt956a/Vrlvd7mroPU9c2qGt/g89HQ/alpX+TNjca9iKLLBJHwDH//PPHkbUymqPRbJgjjQwMwxHSzp07V+6tWVMek6222mpxZI3HzTPPPNXLVPXjEpUM+kai6sctjvZytK2o6scsVe2UpKof1ThSSnX6hhtuiL/Mz5E5lg8LL7xw9NGkQppRtQVHLat2NGvcJlRaeByn8gFHVxdffPE4AplRoc1H/1j3mp6nrCHLVxuOSubm0iwHzS1ZLuTl5ChlGdu16h9OHDllnalAVf1ziPuKz8m25OjrYostFter/nFFlTsf1WW7Vf2TiCOjtWG7caSY9QIVV7YblYe63reuXbtGdZvz+oLPLVWDEUXll88YeI+qdjyqq+T0Lacixl/WOVeD6voclrdRWdVvgJNTi09U9GpT23egPnzW+Y3hdwN8B2i1ka9TbakKIFERQVNehwoZVSq+b6B6xv8Hfi8aiqrbK6+8ElVilpmKIstJ6yVQvVlllVWiukQViZHlG4MqW17njNfg9jJei98TKpx1acx6N3X96vofVtdvcWM09H92bWh9wP8Tfvd5bf6H1re+oAUT/8vysnOd+fJ1qn9lI/t/TFOXPRuRfQz+N1NB5fWpbvLZqcnI+H4V1bY/2Zj9ERSfh32TqtBZPdZLbftHde1bNAT7OTwXWNb8mrxPxf/pTd2HqWsb1LW/MSL70tKoqs2FZZpRZvyw/vnnP/tk0ASGL+fpp5+e1l133Rg0heZcdWnKY7LalonmMTwPzZyY+KfPP2FuL8rX8w8faPLCPxV+iPihK+I+bs8I6llt24TXoIlyXhamPn36xI9l1pDnKWvI8tWEbcs/PXYKwPLx41xcvl9++eUf2wrcVtxWLDf/YMvPieKylR/HOnI//yRqU9f65WWr6X0bOnRoBHEG0aEJ0qmnnhohYESV3yPwPtFs9Zhjjon+2jQ34zXZ8QfLWdfnsLx+ReUQ4+TUElPxO1VW23egIYqf9fJ3m+8u8m9XU14nP7b8vPn2hsjfyz322KP6O3vZZZdVh3jQhJLv+tJLLx0HABuD737xucB1wloZO7u8F3mZatOY9W7q+vG42v6H5ees6be4MXiehvzPrk1N+wINWd8czsHjytdr+tyN7P8xTV32jHmbuo9BKC+/dzUZGd+vorr23Rq6PwKajmd5PX788cdYruKyIi9vXfc1RHF75e3Ka6L4vHW9Tl6fmr43dW2DuvY3RmRfWhpVtbmw3BD806fPE/9ILrnkkjhqSd/kujTlMfXhCO0+++wT/YryRH8yjuwV5Z2B4o8k/V/4h8SPcPnHk38+xR/nhmBZOH1OcVkYBKMpo8wWNXX5OJrJD2reQWP5qCYUl693795xJLqM7VV8TS7Tr6r8nCgG4fLj2LH48MMPo2JUm7rWr6737fLLL4/+S/QNpK8Q/YmaGwcJ+AdGHym2JX3GUd/nsK6DBcUA4+TUUlNzKX7Wy9/tvFNf329XXfJjy8/bmOfk+4qLLrqo+vtKv0H+L2X0C2VHlJ1ZfsMaY6aZZoq+ocXt3L9//9gBrk1dvxFozHo3df3q+h9W128xIai4roMHD65c+qf6fiuboiHr2xQt8T+mMcte1/tTH0IrgTmrL5SOyPerIViXhu6PoLjsObASOlmu4rIiL29d9zVE8bH59XlN1PU7h/w6dX1v6tsGte1vNMe+tNTWjXJhmSNYDKDAPxHQXCT/gNSmMY/hSDvN1RpypIwmLPyQ5OZtNBFmJ6CMo35zzz13/BPiyCY/VjvttFM0CaLpCwNZccQWPAf/7PMgFHVhWfMPN02PaULI48EyMQJqQ0ZbLD5PWVOXr9hcGsstt1zsGDEgBWj2x+AfLCc//Ozw5GWg2nDnnXfGfUwMaEbzufJzlrENaMbF8oLH7LvvvvH8bGsG9CnjMfwjeuGFF+I689F8iWWo633jdWjKRIWA8waz00BTvpo+NzRZYud1RPDPiEE6eA2OCs8444zVO4gN/Rwib+tcOaBZv5NTS0/Fnc/mwm8X35v8nWQQHr7vxepXTcq/R0X835h33nnj+4Zff/01XiM3YWwIggPLwc4p+G259tpro8kjcoDcbbfdYqeU5srlA351/Z9i+bifkbP5vWBnlqa2jDxexvPyXuSd6qLiazRmvZu6fjymtv9hdf0W0yyU6ywTir/z5e3UmN/Kuv4vFtW3vk1V1/+Yuj6jaI5lr+v9qQ/7Cwx4yfOz/8DgqzUZke9X+b2uS137IzVh/4AD9mAwQrqRsKx17R+xvWrbt0B979GLL75Y3Tyf9yO/Zlldr1PX96aubVDb/gbbtq596ZGxryO1RaNcWKYPC+fnY/RI+tkwiiY7X/SzqU1jHsNIgPwAMKpjbnZSG56L+Rndk5EgGWmSfjk1YSRK+pzwvBwhpmkVI8HSj2bbbbeNpi3du3eP02rlkRDrw48dR585+scO4IknnhjLwLput9128Y+Q16gPAZRz/m2yySbxg1rU1OUrn96JvoFsJ/q3sHz8pV8NfaT4p8/RTLYLI9lyP1UQmv9wmREg6cNUfs4ymhrxHrNNmJ+RNrnOjz3/0BndsYxtxDyXXnpprB+jn7Oc/MNGbe/bpptuGp8PlpHH8FmgosP9ZVdccUXsrI4I3mt2mHgdJkb5zUd6G/M5ZFvzD/6II46InRepNVDpbG58F9jBZGRffvPp78nvTn3Kv0dlHLxj+XlOwt7ss88evweNcfDBB6dPPvkklpHp3XffjT6HVNwYCZhRe9mZpn8kv1H8hhTV9X+Kx3HKRL7f/I+jMsnvGH20y+ifSFAujqadlV+jMevdlPWr739Ybb/FCy20UAQCrvN/KleJ+V9WXofG/FYW/7/Wp7b1HRF1/Y+p7zPaHMs+IvsYfAcJYfQRp7LP8pX3NbKmfr/q+k6U1bU/UsZysryMas72oT837wfq2j+qb9+ivveI5aHpffk1y+p7ndq+N3VtA5atpv2N+valR8a+jtQWtcqpoyS1LL7mHCWmgsPRevomcWoOjhJLLY1qGacfIcwyGBXBiYNaVMzUcjjdEtuePquS2gZOV0WLCQ4ySGp9o2SfZUnSqIsRbnPTT7UOmmLSDJMKkaS2xTqW1HYYliVJLYoBY+hn9/DDD1duUUuilcmxxx4bTWLzIE+SJOmfbIYtjQZshq225MILL4zBizglnM2wJUlSW2VlWZIkSZKkEsOyJEmSJEklhmVJkiRJkkrssyyNBpqzzzLnweQ8p5wOiPN/MnDTSy+9FOfurMtSSy0Vy/Pcc89Vbmm69dZbL86t+cEHH1RuqRnnj/zpp59Snz59Krc0zHTTTRfLWx7BmfN68toZ6188f+iNN94Y26MxOF8o5xa/8847K7f8+9hnWZIkjQqsLEtqsmmnnTYtssgi6bbbbkunnXZaOuWUU9IzzzyTVl111TThhBNW5qpZDu0jw2+//RbPV5+mviaP42BD2WeffZaOOeaYmM4999y4je2Qb/vmm2/itsbgtTiIIEmSpNZlZVkaDTRXZZkK6CyzzJJ69+6dxh577HidoUOHRqWQiUrr1FNPnZZYYomoPA8ZMiQ99dRT6auvvoqQzfyTTDJJzMOyPf744+nzzz+P56ZiPc8880S18eeff44Q/vXXX8d9Xbp0SQsssECs04ABA1KHDh3SG2+8Eeu01VZbxSmJ8vMsvvjisRxPP/10LMePP/4Y83LbwgsvnGacccZYjm+//TaWjdcab7zxogo92WSTpcGDB6f+/fvHut50003xnDVp37592nLLLdPll19eHdypSC+66KJRPeU1Xn755fTee+/FfazfvPPOW12NZpneeeedWJ6uXbume++9N+ZbccUV47GPPPJIrY8Z1VhZliRJowIry5KarF+/ftEUmUoyIY+QOcEEE0SYI/gQhDin7v33359OP/30CLxcz6Goc+fO6cEHH4xqLMFvwQUXjNsJz4Tp6667LvXs2bO6Ws3z8vxLL710NHHmPsLnNNNME48DIZJKc8aBgRxei7p16xbLTnDjeagCE6ZBECc0n3nmmemyyy5L008/fdzeGCwrQfehhx5KZ511VlTfWW62EeGQy9dcc00655xz0pVXXhnBmsBYtNhii8W24rHc15DHSJIkaeQwLEtqMqrI5513Xho0aFCEz+7du6cNNtggKqCEPEIsfYQJogTgDz/8MF1wwQXV/XrpY0x1mPto0kx1FgTvt99+O55jyimnTJ9++mnMx2Xm5fkIs/m+xvYLxkwzzZRefPHFqGzzPFR9qZLzmjQv79u3b9xO1fq1116rPKrhWF7C9hdffJGmmmqqWEZuI+wT5qlYE87po8xBBcJ/sfk1VfWOHTumW265JU088cRxX32PkSRJ0shjWJbUZFRIaV5N8+VevXqlk08+OarAVEAJozSzJVDzF8xLWMwIjTwHaMadK87MP9dcc0X43nzzzdP2228f9+cmuzwnl0GlluuNRTBfeeWVo+k0r7HZZptFBZplZKLpM8vDRMhtLB63zDLLpE022SQGAdt0002r1xVXXHFFVIXXWGONWAaai+f1n2KKKaLKTjgmKOfb63qMJEmSRq4W77NMP8Ivv/zSaojUgviaE/iYCKhMAwcOjObBI4JmwFSOv/vuu7hOxZiK7+qrrx6VVKqqSy655HB9fanUfv/992mhhRaK5XjllVfidqq4K6ywQow4TTNonovm2xnrQBWY/sr0Nb711lsr96S0xRZbRGCnzzKhl6bPVLtBoOT3hipysc/yOuusk5588snh+vzyGgRVgu3zzz9fPaI3zcXnn3/+RvVZpk/usssuG8248/bZf//90x133BGVcZaJbUczcZp5sw633357rCPrx+O23Xbb9O6778ZI36jtMfn5RxX77LNPtBDgAAgTBwCYDP6SJKmlUcxgP7TYrS9r0bDMjic7kZ06dYpqkKSWkcMyYYvv4Mga4It+xYS2Rx99tHrkZ5ow01f3rrvuitu22WabGLjr448/TjPPPHOE56uvvjoeW1tYZiTtddddNwYOIxxONNFEMT/Pw7pst912cR8Dhc0666wxGBd9n1mnNddcM5p3EzL5nVl//fXjejks01Sc5SFYs11YD36bOJUVr8VrMlAYYY7+0lSbGxOWadJN03Qew4/wfPPNF4H7nnvuifUmxPPavBf0byb4sk4MKjbnnHOmu+++OwIk249tyXrX9hjWaVTiAF+SJKmtoNBDtz5aP7IfWzTmUVUql5sd/RWpCuXmk5JaDmGLam2uMFPdJYSNCPoVEyYJoVRDGamZyjEhk8o1gY7QSnNkKsn0waUizOtTlWZ5mA+ETcIrVdTcz3n55ZePwEnwpE8xFVSCLa1TCNb066UJNuGR+VknWq8QyHkMfYU5SEcQo080gZggy+MJ1iwrTcY5TzTL9uyzz8bzE+z5rWK9eB7CNT+eb731VixrTfhdY/1fffXVWD9eg0DIIF08F9uK0cAJ4jwP87B+vDbhmNG6WUbCMgcOGDyNUM0o3VSoCfusR02P4fZRydprrx0V9ByS+ZwwGZYlSVJLY3+E/VD2Gdl3LGrRyvJLL71UPdqtpJbD15xwNrIryzwvwZbAmgftyj84VGLBa+XBrQhGhCSCJcGXgESf3Dwft+UfKYIlz51Rbc79nenLm++jesx65f7QPA+hmefOQYzlnHTSSYd7TW6jIsvRRC4zL7ezbCwr8xJWuZ3n5jXLP6BFOcTTvJjXYHsQdLmd6yw/y8ZESOcv6whCIsvOPNzGxEjd4HWZCPP5PhQfM6qxsixJktqamrKqYVkaDfA1b46wLDWFYVmSJLU1NWVVR8OWJEmSJKnEsCxJkiRJUolhWZIkSZKkEsOyJEmSJEklhmVJkiRJkkraTFg++OCDK5eGv1x02GGHpRVXXDGtssoqMXGuzgMPPDDOidUQnOf0vffeq1z7d+rdu3flkhqDEaI5f+1XX31VuaVhtt566zg3b0srvs9nnHFGOv/88yvXJEmSJI0MbSIsc05UzoFavlyTTTfdND3wwAMx3XDDDWnaaadNhxxySPU5Xuty9913p/fff79yrWU1ZPlG1KBBg9I111xTuaZRRWM/G77PkiRJUvNrE+dZfvnll9MHH3yQNtlkk+Eul1FZ5tycO+20U+WWlAYPHpzWWmutdMUVV8T1bbbZJj366KNxGTvssEPq3r17+uyzz9Lll1+eJpxwwqhO77bbbpU5UnrhhRfSCSeckG6++eY43yfuuOOOdN9996Xzzjsvvfbaa1G5++mnn+JcoOuss07acMMNY74NNtggHXHEEWm++eaL6+eee26cz3bvvfdOJ554YgT/F198MXXr1i1uK6KaecEFF6Snn346zn+7wgorpF133TV9+umnta7Hsssum+655550/fXXR8gaY4wx4gAC60SV85tvvokDCCeffHLc99///jfOp8v5SxdYYIF4/vHGGy+dcsopqX379umLL76I1+Ncp3vttVeEsM8//zxNNtlk6bjjjot5y15//fVYz6+//jpNPvnkaZ999klzzjlnnLuX9enTp0+c17dTp05x3zTTTFN9gIP37913343l3H///dMjjzySPvroo9i2Rx99dJppppkatWy8r6eeemrczvZYaqml0p577hnry/NMPPHEaeDAgREwf/jhh/Sf//wn3gvm7dmzZ3ryySfTRBNNlNZdd9105plnphtvvDF17Ngx1u+5556Lbciy8PpzzTVXZQv8jW1OCwfeK5aV9TvqqKNiu/z222/p4osvjsozyzPLLLOkfffdN00yySQ1fjbeeuutWCaWk3XeYost4n0t+vnnn//xPl933XXxueT9eOONN9IEE0yQDjjggHhe8FmhEs1njHXlM8B25iDTK6+8EvNILcnzLEuSpLamzZ1n+bvvvkvHHHNMBFECRfEywbUhctbPIbc2m2++eerSpUvafvvthwvKWGihhWKH7ZlnnqnckiLE0dSb4HLooYemHj16pKuvvjqddtpp6aqrroqNWR+e87HHHotgVA7KuPbaayPI8nxMHCggpNeFsHT66aenk046qXp5CNuEOpqkd+jQIV155ZURUI8//vg088wzx3yXXnppvFauSLK9nn/++XTQQQelXr16xW005z388MPjOmGM5y0j1LI9dtlll3TLLbfEwQIOYnCAgOcm+PJ4XrNz585xEAK8HiGbAxsEwmWWWSYet9lmm8V1gjzPl+dt6LIRcGefffYIhARTQutTTz0V9/E8XCewE35XX3316ud7/PHH4zm4zkToznhvOYDCARjWY7vttov3sTZ8Xgnst956a7wP+T3k/e3bt2+66KKL4j0h5J911llxX/mzwXZlfTnwwWfh2GOPjXnZnkUcICi/zyD077jjjum2226LAyp5PXl9nu+c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4Mvp3fi75pprpg033DCtu+66cd72MgI7z5tPH8ZAZDQP55ReyyyzTARxSZIkCYZlSSOE8Elz6uJEFbgmBOOiHIhRDMhlBGQqyVSFCeeEY8IztxGkGUCMPiZUiDkPNQOO3XnnnZVH/y0//w8//BB/OUf6WWedVT316tUrbpckSZIMy5LaPPooE45pOk1VmWozzba7du0ao5oTgqkKcxuDgxHYl1hiiZivHNBBX2qafK+44ooRwJlWXXXVeIwkSZKEUTYsDxw4MC2//PKx09sWMMIwy/PVV19Vbqnd22+/nd57773KNUn1IQjn71Zuyk2FmVA8YMCAuP3555+Pc6JvuummabXVVktPP/10hOz1118/7i8iQN9zzz1pwgknjPkZtZsRuf1eSpIkKRtlTx1FWGYH96GHHorqUWsjLFOZuvHGG2PAoLqcdtppcXob+ldKLYGveXOcOopRpRnVurZm11SBCaEM1EVwpeqb+wt/9913EVq5LV/nu8wAX6CpNc2rCbSgasw6UGEG53BmoirM4zgNFY8Bz0uTbJ4TDCrGstBsO1eaeS4GDuNx4LV4TFv4Pfm389RRkiSprWmT51lmp51+g/n8poxsu88++8TgPVR+HnnkkagecQ5UdmypAq2xxhr/CMucfua2225L55xzTuwEn3TSSfEYgutKK62UbrjhhnTddddVXvVvG2ywQTriiCPi3KvgNDI8fu+9904nnHBC7Kizk/3NN99E0PjPf/4Tp5dhIKKePXumJ598MnbuGVCIkXhzWH7hhRdih3Dw4MGxfAwkxIBDLAN9KnlemoDutttusZ6c95XXZWd9r732ivPXSiNLc4VlqSkMy5Ikqa1pk+dZvuaaayLUMrDO1VdfnTp37hwhFVSAXn755ajYcm7WI488MgJpuanzU089FWGYii1VKsIoO18E0xNPPDHCaK4mNQaPIQwfeOCBcd5XQjohHI8//ng082S5mT777LO4HVSqjj766LTjjjum66+/Ph1wwAHp9NNPjyoXAb9Lly5p++23j6D8+uuvx3Mff/zx6corr0wbb7xxOvTQQ6urXZIkSZKkltfqYfmJJ56I5shUF7DOOuukN998M5p3gqryXHPNFZdnmWWWqDhzf8ZlqsmnnHJKdfNnjgoQsAm7VH2pLDfVoosuWt1MdNlll43BhGjqyWtwX24yynJnNOekwsz96NatW1RNPv/887he9Nhjj8Xzsp7g9DXo27dv/JUkSZIktbxWD8sET/o0ZjRDRu57mINq1r59++inmB133HHxt/gcnBam+Dj6KTZV8Xl4bfD65dfIy51Rzd5jjz2iesxE89eaWrzTvJvAvNlmm1VPNJHldkmSJElS62j1sMzAOzkYg37J4HYU7wMhtRhMTz311Kjc8jejP3CuTIP+zbWh+lwMsfQxLiq+fj43K69PRTlfRzHcPvPMM9Gk/LDDDkvnnXde9IOmWXhNOnbsmFZZZZVorp2n3r17pxVWWKEyhyRJkiSppbV6WKbZ8d13313dR5dBuhZYYIHqKi79k1988cW4TNNkRtSdZ5554jo4Vcy+++6b+vfvH4N8Ye65506PPvpohGDCL5Xb2jCyLn2mQTDOr5VxPfeRfuCBB6IpOGGZgP7cc89FYOZ1br311pgH9E2m0s0ovQwERr9sBq4ZOnRo3E9wztXx5ZZbLpYvB3qaah911FExwrAkSZIkqXW0eljeYostIoAy4BUjRnPu1IMOOqhyb4pTLDGA19Zbbx1Nrvfff//qqnM2/vjjx4jWF198cerXr1/q0aNHBFxGzuZ2+izXNsoq8xKyGYGbCjD9hwm42eKLLx5Va5aTAM5gX6Dyu8gii6Rtt902de/ePc0+++zxGjyWAEz/6S233DLttNNOacYZZ4zqMYON0eeZ+xmE7Jhjjongv8MOO8Q6Mz9/ec18eh1JkiRJUstr0+dZvu+++6LvLyNhNxahNY+A/fDDD6ebb745Rp1uDEa+pvJMkJdGZXzNPXWU2gpPHSVJktqaNnnqqPo0Jctfe+21ab/99oum3UyEbppNN0ULHkuQJEmSJLURbT4sN8X6668fA2fRdJqm3R06dIim0pIkSZIkNUSbboYtaeSwGbbaEpthS5KktmaUbIYtSZIkSVJLMyxLkiRJklRiWJYkSZIkqcSwLEmSJElSiWFZkiRJkqSSUTYsDxw4MC2//PIxwu+I2GyzzWLksxHx6KOPph9++KFyrXac73nPPff8x+WGaspjGmJkbIMRddFFF6VTTz21ck2jirnnnjvtuOOOafvtt6+eOF0b383xxx+/MlftJpxwwrTTTjs1yyjIXbt2rVySJEmSGm+0ryxfcMEFad55561ca5pevXqlH3/8sXKt+RBAjj/++Mq10c+ff/4Zp0BS28EpqAYMGBCfyzydf/75cd9SSy0Vf+uSD3aN7Pd1ggkmSN26datckyRJkhqv1c+zzM42gbVPnz6xw9ypU6e0zz77pGmmmSbdc8896ZFHHknTTjtt+uijj9L333+fNt1007TGGmtEZXnzzTdPDz30UJyf8/bbb0+33XZbOuecc2IH/KSTTorHTDHFFGmllVZKN9xwQ7ruuusqr/o3qqr/93//F8u1xRZbpI033jg988wzUSkee+yx01FHHZUmn3zy1Ldv33jun376KZ5/ySWXTLvuums65phj0hNPPBHLS4WN288444z06quvRribZZZZ0oEHHpg6dOgQleG77747nqd4uYz1vv766+PxY4wxRqzzmmuuOdxjTjnllDTxxBPHdhg0aFAs73/+858ICDyuZ8+e6cknn0yTTDJJbCdCzLXXXpummmqqyqv8jW2w7rrrpocffjieq0uXLunggw+OZa7r/TnuuONS+/bt07777hvPc+KJJ8bysr71effdd2Mdhg4dmmacccbUsWPHeH7ei6LPP/88bbfddlGxvOqqq9Jll10W613bNn7ggQdi4hyuvMY333yT9t9///gc8Xng/Tv66KPTTDPNVHmF0QPbtjnOszzbbLPF54XPZcbr8PlYYYUV4nOM2WefPc0zzzxRQf7555/jO/b1119H9bl79+7p8ccfT/PNN1985z788MO4n2Wm8sx3is8xCObPP/98rAff+8UWWyw+k+A78PTTT8dniu8xgZnb+N60xMEsNZznWZYkSW1NmzzP8jXXXBMhhurs1VdfnTp37pxOOOGEuI/g9fLLL6dVV101nX322enII49MZ555Zvrqq6/i/uypp56KMHzaaadFkLr88stj54twTIAjfPJc9eExL774YgRtduYIgnfccUfcd95556V11lknlvGKK66I0MVO/RFHHBH304SYyu9NN92UPv300wh2vD7Bgcc0FEHi9NNPj2XgcawTAYCAU8Sy0vyb4Hruueem1VdfPbYhCB5sk0suuSTWg22Yg3dtnn322djGN998c8zLNkRd78/ee+8dj+NAwiuvvJJee+21tMcee8R99eF9WW211SLA8zwsb03YkSbYEYB4LzhwUdc2Zru8/vrraa211ooDBssss0w67LDD4oAA1xdYYIF0yy23xLxqHhNNNFGaf/7508cffxzXp5566rTIIovEe8V7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nHC6nplnnrlyi9Qy+MyNPfbYBmRJktTmtXpY/u2339J5552Xunfvnrbeeut01FFHRTUYxx13XITd7MQTT0wnn3xyXN5ll13S66+/no488sg0YMCA9H//939RYS76+eefIxz36NEjzufZsWPHtPHGG6eHHnqoMoc0eilW8jiItPrqq1fukVrGaqutliaYYILhPouSJEltUauH5WuvvTb17ds3XXTRRenKK69Mk002WTrrrLPivr333js9++yzcf8rr7ySXnvttbTHHnvEfdkRRxwRf0899dS0/PLLx+WMED3OOOOkKaaYonJLSjPMMEP66KOPKtek0UcOJWOMMUZM448/fppzzjnTBhtsELdLzY3P2jzzzBOfvfw5hIFZkiS1Ra0elh9//PG0/vrrx84TNtpoo/TEE0+kP/74I0000URp//33T6effnoE6AMOOCCqYQ1FZZmwXDTeeOPF7dLoJIeRXMmjzyjTJJNMktZYY420zz77pPnmmy/mkUa2bt26xcFPxo7gdz1//vLnEfmvJElSW9FuWAuOdsWAXAsuuGDl2l8YdIvqQjHU/vTTT+myyy6rrghvt912MQ99jjMG+KLpNTv4K620Urr66qtTp06dKvf+pX///mmnnXYartn1yy+/nI4//vjowyyNTviq//nnn+n333+P6ddff43pl19+SUOGDEmDBw+uzCmNXPx+c6CT5tf0V+b3nol+80zcb1iWJEmtqaas2uphmf7E22yzTVpmmWUqtwzvzjvvjL7I7NTT143KBBoSlgkBzH/ppZem6aefPm67+eab03PPPZdOO+20uC6NLviqM9Fqg4nxAvKUAzRhmqkFfxb0L0YAJggz5WBMWM5TTRVmSZKk1tAmwzL9lF999dV0wgknRBNpgizz7b777umzzz6Lvz179owd+r322itGwZ5mmmmqw/L888+fVl555ZhnjjnmqDzr34499tjY8acJ93fffZf222+/COgrrrhiZQ5p9MF3gTCcA3MOyUxcz0E5T1JT5QCcAzOhOAdmphyUrSpLkqS2oE2GZULwJZdckp5++unYUe/QoUPac889U5cuXaIf5VJLLZU22WSTmPeKK66IZtSMkL3FFltEWOb5aFb9zDPPRHNt+jwXcUopBv/q06dPjIi94YYbpq222qpyrzR6KQbhHI5zcC6HZWlElcNyMSDzN99vWJYk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)

Сохраняем изменения и создаём службу автозапуска для **sing-box**.

Создаём файл **/etc/init.d/sing-box** следующего содержания:

```sh
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

```sh
chmod +x /etc/init.d/sing-box
```

После чего добавляем в автозапуск:

```sh
/etc/init.d/sing-box enable
/etc/init.d/sing-box start
```

На этом настройка окончена.

P.S. 35 Мб это достаточно большой объём занимаемой оперативной памяти для роутера со 128 Мб, так что решение что называется на грани.