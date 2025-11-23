```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---
# Ручная установка

![](https://www.youtube.com/embed/5Aql0V-ta8A)

## Текстовая инструкция по настройке Wireguard

>Обновляем сервер:
```shell
apt update && apt upgrade -y
```

>Ставим wireguard:
```shell
apt install -y wireguard
```

>Генерируем ключи сервера:
```shell
wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey
```

>Проставляем права на приватный ключ:
```shell
chmod 600 /etc/wireguard/privatekey
```

>Проверим, как у вас называется сетевой интерфейс:
```shell
ip a
```

>Скорее всего у вас сетевой интерфейс eth0, но возможно и другой, например, ens3 или как-то иначе. Это название интерфейса используется далее в конфиге /etc/wireguard/wg0.conf, который мы сейчас создадим:
```shell
nano /etc/wireguard/wg0.conf
```

```q
[Interface]
PrivateKey = <privatekey>
Address = 10.0.0.1/24
ListenPort = 51830
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Если не знаете текстовый редактор vim — откройте файл с nano, он проще в работе.  
Обратите внимание — в строках PostUp и PostDown использован как раз сетевой интерфейс eth0. Если у вас другой — замените eth0 на ваш.  
Вставляем вместо \<privatekey\> содержимое файла /etc/wireguard/privatekey  

