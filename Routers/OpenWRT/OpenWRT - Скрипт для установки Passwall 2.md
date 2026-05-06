
> установка репозитория и обновление
```bash
cat > /tmp/add-passwall-repo.sh <<'EOF'
#!/bin/sh

echo "== OpenWrt info =="
[ -f /etc/openwrt_release ] && cat /etc/openwrt_release
echo

. /etc/openwrt_release 2>/dev/null

ARCH="${DISTRIB_ARCH:-}"
VERSION="${DISTRIB_RELEASE:-}"

if [ -z "$ARCH" ]; then
  echo "ОШИБКА: не удалось определить DISTRIB_ARCH"
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "ОШИБКА: не удалось определить DISTRIB_RELEASE"
  exit 1
fi

MAJOR_MINOR="$(echo "$VERSION" | cut -d. -f1,2)"
BASE="https://downloads.sourceforge.net/project/openwrt-passwall-build/releases/packages-$MAJOR_MINOR"

echo "Версия OpenWrt: $VERSION"
echo "Ветка репозитория: packages-$MAJOR_MINOR"
echo "Архитектура: $ARCH"
echo "BASE: $BASE"
echo

if command -v apk >/dev/null 2>&1; then
  PM="apk"
elif command -v opkg >/dev/null 2>&1; then
  PM="opkg"
else
  echo "ОШИБКА: не найден ни apk, ни opkg"
  exit 1
fi

echo "Менеджер пакетов: $PM"
echo

check_url() {
  wget -q --spider "$1" 2>/dev/null
}

if [ "$PM" = "apk" ]; then
  echo "== APK feed =="

  KEY_URL="https://downloads.sourceforge.net/project/openwrt-passwall-build/apk.pub"
  KEY_FILE="/etc/apk/keys/openwrt-passwall-build.apk.pub"

  mkdir -p /etc/apk/keys

  echo "Скачиваю ключ:"
  echo "$KEY_URL"

  if wget -q -O "$KEY_FILE" "$KEY_URL"; then
    echo "Ключ скачан: $KEY_FILE"
  else
    echo "ПРЕДУПРЕЖДЕНИЕ: ключ не скачался"
    rm -f "$KEY_FILE"
  fi

  APK_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section/packages.adb"
    echo "Проверка: $URL"

    if check_url "$URL"; then
      APK_FEEDS="$APK_FEEDS
$URL"
    else
      echo "Нет: $URL"
    fi
  done

  if [ -z "$APK_FEEDS" ]; then
    echo
    echo "НЕ ДОБАВЛЕНО."
    echo "Для apk не найден packages.adb."
    echo "Проверенный путь: $BASE/$ARCH/"
    exit 2
  fi

  mkdir -p /etc/apk/repositories.d

  FILE="/etc/apk/repositories.d/passwall-sourceforge.list"
  cp "$FILE" "$FILE.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null

  echo "$APK_FEEDS" | sed '/^$/d' > "$FILE"

  echo
  echo "Добавлен APK feed:"
  cat "$FILE"
  echo

  apk update

  echo
  echo "Проверить:"
  echo "apk search passwall"
  echo
  echo "Установить PassWall:"
  echo "apk add luci-app-passwall"
  echo
  echo "Установить PassWall2:"
  echo "apk add luci-app-passwall2"

  exit 0
fi

if [ "$PM" = "opkg" ]; then
  echo "== OPKG feed =="

  OPKG_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section"

    echo "Проверка каталога: $URL"

    if check_url "$URL/Packages.gz"; then
      echo "Найден Packages.gz"
      OPKG_FEEDS="$OPKG_FEEDS
src/gz passwall_$section $URL"
    elif check_url "$URL/Packages"; then
      echo "Найден Packages"
      OPKG_FEEDS="$OPKG_FEEDS
src/gz passwall_$section $URL"
    else
      echo "Нет Packages.gz / Packages: $URL"
    fi
  done

  if [ -z "$OPKG_FEEDS" ]; then
    echo
    echo "НЕ ДОБАВЛЕНО."
    echo "Для opkg не найден Packages.gz или Packages."
    echo "Проверенный путь: $BASE/$ARCH/"
    exit 3
  fi

  mkdir -p /etc/opkg

  FILE="/etc/opkg/customfeeds.conf"
  cp "$FILE" "$FILE.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null

  grep -v 'openwrt-passwall-build/releases/packages-' "$FILE" 2>/dev/null > /tmp/customfeeds.conf.new

  echo "$OPKG_FEEDS" | sed '/^$/d' >> /tmp/customfeeds.conf.new

  mv /tmp/customfeeds.conf.new "$FILE"

  echo
  echo "Добавлен OPKG feed:"
  echo "$OPKG_FEEDS" | sed '/^$/d'
  echo

  opkg update

  echo
  echo "Проверить:"
  echo "opkg list | grep -i passwall"
  echo
  echo "Установить PassWall:"
  echo "opkg install luci-app-passwall"
  echo
  echo "Установить PassWall2:"
  echo "opkg install luci-app-passwall2"

  exit 0
fi
EOF

chmod +x /tmp/add-passwall-repo.sh
sh /tmp/add-passwall-repo.sh
```