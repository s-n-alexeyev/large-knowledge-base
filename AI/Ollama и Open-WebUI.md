<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 64 64"><circle cx="32" cy="32" r="30" fill="#ccc"/><path fill-rule="evenodd" d="M27.2 16.9a10.1 10.1 0 0 1 4.2-1.3 9 9 0 0 1 5.5 1.3c.3-3.6 2.3-7.5 5-6.7 3.9 1 3.7 7.7 3.4 11.3 5 3.8 4.1 10.8 2.2 13a12 12 0 0 1 1.4 4.9c.2 2.3-.5 4.4-1.6 6.4a13 13 0 0 1 .9 7.1 1.3 1.3 0 0 1-1.5 1 1.3 1.3 0 0 1-1.1-1.4c.3-2 0-4.1-1-6.2a1.3 1.3 0 0 1 .1-1.3 9 9 0 0 0 1.6-5.4c0-1.6-.6-3.1-1.6-4.6a1.3 1.3 0 0 1 .4-1.8c.8-.5 1.9-3 1-6.2-1.3-4.2-5-4.7-7-4.5a1.3 1.3 0 0 1-1.3-.8c-2.6-5.6-10.2-3.8-11.6-.1a1.3 1.3 0 0 1-1.2.8c-2.5 0-6 .7-7.1 4.6-.8 3 .3 5.7 1 6.3a1.3 1.3 0 0 1 .3 1.6c-.8 1.2-1.3 3-1.4 4.9a7 7 0 0 0 1.5 5c.3.5.4 1 .2 1.5-1.2 2.4-1.5 4.5-1.1 6 .3 1.7-2.2 2.3-2.6.7a12 12 0 0 1 1-7.1 10 10 0 0 1-1.6-6.3c.1-2.4.9-4.3 1.3-5.2-2.1-3-2.4-9.7 2.3-13-.3-3.5-.5-10.2 3.4-11.3 2-.7 4.6 2 5 6.8M32 28.4c4 0 7 2.8 7 5.6 0 3.2-2.8 5.1-7.1 5.1-4.4 0-7-2.4-7-5.1 0-2.8 3.2-5.6 7.1-5.6m0 1.8c-2.8 0-5.2 2-5.2 3.8 0 1.7 1.8 3.3 5 3.3 2 0 5.3-.4 5.3-3.3 0-1.8-2-3.8-5-3.8m1.3 2.4c.2.3.2.7-.1 1l-.6.4v1a.8.8 0 0 1-.8.7.8.8 0 0 1-.7-.8v-1l-.6-.3a.7.7 0 0 1 0-1 .7.7 0 0 1 1-.1l.3.3.5-.3a.7.7 0 0 1 1 0m-10.1-3.8a1.7 1.7 0 0 1 1.7 1.8 1.7 1.7 0 0 1-1.7 1.7 1.7 1.7 0 0 1-1.8-1.7 1.7 1.7 0 0 1 1.8-1.8zm17.4 0c1 0 1.7.8 1.7 1.8a1.7 1.7 0 0 1-1.7 1.7 1.7 1.7 0 0 1-1.7-1.7 1.7 1.7 0 0 1 1.7-1.8M22.9 12.6c-2 .9-1.6 6.9-1.5 7.7.9-.3 1.8-.4 2.8-.5 1-1.9 0-6.4-1.3-7.2zm18.3 0c-1.4 1-2.2 6-1.4 7.3 1 0 2 .1 3 .4 0-.9.4-6.8-1.6-7.6z"/></svg>
```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
# Ollama

## Установка Ollama
>Установка/обновление Ollama
```bash
sudo curl -fsSL https://ollama.com/install.sh | sh
```

![](/Media/Pictures/Ollama/Ollama_Install.png)

>Скрипт создает службу `ollama`, можем в в этом убедиться
```
sudo nano /etc/systemd/system/ollama.service
```

```ini
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"

[Install]
WantedBy=default.target
```

>Скрип включает в автозагрузку службу `ollama`, можем выключить, если хотим контролировать вручную
```bash
sudo systemctl disable ollama.service
```

>Запуск службы `ollama`
```bash
sudo systemctl start ollama.service
```

>Остановка службы `ollama`
```bash
sudo systemctl stop ollama.service
```

Ссылка на модели [Ollama](https://ollama.com/search)

>Пример загрузки модели [qwen2.5](https://ollama.com/library/qwen2.5)
```bash
ollama run qwen2.5
```

>[!info] Команды Ollama
```
Использование:
  ollama [флаги]
  ollama [команда]

