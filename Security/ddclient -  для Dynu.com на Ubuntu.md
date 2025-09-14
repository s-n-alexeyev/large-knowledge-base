# Настройка ddclient для Dynu.com на Ubuntu

## Установка ddclient
```bash
sudo apt update
sudo apt install ddclient -y
```

## Редактирование конфигурации
```bash
sudo nano /etc/ddclient.conf
```

### Пример содержимого /etc/ddclient.conf
```bash
protocol=dyndns2
use=web, web=checkip.dynu.com/, web-skip='Current IP Address:'
server=api.dynu.com
login=ВАШ_EMAIL_ИЛИ_ЛОГИН
password='ВАШ_API_KEY_ИЛИ_ПАРОЛЬ'
yourdomain.dynu.net
```

## Тестирование
```bash
sudo ddclient -daemon=0 -verbose -noquiet
```

## Запуск как сервиса
```bash
sudo systemctl enable ddclient
sudo systemctl start ddclient
systemctl status ddclient
```

## Логи
```bash
journalctl -u ddclient -f
```


# Автоматическое обновления IP в Dynu.com на Ubuntu

Эта инструкция позволит обновлять внешний IP-адрес на Dynu.com каждые 5 минут с помощью bash-скрипта и cron.

## 1. Создание скрипта

Создаём файл:

```bash
sudo nano /usr/local/bin/dynu-update.sh
```

Вставляем содержимое:

```bash
#!/bin/bash

# === Настройки ===
USERNAME="ВАШ_ЛОГИН_ИЛИ_EMAIL"
PASSWORD="ВАШ_API_KEY_ИЛИ_ПАРОЛЬ"
HOSTNAME="yourdomain.dynu.net"

# === Получаем текущий внешний IP ===
CURRENT_IP=$(curl -s https://checkip.dynu.com/ | grep -oE '[0-9\.]+')

# === Отправляем обновление на Dynu ===
curl -s "https://api.dynu.com/nic/update?hostname=$HOSTNAME&myip=$CURRENT_IP" \
    --user "$USERNAME:$PASSWORD"
```

Делаем исполняемым:

```bash
sudo chmod +x /usr/local/bin/dynu-update.sh
```

## 2. Добавление в cron

Открываем cron-редактор:

```bash
crontab -e
```

Добавляем строку (запуск каждые 5 минут):

```bash
*/5 * * * * /usr/local/bin/dynu-update.sh >/dev/null 2>&1
```

## 3. Проверка работы

Запустите скрипт вручную:

```bash
/usr/local/bin/dynu-update.sh
```

Затем убедитесь в обновлении IP в панели Dynu.com.

---

Теперь ваш внешний IP будет автоматически обновляться на Dynu.com каждые 5 минут.
