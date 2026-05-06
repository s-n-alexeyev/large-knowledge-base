```bash
cat > /tmp/add-passwall-repo.sh <<'EOF'
#!/bin/sh

BASE="https://downloads.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12"
KEY_URL="https://downloads.sourceforge.net/project/openwrt-passwall-build/apk.pub"
KEY_FILE="/etc/apk/keys/openwrt-passwall-build.apk.pub"

echo "== OpenWrt info =="
[ -f /etc/openwrt_release ] && cat /etc/openwrt_release
echo

. /etc/openwrt_release 2>/dev/null

ARCH="${DISTRIB_ARCH:-}"
VERSION="${DISTRIB_RELEASE:-}"

if [ -z "$ARCH" ]; then
  echo "ОШИБКА: не удалось определить DISTRIB_ARCH из /etc/openwrt_release"
  exit 1
fi

echo "Архитектура OpenWrt: $ARCH"
echo "Версия OpenWrt: ${VERSION:-unknown}"
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
  wget -q -O /dev/null "$1"
}

if [ "$PM" = "apk" ]; then
  echo "== APK: добавляю ключ подписи репозитория =="

  mkdir -p /etc/apk/keys

  if wget -q -O "$KEY_FILE" "$KEY_URL"; then
    echo "Ключ скачан: $KEY_FILE"
  else
    echo "ПРЕДУПРЕЖДЕНИЕ: не удалось скачать ключ:"
    echo "$KEY_URL"
    rm -f "$KEY_FILE"
  fi

  echo
  echo "== Проверяю APK-формат репозитория =="

  APK_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section/packages.adb"
    echo "Проверка: $URL"

    if check_url "$URL"; then
      APK_FEEDS="$APK_FEEDS
$URL"
    fi
  done

  if [ -z "$APK_FEEDS" ]; then
    echo
    echo "НЕ ДОБАВЛЕНО."
    echo "Для apk нужен packages.adb, но по этой архитектуре он не найден."
    echo "Твоя архитектура: $ARCH"
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

  echo "== Выполняю apk update =="
  apk update
  RC="$?"

  echo
  echo "== Проверяю, виден ли luci-app-passwall2 =="
  apk search luci-app-passwall2

  if apk search luci-app-passwall2 | grep -q '^luci-app-passwall2'; then
    echo
    echo "Пакет найден."
    echo "Установить:"
    echo "apk add luci-app-passwall2"
    exit 0
  fi

  echo
  echo "Пакет luci-app-passwall2 не найден через обычный apk search."
  echo "Причина почти наверняка в UNTRUSTED signature: apk не подключил SourceForge feed."
  echo
  echo "Для этого репозитория сейчас рабочий вариант — использовать allow-untrusted:"
  echo
  echo "apk update --allow-untrusted"
  echo "apk add --allow-untrusted luci-app-passwall2"
  echo
  echo "Русский язык, если пакет есть:"
  echo "apk add --allow-untrusted luci-i18n-passwall2-ru"
  echo
  echo "Важно: --allow-untrusted означает установку без доверенной проверки подписи feed'а."

  exit 5
fi

if [ "$PM" = "opkg" ]; then
  echo "== Проверяю OPKG/IPK-формат репозитория =="

  OPKG_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section"
    INDEX="$URL/Packages.gz"
    echo "Проверка: $INDEX"

    if check_url "$INDEX"; then
      OPKG_FEEDS="$OPKG_FEEDS
src/gz passwall_$section $URL"
    fi
  done

  if [ -z "$OPKG_FEEDS" ]; then
    echo
    echo "НЕ ДОБАВЛЕНО."
    echo "Для opkg нужен Packages.gz, но по этой архитектуре он не найден."
    echo "Твоя архитектура: $ARCH"
    echo "Проверенный путь: $BASE/$ARCH/"
    exit 3
  fi

  mkdir -p /etc/opkg

  FILE="/etc/opkg/customfeeds.conf"
  cp "$FILE" "$FILE.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null

  grep -v 'openwrt-passwall-build/releases/packages-25.12' "$FILE" 2>/dev/null > /tmp/customfeeds.conf.new
  echo "$OPKG_FEEDS" | sed '/^$/d' >> /tmp/customfeeds.conf.new
  mv /tmp/customfeeds.conf.new "$FILE"

  echo
  echo "Добавлен OPKG feed:"
  echo "$OPKG_FEEDS" | sed '/^$/d'
  echo

  echo "== Выполняю opkg update =="
  opkg update

  echo
  echo "Готово."
  echo "Проверить пакеты:"
  echo "opkg list | grep -i passwall"
  echo
  echo "Установить PassWall2:"
  echo "opkg install luci-app-passwall2"

  exit 0
fi
EOF

chmod +x /tmp/add-passwall-repo.sh
sh /tmp/add-passwall-repo.sh
```