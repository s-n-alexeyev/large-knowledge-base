2024-04-06

[Оригинальная статья](https://linuxlife.page/posts/25-openconnect-camouflage/)

---
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---
### 1. Ставим все необходимые пакеты для OpenConnect v1.2.4

```shell
sudo apt update && sudo apt install -y vim nano git build-essential libgnutls28-dev libev-dev autoconf automake libtool libpam0g-dev liblz4-dev libseccomp-dev libreadline-dev libnl-route-3-dev libkrb5-dev libradcli-dev libcurl4-gnutls-dev libcjose-dev libjansson-dev liboath-dev libprotobuf-c-dev libtalloc-dev libhttp-parser-dev protobuf-c-compiler gperf iperf3 lcov libuid-wrapper libpam-wrapper libnss-wrapper libsocket-wrapper gss-ntlmssp haproxy iputils-ping freeradius gawk gnutls-bin iproute2 yajl-tools tcpdump

ТУТ можно в теории не ставить iperf3 haproxy freeradius, но я ставлю все, чтобы собралось без проблем
```
### 2. Клонируем репозиторий последней версии [https://gitlab.com/openconnect/ocserv](https://gitlab.com/openconnect/ocserv) (можно перейти и посмотреть в браузере по тегу какая последняя версия, сейчас 1.2.4)

```shell
cd ~ && git clone -b 1.2.4 https://gitlab.com/openconnect/ocserv 
```
### 3. Собираем

```shell
cd ocserv
autoreconf -fvi
./configure && make
sudo make install
```
### 4. Скачаем config

```shell
cd ~/ocserv/src && wget https://gitlab.com/openconnect/ocserv/-/raw/master/doc/sample.config
```
### 5. Генерируем сертификаты и ключи сервера

Первым делом создаем шаблон для генерации ключей

```shell
nano ca-cert.cfg
```

```ini
# X.509 Certificate options

# The organization of the subject.
organization = "142.54.160.100"

# The common name of the certificate owner.
cn = "Example CA"

# The serial number of the certificate.
serial = 001

# In how many days, counting from today, this certificate will expire. Use -1 if there is no expiration date.
expiration_days = -1

# Whether this is a CA certificate or not
ca

# Whether this certificate will be used to sign data
signing_key

# Whether this key will be used to sign other certificates.
cert_signing_key

# Whether this key will be used to sign CRLs.
crl_signing_key
key encipherment
encryption_key
tls_www_server
```

А теперь генерируем ключи:

```shell
certtool --generate-privkey > ./ocserv-key.pem
certtool --generate-self-signed --load-privkey ocserv-key.pem --template ca-cert.cfg --outfile ocserv-cert.pem
```

И также создадим темплейт для dh.pem

```shell
nano dh.conf
```

```ini
key_type = RSA
key_bits = 2048
dh_bits = 2048
```

И генерируем dh.pem

```shell
certtool --generate-dh-params --load-privkey dh.conf --outfile dh.pem
```
### 6. Теперь создаем клиентов VPN

Создаем директорию с конфигурациями внутри ~/ocserv/src

```shell
mkdir ./clients
```

Создаем первого пользователя

```shell
ocpasswd -c ./clients/ocpasswd dmitry
```

Чтобы добавить клиента, также запускаем с другим именем

```shell
ocpasswd -c ./clients/ocpasswd test
```

И проверяем что там уже 2 пользователя:

```shell
cat ./clients/ocpasswd
```
### 7. Теперь работаем с конфигом сервера

```shell
nano ~/ocserv/src/sample.config
```

ВСЕ ПАРАМЕТРЫ ПРОВЕРЯЕМ ПОИСКОМ ЧТОБЫ НЕ ДУБЛИРОВАЛИСЬ!

```ini
server-cert = /home/debian/ocserv/src/ocserv-cert.pem
server-key = /home/debian/ocserv/src/ocserv-key.pem
dh-params = /home/debian/ocserv/src/dh.pem
ca-cert = /home/debian/ocserv/src/ocserv-cert.pem

ЭТО УДАЛЯЕМ
#server-cert = /etc/ocserv/server-cert.pem
#server-key = /etc/ocserv/server-key.pem
#server-cert = ../tests/certs/server-cert.pem
#server-key = ../tests/certs/server-key.pem


auth = "plain[passwd=./clients/ocpasswd]"
#auth = "certificate" - ВЫБИРАТЬ ЧТО-ТО ОДНО! либо pass, либо cert, а также важно, что с сертификатами camouflage не работает, его надо отключать camouflage = false, ЛИБО пытаться подружить с двойной аутентификацией и по паролю и по сертификату, что не очень удобно, но возможно кому-то понадобится в корп среде

tcp-port = 28855  - Порт из бота!
#udp-port = 443  - ОТРУБАЕМ udp, потому что он нам не нужен, так как мы москируемся под веб трафик

compression = true
max-clients = 0
max-same-clients = 2

# КОНФИГИ ДЛЯ ПОЛЬЗОВАТЕЛЕЙ ЕСЛИ НУЖНЫ
#config-per-user = /home/debian/ocserv/src/clients/configs

keepalive = 60
try-mtu-discovery = true
idle-timeout = 1200
mobile-idle-timeout = 2400

Либо так
#ipv4-network = 10.18.18.0
#ipv4-netmask = 255.255.255.0
Либо так
ipv4-network = 10.18.18.0/24   - НАША ПОДСЕТЬ! Можно сделать любую

tunnel-all-dns = true

dns = 8.8.8.8    
dns = 1.1.1.1

# РОУТЫ МОЖЕМ ЗАКОММЕНТИРОВАТЬ ВСЕ, ЕСЛИ ОНИ НАМ НЕ НУЖНЫ, ЕСЛИ НУЖНЫ - СОЗДАЙТЕ СВОЙ ДЛЯ НУЖНОЙ ПОДСЕТИ
#route = 10.10.10.0/255.255.255.0
#route = 192.168.0.0/255.255.0.0
#route = fef4:db8:1000:1001::/64
#route = default
#no-route = 192.168.5.0/255.255.255.0

#for iOS comment line
#user-profile = profile.xml

camouflage = true
camouflage_secret = "mysecretkluch"

#URL СЕРВЕРА В КЛИЕНТЕ, И ПОМЕНЯЙТЕ КЛЮЧ !!! https://142.54.160.100:28855/?mysecretkluch
```
### 8. Создаем директорию clients/configs где будем хранить клиентские конфиги с нужными IP и маршрутами

```shell
nano ./clients/configs/dmitry
```

```ini
explicit-ipv4 = 10.18.18.24
route = 10.17.17.0/24 (к примеру маршрут в соседнюю подсеть wireguard)
```

Имя конфигов должны совпадать с именами пользователей, то есть для dmitry будет также имя ./clients/configs/dmitry
### 9. Включим ipforwarding на сервере

```shell
sudo nano /etc/sysctl.conf
```

```ini
net.ipv4.ip_forward = 1
sudo sysctl -p
```
### 10. Создаем автозапуск правил iptables (ВНИМАТЕЛЬНО СМОТРИМ НАШУ ПОДСЕТЬ, ЛОКАЛЬНЫЙ IP, И ПОРТ ИЗ КОНФИГА)

```shell
sudo nano /etc/systemd/system/ocserv-iptables.service
```

```ini
[Unit]
Before=network.target
[Service]
Type=oneshot

ExecStart=/usr/sbin/iptables -t nat -A POSTROUTING -s 10.18.18.0/24 ! -d 10.18.18.0/24 -j SNAT --to 10.10.10.101
ExecStart=/usr/sbin/iptables -I INPUT -p udp --dport 28855 -j ACCEPT
ExecStart=/usr/sbin/iptables -I FORWARD -s 10.18.18.0/24 -j ACCEPT
ExecStart=/usr/sbin/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

ExecStop=/usr/sbin/iptables -t nat -D POSTROUTING -s 10.18.18.0/24 ! -d 10.18.18.0/24 -j SNAT --to 10.10.10.101
ExecStop=/usr/sbin/iptables -D INPUT -p udp --dport 28855 -j ACCEPT
ExecStop=/usr/sbin/iptables -D FORWARD -s 10.18.18.0/24 -j ACCEPT
ExecStop=/usr/sbin/iptables -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
```

И команды для запуска сервиса iptables

```shell
sudo systemctl daemon-reload
sudo systemctl enable ocserv-iptables.service
sudo systemctl start ocserv-iptables.service
sudo systemctl status ocserv-iptables.service
```
### 11. Запускаем OpenConnect Server с логированием для первого теста

```shell
sudo ./ocserv -d 9 -f -c sample.config
```
### 12. Подключаемся с помощью клиентов Android/iOS и Linux

```
Android/iOS в поиске вводим OpenConnect и ставим Cisco AnyConnect либо нативный OpenConnect
```

Linux: Ставим openconnect из репозитория - утилита
```shell
sudo openconnect https://142.54.160.100:28855/?mysecretkluch
```

Еще вариант GUI:
Для gnome лучше плагином networkmanager-openconnect или любым openconnect GUI
### 13. Проверяем работает ли маскировка camouflage

Открываем в браузере https://142.54.160.100:28855/
### 14. Создаем сервис ocserv (Можно убрать в ExecStart флаг -d 9, чтобы писалось меньше логов, либо выставить -d 4)

```shell
sudo nano /etc/systemd/system/ocserv.service
```

```ini
[Unit]
After=network.target
[Service]
WorkingDirectory=/home/debian/ocserv/src
Type=simple
ExecStart=/home/debian/ocserv/src/ocserv -d 9 -f -c /home/debian/ocserv/src/sample.config
ExecStop=/bin/kill $(cat /run/ocserv.pid)
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

И команды для запуска сервисов

```shell
sudo systemctl daemon-reload
sudo systemctl enable ocserv.service
sudo systemctl start ocserv.service
sudo systemctl status ocserv.service
```
### Дополнительные материалы

[OpenConnect VPN server](https://ocserv.openconnect-vpn.net/ocserv.8.html)  
[Set Up OpenConnect VPN Server (ocserv) on Ubuntu 20.04](https://www.linuxbabe.com/ubuntu/openconnect-vpn-server-ocserv-ubuntu-20-04-lets-encrypt)  
[Set up Certificate Authentication in OpenConnect VPN Server (ocserv)](https://www.linuxbabe.com/ubuntu/certificate-authentication-openconnect-vpn-server-ocserv)  