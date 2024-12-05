# Ollama

>Установка/обновление Ollama
```bash
sudo curl -fsSL https://ollama.com/install.sh | sh
```

>Создание службы Ollama
```
sudo nano /etc/systemd/system/ollama.service
```

```
[Unit]  
Description=Ollama Service  
After=network-online.target  
  
[Service]  
ExecStart=/usr/local/bin/ollama serve  
User=user  
Group=user  
Restart=always  
RestartSec=3  
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"  
  
[Install]  
WantedBy=default.target
```

>Запуск службы Ollama
```bash
sudo systemctl start ollama.service
```

Ссылка на модели [Ollama](https://ollama.com/search)

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

>[!tip] все настройки и модели хранятся в `~/.ollama/`

## Дополнительно

>[!example]- Скрипт для запуска/остановки сервиса Ollama
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
>SERVICE="ollama"
>ICON="/tmp/ollama_icon.svg"
>
># Сохраняем картинку в SVG
>echo '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><circle cx="32" cy="32" r="30" fill="#ccc"/><path fill-rule="evenodd" d="M27.178 16.886a10.1 10.1 0 0 1 4.2-1.28c2.461-.198 4.32.528 5.554 1.288.298-3.552 2.23-7.499 4.956-6.72 3.899 1.108 3.76 7.749 3.384 11.338 4.97 3.751 4.15 10.738 2.18 13.036.863 1.485 1.262 3.118 1.452 4.806l.004.06c.142 2.29-.545 4.42-1.642 6.4 1.11 2.666 1.189 5.115.884 7.098a1.3 1.3 0 0 1-1.494 1.072 1.3 1.3 0 0 1-1.08-1.484c.334-2.066.02-4.138-.96-6.246a1.28 1.28 0 0 1 .08-1.234c.762-1.143 1.75-3.106 1.608-5.452-.092-1.558-.65-3.088-1.6-4.546a1.29 1.29 0 0 1 .36-1.772c.82-.547 1.91-3.06.988-6.2-1.26-4.3-4.919-4.716-6.97-4.586a1.3 1.3 0 0 1-1.264-.742c-2.64-5.591-10.236-3.774-11.57-.164a1.3 1.3 0 0 1-1.22.85c-2.499.005-6.019.736-7.126 4.582-.846 3.078.332 5.701 1.044 6.324a1.29 1.29 0 0 1 .218 1.57c-.72 1.244-1.258 3.098-1.346 4.88-.124 2.526.643 4.128 1.47 5.11.33.382.404.923.19 1.38-1.152 2.472-1.506 4.504-1.124 6.104.342 1.657-2.107 2.232-2.538.596-.66-2.769.31-5.408.974-7.066-.927-1.39-1.735-3.433-1.576-6.25.117-2.429.857-4.34 1.268-5.232-2.116-2.957-2.428-9.735 2.356-12.924-.381-3.577-.54-10.264 3.378-11.388 2.055-.712 4.58 2.068 4.962 6.792m4.864 11.474c3.978 0 6.902 2.816 6.902 5.59 0 3.253-2.717 5.158-7.072 5.158-4.38 0-6.912-2.437-6.912-5.158 0-2.79 3.113-5.59 7.082-5.59m0 1.792c-2.888-.025-5.276 2.01-5.276 3.8 0 1.78 1.85 3.364 5.106 3.364 1.845 0 5.264-.4 5.264-3.366 0-1.726-2.062-3.798-5.094-3.798m1.324 2.42.008.008c.24.302.19.74-.112.98l-.584.46v.892a.75.75 0 0 1-.752.746.75.75 0 0 1-.752-.746v-.92l-.542-.436a.694.694 0 0 1-.104-.98.706.706 0 0 1 .988-.102l.43.344.44-.348a.706.706 0 0 1 .98.102m-10.08-3.838a1.74 1.74 0 0 1 1.734 1.742 1.74 1.74 0 0 1-1.736 1.742 1.74 1.74 0 0 1-1.734-1.74 1.74 1.74 0 0 1 1.734-1.744zm17.412 0c.96 0 1.736.78 1.736 1.742a1.74 1.74 0 0 1-1.736 1.742 1.74 1.74 0 0 1-1.734-1.74 1.74 1.74 0 0 1 1.734-1.744M22.88 12.6l-.006.004c-1.997.87-1.592 6.862-1.524 7.716.918-.294 1.874-.39 2.828-.476 1.076-1.925-.052-6.423-1.292-7.24zm18.348.08-.004.002c-1.454.958-2.182 5.939-1.448 7.174 1.071 0 2.044.145 2.992.424.064-.842.442-6.735-1.532-7.598h-.008z"/></svg>' > $ICON
>
># Проверка состояния службы Ollama
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
>yad --title "Управление Ollama" --image $ICON --window-icon=$ICON --fixed \
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
>
>```

---
# Open WebUI

>Установка open-webui окружения и его активация
```bash
python3 -m venv /opt/open-webui-env
source /opt/open-webui-env/bin/activate
pip install open-webui
```

>Создание службы Open-WebUI
```bash
sudo nano /etc/systemd/system/open-webui.service
```

```
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
>echo '<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="64" height="64" viewBox="0 0 176.972 176.971"><g style="display:inline" transform="translate(-21.195 -64.587)"><circle cx="109.681" cy="153.073" r="88.486" style="display:inline;fill:#ccc;fill-opacity:1;stroke:none;stroke-width:.264583"/><path d="M143.584 113.444h16.034v78.242h-16.034z" style="display:inline;fill:#000;fill-opacity:1;stroke:none;stroke-width:.264583"/><circle cx="92.371" cy="152.131" r="39.145" style="display:inline;fill:#000;fill-opacity:1;stroke:none;stroke-width:.276124;stroke-opacity:1"/><circle cx="92.428" cy="152.101" r="23.388" style="display:inline;fill:#ccc;fill-opacity:1;stroke:none;stroke-width:.280487"/></g></svg>' > $ICON
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
>yad --title "Управление Ollama" --image $ICON --window-icon=$ICON --fixed \
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





