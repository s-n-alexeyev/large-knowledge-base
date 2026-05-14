
> установка репозитория и обновление для любой версии и архитектуры
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

> скрипт для установки на 25 версию OpenWrt

```bash
rm -f /tmp/pw.sh  
wget -qO /tmp/pw.sh "[https://gist.githubusercontent.com/zonetx/15ca9f18ec2a44a24b034dca28375857/raw/install.sh?t=$(date](https://gist.githubusercontent.com/zonetx/15ca9f18ec2a44a24b034dca28375857/raw/install.sh?t=$\(date) +%s)"  
sh /tmp/pw.sh
```

>сам скрипт, взят по [ссылке](https://gist.githubusercontent.com/zonetx/15ca9f18ec2a44a24b034dca28375857/raw/install.sh?t=$(date%20+%s))
```bash
#!/bin/sh
# ==============================================================================
# Passwall 2 + Argon for OpenWrt (APK-only)
# GPT+Claude v2
# Target:  OpenWrt 25.12+ with apk
# Shell:   BusyBox / ash (POSIX)
#
# Изменения относительно v1:
#   - wget больше не глушится через 2>/dev/null (видимый прогресс/ошибки)
#   - скачивание через temp-файл с атомарным mv (как у ChatGPT)
#   - упрощён цикл перебора зеркал без IFS-гимнастики
#   - retry для apk add базовых пакетов (3 попытки)
#   - дополнительная проверка распакованного ZIP (не пустой, .apk есть)
#   - уникальный BACKUP_ROOT через timestamp+PID (избегает коллизий)
#   - флаг INSECURE_HTTPS=1 для роутеров со сбитым временем
#   - различные exit codes: 1 fatal error, 2 rollback done, 130+ signals
# ==============================================================================

SCRIPT_VERSION="gpt+claude v4"

set -eu
umask 022

# -----------------------------
# User options (env overrides)
# -----------------------------
INSTALL_ARGON="${INSTALL_ARGON:-1}"
APPLY_SYSTEM_TUNING="${APPLY_SYSTEM_TUNING:-0}"
AUTO_REBOOT="${AUTO_REBOOT:-0}"
STRICT_APK_UPDATE="${STRICT_APK_UPDATE:-0}"
ROLLBACK_PACKAGES_ON_FAIL="${ROLLBACK_PACKAGES_ON_FAIL:-1}"
INSECURE_HTTPS="${INSECURE_HTTPS:-0}"   # 1 = --no-check-certificate (если время сбито)

TIMEZONE_NAME="${TIMEZONE_NAME:-Europe/Moscow}"
TIMEZONE_STRING="${TIMEZONE_STRING:-MSK-3}"

ENABLE_PACKET_STEERING="${ENABLE_PACKET_STEERING:-1}"
ENABLE_FLOW_OFFLOADING="${ENABLE_FLOW_OFFLOADING:-1}"
ENABLE_HW_FLOW_OFFLOADING="${ENABLE_HW_FLOW_OFFLOADING:-0}"

MIN_FREE_KB="${MIN_FREE_KB:-25000}"

# GitHub-прокси пробуется первым, до встроенных зеркал.
GITHUB_PROXY_PREFIX="${GITHUB_PROXY_PREFIX:-}"

# -----------------------------
# Paths
# -----------------------------
LOCKDIR="/tmp/passwall_install.lock"
LOCKPID="$LOCKDIR/pid"
WORKDIR="/tmp/passwall_install.$$"
PW_DIR="$WORKDIR/passwall2"
ARGON_DIR="$WORKDIR/argon"

# Уникальный бэкап: timestamp + PID гарантирует уникальность даже при
# параллельных запусках с секундной точностью и при отсутствии date (редко).
_TS="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo manual)"
BACKUP_ROOT="/root/passwall2-backup-${_TS}-$$"
BACKUP_DIR="$BACKUP_ROOT/config"

BEFORE_PKGS="$WORKDIR/before_pkgs.txt"
AFTER_PKGS="$WORKDIR/after_pkgs.txt"
NEW_PKGS="$WORKDIR/new_pkgs.txt"

# -----------------------------
# State
# -----------------------------
ROLLBACK_NEEDED=0
DNSMASQ_WAS_REMOVED=0
OWN_LOCK=0
SNAPSHOT_DONE=0

# -----------------------------
# UI
# -----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { printf '%b\n' "${GREEN}[INFO] $*${NC}"; }
warn() { printf '%b\n' "${YELLOW}[WARN] $*${NC}"; }
die()  { printf '%b\n' "${RED}[FATAL] $*${NC}" >&2; exit 1; }

# -----------------------------
# GitHub mirrors (пробуются в порядке)
# -----------------------------
_BUILTIN_MIRRORS="
https://ghfast.top/
https://gh-proxy.com/
https://ghproxy.net/
"

# -----------------------------
# Cleanup / rollback
# -----------------------------
cleanup() {
    rm -rf "$WORKDIR"
    if [ "$OWN_LOCK" -eq 1 ]; then
        rm -rf "$LOCKDIR"
    fi
}

backup_config_file() {
    _name="$1"
    if [ -f "/etc/config/$_name" ]; then
        cp -fp "/etc/config/$_name" "$BACKUP_DIR/$_name" \
            || die "Не удалось сохранить резервную копию /etc/config/$_name"
    fi
}

restore_config_file() {
    _name="$1"
    if [ -f "$BACKUP_DIR/$_name" ]; then
        cp -fp "$BACKUP_DIR/$_name" "/etc/config/$_name" \
            || warn "Не удалось восстановить /etc/config/$_name"
    fi
}

snapshot_installed_packages() {
    apk info 2>/dev/null | sort -u > "$BEFORE_PKGS" 2>/dev/null || return 0
    SNAPSHOT_DONE=1
}

rollback_new_packages() {
    [ "$ROLLBACK_PACKAGES_ON_FAIL" = "1" ] || return 0
    [ "$SNAPSHOT_DONE" -eq 1 ] || return 0
    [ -f "$BEFORE_PKGS" ] || return 0

    apk info 2>/dev/null | sort -u > "$AFTER_PKGS" 2>/dev/null || return 0
    grep -Fxv -f "$BEFORE_PKGS" "$AFTER_PKGS" > "$NEW_PKGS" 2>/dev/null || true

    if [ ! -s "$NEW_PKGS" ]; then
        return 0
    fi

    warn "Откат пакетов: удаляю новые пакеты, добавленные во время установки..."
    while IFS= read -r _pkg; do
        [ -n "$_pkg" ] || continue
        apk del "$_pkg" >/dev/null 2>&1 || true
    done < "$NEW_PKGS"
}

rollback() {
    [ "$ROLLBACK_NEEDED" -eq 1 ] || return 0
    warn "Откат: восстанавливаю системные конфиги..."
    restore_config_file system
    restore_config_file network
    restore_config_file firewall
    restore_config_file luci

    if [ "$DNSMASQ_WAS_REMOVED" -eq 1 ] \
        && ! pkg_installed dnsmasq \
        && ! pkg_installed dnsmasq-full
    then
        warn "Пытаюсь восстановить удалённый dnsmasq..."
        apk add dnsmasq >/dev/null 2>&1 \
            || warn "Не удалось восстановить dnsmasq! Настрой DNS/DHCP вручную."
    fi

    rollback_new_packages

    service_do dnsmasq  restart
    service_do uhttpd   restart
    service_do network  reload
    service_do firewall restart
}

on_exit() {
    _rc=$?
    trap - EXIT INT TERM QUIT HUP
    if [ "$_rc" -ne 0 ]; then
        rollback
    fi
    cleanup
    exit "$_rc"
}

on_signal() {
    trap - EXIT INT TERM QUIT HUP
    warn "Прерван сигналом, откатываю изменения..."
    rollback
    cleanup
    exit "$1"
}

trap on_exit EXIT
trap 'on_signal 130' INT
trap 'on_signal 143' TERM
trap 'on_signal 131' QUIT
trap 'on_signal 129' HUP

# -----------------------------
# Helpers
# -----------------------------
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Не найдена команда: $1"
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

pkg_installed() {
    apk info -e "$1" >/dev/null 2>&1
}

service_do() {
    _name="$1"
    _action="$2"
    if [ -x "/etc/init.d/$_name" ]; then
        "/etc/init.d/$_name" "$_action" >/dev/null 2>&1 || true
    fi
}

set_uci_quiet() {
    uci -q set "$1" || true
}

acquire_lock() {
    if mkdir "$LOCKDIR" 2>/dev/null; then
        OWN_LOCK=1
        echo "$$" > "$LOCKPID"
        return 0
    fi
    _old_pid=""
    [ -f "$LOCKPID" ] && _old_pid="$(cat "$LOCKPID" 2>/dev/null || true)"
    if [ -n "$_old_pid" ] && [ -d "/proc/$_old_pid" ]; then
        die "Скрипт уже запущен (PID $_old_pid). Lock: $LOCKDIR"
    fi
    warn "Обнаружен устаревший lock (PID=${_old_pid:-?}). Удаляю."
    rm -rf "$LOCKDIR" || die "Не удалось удалить устаревший lock."
    mkdir "$LOCKDIR" 2>/dev/null || die "Не удалось создать lock: $LOCKDIR"
    OWN_LOCK=1
    echo "$$" > "$LOCKPID"
}

is_html_stub() {
    # Ищем HTML-сигнатуры в первых 1024 байт.
    # Флаг -a заставляет grep обрабатывать файл как текст (важно для бинарных
    # файлов с null-байтами — иначе grep пропускает их после первого null).
    head -c 1024 "$1" 2>/dev/null | grep -qaiE '<html|<!doctype|<body|access denied|not found|rate limit'
}

validate_zip() {
    # Для .zip архивов — unzip -tqq авторитетно проверяет целостность.
    [ -s "$1" ] || return 1
    is_html_stub "$1" && return 1
    unzip -tqq "$1" >/dev/null 2>&1
}

validate_apk_pkg() {
    # Alpine APK — это tar.gz с подписью, не ZIP. Проверяем:
    # 1) размер разумный (>= 16KB, меньше — почти наверняка HTML-заглушка)
    # 2) нет HTML-маркеров в первых 1024 байтах
    # Этого достаточно — если прокси/CDN отдали не то, любая из проверок сработает.
    [ -s "$1" ] || return 1
    _size="$(wc -c < "$1" 2>/dev/null | tr -d ' ')"
    case "$_size" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "$_size" -ge 16384 ] || return 1
    is_html_stub "$1" && return 1
    return 0
}

validate_release_json() {
    [ -s "$1" ] || return 1
    is_html_stub "$1" && return 1
    grep -q '"tag_name"' "$1" 2>/dev/null || return 1
    grep -q '"browser_download_url"' "$1" 2>/dev/null || return 1
    return 0
}

# -----------------------------
# HTTP fetcher
# -----------------------------
# Download-to-temp pattern:
#   1) качаем в $OUT.part
#   2) проверяем валидатором
#   3) атомарно mv в $OUT только если всё ок
# Так в $OUT никогда не лежит битый файл — важно для post-check и диагностики.
_download_single() {
    _url="$1"
    _out="$2"
    _validator="$3"
    _tmp="${_out}.part"

    rm -f "$_tmp"

    # НЕ глушим stderr (в отличие от v1): busybox wget на OpenWrt иногда
    # ведёт себя иначе с -q vs без него, а видимый прогресс помогает понять
    # что происходит на нестабильной сети.
    _wget_opts="-T 30 -O"
    if [ "$INSECURE_HTTPS" = "1" ] && have_cmd wget; then
        _wget_opts="--no-check-certificate $_wget_opts"
    fi

    if have_cmd wget; then
        # shellcheck disable=SC2086
        wget $_wget_opts "$_tmp" "$_url" || {
            rm -f "$_tmp"
            return 1
        }
    elif have_cmd uclient-fetch; then
        uclient-fetch -T 30 -O "$_tmp" "$_url" || {
            rm -f "$_tmp"
            return 1
        }
    else
        die "Нужен wget или uclient-fetch"
    fi

    if [ ! -s "$_tmp" ]; then
        rm -f "$_tmp"
        return 1
    fi

    # КРИТИЧНО: busybox wget может вернуть exit 0 при SSL EOF в середине
    # передачи, если какие-то байты уже получены. Валидатор ловит это.
    if [ -n "$_validator" ]; then
        if ! "$_validator" "$_tmp"; then
            rm -f "$_tmp"
            return 1
        fi
    fi

    # Атомарное переименование — финальный файл существует только в целом виде.
    mv -f "$_tmp" "$_out" || {
        rm -f "$_tmp"
        return 1
    }
    return 0
}

_try_source() {
    _url="$1"
    _out="$2"
    _validator="$3"
    _max="$4"

    info "Источник: $_url"
    _try=1
    while [ "$_try" -le "$_max" ]; do
        if _download_single "$_url" "$_out" "$_validator"; then
            return 0
        fi
        warn "Попытка $_try/$_max не удалась."
        if [ "$_try" -eq "$_max" ]; then
            break
        fi
        _try=$((_try + 1))
        sleep $((_try))
    done
    return 1
}

fetch_file() {
    # usage: fetch_file URL OUTFILE [VALIDATOR]
    _url="$1"
    _out="$2"
    _validator="${3:-}"

    # 1) Пробуем оригинальный URL (3 попытки).
    if _try_source "$_url" "$_out" "$_validator" 3; then
        return 0
    fi

    # 2) Зеркала — только для релизов github.com, не для api.github.com.
    case "$_url" in
        https://github.com/*)
            warn "Оригинальный GitHub недоступен, пробую зеркала..."
            # Упрощённый цикл: пробуем прокси по одному, без IFS-танцев.
            # Пользовательский prefix — первый.
            if [ -n "$GITHUB_PROXY_PREFIX" ]; then
                if _try_source "${GITHUB_PROXY_PREFIX}${_url}" "$_out" "$_validator" 3; then
                    return 0
                fi
            fi
            # Встроенные зеркала — каждое на отдельной строке в heredoc.
            echo "$_BUILTIN_MIRRORS" | while IFS= read -r _m; do
                [ -n "$_m" ] || continue
                # Важно: _try_source внутри pipe | while работает в subshell,
                # поэтому возврат кода — единственный способ передать успех.
                if _try_source "${_m}${_url}" "$_out" "$_validator" 3; then
                    exit 0   # exit 0 ИЗ SUBSHELL (pipe)
                fi
            done
            # Проверяем код subshell. 0 = одно из зеркал сработало.
            if [ "$?" -eq 0 ] && [ -s "$_out" ]; then
                return 0
            fi
            ;;
    esac

    rm -f "$_out"
    return 1
}

# -----------------------------
# JSON parsing
# -----------------------------
json_first_asset_url() {
    _file="$1"
    _pat="$2"
    tr ',{}' '\n' < "$_file" \
        | grep '"browser_download_url"' \
        | sed -n 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        | grep -E "$_pat" \
        | head -n 1
}

json_find_tag() {
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -n1
}

diagnose_json_failure() {
    _file="$1"
    _what="$2"

    warn "--- Диагностика для '$_what' ---"
    _size="$(wc -c < "$_file" 2>/dev/null || echo 0)"
    warn "Размер JSON: ${_size} байт"

    if grep -q '"message"[[:space:]]*:[[:space:]]*"[^"]*[Rr]ate limit' "$_file" 2>/dev/null; then
        warn "GitHub API вернул RATE LIMIT. Подожди час или используй VPN."
    elif grep -q '"message"[[:space:]]*:[[:space:]]*"Not Found"' "$_file" 2>/dev/null; then
        warn "GitHub API вернул 'Not Found'. URL репозитория мог измениться."
    elif grep -q '"message"[[:space:]]*:' "$_file" 2>/dev/null; then
        _msg="$(sed -n 's/.*"message"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$_file" | head -1)"
        warn "GitHub API вернул ошибку: $_msg"
    fi

    _count="$(tr ',{}' '\n' < "$_file" 2>/dev/null | grep -c '"browser_download_url"' || true)"
    warn "Найдено browser_download_url: ${_count:-0}"

    warn "Первые 300 байт ответа:"
    head -c 300 "$_file" 2>/dev/null | sed 's/^/    /' >&2 || true
    printf '\n' >&2
    warn "Полный JSON: $_file"
    warn "--- Конец диагностики ---"
}

print_sha256() {
    if have_cmd sha256sum; then
        _s="$(sha256sum "$1" 2>/dev/null | awk '{print $1}')"
        [ -n "$_s" ] && info "SHA256 $(basename "$1"): $_s"
    fi
}

# -----------------------------
# Package installation
# -----------------------------
install_apks_from_dir() {
    _dir="$1"
    OLDIFS="$IFS"
    IFS='
'
    set --
    for _apk in $(find "$_dir" -type f -name '*.apk' | sort); do
        [ -n "$_apk" ] || continue
        set -- "$@" "$_apk"
    done
    IFS="$OLDIFS"

    [ "$#" -gt 0 ] || return 1
    info "Устанавливаю $# пакетов из $_dir"
    apk add --allow-untrusted "$@" || return 1
}

verify_required_package() {
    pkg_installed "$1" || die "Не установлен обязательный пакет: $1"
}

# apk add с ретраями — на случай сетевых флапов при скачивании пакетов.
apk_add_with_retry() {
    _try=1
    _max=3
    while [ "$_try" -le "$_max" ]; do
        if apk add "$@"; then
            return 0
        fi
        warn "apk add не удался (попытка $_try/$_max)."
        if [ "$_try" -eq "$_max" ]; then
            break
        fi
        _try=$((_try + 1))
        sleep $((_try * 2))
    done
    return 1
}

apk_update_with_retry() {
    _try=1
    while [ "$_try" -le 3 ]; do
        if apk update; then
            return 0
        fi
        warn "apk update не удался (попытка $_try/3)."
        if [ "$_try" -eq 3 ]; then
            break
        fi
        _try=$((_try + 1))
        sleep $((_try * 2))
    done

    if [ "$STRICT_APK_UPDATE" = "1" ]; then
        return 1
    fi

    _pkg_count="$(apk list 2>/dev/null | wc -l)"
    case "$_pkg_count" in
        ''|*[!0-9]*) _pkg_count=0 ;;
    esac
    if [ "$_pkg_count" -ge 1000 ]; then
        warn "Часть репозиториев не обновилась, но в индексе $_pkg_count пакетов — продолжаю."
        warn "Если установка упадёт на отсутствующих зависимостях — повтори скрипт позже."
        return 0
    fi

    warn "В индексе слишком мало пакетов ($_pkg_count) — apk update провалился."
    return 1
}

# -----------------------------
# 1. Prechecks
# -----------------------------
info "Запускаю Passwall 2 installer (${SCRIPT_VERSION})."

[ "$(id -u)" -eq 0 ] || die "Запускай от root."

require_cmd apk
require_cmd uci
require_cmd grep
require_cmd sed
require_cmd find
require_cmd awk
require_cmd tr
require_cmd head
require_cmd sort
require_cmd mv
have_cmd wget || have_cmd uclient-fetch \
    || die "Нужен wget или uclient-fetch (ни того ни другого не нашёл)."

[ -r /etc/os-release ] && grep -q '^OPENWRT_ARCH=' /etc/os-release 2>/dev/null \
    || die "Скрипт рассчитан на APK-based OpenWrt (нужен /etc/os-release с OPENWRT_ARCH)."

acquire_lock
mkdir -p "$PW_DIR" "$ARGON_DIR" "$BACKUP_DIR"

# Свободное место: сначала /overlay (лимитирующий), затем fallback /.
_FREE_DEV="/overlay"
AVAILABLE_KB="$(df -k "$_FREE_DEV" 2>/dev/null | awk 'END {print $(NF-2)}')"
case "$AVAILABLE_KB" in
    ''|*[!0-9]*)
        _FREE_DEV="/"
        AVAILABLE_KB="$(df -k / | awk 'END {print $(NF-2)}')"
        ;;
esac
case "$AVAILABLE_KB" in
    ''|*[!0-9]*) die "Некорректное значение свободного места: '$AVAILABLE_KB'" ;;
esac

info "Свободно ${AVAILABLE_KB} KB в ${_FREE_DEV}; минимум ${MIN_FREE_KB} KB."
[ "$AVAILABLE_KB" -ge "$MIN_FREE_KB" ] || die "Недостаточно места."

ARCH=""
if [ -r /etc/os-release ]; then
    ARCH="$(grep '^OPENWRT_ARCH=' /etc/os-release | sed 's/^OPENWRT_ARCH=//; s/^"//; s/"$//')"
fi
if [ -z "$ARCH" ]; then
    ARCH="$(apk --print-arch 2>/dev/null || true)"
fi
[ -n "$ARCH" ] || die "Не удалось определить архитектуру OpenWrt."
info "Архитектура: $ARCH"

# -----------------------------
# 2. Snapshot & backup
# -----------------------------
info "Снимок установленных пакетов (для отката)..."
snapshot_installed_packages

info "Резервная копия /etc/config/ в $BACKUP_ROOT"
backup_config_file system
backup_config_file network
backup_config_file firewall
backup_config_file luci
ROLLBACK_NEEDED=1

# -----------------------------
# 3. Time sync (soft)
# -----------------------------
# HTTPS на только что загруженном роутере часто падает на "certificate not yet
# valid" — время-то 1970-й год. Просим sysntpd синхронизировать.
if [ -x /etc/init.d/sysntpd ]; then
    info "Синхронизирую время..."
    service_do sysntpd enable
    service_do sysntpd restart
    sleep 3
fi

# -----------------------------
# 4. apk update
# -----------------------------
info "Обновляю индекс apk..."
apk_update_with_retry || die "apk update завершился ошибкой."

# -----------------------------
# 5. Minimal packages + HTTPS precheck
# -----------------------------
info "Ставлю минимальные пакеты для HTTPS и распаковки..."
apk_add_with_retry ca-bundle unzip || die "Не удалось установить ca-bundle/unzip."

info "Проверяю HTTPS-доступ к GitHub..."
_https_ok=0
_i=1
while [ "$_i" -le 5 ]; do
    if _download_single "https://api.github.com/" "/tmp/_github_probe.$$" ""; then
        _https_ok=1
        rm -f "/tmp/_github_probe.$$"
        break
    fi
    rm -f "/tmp/_github_probe.$$" "/tmp/_github_probe.$$.part"
    warn "HTTPS к api.github.com не удался (попытка $_i/5)."
    _i=$((_i + 1))
    sleep 2
done
if [ "$_https_ok" -ne 1 ]; then
    warn "----------------------------------------------------------------"
    warn "Не удалось достучаться до api.github.com по HTTPS."
    warn "Чаще всего это значит что провайдер/DPI режет TLS-соединения."
    warn "Что можно попробовать:"
    warn "  1) Поменять DNS на роутере:"
    warn "     uci set network.wan.peerdns=0"
    warn "     uci add_list network.wan.dns='1.1.1.1'"
    warn "     uci add_list network.wan.dns='8.8.8.8'"
    warn "     uci commit network; /etc/init.d/network restart"
    warn "  2) Подождать 10-20 минут и запустить скрипт заново."
    warn "  3) Указать свой прокси:"
    warn "     GITHUB_PROXY_PREFIX=https://your-proxy/ sh /tmp/pw.sh"
    warn "  4) Если время сбито (не синхронизировалось): INSECURE_HTTPS=1 sh /tmp/pw.sh"
    warn "  5) Скачать пакеты вручную на ПК и залить через scp."
    warn "----------------------------------------------------------------"
    die "Нет HTTPS-доступа к GitHub после установки ca-bundle."
fi
info "HTTPS к GitHub работает."

# -----------------------------
# 6. Base packages
# -----------------------------
if pkg_installed dnsmasq && ! pkg_installed dnsmasq-full; then
    info "Удаляю стандартный dnsmasq (конфликт с dnsmasq-full)..."
    if apk del dnsmasq >/dev/null 2>&1; then
        DNSMASQ_WAS_REMOVED=1
    else
        warn "Не удалось удалить dnsmasq; продолжаю."
    fi
fi

info "Ставлю базовые пакеты..."
apk_add_with_retry luci kmod-nft-socket kmod-nft-tproxy dnsmasq-full \
    || die "Не удалось установить базовые пакеты."

if ! pkg_installed luci-ssl; then
    apk_add_with_retry luci-ssl >/dev/null 2>&1 \
        || warn "luci-ssl не установлен, продолжаю без него."
fi

DNSMASQ_WAS_REMOVED=0

# -----------------------------
# 7. Passwall 2
# -----------------------------
PASSWALL_JSON="$PW_DIR/latest_passwall.json"

info "Получаю актуальный релиз Passwall 2..."
fetch_file \
    "https://api.github.com/repos/Openwrt-Passwall/openwrt-passwall2/releases/latest" \
    "$PASSWALL_JSON" \
    || die "Не удалось получить JSON релиза Passwall 2."

# Сохраним копию для диагностики (переживёт cleanup при die).
cp -f "$PASSWALL_JSON" "/tmp/passwall2_api_response.json" 2>/dev/null || true

if ! validate_release_json "$PASSWALL_JSON"; then
    diagnose_json_failure "$PASSWALL_JSON" "Passwall 2 release JSON"
    die "GitHub API вернул некорректный ответ. Копия: /tmp/passwall2_api_response.json"
fi

PW_TAG="$(json_find_tag "$PASSWALL_JSON")"
[ -n "$PW_TAG" ] && info "Релиз Passwall 2: $PW_TAG"

PW_APK_URL="$(json_first_asset_url "$PASSWALL_JSON" '/luci-app-passwall2(-|_).*[.]apk$')"
PW_ZIP_URL="$(json_first_asset_url "$PASSWALL_JSON" "/passwall_packages_apk_${ARCH}[.]zip$")"

if [ -z "$PW_APK_URL" ]; then
    diagnose_json_failure "$PASSWALL_JSON" "Passwall 2 APK"
    die "Не найден APK Passwall 2 в последнем релизе."
fi

if [ -z "$PW_ZIP_URL" ]; then
    diagnose_json_failure "$PASSWALL_JSON" "passwall_packages_apk_${ARCH}.zip"
    die "Не найден архив зависимостей passwall_packages_apk_${ARCH}.zip (возможно архитектура '$ARCH' не поддерживается)."
fi

info "Нашёл APK: $PW_APK_URL"
info "Нашёл ZIP: $PW_ZIP_URL"

info "Скачиваю Passwall 2 APK..."
fetch_file "$PW_APK_URL" "$PW_DIR/luci-app-passwall2.apk" validate_apk_pkg \
    || die "Не удалось скачать luci-app-passwall2.apk ни с GitHub, ни с зеркал."
print_sha256 "$PW_DIR/luci-app-passwall2.apk"

info "Скачиваю архив зависимостей Passwall 2..."
fetch_file "$PW_ZIP_URL" "$PW_DIR/passwall_packages.zip" validate_zip \
    || die "Не удалось скачать архив зависимостей Passwall 2 ни с GitHub, ни с зеркал."
print_sha256 "$PW_DIR/passwall_packages.zip"

# Финальная проверка перед распаковкой (paranoid, но дёшево).
validate_zip "$PW_DIR/passwall_packages.zip" \
    || die "Архив зависимостей повреждён после скачивания (не прошёл финальную проверку)."

mkdir -p "$PW_DIR/pkgs"
unzip -q -o "$PW_DIR/passwall_packages.zip" -d "$PW_DIR/pkgs" \
    || die "Не удалось распаковать зависимости Passwall 2."

# Проверяем что в архиве действительно есть .apk-файлы
_apk_count="$(find "$PW_DIR/pkgs" -type f -name '*.apk' | wc -l)"
if [ "$_apk_count" -lt 1 ]; then
    die "В распакованном архиве зависимостей нет .apk-файлов (архив пустой или другого формата)."
fi
info "В архиве зависимостей: $_apk_count пакетов"

info "Ставлю зависимости Passwall 2..."
install_apks_from_dir "$PW_DIR/pkgs" \
    || die "Не удалось установить зависимости Passwall 2."

info "Ставлю / обновляю luci-app-passwall2..."
apk add --allow-untrusted "$PW_DIR/luci-app-passwall2.apk" \
    || die "Не удалось установить luci-app-passwall2."

# -----------------------------
# 8. Argon (soft)
# -----------------------------
if [ "$INSTALL_ARGON" = "1" ]; then
    info "Пробую установить luci-theme-argon из репозитория..."
    if apk add luci-theme-argon >/dev/null 2>&1; then
        info "Argon установлен из репозитория."
    else
        warn "В репозитории Argon нет, качаю релиз с GitHub..."
        ARGON_JSON="$ARGON_DIR/latest_argon.json"

        if fetch_file \
            "https://api.github.com/repos/jerrykuku/luci-theme-argon/releases/latest" \
            "$ARGON_JSON"
        then
            if validate_release_json "$ARGON_JSON"; then
                ARGON_APK_URL="$(json_first_asset_url "$ARGON_JSON" '/luci-theme-argon(-|_).*[.]apk$')"
                ARGON_ZIP_URL="$(json_first_asset_url "$ARGON_JSON" '/luci-theme-argon(-|_).*[.]zip$')"

                if [ -n "$ARGON_APK_URL" ]; then
                    info "Скачиваю Argon APK..."
                    if fetch_file "$ARGON_APK_URL" "$ARGON_DIR/luci-theme-argon.apk" validate_apk_pkg; then
                        apk add --allow-untrusted "$ARGON_DIR/luci-theme-argon.apk" \
                            || warn "Не удалось установить Argon APK (пропускаю)."
                    else
                        warn "Не удалось скачать APK Argon (пропускаю)."
                    fi
                elif [ -n "$ARGON_ZIP_URL" ]; then
                    info "Скачиваю Argon ZIP..."
                    if fetch_file "$ARGON_ZIP_URL" "$ARGON_DIR/argon.zip" validate_zip; then
                        mkdir -p "$ARGON_DIR/unpacked"
                        if unzip -q -o "$ARGON_DIR/argon.zip" -d "$ARGON_DIR/unpacked"; then
                            install_apks_from_dir "$ARGON_DIR/unpacked" \
                                || warn "Не удалось установить APK из ZIP Argon (пропускаю)."
                        fi
                    fi
                else
                    warn "В релизе Argon нет ни APK, ни ZIP. Пропускаю."
                fi
            else
                warn "Некорректный JSON релиза Argon. Пропускаю."
            fi
        else
            warn "Не удалось получить JSON релиза Argon. Пропускаю тему."
        fi
    fi

    if pkg_installed luci-theme-argon; then
        info "Активирую Argon..."
        set_uci_quiet "luci.main.mediaurlbase=/luci-static/argon"
        uci -q commit luci || true
    fi
fi

# -----------------------------
# 9. System tuning
# -----------------------------
if [ "$APPLY_SYSTEM_TUNING" = "1" ]; then
    info "Применяю системные настройки..."
    set_uci_quiet "system.@system[0].zonename=${TIMEZONE_NAME}"
    set_uci_quiet "system.@system[0].timezone=${TIMEZONE_STRING}"
    uci -q commit system || true

    uci -q get network.globals >/dev/null 2>&1 || uci -q set network.globals=globals
    set_uci_quiet "network.globals.packet_steering=${ENABLE_PACKET_STEERING}"
    uci -q commit network || true

    set_uci_quiet "firewall.@defaults[0].flow_offloading=${ENABLE_FLOW_OFFLOADING}"
    set_uci_quiet "firewall.@defaults[0].flow_offloading_hw=${ENABLE_HW_FLOW_OFFLOADING}"
    uci -q commit firewall || true
fi

# -----------------------------
# 10. Service reload
# -----------------------------
service_do sysntpd  enable
service_do sysntpd  start
service_do uhttpd   enable
service_do uhttpd   restart
service_do dnsmasq  enable
service_do dnsmasq  restart
service_do rpcd     restart
service_do network  reload
service_do firewall restart

if [ -x /etc/init.d/passwall2 ]; then
    service_do passwall2 enable
    service_do passwall2 restart
fi

sync
sleep 2

# -----------------------------
# 11. Post-check
# -----------------------------
info "Пост-проверка..."
verify_required_package ca-bundle
verify_required_package unzip
verify_required_package luci
verify_required_package kmod-nft-socket
verify_required_package kmod-nft-tproxy
verify_required_package dnsmasq-full
verify_required_package luci-app-passwall2

if [ "$INSTALL_ARGON" = "1" ] && pkg_installed luci-theme-argon; then
    info "Argon установлен."
fi

if [ ! -x /etc/init.d/passwall2 ]; then
    warn "init-скрипт passwall2 не найден. Проверь пакет вручную."
fi

ROLLBACK_NEEDED=0

# -----------------------------
# 12. Summary
# -----------------------------
echo
echo '================ DONE ================'
info "Passwall 2 установлен (${SCRIPT_VERSION})."
info "LuCI -> Services -> Passwall 2"
if [ "$INSTALL_ARGON" = "1" ] && pkg_installed luci-theme-argon; then
    info "Theme -> Argon"
fi
info "Бэкап конфигов: $BACKUP_ROOT"
[ -n "$PW_TAG" ] && info "Версия Passwall 2: $PW_TAG"
echo '======================================'

if [ "$AUTO_REBOOT" = "1" ]; then
    info "AUTO_REBOOT=1: перезагрузка через 3 секунды..."
    sleep 3
    reboot
else
    info "Если LuCI ведёт себя странно — перезагрузи роутер вручную."
fi

exit 0
```

>обновление неподписанных пакетов
```bash
apk update verify --allow-untrusted && apk upgrade --allow-untrusted
```
