2024-12-06

Файлы SVG, особенно те, которые экспортируются из векторных редакторов, обычно содержат много лишней информации. Они включает метаданные редактора, комментарии, скрытые элементы, значения по умолчанию или неоптимальные значения и другую информацию, которую можно безопасно удалить или преобразовать без особого влияния на отображение.

SVGOMG предоставляет несколько опций для очистки и сжатия ваших файлов SVG.
# Установка SVGOMG

Клонирование svgomg
```bash
git clone https://github.com/jakearchibald/svgomg
```

После клонирования репозитория хорошей практикой является перемещение клонированной директории в более подходящее место на вашей системе. В данном случае рекомендуется переместить её в `/opt`, так как это обычно используется для установки программных пакетов, которые не являются частью стандартного дистрибутива.

Команда для перемещения каталога SVGOMG в /opt выглядит следующим образом:
```bash
sudo mv ./svgomg /opt
```

Эта команда требует привилегий суперпользователя, поэтому используется `sudo`. Она перемещает весь каталог SVGOMG из его текущего местоположения в `/opt`.
# Запуск SVGOMG

Запуск сервера из консоли:
```bash
cd /opt/svgomg/  
npm run dev
```

Страница SVGOMG в браузере по адресу [http://localhost:8080](http://localhost:8080)
![](/Media/Pictures/SVGOMG/screenshot1.png)
# Настройка сервиса

Для того чтобы приложение запускалось в виде сервиса, а не в консоли, его можно создать с помощью `systemd`.

Создание файла `/etc/systemd/system/svgomg.service`
```bash
sudo nano /etc/systemd/system/svgomg.service
```

со следующим содержимым:
```ini
[Unit]  
Description=SVGOMG Development Server  
After=network.target  
  
[Service]  
Type=simple  
User=user  
WorkingDirectory=/opt/svgomg  
ExecStart=npm run dev  
Restart=on-failure  
  
[Install]  
WantedBy=multi-user.target
```

Активация и запуск сервиса:
```bash
sudo systemctl daemon-reload
sudo systemctl start svgomg.service
```

Остановка сервиса:
```bash
sudo systemctl stop svgomg.service
```

Автозапуск при загрузке системы:
```bash
sudo systemctl enable svgomg.service
```

>[!warning] Если порт `8080` уже занят!
Чтобы изменить порт открываем файл `gulpfile.js`, найдя строчку `port: 8080` и заменив порт на желаемый, после чего нужно перезапустить сервис и открыть страницу в браузере уже с новым портом.
# Дополнительно

Можно создать ярлык на рабочем столе, добавив в него путь на файл со скриптом, для того чтобы не пользоваться консолью для старта/остановки сервиса, в качестве аргумента командной строки можно указать пароль для `root`
>[!example]- Скрипт для запуска/остановки сервиса svgomg
>```bash
>#!/bin/bash
>
># Функция проверки зависимостей
>check_dependencies() {
>    local dependencies=("yad" "npm" "faillock" "notify-send" "systemctl" "sudo")
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
>SERVICE="svgomg"
>ICON="/tmp/svgomg_icon.svg"
>
># Сохраняем картинку в SVG
>echo '<svg width="48" height="48" viewBox="0 0 600 600"><path fill="#0097a7" d="M0 2h600v598H0z"/><path fill="#00bcd4" d="M0 0h600v395.7H0z"/><path d="M269.2 530.3 519 395.5H269.2v134.8zM214.4 91.8H519v303.7H214.4V91.8z" opacity=".2"/><path fill="#fff" d="M80 341.7h189.2v188.6H80z"/></svg>' > $ICON
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
>      notify_show "Сервис $SERVICE успешно запущен. Адрес http://localhost:8808" "Успех"
>
>      # Открываем браузер по адресу
>      sleep 4
>      xdg-open "http://localhost:8808"
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