Доступные команды:
serve        Запустить ollama
create       Создать модель из Modelfile
show         Показать информацию о модели
run          Запустить модель
stop         Остановить запущенную модель
pull         Загрузить модель из реестра
push         Отправить модель в реестр
list         Список моделей
ps           Список запущенных моделей
cp           Копировать модель
rm           Удалить модель
help         Помощь

Флаги:
  -h, --help     Помощь для ollama
  -v, --version  Показать информацию о версии
```

>[!tip] все настройки и модели хранятся в `/usr/share/ollama/.ollama/`

>Для ручных манипуляций с файлами `ollama` делаем следующее
```bash
# Даем доступ к директории и вложенным поддиркеториям группе ollama
sudo chgrp -R ollama /usr/share/ollama
sudo chmod -R g+rwx /usr/share/ollama
sudo chmod -R g+s /usr/share/ollama

# Добавляем себя в группу ollama
sudo usermod -aG ollama $USER
```

>Чтобы права вступили в силу нужно завершить текущую сессию или перегрузить компьютер или выполнить следующую команду
```bash
newgrp ollama
```
## Просмотр журнала

>Просмотр журналы работы `ollama`
```shell
journalctl -e -u ollama
```
## Удаление Ollama

>Удаление службы ollama
```shell
sudo systemctl stop ollama
sudo systemctl disable ollama
sudo rm /etc/systemd/system/ollama.service
```

>Удаление файлов `ollama` из каталога `/usr/local/bin`, `/usr/bin`, `/bin`
```shell
sudo rm $(which ollama)
```

>Удаление загруженных моделей и пользователя и группы сервиса `ollama`
```bash
# Удаляем директорию с данными
sudo rm -r /usr/share/ollama

# Удаляем пользователя
sudo userdel ollama

# Удаляем пользователей из груупы ollama
for user in $(getent group ollama | cut -d: -f4 | tr ',' ' '); do
   sudo gpasswd -d "$user" ollama
done

