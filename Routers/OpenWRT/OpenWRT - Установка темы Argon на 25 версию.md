```bash
cat > /tmp/install_argon_only.sh <<'EOF'
#!/bin/sh

set -eu
umask 022

INSTALL_ARGON="${INSTALL_ARGON:-1}"
INSECURE_HTTPS="${INSECURE_HTTPS:-0}"
GITHUB_PROXY_PREFIX="${GITHUB_PROXY_PREFIX:-}"

WORKDIR="/tmp/argon_install.$$"
ARGON_DIR="$WORKDIR/argon"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { printf '%b\n' "${GREEN}[INFO] $*${NC}"; }
warn() { printf '%b\n' "${YELLOW}[WARN] $*${NC}"; }
die()  { printf '%b\n' "${RED}[FATAL] $*${NC}" >&2; exit 1; }

cleanup() {
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

pkg_installed() {
    apk info -e "$1" >/dev/null 2>&1
}

set_uci_quiet() {
    uci -q set "$1" || true
}

is_html_stub() {
    head -c 1024 "$1" 2>/dev/null | grep -qaiE '<html|<!doctype|<body|access denied|not found|rate limit'
}

validate_apk_pkg() {
    [ -s "$1" ] || return 1
    _size="$(wc -c < "$1" 2>/dev/null | tr -d ' ')"
    case "$_size" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "$_size" -ge 16384 ] || return 1
    is_html_stub "$1" && return 1
    return 0
}

validate_zip() {
    [ -s "$1" ] || return 1
    is_html_stub "$1" && return 1
    unzip -tqq "$1" >/dev/null 2>&1
}

validate_release_json() {
    [ -s "$1" ] || return 1
    is_html_stub "$1" && return 1
    grep -q '"tag_name"' "$1" 2>/dev/null || return 1
    grep -q '"browser_download_url"' "$1" 2>/dev/null || return 1
    return 0
}

_download_single() {
    _url="$1"
    _out="$2"
    _validator="${3:-}"
    _tmp="${_out}.part"

    rm -f "$_tmp"

    _wget_opts="-T 30 -O"
    if [ "$INSECURE_HTTPS" = "1" ] && have_cmd wget; then
        _wget_opts="--no-check-certificate $_wget_opts"
    fi

    if have_cmd wget; then
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

    [ -s "$_tmp" ] || {
        rm -f "$_tmp"
        return 1
    }

    if [ -n "$_validator" ]; then
        if ! "$_validator" "$_tmp"; then
            rm -f "$_tmp"
            return 1
        fi
    fi

    mv -f "$_tmp" "$_out"
}

fetch_file() {
    _url="$1"
    _out="$2"
    _validator="${3:-}"

    info "Источник: $_url"
    if _download_single "$_url" "$_out" "$_validator"; then
        return 0
    fi

    case "$_url" in
        https://github.com/*)
            warn "Оригинальный GitHub недоступен, пробую зеркала..."

            if [ -n "$GITHUB_PROXY_PREFIX" ]; then
                info "Источник: ${GITHUB_PROXY_PREFIX}${_url}"
                if _download_single "${GITHUB_PROXY_PREFIX}${_url}" "$_out" "$_validator"; then
                    return 0
                fi
            fi

            for _m in \
                "https://ghfast.top/" \
                "https://gh-proxy.com/" \
                "https://ghproxy.net/"
            do
                info "Источник: ${_m}${_url}"
                if _download_single "${_m}${_url}" "$_out" "$_validator"; then
                    return 0
                fi
            done
            ;;
    esac

    rm -f "$_out"
    return 1
}

json_first_asset_url() {
    _file="$1"
    _pat="$2"

    tr ',{}' '\n' < "$_file" \
        | grep '"browser_download_url"' \
        | sed -n 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        | grep -E "$_pat" \
        | head -n 1
}

install_apks_from_dir() {
    _dir="$1"

    OLDIFS="$IFS"
    IFS=' '
    set --

    for _apk in $(find "$_dir" -type f -name '*.apk' | sort); do
        [ -n "$_apk" ] || continue
        set -- "$@" "$_apk"
    done

    IFS="$OLDIFS"

    [ "$#" -gt 0 ] || return 1

    info "Устанавливаю $# пакетов из $_dir"
    apk add --allow-untrusted "$@"
}

command -v apk >/dev/null 2>&1 || die "apk не найден"
command -v uci >/dev/null 2>&1 || die "uci не найден"
command -v grep >/dev/null 2>&1 || die "grep не найден"
command -v sed >/dev/null 2>&1 || die "sed не найден"
command -v tr >/dev/null 2>&1 || die "tr не найден"
command -v head >/dev/null 2>&1 || die "head не найден"
command -v find >/dev/null 2>&1 || die "find не найден"

mkdir -p "$ARGON_DIR"

apk update || warn "apk update не прошёл, продолжаю"

apk add ca-bundle unzip >/dev/null 2>&1 || warn "ca-bundle/unzip не установлены"

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

/etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true

if pkg_installed luci-theme-argon; then
    info "DONE: Argon установлен и активирован."
else
    die "Argon не установлен."
fi
EOF

chmod +x /tmp/install_argon_only.sh
sh /tmp/install_argon_only.sh
```