>Настраиваем IP форвардинг:
```shell
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

>Включаем systemd демон с wireguard:
```shell
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service
```

>Создаём ключи клиента:
```shell
wg genkey | tee /etc/wireguard/wg_alex_privatekey | wg pubkey | tee /etc/wireguard/wg_alex_publickey
```

Добавляем в конфиг сервера клиента:
```shell
nano /etc/wireguard/wg0.conf
```

```q
[Peer]
PublicKey = <wg_alex_publickey>
AllowedIPs = 10.0.0.2/32
```

Вместо \<wg_alex_publickey\>  — заменяем на содержимое файла /etc/wireguard/wg_alex_publickey

>Перезагружаем systemd сервис с wireguard:
```shell
systemctl restart wg-quick@wg0
systemctl status wg-quick@wg0
```

>На локальной машине (например, на ноутбуке) создаём текстовый файл с конфигурацией клиента:
```shell
nano wg_alex.conf
```

```q
[Interface]
PrivateKey = <CLIENT-PRIVATE-KEY>
Address = 10.0.0.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = <SERVER-PUBKEY>
Endpoint = <SERVER-IP>:51830
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
```

Здесь \<CLIENT-PRIVATE-KEY\> заменяем на приватный ключ клиента, то есть содержимое файла /etc/wireguard/wg_alex_privatekey на сервере.  \<SERVER-PUBKEY\> заменяем на публичный ключ сервера, то есть на содержимое файла /etc/wireguard/publickey на сервере. \<SERVER-IP\> заменяем на IP сервера. 

Этот файл открываем в Wireguard клиенте (есть для всех операционных систем, в том числе мобильных) — и жмем в клиенте кнопку подключения.

---
# Скрипт для автоматической установки

## Установка своего VPN-сервера WireGuard на VPS-хостинге

![|300](../../Media/Pictures/Wireguard/image_1.png)

[WireGuard](https://www.wireguard.com/) – самый актуальный и быстрый VPN-протокол на сегодняшний день. Обеспечивает максимальную скорость работы и надежную криптографическую защиту.
## 1. VPS-хостинг и клиенты

VPS-хостинг желательно выбирать в Европе, но сейчас оплатить его уже будет проблематично. Можно подобрать хостинг на сайтах [VPS.today](https://vps.today/) и [Hostings.info](https://ru.hostings.info/) в России с серверами в Европе (например в Нидерландах), главное выбрать сервер с **KVM-виртуализацией** и наличием канала минимум 100 Мбит/с с безлимитным трафиком или с его приличным объемом.

На этапе выбора ОС для сервера выбираем **Ubuntu 18.04**. На поднятие сервера нужно время, после чего приходит письмо из которого нам нужно три пункта: IP-адрес сервера, имя пользователя (root), пароль.

Заранее установите необходимые вам клиенты WireGuard: [Windows](https://download.wireguard.com/windows-client/wireguard-installer.exe), [macOS](https://itunes.apple.com/us/app/wireguard/id1451685025?ls=1&mt=12), [Android](https://play.google.com/store/apps/details?id=com.wireguard.android), [iOS](https://itunes.apple.com/us/app/wireguard/id1441195209?ls=1&mt=8).

## 2. Подключение к серверу

Для удобства будем использовать кроссплатформенный SSH-клиент [Hyper](https://hyper.is/#installation).

1. Подключаемся к серверу с вашим IP-адресом и именем пользователя следующей командой:

```shell
ssh root@IP
```

2. Пишем yes, затем вводим пароль от вашего сервера (не отображается при вводе, но можно вставить из буфера обмена):

```
пароль
```

3. После подключения к серверу проверяем ОС на наличие обновлений:

```shell
apt update && apt upgrade
```
## 3. Установка сервера WireGuard

Существует автоматический способ установки сервера при помощи клиента [AmneziaVPN](https://ru.amnezia.org/) о котором я писал в своем [телеграм-канале](https://t.me/avennom/23), но в этом гайде мы будем использовать скрипт **WireGuard installer** от **angristan**.

1. Сначала установим инструмент curl:

```shell
apt install curl -y
```

2. Затем запустим скачивание скрипта установки:

```shell
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
./wireguard-install.sh
```

3. Появится строка ./wireguard-install.sh, жмем Enter.

![|800](../../Media/Pictures/Wireguard/image_2.png)
4. Отвечаем на все вопросы утвердительно, попросит нажать любую клавишу для начала установки, затем попросит ввести имя клиента (**Client name**) пишем **wireguard,** соглашаемся с предложенными IP-адресами.

![|800](../../Media/Pictures/Wireguard/image_3.png)

После чего будет отображен QR-код.
![|800](../../Media/Pictures/Wireguard/image_4.png)

Далее определимся с клиентом WireGuard:

1. Для смартфонов открываем мобильный клиент WireGuard, выбираем «**Создать из QR-кода**» и пробуем подключиться к VPN.

![|300](../../Media/Pictures/Wireguard/image_5.gif)

2. Для компьютеров открываем конфигурационный файл командой:

```
nano ./wg0-client-wireguard.conf
```

Затем копируем весь текст в любой текстовой редактор и сохраняем файл с именем **wg0-client-wireguard.conf** и импортируем в клиенте WireGuard.
## 4. Добавление других клиентов

Для каждого отдельного клиента нужно генерировать отдельный конфигурационный файл.

1. Для этого мы повторно запускаем скрипт установки:

```
bash ./wireguard-install.sh
```
![|800](../../Media/Pictures/Wireguard/image_6.png)

2. Выбираем 1-й пункт «**Add a new user**», далее пишем имя например для клиента в Windows **wireguard-win** (не более 15 символов), соглашаемся с предложенными IP-адресами. Появится QR-код, а под ним путь к конфигурационному файлу. Открываем содержимое файла следующей командой:

```shell
nano ./wg0-client-wireguard-win.conf
```

Затем копируем весь текст в любой текстовой редактор и сохраняем файл с именем **wg0-client-wireguard-win.conf** и импортируем в клиенте WireGuard.
## 5. Подключение к WireGuard

По умолчанию прописывается DNS-сервер от AdGuard, с ним тоже все работает и открывается. При желании можно отредактировать соединение в клиенте и вручную прописать DNS-сервер 1.1.1.1 от Cloudflare, который не стал блокировать доступ из России.

Подключение с мобильного устройства самое простое. После сканирования QR-кода, создается соединение к вашему серверу и вам остается только к нему подключиться.  
Для клиента WireGuard для Windows, нажимаем «**Добавить туннель**» и выбираем скопированный ранее конфигурационный файл **wg0-client-wireguard-win.conf** и пробуем подключиться.  
Заходим [сюда](https://whatismyipaddress.com/) и видим IP-адрес и страну вашего сервера.

Проверяем доступ к заблокированным [сайтам](https://twitter.com/) и замеряем [скорость](https://www.speedcheck.org/ru/).
## 6. Настройка и подключение в роутерах Keenetic

В роутерах Keenetic можно установить компонент WireGuard и пустить весь трафик по VPN или только выбранные устройства.

1. Переходим в админке роутера в «**Управление**» > «**Общие настройки**» > «**Изменить набор компонентов**», ищем «**Сетевые функции**», выбираем «**Wireguard VPN**» и жмем «**Установить обновление**».  
2. Далее переходим в «**Интернет**» > «**Другие подключения**» > «**Wireguard**» > «**Загрузить из файла**» и выбираем сохраненный файл .conf.  
3. Отредактируем соединение, отмечаем «**Использовать для выхода в интернет**» и оставляем DNS-серверы от AdGuard или прописываем в «**DNS 1**»: 1.1.1.1 и «**DNS 2**»: 1.0.0.1 от Cloudflare.   

**Весь трафик по VPN:**

Переходим в «**Интернет**» > «**Приоритеты подключений**» и переносим соединение Wireguard над всеми другими подключениями и нажимаем «**Сохранить**», затем переходим в «**Другие подключения**» и активируем подключение к Wireguard.

**Выбранные устройства по VPN:**

Переходим в «**Интернет**» > «**Приоритеты подключений**» и жмем «**Добавить политику**», пишем имя Wireguard, отмечаем справа подключение Wireguard и жмем «**Сохранить**». Переходим во вкладку «**Применение политик**», жмем «**Показать все объекты**» и выбираем устройство, которое будем пускать по Wireguard VPN и в «**Переместить в**» выбираем Wireguard, жмем «**Подтвердить**», затем переходим в «**Другие подключения**» и активируем подключение к Wireguard.
## 7. Копирование конфигурационных файлов

>пример копирования готовых конфигурационных файлов на свой компьютер
```shell
scp -r root@185.87.49.134:/root/wg/ /home/user/Documents
```
- где `/root/wg/` - директория конфигурационных файлов на сервере, `/home/user/Documents` - директория на локальном компьютере

> [!info]- скрипт для установки/настройки Wireguard на случай если недоступен на GitHub
>```bash
>#!/bin/bash
>
># Secure WireGuard server installer
># https://github.com/angristan/wireguard-install
>
>RED='\033[0;31m'
>ORANGE='\033[0;33m'
>GREEN='\033[0;32m'
>NC='\033[0m'
>
>function isRoot() {
>	if [ "${EUID}" -ne 0 ]; then
>		echo "You need to run this script as root"
>		exit 1
>	fi
>}
>
>function checkVirt() {
>	if [ "$(systemd-detect-virt)" == "openvz" ]; then
>		echo "OpenVZ is not supported"
>		exit 1
>	fi
>
>	if [ "$(systemd-detect-virt)" == "lxc" ]; then
>		echo "LXC is not supported (yet)."
>		echo "WireGuard can technically run in an LXC container,"
>		echo "but the kernel module has to be installed on the host,"
>		echo "the container has to be run with some specific parameters"
>		echo "and only the tools need to be installed in the container."
>		exit 1
>	fi
>}
>
>function checkOS() {
>	source /etc/os-release
>	OS="${ID}"
>	if [[ ${OS} == "debian" || ${OS} == "raspbian" ]]; then
>		if [[ ${VERSION_ID} -lt 10 ]]; then
>			echo "Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 10 Buster or later"
>			exit 1
>		fi
>		OS=debian # overwrite if raspbian
>	elif [[ ${OS} == "ubuntu" ]]; then
>		RELEASE_YEAR=$(echo "${VERSION_ID}" | cut -d'.' -f1)
>		if [[ ${RELEASE_YEAR} -lt 18 ]]; then
>			echo "Your version of Ubuntu (${VERSION_ID}) is not supported. Please use Ubuntu 18.04 or later"
>			exit 1
>		fi
>	elif [[ ${OS} == "fedora" ]]; then
>		if [[ ${VERSION_ID} -lt 32 ]]; then
>			echo "Your version of Fedora (${VERSION_ID}) is not supported. Please use Fedora 32 or later"
>			exit 1
>		fi
>	elif [[ ${OS} == 'centos' ]] || [[ ${OS} == 'almalinux' ]] || [[ ${OS} == 'rocky' ]]; then
>		if [[ ${VERSION_ID} == 7* ]]; then
>			echo "Your version of CentOS (${VERSION_ID}) is not supported. Please use CentOS 8 or later"
>			exit 1
>		fi
>	elif [[ -e /etc/oracle-release ]]; then
>		source /etc/os-release
>		OS=oracle
>	elif [[ -e /etc/arch-release ]]; then
>		OS=arch
>	else
>		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, AlmaLinux, Oracle or Arch Linux system"
>		exit 1
>	fi
>}
>
>function getHomeDirForClient() {
>	local CLIENT_NAME=$1
>
>	if [ -z "${CLIENT_NAME}" ]; then
>		echo "Error: getHomeDirForClient() requires a client name as argument"
>		exit 1
>	fi
>
>	# Home directory of the user, where the client configuration will be written
>	if [ -e "/home/${CLIENT_NAME}" ]; then
>		# if $1 is a user name
>		HOME_DIR="/home/${CLIENT_NAME}"
>	elif [ "${SUDO_USER}" ]; then
>		# if not, use SUDO_USER
>		if [ "${SUDO_USER}" == "root" ]; then
>			# If running sudo as root
>			HOME_DIR="/root"
>		else
>			HOME_DIR="/home/${SUDO_USER}"
>		fi
>	else
>		# if not SUDO_USER, use /root
>		HOME_DIR="/root"
>	fi
>
>	echo "$HOME_DIR"
>}
>
>function initialCheck() {
>	isRoot
>	checkVirt
>	checkOS
>}
>
>function installQuestions() {
>	echo "Welcome to the WireGuard installer!"
>	echo "The git repository is available at: https://github.com/angristan/wireguard-install"
>	echo ""
>	echo "I need to ask you a few questions before starting the setup."
>	echo "You can keep the default options and just press enter if you are ok with them."
>	echo ""
>
>	# Detect public IPv4 or IPv6 address and pre-fill for the user
>	SERVER_PUB_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | awk '{print $1}' | head -1)
>	if [[ -z ${SERVER_PUB_IP} ]]; then
>		# Detect public IPv6 address
>		SERVER_PUB_IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
>	fi
>	read -rp "IPv4 or IPv6 public address: " -e -i "${SERVER_PUB_IP}" SERVER_PUB_IP
>
>	# Detect public interface and pre-fill for the user
>	SERVER_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
>	until [[ ${SERVER_PUB_NIC} =~ ^[a-zA-Z0-9_]+$ ]]; do
>		read -rp "Public interface: " -e -i "${SERVER_NIC}" SERVER_PUB_NIC
>	done
>
>	until [[ ${SERVER_WG_NIC} =~ ^[a-zA-Z0-9_]+$ && ${#SERVER_WG_NIC} -lt 16 ]]; do
>		read -rp "WireGuard interface name: " -e -i wg0 SERVER_WG_NIC
>	done
>
>	until [[ ${SERVER_WG_IPV4} =~ ^([0-9]{1,3}\.){3} ]]; do
>		read -rp "Server WireGuard IPv4: " -e -i 10.66.66.1 SERVER_WG_IPV4
>	done
>
>	until [[ ${SERVER_WG_IPV6} =~ ^([a-f0-9]{1,4}:){3,4}: ]]; do
>		read -rp "Server WireGuard IPv6: " -e -i fd42:42:42::1 SERVER_WG_IPV6
>	done
>
>	# Generate random number within private ports range
>	RANDOM_PORT=$(shuf -i49152-65535 -n1)
>	until [[ ${SERVER_PORT} =~ ^[0-9]+$ ]] && [ "${SERVER_PORT}" -ge 1 ] && [ "${SERVER_PORT}" -le 65535 ]; do
>		read -rp "Server WireGuard port [1-65535]: " -e -i "${RANDOM_PORT}" SERVER_PORT
>	done
>
>	# Adguard DNS by default
>	until [[ ${CLIENT_DNS_1} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
>		read -rp "First DNS resolver to use for the clients: " -e -i 1.1.1.1 CLIENT_DNS_1
>	done
>	until [[ ${CLIENT_DNS_2} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
>		read -rp "Second DNS resolver to use for the clients (optional): " -e -i 1.0.0.1 CLIENT_DNS_2
>		if [[ ${CLIENT_DNS_2} == "" ]]; then
>			CLIENT_DNS_2="${CLIENT_DNS_1}"
>		fi
>	done
>
>	until [[ ${ALLOWED_IPS} =~ ^.+$ ]]; do
>		echo -e "\nWireGuard uses a parameter called AllowedIPs to determine what is routed over the VPN."
>		read -rp "Allowed IPs list for generated clients (leave default to route everything): " -e -i '0.0.0.0/0,::/0' ALLOWED_IPS
>		if [[ ${ALLOWED_IPS} == "" ]]; then
>			ALLOWED_IPS="0.0.0.0/0,::/0"
>		fi
>	done
>
>	echo ""
>	echo "Okay, that was all I needed. We are ready to setup your WireGuard server now."
>	echo "You will be able to generate a client at the end of the installation."
>	read -n1 -r -p "Press any key to continue..."
>}
>
>function installWireGuard() {
>	# Run setup questions first
>	installQuestions
>
>	# Install WireGuard tools and module
>	if [[ ${OS} == 'ubuntu' ]] || [[ ${OS} == 'debian' && ${VERSION_ID} -gt 10 ]]; then
>		apt-get update
>		apt-get install -y wireguard iptables resolvconf qrencode
>	elif [[ ${OS} == 'debian' ]]; then
>		if ! grep -rqs "^deb .* buster-backports" /etc/apt/; then
>			echo "deb http://deb.debian.org/debian buster-backports main" >/etc/apt/sources.list.d/backports.list
>			apt-get update
>		fi
>		apt update
>		apt-get install -y iptables resolvconf qrencode
>		apt-get install -y -t buster-backports wireguard
>	elif [[ ${OS} == 'fedora' ]]; then
>		if [[ ${VERSION_ID} -lt 32 ]]; then
>			dnf install -y dnf-plugins-core
>			dnf copr enable -y jdoss/wireguard
>			dnf install -y wireguard-dkms
>		fi
>		dnf install -y wireguard-tools iptables qrencode
>	elif [[ ${OS} == 'centos' ]] || [[ ${OS} == 'almalinux' ]] || [[ ${OS} == 'rocky' ]]; then
>		if [[ ${VERSION_ID} == 8* ]]; then
>			yum install -y epel-release elrepo-release
>			yum install -y kmod-wireguard
>			yum install -y qrencode # not available on release 9
>		fi
>		yum install -y wireguard-tools iptables
>	elif [[ ${OS} == 'oracle' ]]; then
>		dnf install -y oraclelinux-developer-release-el8
>		dnf config-manager --disable -y ol8_developer
>		dnf config-manager --enable -y ol8_developer_UEKR6
>		dnf config-manager --save -y --setopt=ol8_developer_UEKR6.includepkgs='wireguard-tools*'
>		dnf install -y wireguard-tools qrencode iptables
>	elif [[ ${OS} == 'arch' ]]; then
>		pacman -S --needed --noconfirm wireguard-tools qrencode
>	fi
>
>	# Make sure the directory exists (this does not seem the be the case on fedora)
>	mkdir /etc/wireguard >/dev/null 2>&1
>
>	chmod 600 -R /etc/wireguard/
>
>	SERVER_PRIV_KEY=$(wg genkey)
>	SERVER_PUB_KEY=$(echo "${SERVER_PRIV_KEY}" | wg pubkey)
>
>	# Save WireGuard settings
>	echo "SERVER_PUB_IP=${SERVER_PUB_IP}
>SERVER_PUB_NIC=${SERVER_PUB_NIC}
>SERVER_WG_NIC=${SERVER_WG_NIC}
>SERVER_WG_IPV4=${SERVER_WG_IPV4}
>SERVER_WG_IPV6=${SERVER_WG_IPV6}
>SERVER_PORT=${SERVER_PORT}
>SERVER_PRIV_KEY=${SERVER_PRIV_KEY}
>SERVER_PUB_KEY=${SERVER_PUB_KEY}
>CLIENT_DNS_1=${CLIENT_DNS_1}
>CLIENT_DNS_2=${CLIENT_DNS_2}
>ALLOWED_IPS=${ALLOWED_IPS}" >/etc/wireguard/params
>
>	# Add server interface
>	echo "[Interface]
>Address = ${SERVER_WG_IPV4}/24,${SERVER_WG_IPV6}/64
>ListenPort = ${SERVER_PORT}
>PrivateKey = ${SERVER_PRIV_KEY}" >"/etc/wireguard/${SERVER_WG_NIC}.conf"
>
>	if pgrep firewalld; then
>		FIREWALLD_IPV4_ADDRESS=$(echo "${SERVER_WG_IPV4}" | cut -d"." -f1-3)".0"
>		FIREWALLD_IPV6_ADDRESS=$(echo "${SERVER_WG_IPV6}" | sed 's/:[^:]*$/:0/')
>		echo "PostUp = firewall-cmd --add-port ${SERVER_PORT}/udp && firewall-cmd --add-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --add-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'
>PostDown = firewall-cmd --remove-port ${SERVER_PORT}/udp && firewall-cmd --remove-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --remove-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
>	else
>		echo "PostUp = iptables -I INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
>PostUp = iptables -I FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
>PostUp = iptables -I FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
>PostUp = iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
>PostUp = ip6tables -I FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
>PostUp = ip6tables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
>PostDown = iptables -D INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
>PostDown = iptables -D FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
>PostDown = iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
>PostDown = iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
>PostDown = ip6tables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
>PostDown = ip6tables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
>	fi
>
>	# Enable routing on the server
>	echo "net.ipv4.ip_forward = 1
>net.ipv6.conf.all.forwarding = 1" >/etc/sysctl.d/wg.conf
>
>	sysctl --system
>
>	systemctl start "wg-quick@${SERVER_WG_NIC}"
>	systemctl enable "wg-quick@${SERVER_WG_NIC}"
>
>	newClient
>	echo -e "${GREEN}If you want to add more clients, you simply need to run this script another time!${NC}"
>
>	# Check if WireGuard is running
>	systemctl is-active --quiet "wg-quick@${SERVER_WG_NIC}"
>	WG_RUNNING=$?
>
>	# WireGuard might not work if we updated the kernel. Tell the user to reboot
>	if [[ ${WG_RUNNING} -ne 0 ]]; then
>		echo -e "\n${RED}WARNING: WireGuard does not seem to be running.${NC}"
>		echo -e "${ORANGE}You can check if WireGuard is running with: systemctl status wg-quick@${SERVER_WG_NIC}${NC}"
>		echo -e "${ORANGE}If you get something like \"Cannot find device ${SERVER_WG_NIC}\", please reboot!${NC}"
>	else # WireGuard is running
>		echo -e "\n${GREEN}WireGuard is running.${NC}"
>		echo -e "${GREEN}You can check the status of WireGuard with: systemctl status wg-quick@${SERVER_WG_NIC}\n\n${NC}"
>		echo -e "${ORANGE}If you don't have internet connectivity from your client, try to reboot the server.${NC}"
>	fi
>}
>
>function newClient() {
>	# If SERVER_PUB_IP is IPv6, add brackets if missing
>	if [[ ${SERVER_PUB_IP} =~ .*:.* ]]; then
>		if [[ ${SERVER_PUB_IP} != *"["* ]] || [[ ${SERVER_PUB_IP} != *"]"* ]]; then
>			SERVER_PUB_IP="[${SERVER_PUB_IP}]"
>		fi
>	fi
>	ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"
>
>	echo ""
>	echo "Client configuration"
>	echo ""
>	echo "The client name must consist of alphanumeric character(s). It may also include underscores or dashes and can't exceed 15 chars."
>
>	until [[ ${CLIENT_NAME} =~ ^[a-zA-Z0-9_-]+$ && ${CLIENT_EXISTS} == '0' && ${#CLIENT_NAME} -lt 16 ]]; do
>		read -rp "Client name: " -e CLIENT_NAME
>		CLIENT_EXISTS=$(grep -c -E "^### Client ${CLIENT_NAME}\$" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>
>		if [[ ${CLIENT_EXISTS} != 0 ]]; then
>			echo ""
>			echo -e "${ORANGE}A client with the specified name was already created, please choose another name.${NC}"
>			echo ""
>		fi
>	done
>
>	for DOT_IP in {2..254}; do
>		DOT_EXISTS=$(grep -c "${SERVER_WG_IPV4::-1}${DOT_IP}" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>		if [[ ${DOT_EXISTS} == '0' ]]; then
>			break
>		fi
>	done
>
>	if [[ ${DOT_EXISTS} == '1' ]]; then
>		echo ""
>		echo "The subnet configured supports only 253 clients."
>		exit 1
>	fi
>
>	BASE_IP=$(echo "$SERVER_WG_IPV4" | awk -F '.' '{ print $1"."$2"."$3 }')
>	until [[ ${IPV4_EXISTS} == '0' ]]; do
>		read -rp "Client WireGuard IPv4: ${BASE_IP}." -e -i "${DOT_IP}" DOT_IP
>		CLIENT_WG_IPV4="${BASE_IP}.${DOT_IP}"
>		IPV4_EXISTS=$(grep -c "$CLIENT_WG_IPV4/32" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>
>		if [[ ${IPV4_EXISTS} != 0 ]]; then
>			echo ""
>			echo -e "${ORANGE}A client with the specified IPv4 was already created, please choose another IPv4.${NC}"
>			echo ""
>		fi
>	done
>
>	BASE_IP=$(echo "$SERVER_WG_IPV6" | awk -F '::' '{ print $1 }')
>	until [[ ${IPV6_EXISTS} == '0' ]]; do
>		read -rp "Client WireGuard IPv6: ${BASE_IP}::" -e -i "${DOT_IP}" DOT_IP
>		CLIENT_WG_IPV6="${BASE_IP}::${DOT_IP}"
>		IPV6_EXISTS=$(grep -c "${CLIENT_WG_IPV6}/128" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>
>		if [[ ${IPV6_EXISTS} != 0 ]]; then
>			echo ""
>			echo -e "${ORANGE}A client with the specified IPv6 was already created, please choose another IPv6.${NC}"
>			echo ""
>		fi
>	done
>
>	# Generate key pair for the client
>	CLIENT_PRIV_KEY=$(wg genkey)
>	CLIENT_PUB_KEY=$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)
>	CLIENT_PRE_SHARED_KEY=$(wg genpsk)
>
>	HOME_DIR=$(getHomeDirForClient "${CLIENT_NAME}")
>
>	# Create client file and add the server as a peer
>	echo "[Interface]
>PrivateKey = ${CLIENT_PRIV_KEY}
>Address = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128
>DNS = ${CLIENT_DNS_1},${CLIENT_DNS_2}
>
>[Peer]
>PublicKey = ${SERVER_PUB_KEY}
>PresharedKey = ${CLIENT_PRE_SHARED_KEY}
>Endpoint = ${ENDPOINT}
>AllowedIPs = ${ALLOWED_IPS}" >"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
>
>	# Add the client as a peer to the server
>	echo -e "\n### Client ${CLIENT_NAME}
>[Peer]
>PublicKey = ${CLIENT_PUB_KEY}
>PresharedKey = ${CLIENT_PRE_SHARED_KEY}
>AllowedIPs = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
>
>	wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")
>
>	# Generate QR code if qrencode is installed
>	if command -v qrencode &>/dev/null; then
>		echo -e "${GREEN}\nHere is your client config file as a QR Code:\n${NC}"
>		qrencode -t ansiutf8 -l L <"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
>		echo ""
>	fi
>
>	echo -e "${GREEN}Your client config file is in ${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf${NC}"
>}
>
>function listClients() {
>	NUMBER_OF_CLIENTS=$(grep -c -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>	if [[ ${NUMBER_OF_CLIENTS} -eq 0 ]]; then
>		echo ""
>		echo "You have no existing clients!"
>		exit 1
>	fi
>
>	grep -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | nl -s ') '
>}
>
>function revokeClient() {
>	NUMBER_OF_CLIENTS=$(grep -c -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf")
>	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
>		echo ""
>		echo "You have no existing clients!"
>		exit 1
>	fi
>
>	echo ""
>	echo "Select the existing client you want to revoke"
>	grep -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | nl -s ') '
>	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
>		if [[ ${CLIENT_NUMBER} == '1' ]]; then
>			read -rp "Select one client [1]: " CLIENT_NUMBER
>		else
>			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
>		fi
>	done
>
>	# match the selected number to a client name
>	CLIENT_NAME=$(grep -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
>
>	# remove [Peer] block matching $CLIENT_NAME
>	sed -i "/^### Client ${CLIENT_NAME}\$/,/^$/d" "/etc/wireguard/${SERVER_WG_NIC}.conf"
>
>	# remove generated client file
>	HOME_DIR=$(getHomeDirForClient "${CLIENT_NAME}")
>	rm -f "${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
>
>	# restart wireguard to apply changes
>	wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")
>}
>
>function uninstallWg() {
>	echo ""
>	echo -e "\n${RED}WARNING: This will uninstall WireGuard and remove all the configuration files!${NC}"
>	echo -e "${ORANGE}Please backup the /etc/wireguard directory if you want to keep your configuration files.\n${NC}"
>	read -rp "Do you really want to remove WireGuard? [y/n]: " -e REMOVE
>	REMOVE=${REMOVE:-n}
>	if [[ $REMOVE == 'y' ]]; then
>		checkOS
>
>		systemctl stop "wg-quick@${SERVER_WG_NIC}"
>		systemctl disable "wg-quick@${SERVER_WG_NIC}"
>
>		if [[ ${OS} == 'ubuntu' ]]; then
>			apt-get remove -y wireguard wireguard-tools qrencode
>		elif [[ ${OS} == 'debian' ]]; then
>			apt-get remove -y wireguard wireguard-tools qrencode
>		elif [[ ${OS} == 'fedora' ]]; then
>			dnf remove -y --noautoremove wireguard-tools qrencode
>			if [[ ${VERSION_ID} -lt 32 ]]; then
>				dnf remove -y --noautoremove wireguard-dkms
>				dnf copr disable -y jdoss/wireguard
>			fi
>		elif [[ ${OS} == 'centos' ]] || [[ ${OS} == 'almalinux' ]] || [[ ${OS} == 'rocky' ]]; then
>			yum remove -y --noautoremove wireguard-tools
>			if [[ ${VERSION_ID} == 8* ]]; then
>				yum remove --noautoremove kmod-wireguard qrencode
>			fi
>		elif [[ ${OS} == 'oracle' ]]; then
>			yum remove --noautoremove wireguard-tools qrencode
>		elif [[ ${OS} == 'arch' ]]; then
>			pacman -Rs --noconfirm wireguard-tools qrencode
>		fi
>
>		rm -rf /etc/wireguard
>		rm -f /etc/sysctl.d/wg.conf
>
>		# Reload sysctl
>		sysctl --system
>
>		# Check if WireGuard is running
>		systemctl is-active --quiet "wg-quick@${SERVER_WG_NIC}"
>		WG_RUNNING=$?
>
>		if [[ ${WG_RUNNING} -eq 0 ]]; then
>			echo "WireGuard failed to uninstall properly."
>			exit 1
>		else
>			echo "WireGuard uninstalled successfully."
>			exit 0
>		fi
>	else
>		echo ""
>		echo "Removal aborted!"
>	fi
>}
>
>function manageMenu() {
>	echo "Welcome to WireGuard-install!"
>	echo "The git repository is available at: https://github.com/angristan/wireguard-install"
>	echo ""
>	echo "It looks like WireGuard is already installed."
>	echo ""
>	echo "What do you want to do?"
>	echo "   1) Add a new user"
>	echo "   2) List all users"
>	echo "   3) Revoke existing user"
>	echo "   4) Uninstall WireGuard"
>	echo "   5) Exit"
>	until [[ ${MENU_OPTION} =~ ^[1-5]$ ]]; do
>		read -rp "Select an option [1-5]: " MENU_OPTION
>	done
>	case "${MENU_OPTION}" in
>	1)
>		newClient
>		;;
>	2)
>		listClients
>		;;
>	3)
>		revokeClient
>		;;
>	4)
>		uninstallWg
>		;;
>	5)
>		exit 0
>		;;
>	esac
>}
>
># Check for root, virt, OS...
>initialCheck
>
># Check if WireGuard is already installed and load params
>if [[ -e /etc/wireguard/params ]]; then
>	source /etc/wireguard/params
>	manageMenu
>else
>	installWireGuard
>fi
>```
