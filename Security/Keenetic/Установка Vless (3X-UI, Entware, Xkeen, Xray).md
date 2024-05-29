2024-05-28 
[Автор](https://github.com/s-n-alexeyev/)
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
## Установка 3X-UI на VDS сервер

Российские VDS сервера можно арендовать по [ссылке](https://vps.today/)

Заходим на свой сервер VDS по `ssh`
```shell
ssh root@yourserver.com
```

Первым делом обновляемся и устанавливаем `curl`

>Debian/Ubuntu
```shell
apt update && apt upgrade && apt install curl -y
```

>RHEL/CentOS
```shell
dnf check-update && dnf upgrade && dnf install curl
```

Устанавливаем 3X-UI с помощью скрипта
```shell
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

>На запрос 
```
Install/update finished! For security it's recommended to modify panel settings    
Do you want to continue with the modification [y/n]?:
```
отвечаем отрицательно `n`

>Готово, сервер автоматически поднялся на порте 2053, не забываем записать сгенерированные данные
```q
Install/update finished! For security it's recommended to modify panel settings    
Do you want to continue with the modification [y/n]?:n  
Cancel...  
set username and password success  
This is a fresh installation, will generate random login info for security concerns:  
###############################################  
Username: F92M6aia  
Password: 9/fHDY37  
WebBasePath: mBDNYtiG  
###############################################  
If you forgot your login info, you can type x-ui and then type 8 to check after installation  
Start migrating database...  
Migration done!  
Created symlink /etc/systemd/system/multi-user.target.wants/x-ui.service → /etc/systemd/system/x-ui.service.  
x-ui v2.3.4 installation finished, it is running now...  
  
x-ui control menu usages:    
----------------------------------------------  
x-ui              - Enter     Admin menu  
x-ui start        - Start     x-ui  
x-ui stop         - Stop      x-ui  
x-ui restart      - Restart   x-ui  
x-ui status       - Show      x-ui status  
x-ui enable       - Enable    x-ui on system startup  
x-ui disable      - Disable   x-ui on system startup  
x-ui log          - Check     x-ui logs  
x-ui banlog       - Check Fail2ban ban logs  
x-ui update       - Update    x-ui  
x-ui install      - Install   x-ui  
x-ui uninstall    - Uninstall x-ui  
----------------------------------------------
```
## Регистрация доменного имени

Переходим в браузере по адресу https://freemyip.com/

>Регистрируем наши "рога и копыта", разумеется это для примера
![|600](/Media/Vless/freemyip1.png)

>Убеждаемся что имя не занято, занимаем его `CLAIM IT!`
![|600](/Media/Vless/freemyip2.png)

>Обязательно сохраняем строку с токеном!
![|600](/Media/Vless/freemyip3.png)

>Возвращаемся на наш VDS и вводим полученную строку через `curl`
```shell
curl https://freemyip.com/update?token=f4782a18ef08fd3b3f8b33c4&domain=hoofsandhorns.freemyip.com
```

>В ответ получаем `OK`, если все прошло удачно
```
[5] 1178  
[4]   Завершён        curl https://freemyip.com/updatetoken=f4782a18ef08fd3b3f8b33c4  
root@3X-UI:/home/user# OK
```

>Возвращаемся в браузер заходим в административную панель 3X-UI уже по нашему адресу `hoofsandhorns.freemyip.com:2053`
```http
hoofsandhorns.freemyip.com:2053
```

>Выбираем русский язык и тему, вводим записанный наш логин и пароль
![|700](/Media/Vless/3X-UI1.png)

>Появляется страница со статусом
![|1000](/Media/Vless/3X-UI2.png)

>Далее необходимо создать подключение, выбираем `Добавть подключение`, на вкладке `Подключения`
![|900](/Media/Vless/3X-UI3.png)

Заполняем подключение:  
- Пишем название в поле `Примечание`, например **Ausweis**
- `Протокол` выбираем **vless**
- `Порт` меняем на **443**
- `Безопасность` переключаем на **REALITY**
- В `uTLS` выбираем браузер, которым пользуетесь чаще, например **chrome**
- `Dest` и `SNI` лучше заменить с yahoo.com на российский **yandex.ru**
- Генерируем пару ключей путем нажатия на `Get New Cert`
- Сохраняем подключение кнопкой `Создать`

![|380](/Media/Vless/3X-UI4.png)

Усилим маскировку нашего соединения:  
- Разворачиваем меню нашего соединения `+`
- Нажимаем пиктограмму с карандашом для редактирования
- В поле `Flow` выбираем **xtls-rprx-vision**
- Сохраняем изменения

![|1000](/Media/Vless/3X-UI5.png)
Готово!  
Для проверки работоспособности можно воспользоваться телефоном установив на Android приложение [v2rayNG](https://play.google.com/store/apps/details?id=com.v2ray.ang&hl=ru), а на iOS [V2BOX](https://apps.apple.com/us/app/v2box-v2ray-client/id6446814690)  
Нажимаем значок с QR-кодом и показываем его приложению в телефоне.


![|1000](/Media/Vless/3X-UI6.png)

## Установка OPKG Entware на маршрутизатор Keenetic

**Для справки**  
[**Entware**](https://www.ixbt.com/live/tv/dobavlyaem-podderzhku-repozitoriya-entware-na-android-bokse.html#:~:text=Entware%20%E2%80%94%20%D1%8D%D1%82%D0%BE%20%D0%BC%D0%B5%D0%BD%D0%B5%D0%B4%D0%B6%D0%B5%D1%80%20%D0%9F%D0%9E,%D0%BF%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%BA%D0%BE%D0%B9%20Entware%20%D0%BE%D0%B1%D0%BB%D0%B0%D0%B4%D0%B0%D1%8E%D1%82%20%D0%BF%D1%80%D0%BE%D0%B4%D0%B2%D0%B8%D0%BD%D1%83%D1%82%D1%8B%D0%B5%20%D0%BC%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%82%D0%BE%D1%80%D1%8B) — **это** менеджер ПО для встраиваемых систем, который открывает доступ к огромному количеству (более 1500) пакетов программ для Linux, расширяя возможности устройства, на котором он установлен. Чаще всего поддержкой **Entware** обладают продвинутые маршрутизаторы.

Перед установкой OPKG Entware необходимо подготовить Flash-накопитель на USB, подойдет минимальный объем (4-8 GB). Накопитель будет вставлен в USB порт постоянно, на нем будет находиться операционная система.  
Делаем подготовку USB накопителя по ссылке [[EXT4 на USB-накопителях]] или [Оригинальная статья](https://help.keenetic.com/hc/ru/articles/115005875145-%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%BE%D0%B9-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B-EXT4-%D0%BD%D0%B0-USB-%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8F%D1%85)
После того как имеем подготовленный носитель, приступаем непосредственно к установке [[Установка OPKG Entware на USB-накопитель]] или [Оригинальная статья](https://docs.keenetic.com/eaeu/hopper/kn-3810/ru/20980-installing-the-entware-repository-on-a-usb-drive.html)
## Настройка клиента `xray` с помощью скрипта `xkeen`

**Для справки**  
[Ветка по теме xkeen на форуме keenetic](https://forum.keenetic.com/topic/16899-xray-%D0%BD%D0%B0-entware-xkeen/page/1/)

## Установка  скрипта

>Заходим по `ssh` на ваш роутер, ip-адрес может отличаться, порт 222 по умолчанию
```
ssh -p222 root@192.168.1.1
```

>Установка скрипта `Xkeen`
```shell
opkg install curl tar
cd /tmp
curl -s -L https://github.com/Skrill0/XKeen/releases/latest/download/xkeen.tar --output xkeen.tar && tar -xvf xkeen.tar -C /opt/sbin --overwrite > /dev/null && rm xkeen.tar
xkeen -i
```

![|800](/Media/Vless/install.gif)

>GeoIP пропускаем (`0`)
```
 Выберите номер или номера действий для GeoIP  
  
    0. Пропустить  
    1. Все доступные GeoIP установлены  
    2. Обновить установленные GeoIP  
    3. Обновить AntiFilter  
    4. Обновить v2fly  
    99. Удалить все GeoIP  
  
 Ваш выбор: 0
```

>GeoSite пропускаем (`0`)
```
 Выберите номер или номера действий для GeoSite  
  
    0. Пропустить  
    1. Установить отсутствующие GeoSite  
    2. Нет доступных GeoSite для обновления  
    3. Установить v2fly  
    4. Установить AntiFilter  
    5. Установить AntiZapret  
    6. Установить Zkeen  
    99. Нет установленных GeoSite для удаления  
  
 Ваш выбор: 0
```

>Включаем автоматическое обновление для всех (`1`)
```
 Выберите номер или номера действий для автоматических обновлений  
  
    0. Пропустить  
    1. Включить отсутствующие задачи автоматического обновления  
    2. Обновить включенные задачи автоматического обновления  
    3. Обновить Xkeen  
    4. Обновить Xray  
    5. Включить GeoSite  
    6. Обновить GeoIP  
    99. Выключить все  
  
 Ваш выбор: 1
```

>Устанавливаем обновление, например ежедневно в 00:00
```
 Время автоматического обновления для всех задач:  
  
 Выберите день  
    0. Отмена  
    1. Понедельник  
    2. Вторник  
    3. Среда  
    4. Четверг  
    5. Пятница  
    6. Суббота  
    7. Воскресенье  
    8. Ежедневно  
  
 Ваш выбор: 8
```

```
 Cron остановлен  
 Cron запущен  
  
 Выполняется очистка временных файлов после работы Xkeen  
 Очистка временных файлов успешно выполнена  
  
 Перед использованием Xray настройте конфигураций по пути «/opt/etc/xray/configs»  
 Установка окончена
```
## Конфигурирование Xray

>Список файлов конфигурации `Xray`
```shell
ls -la /opt/etc/xray/configs/
```

```q
drwxr-xr-x    4 root     root          4096 May 28 05:45 ./  
drwxr-xr-x    4 root     root          4096 May 25 20:47 ../  
-rw-rwxrwx    1 root     root           564 May 25 20:47 01_log.json*  
-rw-rwxrwx    1 root     root           724 May 25 20:47 02_transport.json*  
-rwxrwxrwx    1 root     root           383 May 28 02:13 03_inbounds.json*  
-rwxrwxrwx    1 root     root           915 May 28 03:45 04_outbounds.json*  
-rw-rwxrwx    1 root     root          1097 May 28 03:26 05_routing.json*  
-rwxrwxrwx    1 root     root           182 May 26 00:21 06_policy.json*
```
Нас интересуют только 3 файла `03_inbounds.json`, `04_outbounds.json` и `05_routing.json`

>Редактировать можно редактором `nano`, устанавливаем
```shell
opkg install nano
```

>Конфигурационный файл `03_inbounds.json`
```shell
nano /opt/etc/xray/configs/03_inbounds.json
```

```json
{  
 "inbounds": [  
   {  
     "listen": "192.168.1.1",  
     "port": 2080,  
     "protocol": "socks",  
     "settings": {  
       "auth": "noauth",  
       "udp": false  
     },  
     "sniffing": {  
       "destOverride": ["http", "tls"],  
       "enabled": true,  
       "metadataOnly": false  
     },  
     "tag": "socks-in"  
   }  
 ]  
}
```

`listen` - ip-адрес вашего роутера  
`port` - произвольный порт (2000-65535)  
`protocol` - указываем "socks"  
`tag` - тег соединения, пусть будет "socks-in"
остальное как в примере

Нажимаем сохранение `CRTL+O`, затем выходим из редактора `CTRL=X` 

>Конфигурационный файл `04_outbounds.json`
```shell
nano /opt/etc/xray/configs/04_outbounds.json
```

```json
{  
 "outbounds": [  
   {  
     "domainStrategy": "UseIPv4",  
     "tag": "vless-reality",  
     "protocol": "vless",  
     "settings": {  
       "vnext": [  
         {  
           "address": "hoofsandhorns.freemyip.com",  
           "port": 443,  
           "users": [  
             {  
               "id": "8bda3d23-262f-44ff-b8a3-f7dfc83cb705",  
               "encryption": "none",  
               "flow": "xtls-rprx-vision",  
               "level": 0  
             }  
           ]  
         }  
       ]  
     },  
     "streamSettings": {  
       "network": "tcp",  
       "security": "reality",  
       "realitySettings": {  
         "publicKey": "Jf0f3n7elMH7PZNXpCKcKzT7Qx2_n1kvA6NIwn_eSk4",  
         "fingerprint": "chrome",  
         "serverName": "yandex.ru",  
         "shortId": "d0c03b88",  
         "spiderX": "/"  
       }  
     }  
   },  
   {  
     "tag": "dns",  
     "protocol": "dns"  
   }  
 ]  
}
```

`tag` - тег соединения, пусть будет "vless-reality"  
`protocol` - обязательно "vless"  
`address` - тот что мы регистрировали, "hoofsandhorns.freemyip.com"  
`port` - "443"  
`fingerprint` - то что указывали в настройках 3X-UI "chrome"   
`serverName`  - тоже такие же как в 3X-UI "yandex.ru"  
`id`, `publicKey`, `shortId` - смотрим в инфо соединения на 3X-UI в разделе URL

Нажимаем сохранение `CRTL+O`, затем выходим из редактора `CTRL=X` 

![|400](/Media/Vless/3X-UI7.png)

>Конфигурационный файл `04_outbounds.json`
```shell
nano /opt/etc/xray/configs/05_routing.json
```


```json
{  
 "routing": {
   "rules": [
     // Прямые подключение  |  Доменные имена
     {
       "inboundTag": ["redirect", "tproxy"],
       "domain": ["keenetic.com"],
       "outboundTag": "direct",
       "type": "field"
     },
     // VPS подключение  |  Основное
     {
       "inboundTag": ["socks-in"],
       "outboundTag": "vless-reality",
       "type": "field"
     }
   ]
 }
}
```

VPS подключение
`inboundTag` - тег что что указывали в `03_inbounds.json` "socks-in"
`outboundTag` - тег из `04_outbounds.json` "vless-reality"
Остальное можно сделать как в примере
## Настройка роутера для подключения

Заходим на ваш роутер в браузере по адресу 192.168.1.1 (ваш ip может отличаться)

1. Устанавливаем клиента прокси

Путь: `Упрвление`-> `Праметры системы`->` Изменить набор компонентов` -> `Клиент прокси`

Нажимаем `Обновить KeeneticOS`, маршрутизатор перезагрузиться

![|1000](/Media/Vless/Keenetic1.png)

2. Настраиваем прокси подключение

Путь: `Интернет` -> `Другие подключения` -> `Прокси подключения` -> `Добавить`

- `Имя` - xray  
- `Протокол` - SOCKS v5  
- `Адрес` - ip адрес вашего роутера : `порт` тот что указан `03_inbounds.json` 2080

![|500](/Media/Vless/Keenetic2.png)

3. Добавляем политику `Xkeen`

Путь: `Интернет` -> `Приоритеты подключений` -> `Добавить политику` -> `Xkeen`

![|500](/Media/Vless/Keenetic3.png)

4. Добавляем в политику `Xkeen` прокси `Xray`, нажимаем `сохранить`

![|500](/Media/Vless/Keenetic4.png)

5. Добавляем клиента в политику `Xkeen` путем перетаскивания на него мышкой

![|500](/Media/Vless/Keenetic5.png)

Все готово! Проверяем наш внешний ip адрес

![|700](/Media/Vless/ifconfig.png)
