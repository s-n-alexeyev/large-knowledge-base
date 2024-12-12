Установка 3proxy с поддержкой http(s) и socks5-proxy

Ни в коем случае не устанавливайте сервер без авторизации, т.к. этим незамедлительно воспользуются злоумышленники — создадут большой трафик и организуют рассылку спама через ваш сервер.
# Установка

Так как в репозиториях 3proxy как правило отсутствует, мы будем устанавливать его из исходников. Для установки потребуется установить некоторые пакеты.

Для AlmaLinux и CentOS 7:

```bash
yum -y install gcc wget tar make
```

Для Debian и Ubuntu (предварительно лучше выполнить команду apt update):

```bash
apt install -y build-essential wget tar
```

Далее скачиваем файлы 3proxy (ссылка на актуальную версию 3proxy со временем может измениться) и распаковываем архив:

```bash
wget https://github.com/3proxy/3proxy/releases/download/0.9.4/3proxy-0.9.4-x64.zip
tar -xvzf 0.9.4.tar.gz
```

Переходим в распакованную директорию и компилируем:

```bash
cd 3proxy-0.9.4/
make -f Makefile.Linux
```

# Настройка

Создаем директорию для конфигурационных файлов, директорию для логов и переносим исполняемый файл 3proxy:

```bash
mkdir /etc/3proxy
mkdir -p /var/log/3proxy
cp bin/3proxy /usr/bin/
```

Теперь создадим пользователя для работы с 3proxy:

```bash
useradd -s /usr/sbin/nologin -U -M -r proxyuser
```

И даем нашему пользователю proxyuser права на директории /etc/3proxy, /var/log/3proxy и /usr/bin/3proxy:

```bash
chown -R proxyuser:proxyuser /etc/3proxy
chown -R proxyuser:proxyuser /var/log/3proxy
chown -R proxyuser:proxyuser /usr/bin/3proxy
```

Создаем новый конфигурационный файл:

```bash
touch /etc/3proxy/3proxy.cfg
```

И даём права на конфигурационный файл только пользователю root:

```bash
chmod 600 /etc/3proxy/3proxy.cfg
```

Дальше необходимо правильно заполнить созданный конфигурационный файл. Для этого нам понадобится узнать uid и gid нашего пользователя proxyuser:

```bash
id proxyuser
```
`uid=991(proxyuser) gid=991(proxyuser) groups=991(proxyuser)`

Запоминаем uid и gid пользователя, вставляем текст из примера файла конфигурации с помощью удобного для вас текстового редактора и сохраняем.

Пример файла конфигурации

Пример файла конфигурации 3proxy.cfg, который должен у вас получиться после его редактирования:

```ini
# Настройка запуска сервера от пользователя proxyuser и заданным паролем password
auth strong
users proxyuser:CL:password

# Вставляем uid и gid нашего пользователя, которые мы узнали ранее
setgid 991
setuid 991

# Указываем правильные сервера имен. Посмотреть можно в /etc/resolv.conf
nserver 8.8.8.8
nserver 8.8.4.4

# Используем таймауты и размер кэша для запросов DNS по умолчанию
timeouts 1 5 30 60 180 1800 15 60
nscache 65536

# Указываем режим запуска как daemon
daemon

# Настраиваем http proxy на стандартном порту 3128
proxy -p3128

# Настраиваем socks proxy на стандартном порту 1080
socks -p1080 
# параметры порта и интерфейсов задаются аналогично proxy

# Указываем путь к логам, формат лога и ротацию
log /var/log/3proxy/3proxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"

rotate 30
```

Создаем файл-инициализации для systemd и настраиваем верные права:

```bash
touch /etc/systemd/system/3proxy.service
chmod 664 /etc/systemd/system/3proxy.service
```

В данный файл нужно вставить следующий текст

```ini
[Unit]
Description=3proxy Proxy Server
After=network.target
[Service]
Type=simple
ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg
ExecStop=/bin/kill `/usr/bin/pgrep proxyuser`
RemainAfterExit=yes
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

Сохраняем и обновляем конфигурацию systemd:

```bash
systemctl daemon-reload
```

Запускаем 3proxy и добавляем его в автозагрузку:

```bash
systemctl start 3proxy
systemctl enable 3proxy
```

Не забудьте открыть порт http proxy в firewalld или iptables.

Настройка закончена. На порту 3128 теперь у вас работает http-proxy, а на порту 1080 — socks-proxy.
# Исправление распространённых проблем
## Проблема 1

Из-за кеширования доменных имён есть вероятность, что ваш новый домен для вас будет недоступен.

Решение: необходимо дождаться обновления записей DNS либо прописать в файл hosts IP-адрес вашего сервера и новый домен.
## Проблема 2

Ваш прокси-сервер с дефолтными портами рано или поздно найдут.

Решение: поменять порты. 

```ini
# на http proxy слушать порт 7834 
proxy -n -p7834

