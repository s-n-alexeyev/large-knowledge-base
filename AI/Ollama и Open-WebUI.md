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
>echo '<svg height="64" width="64" xmlns="http://www.w3.org/2000/svg"><circle cx="32" cy="32" fill="#ccc" r="30"/><path d="m7.905 1.09c.216.085.411.225.588.41.295.306.544.744.734 1.263.191.522.315 1.1.362 1.68a5.05 5.05 0 0 1 2.049-.636l.051-.004c.87-.07 1.73.087 2.48.474q.151.08.297.17a6.4 6.4 0 0 1 .36-1.644c.19-.52.439-.957.733-1.264a1.7 1.7 0 0 1 .589-.41c.257-.1.53-.118.796-.042.401.114.745.368 1.016.737.248.337.434.769.561 1.287.23.934.27 2.163.115 3.645l.053.04.026.019c.757.576 1.284 1.397 1.563 2.35.435 1.487.216 3.155-.534 4.088l-.018.021.002.003c.417.762.67 1.567.724 2.4l.002.03c.064 1.065-.2 2.137-.814 3.19l-.007.01.01.024c.472 1.157.62 2.322.438 3.486l-.006.039a.65.65 0 0 1 -.747.536.65.65 0 0 1 -.54-.742c.167-1.033.01-2.069-.48-3.123a.64.64 0 0 1 .04-.617l.004-.006c.604-.924.854-1.83.8-2.72-.046-.779-.325-1.544-.8-2.273a.644.644 0 0 1 .18-.886l.009-.006c.243-.159.467-.565.58-1.12a4.2 4.2 0 0 0 -.095-1.974c-.205-.7-.58-1.284-1.105-1.683-.595-.454-1.383-.673-2.38-.61a.65.65 0 0 1 -.632-.371c-.314-.665-.772-1.141-1.343-1.436a3.3 3.3 0 0 0 -1.772-.332c-1.245.099-2.343.801-2.67 1.686a.65.65 0 0 1 -.61.425c-1.067.002-1.893.252-2.497.703-.522.39-.878.935-1.066 1.588a4.1 4.1 0 0 0 -.068 1.886c.112.558.331 1.02.582 1.269l.008.007c.212.207.257.53.109.785-.36.622-.629 1.549-.673 2.44-.05 1.018.186 1.902.719 2.536l.016.019a.64.64 0 0 1 .095.69c-.576 1.236-.753 2.252-.562 3.052a.652.652 0 0 1 -1.269.298c-.243-1.018-.078-2.184.473-3.498l.014-.035-.008-.012a4.3 4.3 0 0 1 -.598-1.309l-.005-.019a5.8 5.8 0 0 1 -.177-1.785c.044-.91.278-1.842.622-2.59l.012-.026-.002-.002c-.293-.418-.51-.953-.63-1.545l-.005-.024a5.35 5.35 0 0 1 .093-2.49c.262-.915.777-1.701 1.536-2.269q.09-.068.186-.132c-.159-1.493-.119-2.73.112-3.67.127-.518.314-.95.562-1.287.27-.368.614-.622 1.015-.737.266-.076.54-.059.797.042zm4.116 9.09c.936 0 1.8.313 2.446.855.63.527 1.005 1.235 1.005 1.94 0 .888-.406 1.58-1.133 2.022-.62.375-1.451.557-2.403.557-1.009 0-1.871-.259-2.493-.734-.617-.47-.963-1.13-.963-1.845 0-.707.398-1.417 1.056-1.946.668-.537 1.55-.849 2.485-.849m0 .896a3.07 3.07 0 0 0 -1.916.65c-.461.37-.722.835-.722 1.25 0 .428.21.829.61 1.134.455.347 1.124.548 1.943.548.799 0 1.473-.147 1.932-.426.463-.28.7-.686.7-1.257 0-.423-.246-.89-.683-1.256-.484-.405-1.14-.643-1.864-.643m.662 1.21.004.004c.12.151.095.37-.056.49l-.292.23v.446a.375.375 0 0 1 -.376.373.375.375 0 0 1 -.376-.373v-.46l-.271-.218a.347.347 0 0 1 -.052-.49.353.353 0 0 1 .494-.051l.215.172.22-.174a.353.353 0 0 1 .49.051m-5.04-1.919a.87.87 0 0 1 .867.871.87.87 0 0 1 -.868.871.87.87 0 0 1 -.867-.87.87.87 0 0 1 .867-.872zm8.706 0c.48 0 .868.39.868.871a.87.87 0 0 1 -.868.871.87.87 0 0 1 -.867-.87.87.87 0 0 1 .867-.872m-8.909-8.067-.003.002a.66.66 0 0 0 -.285.238l-.005.006c-.138.189-.258.467-.348.832-.17.692-.216 1.631-.124 2.782q.646-.193 1.404-.237l.01-.001.019-.034a3 3 0 0 1 .148-.239c.123-.771.022-1.692-.253-2.444-.134-.364-.297-.65-.453-.813a.6.6 0 0 0 -.107-.09zm9.174.04-.002.001a.6.6 0 0 0 -.107.09c-.156.163-.32.45-.453.814-.29.794-.387 1.776-.23 2.572l.058.097.008.014h.03a5.2 5.2 0 0 1 1.466.212c.086-1.124.038-2.043-.128-2.722-.09-.365-.21-.643-.349-.832l-.004-.006a.66.66 0 0 0 -.285-.239h-.004z" fill-rule="evenodd" transform="matrix(2 0 0 2 8 8)"/></svg>' > $ICON
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





