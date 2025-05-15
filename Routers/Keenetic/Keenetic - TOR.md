
> Обновляем, устанавливаем необходимые пакеты
```bash
opkg update
opkg install tor obfs4 privoxy lyrebird
```

>Редактируем файл `/opt/etc/tor/torrc` (пример базовой настройки)
```r
DataDirectory /opt/var/lib/tor
User tor

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

# === Поиск bridge-интерфейса с IP в локальной сети ===
bridge_iface=$(ip -o -4 addr show | awk '$2 ~ /^br/ && $4 ~ /^192\.168\./ {print $2; exit}')
if [ -z "$bridge_iface" ]; then
    echo "❌ Не удалось найти bridge-интерфейс с локальным IP (192.168.x.x)"
    exit 1
fi

echo "🔍 Обнаружен bridge-интерфейс: $bridge_iface"

# === Получаем CIDR ===
cidr=$(ip -o -4 addr show dev "$bridge_iface" | awk '{print $4}')
[ -z "$cidr" ] && { echo "❌ Не удалось получить IP с интерфейса $bridge_iface"; exit 1; }

ip_address=${cidr%/*}
prefix_len=${cidr#*/}

# === Преобразуем IP и префикс в адрес сети ===
ip_to_dec() {
    
    echo $(( (o1 << 24) + (o2 << 16) + (o3 << 8) + o4 ))
}

dec_to_ip() {
    dec=$1
    echo "$(( (dec >> 24) & 255 )).$(( (dec >> 16) & 255 )).$(( (dec >> 8) & 255 )).$(( dec & 255 ))"
}

netmask=$(( 0xFFFFFFFF << (32 - prefix_len) & 0xFFFFFFFF ))
ip_dec=$(ip_to_dec "$ip_address")
network_dec=$(( ip_dec & netmask ))
network=$(dec_to_ip "$network_dec")
subnet="${network}/${prefix_len}"

echo "✅ Подсеть $bridge_iface: $subnet"

# === Определение окружения по имени хоста ===
hostname=$(uname -n)

if echo "$hostname" | grep -iqE 'entware|keenetic'; then
    ENVIRONMENT="entware"
    PRIVOXY_CONFIG="/opt/etc/privoxy/config"
    PRIVOXY_INIT=$(find /opt/etc/init.d/ -type f -name 'S??privoxy' | head -n1)
    if [ -z "$PRIVOXY_INIT" ]; then
        echo "❌ Не удалось найти init-скрипт privoxy в Entware"
        exit 1
    fi
    RESTART_CMD="$PRIVOXY_INIT restart"
    AUTOSTART_CMD="ln -sf $PRIVOXY_INIT /opt/etc/init.d/rc.custom"
elif echo "$hostname" | grep -iq "openwrt"; then
    ENVIRONMENT="openwrt"
    RESTART_CMD="/etc/init.d/privoxy restart"
    AUTOSTART_CMD="/etc/init.d/privoxy enable"
else
    echo "❌ Не удалось определить окружение по имени хоста"
    exit 1
fi

echo "📦 Обнаружено окружение: $ENVIRONMENT"

# === Обновление конфигурации ===
if [ "$ENVIRONMENT" = "entware" ]; then
    if [ ! -f "$PRIVOXY_CONFIG" ]; then
        echo "❌ Конфигурационный файл Privoxy не найден: $PRIVOXY_CONFIG"
        exit 1
    fi

    # Очистка старых параметров
    sed -i '/^listen-address /d' "$PRIVOXY_CONFIG"
    sed -i '/^permit-access /d' "$PRIVOXY_CONFIG"
    sed -i '/^forward-socks5 /d' "$PRIVOXY_CONFIG"
    sed -i '/^toggle /d' "$PRIVOXY_CONFIG"
    sed -i '/^enable-remote-toggle /d' "$PRIVOXY_CONFIG"
    sed -i '/^enable-edit-actions /d' "$PRIVOXY_CONFIG"
    sed -i '/^enforce-blocks /d' "$PRIVOXY_CONFIG"
    sed -i '/^forwarded-connect-retries /d' "$PRIVOXY_CONFIG"

    # Добавление новых параметров
    cat <<EOF >> "$PRIVOXY_CONFIG"
listen-address  0.0.0.0:8123
permit-access 127.0.0.1
permit-access $subnet
forward-socks5 / 127.0.0.1:9050 .
toggle 1
enable-remote-toggle 0
enable-edit-actions 0
enforce-blocks 0
forwarded-connect-retries 1
EOF

    echo "✅ Конфигурация Privoxy обновлена в $PRIVOXY_CONFIG"

else
    echo "🛠 Обновление конфигурации через UCI..."

    uci -q delete privoxy.@privoxy[0].listen_address
    uci -q delete privoxy.@privoxy[0].permit_access
    uci -q delete privoxy.@privoxy[0].forward_socks5

    uci add_list privoxy.@privoxy[0].listen_address='0.0.0.0:8123'
    uci add_list privoxy.@privoxy[0].permit_access='127.0.0.1'
    uci add_list privoxy.@privoxy[0].permit_access="$subnet"
    uci add_list privoxy.@privoxy[0].forward_socks5='/ 127.0.0.1:9050 .'

    uci commit privoxy

    # Ручное добавление нестандартных параметров
    PRIVOXY_CONFIG="/etc/privoxy/config"
    [ -f "$PRIVOXY_CONFIG" ] && {
        sed -i '/^toggle /d' "$PRIVOXY_CONFIG"
        sed -i '/^enable-remote-toggle /d' "$PRIVOXY_CONFIG"
        sed -i '/^enable-edit-actions /d' "$PRIVOXY_CONFIG"
        sed -i '/^enforce-blocks /d' "$PRIVOXY_CONFIG"
        sed -i '/^forwarded-connect-retries /d' "$PRIVOXY_CONFIG"

        cat <<EOF >> "$PRIVOXY_CONFIG"

toggle 1
enable-remote-toggle 0
enable-edit-actions 0
enforce-blocks 0
forwarded-connect-retries 1
EOF
    }

    echo "✅ Конфигурация обновлена через UCI и вручную"
fi

# === Перезапуск ===
echo "♻ Перезапуск Privoxy..."
eval "$RESTART_CMD" || {
    echo "⚠ Не удалось перезапустить privoxy, пробуем вручную..."
    killall privoxy 2>/dev/null
    sleep 1
    privoxy "$PRIVOXY_CONFIG" &
}

# === Автозапуск ===
echo "🔄 Добавление в автозапуск..."
eval "$AUTOSTART_CMD"

echo "✅ Готово!"

```



>Стартуем сервисы
```bash
/opt/etc/init.d/S28polipo start
/opt/etc/init.d/S35tor start
```

Для точечной настройки в браузере, рекомендую использовать прокси-свитчер плагин `Proxy SwitchyOmega 3`:
- Для [Chromium](https://chromewebstore.google.com/detail/proxy-switchyomega-3-zero/pfnededegaaopdmhkdmcofjmoldfiped?pli=1)  
- Для [Firefox](https://addons.mozilla.org/ru/firefox/addon/zeroomega/)  