# на socks слушать порт 7835
socks -p7835   
```

Но их тоже могут найти. Поэтому можно в фаерволе разрешить доступ с определённых адресов, а остальным — запретить. Довольно негибкое (так как у вас может и не быть статического IP), но железное решение.
## Проблема 3

Если вы ведёте логи, в которых отражаются все соединения, со временем они станут занимать всё больше места. В конечном итоге логи могут занять всё место на диске.

Решение: не вести логи или настроить их ротацию. 

Лучше предусмотреть всё заранее.
Упрощенный конфиг анонимного http(s) proxy сервера на порту 3128

```ini
users proxyuser:CL:password
daemon
log /var/log/3proxy/3proxy.log D
rotate 30
auth strong
proxy -n -a
setgid 65534
setuid 65534
```

Также нужно создать директорию под логи и выставить права (мы запускаем сервер с минимальными правами nobody в системе используя директивы setgid/setud):

```bash
mkdir /var/log/3proxy ; chown nobody /var/log/3proxy
```

# Установка 3proxy в Docker

Рассмотрим вариант установки 3proxy в Docker.

Для начала потребуется установить некоторые пакеты (а для свежеустановленных ОС Debian и Ubuntu, возможно, ещё потребуется обновить индекс пакетов apt командой # apt update).

Для AlmaLinux и CentOS:

```bash
yum install docker docker-compose
```

для Ubuntu и Debian:

```bash
apt install docker docker.io docker-compose
```

Скачиваем образ:

```bash
docker pull 3proxy/3proxy
```

По умолчанию 3proxy использует безопасную среду chroot в /usr/local/3proxy с uid 65535 и gid 65535, и ожидает, что конфигурационный файл 3proxy будет помещен в /usr/local/etc/3proxy. Пути в конфигурационном файле должны указываться относительно /usr/local/3proxy, т.е. должно быть /logs вместо /usr/local/3proxy/logs. В chroot требуется разрешение для nserver.

Для этого создадим директорию и конфигурационный файл 3proxy:

```bash
mkdir -p /etc/dockerapp/3proxy
touch /etc/dockerapp/3proxy/3poxy.conf
```

Далее с помощью любого удобного для вас текстового редактора необходимо отредактировать созданный конфигурационный файл 3proxy.conf. Для запуска 3proxy в Docker достаточно минимальной конфигурации:

```ini
nserver 8.8.8.8
socks -p3129
```

Для того чтобы добавить логирование и пользователя, необходимо в файл конфигурации 3proxy добавить:

```ini
log /logs/3proxy.log
auth strong
users "proxyuser:CR:87beeef3f4ee4661ac1897eca216fc26"
```

Вместо «87beeef3f4ee4661ac1897eca216fc26» необходимо указать хэш MD5 пароля для пользователя proxyuser.
 
Узнать хэш MD5 можно с помощью команды.
```bash
echo -n "password" | openssl dgst -md5 | awk '{print $2}'
```

Запустим 3proxy с помощью docker-compose. Для этого потребуется создать файл конфигурации в формате .yml:

```bash
touch /etc/dockerapp/3proxy/docker-compose.yml
```

Вставляем туда с помощью текстового редактора следующий текст:

```yml
version: "2.1"
services:
  3proxysvc:
image: 3proxy/3proxy:latest
container_name: 3proxy
volumes:
   - /etc/dockerapp/3proxy/conf:/usr/local/3proxy/conf
ports:
   - 8080:3129
restart: unless-stopped
```

Сохраняем. В данном файле мы указали внешний порт 8080. Теперь можем запускать:

```bash
docker-compose -f /etc/dockerapp/3proxy/docker-compose.yml up -d
```

Получим примерно такой ответ:

```
Creating network "3proxy_default" with the default driver
Creating 3proxy ... done
```

Проверяем:

```bash
docker ps
```
