 <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#1794D4"/><path fill="#fff" d="M18 7h-2v2h2zM10 10h2v2h-2zM6.002 16.941C6.172 19.843 7.9 24 14 24c6.8 0 9.833-5 10.5-7.5.833 0 2.7-.5 3.5-2.5-.5-.5-2.5-.5-3.5 0 0-.8-.5-2.5-1.5-3-.667.667-1.7 2.4-.5 4-.5 1-1.833 1-2.5 1H6.943c-.53 0-.973.413-.941.941M9 13H7v2h2z"/><path fill="#fff" d="M10 13h2v2h-2zM15 13h-2v2h2zM16 13h2v2h-2zM21 13h-2v2h2zM15 10h-2v2h2zM16 10h2v2h-2z"/></svg> 
## Install DOCKER

[Official DOCKER installation page](https://docs.docker.com/engine/install/ubuntu/)  
Официальный скрипт, который всё сделает за Вас:

```shell
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh
```
## Info and Registry

>Информация обо всём в установленном Docker  
```shell
docker info
```

>История образа 
```shell
docker history 
``` 

>Дать тег образу локально или в registry  
```shell
docker tag 
```

>Залогиниться в registry 
```
docker login 
``` 

>Поиск образа в registry
```
docker search
``` 

>Загрузить образ из Registry себе на хост 
```
docker pull
```

>Отправить локальный образ в registry
```
docker push
```
## Container Management

>Посмотреть все контейнеры
```
docker ps -а
``` 

>Запустить контейнер 
```
docker start container-name
```

>Убить (SIGKILL) /Остановить (SIGTERM) контейнер
```shell
docker kill/stop container-name
```

>Вывести логи контейнера, последние 100 строк
```shell
docker logs --tail 100 container-name
```

>Вся информация о контейнере + IP
```shell
docker inspect container-name
```

>Удалить контейнер (поле каждой сборки Dockerfile)
```shell
docker rm container-name
```

>Удалить все запущенные и остановленные контейнеры
```shell
docker rm -f $(docker ps -aq)
```

>Просмотр событий
```shell
docker events container-name
```

>Показать публичный порт контейнера
```shell
docker port container-name
```

>Отобразить процессы в контейнере
```shell
docker top container-name
```

>Статистика использования ресурсов в контейнере
```shell
docker stats container-name
```

>Изменения в ФС контейнера
```shell
docker diff container-name
```
## Images

>Построение контейнера в текущей папке, скачивает все слои для запуска образа
```shell
docker build -t my_app .
```

>Показать все образы в системе
```shell
docker images
docker image ls
```

>Удалить образы
```shell
docker rmi image-name
```

>Создает образ из контейнера
```shell
docker commit containerName/containerID lepkov/debian11slim:version3
```

>Вставляет файл из URL в контейнер
```shell
docker insert URL
```

  >Сохранить образ в backup.tar в STDOUT с тегами, версиями, слоями 
```shell
docker save -o backup.tar
```

>Загрузить образ в .tar в STDIN с тегами, версиями, слоями
```shell
docker load
```

>Создать образ из .tar
```shell
docker import
```

>Посмотреть историю слоёв образа
```shell
docker image history --no-trunc
```

>Удалит все, кроме используемого (лучше не использовать на проде, ещё кстати из-за старого кеша может собираться cтарая версия контейнера)
```shell
docker system prune -f
```
## Run

>Запуск контейнера интерактивно или как демона/detached (-d), Порты: слева хостовая система, справа в контейнере, пробрасывается сразу 2 порта 80 и 22, используется легкий образ Debian 11 и команда бесконечный сон
```shell
docker run -d -p 80:80 -p 22:22 debian:11.1-slim sleep infinity
# --rm удалит после закрытия контейнера, --restart unless-stopped добавит автозапуск контейнера
```

>Добавит к контейнеру правило перезапускаться при закрытии, за исключением команды стоп, автозапуск по-сути
```shell
docker update --restart unless-stopped redis
```

>Интерактивно подключиться к контейнеру для управления, exit чтобы выйти
```shell
docker exec -it container-name /bin/bash
# ash для alpine
```

>Интерактивно подключиться к контейнеру для управления из под root, exit чтобы выйти
```shell
docker exec -u root -it container-name /bin/bash
# ash для alpine
```

Подключиться к контейнеру чтоб мониторить ошибки логи в режиме реального времени
```shell
docker attach container-name
```
## Volumes

>Скопировать в корень контейнера file
```shell
docker cp file <containerID>:/
```

>Скопировать file из корня контейнера в текущую директорию командной строки
```shell
docker cp <containerID>:/file .
```

>Создать volume для постоянного хранения файлов
```shell
docker volume create todo-db
```

>Добавить named volumу todo-db к контейнеру (они ok когда мы не заморачиваемся где конкретно хранить данные)
```shell
docker run -dp 3000:3000 --name=dev -v todo-db:/etc/todos container-name
```

>Тоже самое что команда сверху
```shell
docker run -dp 3000:3000 --name=dev --mount source=todo-db,target=/etc/todos container-name
```

>Отобразить список всех volume
```shell
docker volume ls
```

Инспекция volume 
```shell
docker volume inspect
```

>Удалить volume
```shell
docker volume rm
```
## Network

>Создать сеть
```shell
docker network create todo-app
```

>Удалить сеть
```shell
docker network rm
```

>Отразить все сеть
```shell
docker network ls
```

>Вся информация о сети
```shell
docker network inspect
```

>Соединиться с сетью
```shell
docker network connect
```

>Отсоединиться от сети
```shell
docker network disconnect
```


>Пробросить текущую папку в контейнер и работать на хосте, -w working dir, sh shell
```shell
docker run -dp 3000:3000 \
-w /app -v "$(pwd):/app" \
node:12-alpine \
sh -c "yarn install && yarn run dev"
```

>Запуск контейнера с присоединением к сети и заведение переменных окружения
```shell
docker run -d \
--network todo-app --network-alias mysql \ (алиас потом сможет резолвить докер для других контейнеров)
-v todo-mysql-data:/var/lib/mysql \ (автоматом создает named volume)
-e MYSQL_ROOT_PASSWORD=secret \ (в проде нельзя использовать, небезопасно)
-e MYSQL_DATABASE=todos \ (в проде юзают файлы внутри конейнера с логинами паролями)
mysql:5.7
```

>Запуск контейнера с приложением
```shell
docker run -dp 3000:3000 \
-w /app -v "$(pwd):/app" \
--network todo-app \
-e MYSQL_HOST=mysql \
-e MYSQL_USER=root \
-e MYSQL_PASSWORD=secret \
-e MYSQL_DB=todos \
node:12-alpine \
sh -c "yarn install && yarn run dev"
```
## Variables

![|600](/Media/Docker/image_1.png)  
*.env* файл это только для Docker Compose  
*ARG* используются только во время билда в Dockerfile, контейнеры не имеют доступа к ним, но значения ARG можно присвоить в ENV переменные в Dockerfile  
*ENV* переменные доступны и в билде и в контейнере

### Пример Dockerfile со всеми переменными / variables

```shell
# Build with this command: docker build -t envvars_image:latest .
# Run with this: docker run -d -e "VAR4=I'm from start command" --env-file=env_file --name envvars_container envvars_image:latest
# Connect with this: docker exec -it envvars_container /bin/ash
FROM alpine:latest
#VAR1 with no default value will end up with an error if no --build-arg VAR1="I'm from ARG" provided
ARG VAR1="I'm from ARG" #or VAR1 "I'm from ARG"
ENV VAR2=$VAR1
ENV VAR3="I'm env variable"
CMD ["sleep","infinity"]

#example: docker run -e VAR5 alpine env (pass value from host)
#example: docker run --env-file=env_file alpine env (contents:VAR6="I'm from env_file")
#Use printenv to look for environment variables inside the container
#Use docker inspect to look for environment variables
```

Файл *env_file*, содержимое:  
VAR5=I'm from env_file

## CMD VS ENTRYPOINT

Разница в том, что CMD выполняется из под /bin/sh по дефолту, а ENTRYPOINT без него.  
В случае с CMD, команда и параметры к ней захардкожены в образ, пример запуска с переопределением команды CMD ["sleep","10"]

```shell
docker run ubuntu sleep 5
```

Контейнер проспит 5 секунд вместо 10.

В случае с ENTRYPOINT, **только команда** захардкожена в образ, пример запуска с переопределением команды ENTRYPOINT ["sleep"] CMD ["10"] (Есл используются обе директивы, то в энтрипоинте команда, а в cmd параметры к ней)

```markup
docker run ubuntu 5
```

Контейнер проспит 5 секунд вместо 10.  
Чтобы **переопределить ENTRYPOINT:**

```markup
docker run --entrypoint another-command ubuntu 20
```

Обычно практика такая, всегда используй CMD, если только не требуется каждый раз запускать контейнер с разным параметром (экономия времени, чтоб каждый раз не вводить строчку с командой)

>Разрешение docker.sock
```shell
sudo chmod -R 777 /var/run/docker.sock
```

## Best Practice

Следуй принципу минимальных привилегий, процессы в контейнере никогда не должны выполняться из под рута, кроме редких случаев, нужно добавлять команду user и менять юзера на non-root.  
Не привязываться к UID, он динамичен, можно записать во временную папку UID.  
Сделать все исполняемые файлы владельцем рута, чтобы никто не изменил исполняемые файлы, а пользователю достаточно только права на выполнение.  
Чем меньше компонентов и открытых портов, тем меньше поверхность для атак.  
Использовать multistage для промежуточного контейнера для компиляции всего, зависимостей, временных файлов, образ может весить на треть меньше.  
Distroless с чистого листа, использовать минимальный набор пакетов, например избавиться от образа Ubuntuи выбрать Debian-base, наши контейнеры содержат уязвимости изначального образа, чекать это.  
Нужно обновлять всё до того, как выйдет из под поддержки.  
Оставлять только те порты, которые реально нужны, избегать 22 и 21 3389 (ssh & ftp & rdp).  
Никогда не помещайте логины/пароли в команде, в докерфайлах, переменных, docker secret или любой другой менеджер секретов ok.  
Не использовать ADD, только COPY (когда используем точку - это воркдир где лежит докерфайл).  
При сборке используйте .dockerignore чтобы убрать сенситив дату, это как .gitignore.  
При сборке вначале команд лучше кешировать команду ран, а потом скопировать исходные данные.  
Метадату записать.  
Использовать тесты типа Linter и сканеры образов для CI.  
Время от времени делать prune, докер любит много места жрать


Согласно официальным документам Docker, приведенным здесь:

[https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user)

Вам нужно сделать следующее:

Чтобы создать группу docker и добавить своего пользователя:

- Создайте группу docker.

```
sudo groupadd docker
```

- Добавьте своего пользователя в группу docker.

```
sudo usermod -aG docker ${USER}
```

- Вам нужно будет выйти из системы и снова войти в систему, чтобы повторно оценить ваше членство в группе, или введите следующую команду:

```
su -s ${USER}
```

- Убедитесь, что вы можете запускать команды docker без sudo.

```
docker run hello-world
```

- Эта команда загружает тестовый образ и запускает его в контейнере. Когда контейнер запускается, он печатает информационное сообщение и завершает работу.
    
- Если вы изначально запускали команды Docker CLI с использованием sudo перед добавлением вашего пользователя в группу docker, вы можете увидеть следующую ошибку, которая указывает на то, что ваш `~/.docker/` каталог был создан с неправильными разрешениями из-за команд sudo.
    

```
WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied
```

- Чтобы устранить эту проблему, либо удалите `~/.docker/` каталог (он создается автоматически, но все пользовательские настройки теряются), или измените его владельца и разрешения с помощью следующих команд:

```
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```

## Скрипт GUI для запуска/остановки Docker сервиса

```shell
#!/bin/bash

#Очищаем неудачные попытки входа
faillock --user $USER --reset

# Просим пароль root
password=$(yad --entry --title="Авторизация" \
--window-icon="lock" --image "lock" \
--width=300 --fixed \
--text="Введите root пароль:" --hide-text)

if [ -z $password ]; then
    exit 0
fi

# Функция для отображения сообщений
notify_show() {
    notify-send "$1" --icon=$ICON --app-name="$2 " --expire-time=4000
}

# Проверка пароля с использованием sudo
ICON="state-error"
echo "$password" | sudo -S ls >/dev/null 2>&1
if [ $? -ne 0 ]; then
    notify_show $'Неверный пароль!\nЗавершение работы.' "Ошибка"
    exit 1
fi

DOCKER_SERVICE="docker"
DOCKER_SOCKET="docker.socket"
ICON="/tmp/docker_icon.svg"

docker_icon_SVG='<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48"
fill="none" viewBox="0 0 32 32"><circle cx="16" cy="16" r="14" fill="#1794D4"/>
<path fill="#fff" d="M18 7h-2v2h2zM10 10h2v2h-2zM6.002 16.941C6.172 19.843 7.9
24 14 24c6.8 0 9.833-5 10.5-7.5.833 0 2.7-.5 3.5-2.5-.5-.5-2.5-.5-3.5 0
0-.8-.5-2.5-1.5-3-.667.667-1.7 2.4-.5 4-.5 1-1.833 1-2.5 1H6.943c-.53
0-.973.413-.941.941M9 13H7v2h2z"/><path fill="#fff" d="M10 13h2v2h-2zM15
13h-2v2h2zM16 13h2v2h-2zM21 13h-2v2h2zM15 10h-2v2h2zM16 10h2v2h-2z"/></svg>'

# Сохраняем картинку в SVG
echo "$docker_icon_SVG" > $ICON

# Проверка состояния службы Docker
status=$(echo "$password" | sudo -S systemctl is-active $DOCKER_SERVICE)

# Формируем сообщение в зависимости от состояния службы
if [ "$status" = "active" ]; then
    message="<span foreground='green'><b>Сервис Docker активен.</b></span>\nХотите его остановить?"
else
    message="<span foreground='red'><b>Сервис Docker остановлен.</b></span>\nХотите его запустить?"
fi

# Запрашиваем ответ пользователя
yad --title "Управление Docker" --image $ICON --window-icon=$ICON --fixed --text "$message" \
--button=Да:0 \
--button=Нет:1 \

# Проверяем ответ
response=$?
if [ $response -eq 0 ]; then
    # Пользователь выбрал "да"
    if [ "$status" = "active" ]; then
        # Останавливаем docker.socket
        echo "$password" | sudo -S systemctl stop $DOCKER_SOCKET
            if [ $? -eq 0 ]; then
                notify_show "Сервис $DOCKER_SOCKET успешно остановлен."
            else
                notify_show "Не удалось остановить сервис $DOCKER_SOCKET." "Ошибка"
            fi
        # Останавливаем docker.service
        echo "$password" | sudo -S systemctl stop $DOCKER_SERVICE
            if [ $? -eq 0 ]; then
                notify_show "Сервис $DOCKER_SERVICE успешно остановлен"
            else
                notify_show "Не удалось остановить $DOCKER_SERVICE." "Ошибка"
            fi
    else
        # Служба Docker остановлена, запускаем её
        echo "$password" | sudo -S systemctl start $DOCKER_SERVICE
            if [ $? -eq 0 ]; then
                notify_show "Сервис $DOCKER_SERVICE успешно запущен."
            else
                notify_show "Не удалось запустить $DOCKER_SERVICE." "Ошибка"
            fi
    fi
else
    # Пользователь выбрал "нет" или закрыл диалог
    notify_show "Действие отменено."
fi

rm -f $ICON
exit 0
