2024-12-06

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

![](/Media/Pictures/Ollama/Ollama_icon.png) [Ссылка на источник](https://ollama.com/)

Ollama — это платформа и набор инструментов для создания и использования моделей искусственного интеллекта, включая языковые модели, для различных задач. Она предназначена для упрощения интеграции ИИ в рабочие процессы, позволяя пользователям разрабатывать и развертывать модели с минимальными усилиями. Ollama предлагает различные модели ИИ, которые можно использовать для обработки текста, создания приложений и улучшения взаимодействия с пользователями через чат-ботов или другие интерфейсы.

Платформа также обеспечивает удобный API и интерфейс для работы с моделями, а также поддерживает локальный запуск ИИ, что может быть полезно для пользователей, стремящихся обеспечить большую конфиденциальность и контроль над данными.
## Установка и обновление

>Установка/обновление Ollama
```bash
sudo curl -fsSL https://ollama.com/install.sh | sh
```

![](/Media/Pictures/Ollama/Ollama_install.png)

>Скрипт создает службу `ollama`, можем в этом убедиться
```
sudo nano /etc/systemd/system/ollama
```

```unit
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
sudo systemctl disable ollama
```

>Запуск службы `ollama`
```bash
sudo systemctl start ollama
```

>Остановка службы `ollama`
```bash
sudo systemctl stop ollama
```

## Использование

>[!info] Ссылка на модели [Ollama](https://ollama.com/search)

>Пример загрузки модели [qwen2.5](https://ollama.com/library/qwen2.5)
```bash
ollama run qwen2.5
```

>[!note] Команды Ollama
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

>[!info] все настройки и данные хранятся в `/usr/share/ollama/`

>Для ручных манипуляций с файлами `ollama` делаем следующее
```bash
# Даем доступ к директории и вложенным поддиректориям группе ollama
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
## Удаление

>Удаление службы `ollama`
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

Можно создать ярлык на рабочем столе, добавив в него путь на файл со скриптом, для того чтобы не пользоваться консолью для старта/остановки службы, в качестве аргумента командной строки можно указать пароль для `root`

>[!example]- Скрипт для запуска/остановки сервиса Ollama
>```bash
>#!/bin/bash
>
># Функция проверки зависимостей
>check_dependencies() {
>   local dependencies=("yad" "npm" "faillock" "notify-send" "systemctl" "sudo")
>   local missing_dependencies=()
>
>   for dep in "${dependencies[@]}"; do
>       if ! command -v "$dep" > /dev/null 2>&1; then
>           missing_dependencies+=("$dep")
>       fi
>   done
>
>   if [ ${#missing_dependencies[@]} -ne 0 ]; then
>       echo "Отсутствующие зависимости: ${missing_dependencies[*]}"
>       exit 1
>   fi
>}
>
>check_dependencies
>
># Очищаем неудачные попытки входа
>faillock --user $USER --reset
>
># Используем пароль из командной строки, если он передан
>if [ -n "$1" ]; then
>    password="$1"
>else
>    # Если пароль не передан, просим пароль root
>    password=$(yad --entry --title="Авторизация" \
>        --window-icon="lock" --image "lock" \
>        --width=300 --fixed \
>        --text="Введите root пароль:" --hide-text)
>    if [ -z "$password" ]; then
>        exit 0
>    fi
>fi
>
># Функция для отображения сообщений
>notify_show() {
> notify-send "$1" --icon=$ICON --app-name="$2 " --expire-time=4000
>}
>
># Проверка пароля с использованием sudo
>ICON="state-error"
>echo "$password" | sudo -S ls >/dev/null 2>&1
>if [ $? -ne 0 ]; then
> notify_show $'Неверный пароль!\nЗавершение работы.' "Ошибка"
> exit 1
>fi
>
>SERVICE="ollama"
>ICON="/tmp/ollama_icon.svg"
>
># Сохраняем картинку в SVG
>echo '<svg width="45" height="45" viewBox="0 0 60 60"><circle cx="30" cy="30" r="30" fill="#ccc"/><path d="M25.2 14.9c2.7-1.5 6.4-2 9.7 0 .7-8.8 9.7-11 8.4 4.6 5 3.8 4.1 10.8 2.2 13 2.2 4.1 1.6 8-.2 11.3a13 13 0 0 1 .9 7.1c-.3 1.6-2.7 1.2-2.6-.4.3-2 0-4.1-1-6.2-.2-.4-.2-1 .1-1.3 1-1.5 3-5.4 0-10-.4-.6-.2-1.4.4-1.8.8-.5 1.9-3 1-6.2-1.3-4.2-5-4.7-7-4.5-.6 0-1-.3-1.3-.8-2.6-5.6-10.2-3.8-11.6-.1-.2.5-.7.8-1.2.8-2.5 0-6 .7-7.1 4.6-.8 3 .3 5.7 1 6.3.5.4.6 1 .3 1.6-.8 1.2-2.8 6.2.1 9.9.3.5.4 1 .2 1.5-1.2 2.4-1.5 4.5-1.1 6 .3 1.7-2.2 2.3-2.6.7a12 12 0 0 1 1-7.1c-3.1-4.8-.9-10.2-.3-11.5-2.1-3-2.4-9.7 2.3-13-1.3-15.3 7.6-13.6 8.4-4.5M30 26.4c4 0 7 2.8 7 5.6 0 7-14.1 6.6-14.1 0 0-2.8 3.2-5.6 7.1-5.6M24.8 32c0 4.4 10.3 4.5 10.3 0 0-1.8-2-3.8-5-3.8-2.9 0-5.3 2-5.3 3.8zm6.5-.4-.6.4v1c0 1-1.5 1-1.5 0v-1l-.6-.4c-.6-.6.3-1.7 1-1.1l.4.3.4-.3c.8-.5 1.7.5.9 1.1zm-10.4-21c-2 .9-1.6 6.9-1.5 7.7.9-.3 1.8-.4 2.8-.5 1-1.9 0-6.4-1.3-7.2zm16.9 7.3c1 0 2 .1 3 .4 0-.9.5-7-1.5-7.7-1.2.3-2.5 5.7-1.5 7.3zm2.7 10.5c0 2.4-3.6 2.4-3.6 0s3.6-2.4 3.6 0zm-17.5 0c0 2.4-3.6 2.4-3.6 0s3.6-2.4 3.6 0z"/></svg>' > $ICON
>
># Проверка состояния службы
>status=$(echo "$password" | sudo -S systemctl is-active --quiet $SERVICE && echo "active" || echo "inactive")
>
># Формируем сообщение на основе состояния службы
>if [ "$status" = "active" ]; then
>   message="<span foreground='green'><b>Сервис $SERVICE активен.</b></span>\nХотите его остановить?"
>else
>   message="<span foreground='red'><b>Сервис $SERVICE остановлен.</b></span>\nХотите его запустить?"
>fi
>
># Запрашиваем ответ пользователя
>yad --title "Управление $SERVICE" --image $ICON --window-icon=$ICON --fixed \
> --text "$message" \
> --button=Да:0 \
> --button=Нет:1
># Проверяем response
>response=$?
>if [ $response -eq 0 ]; then
> if [ "$status" = "active" ]; then
>   # Останавливаем службу
>   echo "$password" | sudo -S systemctl stop $SERVICE
>   if [ $? -eq 0 ]; then
>     notify_show "Сервис $SERVICE успешно остановлен." "Успех"
>   else
>     notify_show "Не удалось остановить сервис $SERVICE." "Ошибка"
>   fi
> else
>   # Запускаем службу
>   echo "$password" | sudo -S systemctl start $SERVICE
>   if [ $? -eq 0 ]; then
>     notify_show "Сервис $SERVICE успешно запущен." "Успех"
>   else
>     notify_show "Не удалось запустить сервис $SERVICE." "Ошибка"
>   fi
> fi
>else
> # Пользователь выбрал "Нет" или закрыл диалог
> notify_show "Действие отменено." "Информация"
>fi
>
># Удаляем временный SVG файл
>rm -f $ICON
>```

---

# Open WebUI 

![](/Media/Pictures/Ollama/Open-WebUI_icon.png) [Ссылка на источник](https://github.com/open-webui/open-webui)

Open WebUI — это расширяемый, богатый функциями и дружественный пользователю самодостаточный веб-интерфейс, предназначенный для работы полностью в оффлайне.  Он позволяет пользователям легко управлять моделями ИИ, общаться с ними через чат и настраивать параметры, при этом поддерживает локальное развертывание для повышения конфиденциальности и производительности. В нем реализована поддержка различных языковых моделей LLM, включая Ollama и OpenAI-совместимых API.  Чтобы получить дополнительную информацию, смотрите документацию по [Open WebUI](https://docs.openwebui.com/).

## Установка

>[!warning] Необходимо иметь установленную версию python 3.11 

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

```unit
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
sudo systemctl start open-webui
```

>[!info] Адрес веб интерфейса Open-WebUI в браузере [0.0.0.0:8080](http://0.0.0.0:8080)

## Обновление

>Обновление open-webui
```bash
source /opt/open-webui-env/bin/activate  
pip install --upgrade open-webui
```

## Удаление

>Удаление службы `open-webui`
```bash
sudo systemctl stop open-webui
sudo systemctl disable open-webui
sudo rm /etc/systemd/system/open-webui.service
```

>Удаление директории с виртуальным окружением
```bash
sudo rm -rf /opt/open-webui-env
```

## Дополнительно

Можно создать ярлык на рабочем столе, добавив в него путь на файл со скриптом, для того чтобы не пользоваться консолью для старта/остановки службы, в качестве аргумента командной строки можно указать пароль для `root`

>[!example]- Скрипт для запуска/остановки сервиса Open-WebUI
>```bash
>#!/bin/bash
>
># Функция проверки зависимостей
>check_dependencies() {
>   local dependencies=("yad" "ollama" "faillock" "notify-send" "systemctl" "sudo")
>   local missing_dependencies=()
>
>   for dep in "${dependencies[@]}"; do
>       if ! command -v "$dep" > /dev/null 2>&1; then
>           missing_dependencies+=("$dep")
>       fi
>   done
>
>   if [ ${#missing_dependencies[@]} -ne 0 ]; then
>       echo "Отсутствующие зависимости: ${missing_dependencies[*]}"
>       exit 1
>   fi
>}
>
>check_dependencies
>
># Используем пароль из командной строки, если он передан
>if [ -n "$1" ]; then
>    password="$1"
>else
>    # Если пароль не передан, просим пароль root
>    password=$(yad --entry --title="Авторизация" \
>        --window-icon="lock" --image "lock" \
>        --width=300 --fixed \
>        --text="Введите root пароль:" --hide-text)
>    if [ -z "$password" ]; then
>        exit 0
>    fi
>fi
>
># Функция для отображения сообщений
>notify_show() {
> notify-send "$1" --icon=$ICON --app-name="$2 " --expire-time=4000
>}
>
># Проверка пароля с использованием sudo
>ICON="state-error"
>echo "$password" | sudo -S ls >/dev/null 2>&1
>if [ $? -ne 0 ]; then
> notify_show $'Неверный пароль!\nЗавершение работы.' "Ошибка"
> exit 1
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
>   message="<span foreground='green'><b>Сервис $SERVICE активен.</b></span>\nХотите его остановить?"
>else
>   message="<span foreground='red'><b>Сервис $SERVICE остановлен.</b></span>\nХотите его запустить?"
>fi
>
># Запрашиваем ответ пользователя
>yad --title "Управление $SERVICE" --image $ICON --window-icon=$ICON --fixed \
> --text "$message" \
> --button=Да:0 \
> --button=Нет:1
>
># Проверяем response
>response=$?
>if [ $response -eq 0 ]; then
> if [ "$status" = "active" ]; then
>   # Останавливаем службу
>   echo "$password" | sudo -S systemctl stop $SERVICE
>   if [ $? -eq 0 ]; then
>     notify_show "Сервис $SERVICE успешно остановлен." "Успех"
>   else
>     notify_show "Не удалось остановить сервис $SERVICE." "Ошибка"
>   fi
> else
>   # Запускаем службу
>   echo "$password" | sudo -S systemctl start $SERVICE
>   if [ $? -eq 0 ]; then
>     notify_show "Сервис $SERVICE успешно запущен." "Успех"
>      # Открываем браузер
>      sleep 4
>      xdg-open "http://0.0.0.0:8080"
>   else
>     notify_show "Не удалось запустить сервис $SERVICE." "Ошибка"
>   fi
> fi
>else
> # Пользователь выбрал "Нет" или закрыл диалог
> notify_show "Действие отменено." "Информация"
>fi
>
># Удаляем временный SVG файл
>rm -f $ICON
>```
