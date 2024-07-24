2024-04-30

[Оригинальная статья](https://totaku.ru/ustanovka-docker-i-docker-compose-na-ubuntu-24-04/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Установка Docker на примере Ubuntu

В репозитории Ubuntu может быть не самая последняя версия Docker. По этому мы будем устанавливать его из официального репозитория Docker.

## Подготовка репозитория

>Сначала обновите существующий список пакетов:
```bash
sudo apt update
```

>Затем установите несколько обязательных пакетов, которые позволяют `apt` использовать пакеты по HTTPS:
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

>Добавляем ключ GPG официального репозитория Docker в вашу систему:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

>Добавляем репозиторий Docker:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \| \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## Установка Docker

>Снова обновляем список пакетов:
```bash
sudo apt update
```

>Теперь надо убедится, что все нормально и установка будет из репозитория Docker, а не Ubuntu:
```bash
apt-cache policy docker-ce
```

>На выходе видим плюс минус такую картину:
```q
docker-ce:
  Installed: (none)
  Candidate: 5:26.1.1-1~ubuntu.24.04~noble
  Version table:
     5:26.1.1-1~ubuntu.24.04~noble 500
        500 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages
     5:26.1.0-1~ubuntu.24.04~noble 500
        500 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages
     5:26.0.2-1~ubuntu.24.04~noble 500
        500 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages
     5:26.0.1-1~ubuntu.24.04~noble 500
        500 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages
     5:26.0.0-1~ubuntu.24.04~noble 500
        500 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages
```

>Непосредственно устанавливаем Docker:
```bash
sudo apt install docker-ce
```

## Проверяем работает ли Docker

>Для начала узнаем, что там с Docker’ом:
```bash
sudo systemctl status docker
```

>На выходе:
```q
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-04-01 21:30:25 UTC; 22s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 7854 (dockerd)
      Tasks: 7
     Memory: 38.3M
        CPU: 340ms
     CGroup: /system.slice/docker.service
             └─7854 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

>Теперь давайте попробуем запустить какой нибудь контейнер:
```bash
sudo docker run hello-world
```

>Если все хорошо, то на выходе увидим:
```q
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete
Digest: sha256:bfea6278a0a267fad2634554f4f0c6f31981eea41c553fdf5a83e95a41d40c38
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

>Удаляем тестовый контейнер
```bash
sudo docker rmi -f hello-world
```

## Разрешаем не root пользователю запускать Docker

По умолчанию обычные пользователи не могут запускать докер без использования `sudo`, но все поправимо.  
Никогда так не делайте на продакшине! Это практически выдача рутовых прав пользователю

>Добавляем своего пользователя в группу `docker`:
```bash
sudo usermod -aG docker ${USER}
```

>Перелогиваемся и смело выполняем:
```bash
docker run hello-world
```

## Устанавливаем Docker-compose

>Запускаем эту команду для установки последней версии docker-compose, проверить какая версия является последней можно [тут](https://github.com/docker/compose/releases):
```bash
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/$(\
curl -s https://api.github.com/repos/docker/compose/releases/latest | \
grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/\
docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
```

>Делаем файл исполняемым:
```bash
chmod +x ~/.docker/cli-plugins/docker-compose
```

> Проверяем как все работает:
```bash
docker compose version
```

>Увидим примерно такое:
```q
Docker Compose version v2.29.1
```
