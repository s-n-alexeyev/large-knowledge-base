
> Обновляем, устанавливаем необходимые пакеты
```bash
opkg update
opkg install tor obfs4 privoxy lyrebird
```

>Редактируем файл `/opt/etc/tor/torrc` (пример базовой настройки)
```r
DataDirectory /opt/var/lib/tor

SOCKSPort 9050
HTTPTunnelPort 8118

# Меняем на IP своего роутера
# SOCKSPort 192.168.1.1:9111
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

> Скрип для настройки privoxy
```shell
#!/bin/sh

# Жёстко заданный LAN-интерфейс
interface="br0"

# Получаем CIDR (например, 192.168.1.100/24)
cidr=$(ip -o -4 addr show dev "$interface" | awk '{print $4}')
[ -z "$cidr" ] && { echo "❌ Не удалось получить IP с интерфейса $interface"; exit 1; }

ip_address=${cidr%/*}
prefix_len=${cidr#*/}

# Преобразуем префикс в маску
prefix_to_netmask() {
    local p=$1
    local mask=""
    for i in 1 2 3 4; do
        if [ "$p" -ge 8 ]; then
            mask="${mask}255"
            p=$((p - 8))
        else
            mask="${mask}$((256 - 2 ** (8 - p)))"
            p=0
        fi
        [ "$i" -lt 4 ] && mask="${mask}."
    done
    echo "$mask"
}

netmask=$(prefix_to_netmask "$prefix_len")

# Получаем подсеть
network=$(ipcalc -n "$ip_address" "$netmask" | awk -F= '/NETWORK/ {print $2}')
subnet="${network}/${prefix_len}"

echo "✅ Подсеть br0: $subnet"

# Обновляем конфиг Privoxy
PRIVOXY_CONFIG="/opt/etc/privoxy/config"
sed -i '/^permit-access /d' "$PRIVOXY_CONFIG"
echo "permit-access $subnet" >> "$PRIVOXY_CONFIG"
echo "✅ permit-access $subnet добавлен в $PRIVOXY_CONFIG"

# Перезапуск Privoxy
if pidof privoxy >/dev/null; then
    killall privoxy
    sleep 1
fi
/opt/etc/init.d/Sxxprivoxy start 2>/dev/null || /opt/sbin/privoxy "$PRIVOXY_CONFIG" &

echo "✅ Privoxy перезапущен"

```



>Стартуем сервисы
```bash
/opt/etc/init.d/S28polipo start
/opt/etc/init.d/S35tor start
```

Для точечной настройки в браузере, рекомендую использовать прокси-свитчер плагин `Proxy SwitchyOmega 3`:
- Для [Chromium](https://chromewebstore.google.com/detail/proxy-switchyomega-3-zero/pfnededegaaopdmhkdmcofjmoldfiped?pli=1)  
- Для [Firefox](https://addons.mozilla.org/ru/firefox/addon/zeroomega/)  