# Удаляем группу
sudo groupdel ollama
```
## Дополнительно

>[!example]- Скрипт для запуска/остановки сервиса Ollama
>```bash
>#!/bin/bash
>
># Функция проверки зависимостей
>check_dependencies() {
>    local dependencies=("yad" "ollama" "faillock" "notify-send" "systemctl" "sudo")
>    local missing_dependencies=()
>
>    for dep in "${dependencies[@]}"; do
>        if ! command -v "$dep" > /dev/null 2>&1; then
>            missing_dependencies+=("$dep")
>        fi
>    done
>
>    if [ ${#missing_dependencies[@]} -ne 0 ]; then
>        echo "Отсутствующие зависимости: ${missing_dependencies[*]}"
>        exit 1
>    fi
>}
>
>check_dependencies
>
># Очищаем неудачные попытки входа
>faillock --user $USER --reset
>
># Просим пароль root
>password=$(yad --entry --title="Авторизация" \
>  --window-icon="lock" --image "lock" \
>  --width=300 --fixed \
>  --text="Введите root пароль:" --hide-text)
>if [ -z "$password" ]; then
>  exit 0
>fi
>
># Функция для отображения сообщений
>notify_show() {
>  notify-send "$1" --icon=$ICON --app-name="$2 " --expire-time=4000
>}
>
># Проверка пароля с использованием sudo
>ICON="state-error"
>echo "$password" | sudo -S ls >/dev/null 2>&1
>if [ $? -ne 0 ]; then
>  notify_show $'Неверный пароль!\nЗавершение работы.' "Ошибка"
>  exit 1
>fi
>
>SERVICE="ollama"
>ICON="/tmp/ollama_icon.svg"
>
># Сохраняем картинку в SVG
>echo '<svg width="48" height="48" viewBox="0 0 64 64"><circle cx="32" cy="32" r="30" fill="#ccc"/><path fill-rule="evenodd" d="M27.2 16.9a10.1 10.1 0 0 1 4.2-1.3 9 9 0 0 1 5.5 1.3c.3-3.6 2.3-7.5 5-6.7 3.9 1 3.7 7.7 3.4 11.3 5 3.8 4.1 10.8 2.2 13a12 12 0 0 1 1.4 4.9c.2 2.3-.5 4.4-1.6 6.4a13 13 0 0 1 .9 7.1 1.3 1.3 0 0 1-1.5 1 1.3 1.3 0 0 1-1.1-1.4c.3-2 0-4.1-1-6.2a1.3 1.3 0 0 1 .1-1.3 9 9 0 0 0 1.6-5.4c0-1.6-.6-3.1-1.6-4.6a1.3 1.3 0 0 1 .4-1.8c.8-.5 1.9-3 1-6.2-1.3-4.2-5-4.7-7-4.5a1.3 1.3 0 0 1-1.3-.8c-2.6-5.6-10.2-3.8-11.6-.1a1.3 1.3 0 0 1-1.2.8c-2.5 0-6 .7-7.1 4.6-.8 3 .3 5.7 1 6.3a1.3 1.3 0 0 1 .3 1.6c-.8 1.2-1.3 3-1.4 4.9a7 7 0 0 0 1.5 5c.3.5.4 1 .2 1.5-1.2 2.4-1.5 4.5-1.1 6 .3 1.7-2.2 2.3-2.6.7a12 12 0 0 1 1-7.1 10 10 0 0 1-1.6-6.3c.1-2.4.9-4.3 1.3-5.2-2.1-3-2.4-9.7 2.3-13-.3-3.5-.5-10.2 3.4-11.3 2-.7 4.6 2 5 6.8M32 28.4c4 0 7 2.8 7 5.6 0 3.2-2.8 5.1-7.1 5.1-4.4 0-7-2.4-7-5.1 0-2.8 3.2-5.6 7.1-5.6m0 1.8c-2.8 0-5.2 2-5.2 3.8 0 1.7 1.8 3.3 5 3.3 2 0 5.3-.4 5.3-3.3 0-1.8-2-3.8-5-3.8m1.3 2.4c.2.3.2.7-.1 1l-.6.4v1a.8.8 0 0 1-.8.7.8.8 0 0 1-.7-.8v-1l-.6-.3a.7.7 0 0 1 0-1 .7.7 0 0 1 1-.1l.3.3.5-.3a.7.7 0 0 1 1 0m-10.1-3.8a1.7 1.7 0 0 1 1.7 1.8 1.7 1.7 0 0 1-1.7 1.7 1.7 1.7 0 0 1-1.8-1.7 1.7 1.7 0 0 1 1.8-1.8zm17.4 0c1 0 1.7.8 1.7 1.8a1.7 1.7 0 0 1-1.7 1.7 1.7 1.7 0 0 1-1.7-1.7 1.7 1.7 0 0 1 1.7-1.8M22.9 12.6c-2 .9-1.6 6.9-1.5 7.7.9-.3 1.8-.4 2.8-.5 1-1.9 0-6.4-1.3-7.2zm18.3 0c-1.4 1-2.2 6-1.4 7.3 1 0 2 .1 3 .4 0-.9.4-6.8-1.6-7.6z"/></svg>' > $ICON
>
># Проверка состояния службы
>status=$(echo "$password" | sudo -S systemctl is-active --quiet $SERVICE && echo "active" || echo "inactive")
>
># Формируем сообщение на основе состояния службы
>if [ "$status" = "active" ]; then
>    message="<span foreground='green'><b>Сервис $SERVICE активен.</b></span>\nХотите его остановить?"
>else
>    message="<span foreground='red'><b>Сервис $SERVICE остановлен.</b></span>\nХотите его запустить?"
>fi
>
># Запрашиваем ответ пользователя
>yad --title "Управление $SERVICE" --image $ICON --window-icon=$ICON --fixed \
>  --text "$message" \
>  --button=Да:0 \
>  --button=Нет:1
># Проверяем response
>response=$?
>if [ $response -eq 0 ]; then
>  if [ "$status" = "active" ]; then
>    # Останавливаем службу
>    echo "$password" | sudo -S systemctl stop $SERVICE
>    if [ $? -eq 0 ]; then
>      notify_show "Сервис $SERVICE успешно остановлен." "Успех"
>    else
>      notify_show "Не удалось остановить сервис $SERVICE." "Ошибка"
>    fi
>  else
>    # Запускаем службу
>    echo "$password" | sudo -S systemctl start $SERVICE
>    if [ $? -eq 0 ]; then
>      notify_show "Сервис $SERVICE успешно запущен." "Успех"
>    else
>      notify_show "Не удалось запустить сервис $SERVICE." "Ошибка"
>    fi
>  fi
>else
>  # Пользователь выбрал "Нет" или закрыл диалог
>  notify_show "Действие отменено." "Информация"
>fi
>
># Удаляем временный SVG файл
>rm -f $ICON
>```

---
<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 177 177"><circle cx="88.5" cy="88.5" r="88.5" fill="#ccc"/><path d="M122.8 48.4h16v79h-16z"/><circle cx="71.2" cy="87.5" r="39.1"/><circle cx="71.2" cy="87.5" r="23.4" fill="#ccc"/></svg>
# Open WebUI 

>Установка open-webui окружения и его активация
```bash
mkdir /opt/open-webui-env

# Необходимо иметь версию python 3.11
python3.11 -m venv /opt/open-webui-env

source /opt/open-webui-env/bin/activate
pip install open-webui
```

>Создание службы Open-WebUI
```bash
sudo nano /etc/systemd/system/open-webui.service
```

```ini
[Unit]
Description=Open Web UI Service
After=network.target

[Service]
User=user
WorkingDirectory=/opt/open-webui-env/bin
ExecStart=/bin/bash -lc "source /opt/open-webui-env/bin/activate && open-webui serve"
Restart=always

[Install]
WantedBy=multi-user.target
```

>Запуск службы Open-WebUI
```bash
sudo systemctl start open-webui.service
```

Адрес на фронтэнд Open-WebUI в браузере [0.0.0.0:8080](http://0.0.0.0:8080)

## Дополнительно

>[!example]- Скрипт для запуска/остановки сервиса Open-WebUI
>```bash
>#!/bin/bash
>
># Очищаем неудачные попытки входа
>faillock --user $USER --reset
>
># Просим пароль root
>password=$(yad --entry --title="Авторизация" \
>  --window-icon="lock" --image "lock" \
>  --width=300 --fixed \
>  --text="Введите root пароль:" --hide-text)
>if [ -z "$password" ]; then
>  exit 0
>fi
>
># Функция для отображения сообщений
>notify_show() {
>  notify-send "$1" --icon=$ICON --app-name="$2 " --expire-time=4000
>}
>
># Проверка пароля с использованием sudo
>ICON="state-error"
>echo "$password" | sudo -S ls >/dev/null 2>&1
>if [ $? -ne 0 ]; then
>  notify_show $'Неверный пароль!\nЗавершение работы.' "Ошибка"
>  exit 1
>fi
>
>SERVICE="open-webui"
>ICON="/tmp/open-webui_icon.svg"
>
># Сохраняем картинку в SVG
>echo '<svg width="48" height="48" viewBox="0 0 177 177"><circle cx="88.5" cy="88.5" r="88.5" fill="#ccc"/><path d="M122.8 48.4h16v79h-16z"/><circle cx="71.2" cy="87.5" r="39.1"/><circle cx="71.2" cy="87.5" r="23.4" fill="#ccc"/></svg>' > $ICON
>
># Проверка состояния службы
>status=$(echo "$password" | sudo -S systemctl is-active --quiet $SERVICE && echo "active" || echo "inactive")
>
># Формируем сообщение на основе состояния службы
>if [ "$status" = "active" ]; then
>    message="<span foreground='green'><b>Сервис $SERVICE активен.</b></span>\nХотите его остановить?"
>else
>    message="<span foreground='red'><b>Сервис $SERVICE остановлен.</b></span>\nХотите его запустить?"
>fi
>
># Запрашиваем ответ пользователя
>yad --title "Управление $SERVICE" --image $ICON --window-icon=$ICON --fixed \
>  --text "$message" \
>  --button=Да:0 \
>  --button=Нет:1
>
># Проверяем response
>response=$?
>if [ $response -eq 0 ]; then
>  if [ "$status" = "active" ]; then
>    # Останавливаем службу
>    echo "$password" | sudo -S systemctl stop $SERVICE
>    if [ $? -eq 0 ]; then
>      notify_show "Сервис $SERVICE успешно остановлен." "Успех"
>    else
>      notify_show "Не удалось остановить сервис $SERVICE." "Ошибка"
>    fi
>  else
>    # Запускаем службу
>    echo "$password" | sudo -S systemctl start $SERVICE
>    if [ $? -eq 0 ]; then
>      notify_show "Сервис $SERVICE успешно запущен." "Успех"
>    else
>      notify_show "Не удалось запустить сервис $SERVICE." "Ошибка"
>    fi
>  fi
>else
>  # Пользователь выбрал "Нет" или закрыл диалог
>  notify_show "Действие отменено." "Информация"
>fi
>
># Удаляем временный SVG файл
>rm -f $ICON
>```

>Перенос VENV замена содержимого скриптов в bin
```bash
find /opt/open-webui-env/bin -type f -exec sed -i 's|#!/home/user/.venv/open-webui-env/bin/python3.11|#!/usr/bin/env python3|' {} +
```

>Обновление open-webui
```bash
source /opt/open-webui-env/bin/activate  
pip install --upgrade open-webui
```





