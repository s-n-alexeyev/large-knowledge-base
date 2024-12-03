2024-07-26  
[Оригинальная статья](https://rtfm.wiki/linux/dante)
```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
# Установка SOCKS5 сервера Dante

- [Домашняя страница](https://www.inet.no/dante/ "https://www.inet.no/dante/")  
- [Github](https://github.com/notpeter/dante "https://github.com/notpeter/dante")  
- [Документация](https://www.inet.no/dante/doc/ "https://www.inet.no/dante/doc/")  

>[!info] Заметка:
> Dante это только SOCKS сервер. Если дополнительна нужна поддержка HTTP-прокси, то используйте [3proxy](https://rtfm.wiki/linux/3proxy "linux:3proxy")  
>
Далеко не все программы имеют поддержку SOCKS. Для перенаправления трафика ваших приложений на socks-сервер понадобится установка дополнительной программы (проксификатор). Для Windows это Freecap/Widecap.
# Установка Dante

```bash
sudo apt install dante-server
```

>[!error] Версия **1.4.1+dfsg-5** содержит ошибку (подробности в [багтрекере Debian](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=862988 "https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=862988"))
warning: checkconfig(): no socks authentication methods enabled.  This means all socks requests will be blocked
error: checkconfig(): no internal address given for server to listen for clients
- Можно смело пропустить эту ошибку
# Настройка

Конфигурационный файл `/etc/danted.conf`

>Ниже представлена типовая конфигурация
```ini
logoutput: syslog

# Ваш сетевой интерфейс (Обычно eth0, но может отличатся, например ens3, см. # ip addr)
internal: eth0 port = 1080
external: eth0

# Авторизация по локальным/системным пользователям
socksmethod: username

# Используем системных пользователей, поэтому нужны права на чтение passwd
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody

# Разрешить подключения с любых IP всем пользователям прошедшим авторизацию
client pass {
        from: 0/0 to: 0/0
        log: connect disconnect error ioop
}

socks pass {
        from: 0/0 to: 0/0
        log: connect disconnect error ioop
}
```
- Подробнее об уровнях логирования на сайте Dante смотрите в разделе [Server logging](https://www.inet.no/dante/doc/1.4.x/config/logging.html "https://www.inet.no/dante/doc/1.4.x/config/logging.html")
## Логины/пароли

>Добавим нового пользователя `proxyuser` для работы с socks сервером
```bash
sudo useradd --shell /usr/sbin/nologin proxyuser
sudo passwd proxyuser
```
- При этом у пользователя не будет доступа к SSH, т.к. в качестве шелла указан nologin
## Автозагрузка сервиса

>Добавляем сервис в автозагрузку и запускаем его
```bash
sudo systemctl enable --now danted
```
## Авторизация через PAM

Вместо системных пользователей можно использовать [PAM файл](https://www.inet.no/dante/doc/1.4.x/config/auth_pam.html "https://www.inet.no/dante/doc/1.4.x/config/auth_pam.html") с логинами и паролями (похоже на htpasswd).

>Для этого необходимо дополнительно установить пакет **libpam-pwdfile**, а также заменить строку
```
socksmethod: username
```

>на эту
```
socksmethod: pam.username
```

>В файл `/etc/pam.d/sockd` добавляем
```
auth required pam_pwdfile.so pwdfile /etc/dante.passwd
account required pam_permit.so
```

>Но лучше использовать **mkpasswd** (входит в состав пакета **whois**)
```bash
sudo apt install whois
```

>Получаем зашифрованный пароль пользователя, где **PASSWORD** нешифрованный пароль 
```bash
mkpasswd --method=md5 PASSWORD
```
- Например получаем: `$1$5A8SABDV$lU8g.wB9pVPK33eIHbIA40`

>Логин и зашифрованный пароль следует теперь добавить в файле `/etc/dante.passwd`
```bash
sudo nano /etc/dante.passwd
```

>Добавляем строку
```
proxyuser:$1$5A8SABDV$lU8g.wB9pVPK33eIHbIA40
```
- Подробнее в статье на Habr'е - [Использование libpam при настройке SOCKS сервера Dante](https://habr.com/post/354274/ "https://habr.com/post/354274/")

>Имя PAM сервиса используемое Dante по умолчанию `sockd`. Так же, если вы хотите использовать файл конфигурации libpam_pwdfile от другого настроенного сервиса, либо использовать несколько конфигураций, вы можете воспользоваться директивой `pamservicename` в конфигурационном файле Dante. Пример использования:
```
client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
	#the servicename should differ from the servicename in socks-rules
        pamservicename: pam_host
}
```
# Тестирование

>Проверка с локального xoста Linux. **PASSWORD** - пароль пользователя `proxyuser`, **HOSTNAME** - ip адрес или доменное имя VPS/VDS
```bash
curl --socks5 proxyuser:PASSWORD@HOSTNAME:1080 2ip.ru
curl --socks5 proxyuser:PASSWORD@HOSTNAME:1080 ifconfig.co
curl --socks5 proxyuser:PASSWORD@HOSTNAME:1080 ifconfig.ru
curl --socks5 proxyuser:PASSWORD@HOSTNAME:1080 check-host.net/ip
```

>Для конфигурации `curl` ,  можно использовать файл `~/.curlrc`
```
socks5 = HOSTNAME:1080
proxy-user = proxyuser:PASSWORD
user-agent = "Mozilla/5.0 (X11; Linux i686; rv:7.0.1) Gecko/20100101 Firefox/7.0.1"
```
# Веб-интерфейс для администрирования

Код на Github - [https://github.com/IvanDanilov/dante-gui](https://github.com/IvanDanilov/dante-gui "https://github.com/IvanDanilov/dante-gui")
# Плагины для браузера

Так как браузеры не поддерживают авторизацию на socks-сервере, то необходима установка дополнительных плагинов. Для Firefox рекомендуем [FoxyProxy](https://addons.mozilla.org/ru/firefox/addon/foxyproxy-standard/ "https://addons.mozilla.org/ru/firefox/addon/foxyproxy-standard/").  
Для Google Chrome в сети рекомендуют использовать [Proxy Helper](https://chrome.google.com/webstore/detail/proxy-helper/ "https://chrome.google.com/webstore/detail/proxy-helper/"), но к сожалению он не работает - [SOCKS Authentication is not implemented in Chrome](https://bugs.chromium.org/p/chromium/issues/detail?id=256785 "https://bugs.chromium.org/p/chromium/issues/detail?id=256785").  