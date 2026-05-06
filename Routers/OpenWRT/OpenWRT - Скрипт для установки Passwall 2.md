
> установка репозитория и обновление
```bash
cat > /tmp/add-passwall-repo.sh <<'EOF'
#!/bin/sh

SF_BASE="https://downloads.sourceforge.net/project/openwrt-passwall-build"
DL_BASE="$SF_BASE/releases"

echo "== OpenWrt info =="
[ -f /etc/openwrt_release ] && cat /etc/openwrt_release
echo

. /etc/openwrt_release 2>/dev/null

ARCH="${DISTRIB_ARCH:-}"
VERSION="${DISTRIB_RELEASE:-}"

if [ -z "$ARCH" ]; then
  echo "ERROR: DISTRIB_ARCH not found"
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "ERROR: DISTRIB_RELEASE not found"
  exit 1
fi

MAJOR_MINOR="$(echo "$VERSION" | cut -d. -f1,2)"
BASE="$DL_BASE/packages-$MAJOR_MINOR"

echo "Version: $VERSION"
echo "Arch: $ARCH"
echo "Repo branch: packages-$MAJOR_MINOR"
echo "Base: $BASE"
echo

if command -v apk >/dev/null 2>&1; then
  PM="apk"
elif command -v opkg >/dev/null 2>&1; then
  PM="opkg"
else
  echo "ERROR: neither apk nor opkg found"
  exit 1
fi

echo "Package manager: $PM"
echo

check_url() {
  wget -q --spider "$1" 2>/dev/null
}

if [ "$PM" = "apk" ]; then
  echo "== APK mode =="

  KEY_URL="$SF_BASE/apk.pub"
  KEY_FILE="/etc/apk/keys/openwrt-passwall-build.apk.pub"

  mkdir -p /etc/apk/keys

  echo "Downloading apk key..."
  if wget -q -O "$KEY_FILE" "$KEY_URL"; then
    echo "Key saved: $KEY_FILE"
  else
    echo "WARNING: apk key download failed: $KEY_URL"
    rm -f "$KEY_FILE"
  fi

  APK_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section/packages.adb"
    echo "Checking: $URL"

    if check_url "$URL"; then
      APK_FEEDS="$APK_FEEDS
$URL"
    else
      echo "Not found: $URL"
    fi
  done

  if [ -z "$APK_FEEDS" ]; then
    echo
    echo "NOT ADDED: no packages.adb found"
    echo "Checked path: $BASE/$ARCH/"
    exit 2
  fi

  mkdir -p /etc/apk/repositories.d

  FILE="/etc/apk/repositories.d/passwall-sourceforge.list"
  cp "$FILE" "$FILE.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null

  echo "$APK_FEEDS" | sed '/^$/d' > "$FILE"

  echo
  echo "APK feed added:"
  cat "$FILE"
  echo

  LOG="/tmp/passwall-apk-update.log"

  echo "Running apk update..."
  apk update 2>&1 | tee "$LOG"

  if grep -q "UNTRUSTED signature" "$LOG"; then
    echo
    echo "RESULT: repo added, but apk reports UNTRUSTED signature."
    echo "Normal apk search/add will NOT work for this feed."
    echo
    echo "Working commands for this feed:"
    echo "apk update --allow-untrusted"
    echo "apk search --allow-untrusted passwall"
    echo "apk add --allow-untrusted luci-app-passwall2"
    echo
    echo "Optional:"
    echo "apk add --allow-untrusted luci-app-passwall"
    echo "apk add --allow-untrusted luci-i18n-passwall2-ru"
    echo
    echo "Without --allow-untrusted this apk feed cannot be used until the repo signature/key is fixed."
    exit 5
  fi

  echo
  echo "RESULT: apk repo added and trusted."
  echo
  echo "Working commands:"
  echo "apk search passwall"
  echo "apk add luci-app-passwall2"
  echo "apk add luci-app-passwall"
  echo "apk add luci-i18n-passwall2-ru"

  exit 0
fi

if [ "$PM" = "opkg" ]; then
  echo "== OPKG mode =="

  KEY_URL="$SF_BASE/ipk.pub"

  if [ -d /etc/opkg/keys ]; then
    echo "Downloading ipk key..."
    mkdir -p /tmp/passwall-key
    if wget -q -O /tmp/passwall-key/ipk.pub "$KEY_URL"; then
      FINGERPRINT="$(usign -F -p /tmp/passwall-key/ipk.pub 2>/dev/null | awk '{print $1}')"
      if [ -n "$FINGERPRINT" ]; then
        cp /tmp/passwall-key/ipk.pub "/etc/opkg/keys/$FINGERPRINT"
        echo "Key saved: /etc/opkg/keys/$FINGERPRINT"
      else
        echo "WARNING: cannot calculate ipk key fingerprint"
      fi
    else
      echo "WARNING: ipk key download failed: $KEY_URL"
    fi
    rm -rf /tmp/passwall-key
  fi

  OPKG_FEEDS=""

  for section in passwall_packages passwall_luci passwall2; do
    URL="$BASE/$ARCH/$section"
    INDEX="$URL/Packages.gz"

    echo "Checking: $INDEX"

    if check_url "$INDEX"; then
      OPKG_FEEDS="$OPKG_FEEDS
src/gz passwall_$section $URL"
    else
      echo "Not found: $INDEX"
    fi
  done

  if [ -z "$OPKG_FEEDS" ]; then
    echo
    echo "NOT ADDED: no Packages.gz found"
    echo "Checked path: $BASE/$ARCH/"
    exit 3
  fi

  mkdir -p /etc/opkg

  FILE="/etc/opkg/customfeeds.conf"
  cp "$FILE" "$FILE.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null

  grep -v 'openwrt-passwall-build/releases/packages-' "$FILE" 2>/dev/null > /tmp/customfeeds.conf.new
  echo "$OPKG_FEEDS" | sed '/^$/d' >> /tmp/customfeeds.conf.new
  mv /tmp/customfeeds.conf.new "$FILE"

  echo
  echo "OPKG feed added:"
  echo "$OPKG_FEEDS" | sed '/^$/d'
  echo

  LOG="/tmp/passwall-opkg-update.log"

  echo "Running opkg update..."
  opkg update 2>&1 | tee "$LOG"

  if grep -qi "signature check failed\|failed to verify\|public key" "$LOG"; then
    echo
    echo "RESULT: repo added, but opkg signature verification failed."
    echo "Check key/signature for this repo."
    exit 6
  fi

  echo
  echo "RESULT: opkg repo added."
  echo
  echo "Working commands:"
  echo "opkg list | grep -i passwall"
  echo "opkg install luci-app-passwall2"
  echo "opkg install luci-app-passwall"

  exit 0
fi
EOF

chmod +x /tmp/add-passwall-repo.sh
sh /tmp/add-passwall-repo.sh
```