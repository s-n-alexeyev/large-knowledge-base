
> Обновляем, устанавливаем необходимые пакеты
```bash
opkg update
opkg install tor obfs4 polipo
```

>Редактируем файл `/opt/etc/tor/torrc` (пример базовой настройки)
```r
DataDirectory /opt/var/lib/tor

SOCKSPort 9050
HTTPTunnelPort 8118

# Меняем на IP своего роутера
SOCKSPort 192.168.1.1:9111
ExcludeNodes {ru}, {ua}, {by}, {kz}  

RunAsDaemon 1
UseBridges 1  
  
ClientTransportPlugin obfs4,webtunnel exec /opt/sbin/obfs4proxy managed
#ClientTransportPlugin obfs4,webtunnel exec /opt/sbin/lyrebird managed

# Эти бриджи в кочестве примера, необходимо получить свои
bridge obfs4 85.215.50.238:10009 CA38DC17CBC7BF8651D9FD0EE42D297F728B2027 cert=f0u6PaGdUpTPd//H6QPVIjgjjL037lLbKz8u9/WYiF3/d43sW/FhDXM9pNFdO9NS7hWUBg iat-mode=0
bridge obfs4 45.133.192.226:5443 93729C1C9965F5D3D20704991030AB212417FC2F cert=ODzkvKxbwFQJXGeAUcSvnOr060w6qRz/rbLQUx65SpNzd3IgZAAX552PIOzsMV8vCe7kTA iat-mode=0
bridge obfs4 65.109.172.40:26101 B2313F3150F1D17C438C9A450B39720BC142E694 cert=4o+I2rET2wZwhm0z5S5a/tOP8Q3IN6KfgASXNcvIqceeBKn75bawiQWTCwNrGSksaLtcEg iat-mode=0
bridge obfs4 142.132.228.40:26712 6C9239B5F684285E6561F0EE680997112163D0C2 cert=yWi6LBrn/Gcq5Kns+IxSqdYpIHfC/7KQNt99bJiIZOKz9dApp6AHo1CWLoA6zJQOCm9bMw iat-mode=0
```

- *вместо `obfs4proxy` можно использовать [`lyrebird`](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird) , будут доступны мосты `webtunnel`*

>Редактируем файл `/opt/etc/polipo/config` (пример базовой настройки)
```r
proxyAddress = "0.0.0.0"    # IPv4 only
proxyPort = 8123

# Меняем на IP подсети своего роутера, например 192.168.50.0
allowedClients = 127.0.0.1, 192.168.1.0/24
socksParentProxy = "localhost:9050"
socksProxyType = socks5
dnsQueryIPv6 = no
dnsUseGethostbyname = yes
```

>Стартуем сервисы
```bash
/opt/etc/init.d/S28polipo start
/opt/etc/init.d/S35tor start
```

Для точечной настройки в браузере, рекомендую использовать прокси-свитчер плагин `Proxy SwitchyOmega 3`:
- Для [Chromium](https://chromewebstore.google.com/detail/proxy-switchyomega-3-zero/pfnededegaaopdmhkdmcofjmoldfiped?pli=1)  
- Для [Firefox](https://addons.mozilla.org/ru/firefox/addon/zeroomega/)  




