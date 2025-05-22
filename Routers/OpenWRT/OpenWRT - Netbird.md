2025-01-05

[Источник](https://openwrt.org/docs/guide-user/services/vpn/tailscale/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

>Скрипт для установки/настройки/обновления netbird
```shell
#!/bin/sh

icon_info="ℹ️"
icon_pkg="📦"
icon_ok="✅"
icon_dl="⬇️"
icon_url="🌐"
icon_err="❌"
icon_run="🔁"

print_row() {
  printf "%s  %-12s %s\n" "$1" "$2" "$3"
}

add_netbird_interface() {
  if uci show network | grep -q "^network\.netbird="; then
    print_row "$icon_info" "Interface:" "netbird already exists"
  else
    uci set network.netbird="interface"
    uci set network.netbird.proto="none"
    uci set network.netbird.device="wt0"

    if uci commit network; then
      print_row "$icon_ok" "Interface:" "netbird added"
    else
      print_row "$icon_err" "UCI commit:" "Failed to save changes"
      exit 1
    fi

    if /etc/init.d/network reload; then
      print_row "$icon_ok" "Network:" "Reloaded successfully"
    else
      print_row "$icon_err" "Network:" "Reload failed"
      exit 1
    fi
  fi
}

add_netbird_firewall_zone() {
  if uci show firewall | grep -q 'firewall.@zone.*=zone' | grep -q 'name.\+netbird'; then
    print_row "$icon_info" "Firewall:" "Zone 'netbird' already exists"
    return
  fi

  NETBIRD_ZONE=$(uci add firewall zone)
  uci set firewall.$NETBIRD_ZONE="zone"
  uci set firewall.$NETBIRD_ZONE.name="netbird"
  uci set firewall.$NETBIRD_ZONE.input="ACCEPT"
  uci set firewall.$NETBIRD_ZONE.output="ACCEPT"
  uci set firewall.$NETBIRD_ZONE.forward="ACCEPT"
  uci set firewall.$NETBIRD_ZONE.masq="1"
  uci set firewall.$NETBIRD_ZONE.mtu_fix="1"
  uci add_list firewall.$NETBIRD_ZONE.network="netbird"

  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src="netbird"
  uci set firewall.@forwarding[-1].dest="lan"

  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src="lan"
  uci set firewall.@forwarding[-1].dest="netbird"

  if uci commit firewall; then
    print_row "$icon_ok" "Firewall:" "Zone 'netbird' configured"
  else
    print_row "$icon_err" "UCI commit:" "Failed to save firewall config"
    exit 1
  fi

  if /etc/init.d/firewall reload; then
    print_row "$icon_ok" "Firewall:" "Reloaded"
  else
    print_row "$icon_err" "Firewall:" "Reload failed"
    exit 1
  fi
}

install_pkg_if_missing() {
  local pkg="$1"
  if ! opkg status "$pkg" 2>/dev/null | grep -q "Status:.*installed"; then
    print_row "$icon_run" "Installing:" "$pkg"
    opkg install "$pkg" >/dev/null 2>&1 || {
      print_row "$icon_err" "Failed:" "$pkg"
      exit 1
    }
  else
    print_row "$icon_ok" "Present:" "$pkg"
  fi
}

# Основная часть

# Проверка OpenWrt
if [ -f /etc/openwrt_release ] || grep -q 'openwrt' /etc/os-release 2>/dev/null; then
  SYSTEM="OpenWrt"
else
  print_row "$icon_err" "Error:" "Not an OpenWrt system"
  exit 1
fi

print_row "$icon_info" "System:" "$SYSTEM"

# Определяем архитектуру
ARCH_LINE=$(grep -m1 'packages/' /etc/opkg/distfeeds.conf)
ARCH=$(echo "$ARCH_LINE" | sed -n 's#.*/packages/\([^/]*\)/.*#\1#p')
print_row "$icon_pkg" "Arch:" "$ARCH"

# Установка зависимостей
REQUIRED_PKGS="curl iptables-nft kmod-ipt-conntrack kmod-ipt-conntrack-extra kmod-ipt-conntrack-label kmod-nft-nat kmod-ipt-nat ca-bundle kmod-tun"

print_row "$icon_info" "Check:" "Dependencies"
opkg update >/dev/null 2>&1
for pkg in $REQUIRED_PKGS; do
  install_pkg_if_missing "$pkg"
done

# Проверка наличия /dev/net/tun
if [ ! -c /dev/net/tun ]; then
  print_row "$icon_err" "TUN:" "Device not found"
  exit 1
else
  print_row "$icon_ok" "TUN:" "Available"
fi

# Останавливаем службу netbird, если работает
if command -v service >/dev/null 2>&1; then
  STATUS=$(service netbird status 2>/dev/null)
  if echo "$STATUS" | grep -qvi "stopped"; then
    print_row "$icon_run" "Service:" "Stopping netbird..."
    service netbird stop
  fi
fi

# Определяем CPU и FP для выбора бинарника
case "$ARCH" in
  mipsel_24kc) CPU="mipsle"; FP="softfloat" ;;
  mipsel_24kf) CPU="mipsle"; FP="hardfloat" ;;
  mips_24kc)   CPU="mips";   FP="softfloat" ;;
  mips_24kf)   CPU="mips";   FP="hardfloat" ;;
  mips64el*)   CPU="mips64le"; FP="softfloat" ;;
  aarch64* | arm64*) CPU="arm64"; FP="" ;;
  arm*)        CPU="armv6"; FP="" ;;
  x86_64)      CPU="amd64"; FP="" ;;
  *) print_row "$icon_err" "Error:" "Unknown architecture: $ARCH"; exit 1 ;;
esac

# Скачиваем последнюю версию netbird
VERSION=$(curl -s https://api.github.com/repos/netbirdio/netbird/releases/latest | grep '"tag_name":' | cut -d'"' -f4 | sed 's/^v//')
FILENAME="netbird_${VERSION}_linux_${CPU}"
[ -n "$FP" ] && FILENAME="${FILENAME}_${FP}"
FILENAME="${FILENAME}.tar.gz"
URL="https://github.com/netbirdio/netbird/releases/download/v${VERSION}/${FILENAME}"

print_row "$icon_dl" "File:" "$FILENAME"
print_row "$icon_url" "URL:" "$URL"

if [ -f "$FILENAME" ]; then
  ABS_PATH=$(readlink -f "$FILENAME" 2>/dev/null || realpath "$FILENAME" 2>/dev/null || echo "./$FILENAME")
  print_row "$icon_ok" "File exists:" "$ABS_PATH"
else
  if curl -sfI "$URL" > /dev/null; then
    if curl -sLO "$URL"; then
      ABS_PATH=$(readlink -f "$FILENAME" 2>/dev/null || realpath "$FILENAME" 2>/dev/null || echo "./$FILENAME")
      print_row "$icon_ok" "Downloaded:" "$ABS_PATH"
    else
      print_row "$icon_err" "Not download:" "$FILENAME"
      exit 1
    fi
  else
    print_row "$icon_err" "Not found:" "$URL"
    exit 1
  fi
fi

# Распаковываем и устанавливаем бинарник
TAR_DIR=$(mktemp -d)
if tar -xzf "$FILENAME" -C "$TAR_DIR"; then
  print_row "$icon_ok" "Extracted:" "$TAR_DIR"
else
  print_row "$icon_err" "Unpack failed:" "$FILENAME"
  rm -rf "$TAR_DIR"
  exit 1
fi

BIN_SRC=$(find "$TAR_DIR" -type f -name netbird)
if [ -x "$BIN_SRC" ]; then
  cp "$BIN_SRC" /usr/bin/netbird && chmod +x /usr/bin/netbird
  print_row "$icon_ok" "Installed to:" "/usr/bin/netbird"
  rm -rf "$TAR_DIR"
else
  print_row "$icon_err" "Binary not found in archive"
  rm -rf "$TAR_DIR"
  exit 1
fi

# Запускаем службу netbird
if command -v service >/dev/null 2>&1; then
  STATUS=$(service netbird status 2>/dev/null)
  if echo "$STATUS" | grep -qi "stopped"; then
    print_row "$icon_run" "Service:" "Starting netbird..."
    service netbird start
  else
    print_row "$icon_ok" "Service:" "Already running"
  fi
else
  print_row "$icon_err" "Service:" "Command not available"
fi

# Конфигурируем сеть и firewall
add_netbird_interface

if uci show network.netbird.device 2>/dev/null | grep -q 'wt0'; then
  print_row "$icon_ok" "Interface:" "netbird/wt0 found in /etc/config/network"
  add_netbird_firewall_zone
else
  print_row "$icon_err" "Interface:" "netbird/wt0 not found in /etc/config/network, skipping firewall setup"
fi
```