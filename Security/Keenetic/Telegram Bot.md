2022-07-20
[Оригинальня статья](https://habr.com/ru/articles/669314/)

```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Обхода блокировок много не бывает на роутерах Keenetic

**Версия бота: 2.0 от 15.02.2023**

Итак, зачем нужен этот обход блокировок:

1. Для захода на необходимые сайты, которые блокируются в любой конкретной стране.  
2. Для "обмана" сайтов из других стран, которые не хотят работать для граждан конкретной страны.

С помощью действий, описанных в этой статье, Вы сможете подключить все устройства домашней сети (телефоны, смарт-тв, компьютеры и ноутбуки и другие "домашние" устройства) к данному обходу блокировок, а также подключаться к Вашему роутеру не из дома и пользоваться его обходом блокировок для доступа к любимым сайтам и приложениям. Кроме того, из обеих этих сетей (домашней и через подключение к роутеру), из любого браузера можно будет пользоваться onion-сайтами.

В данной статье будет описана работа телеграм-бота, написанного на python. С его помощью будет возможна установка данного обхода с небольшими предварительными настройками, а также работа со списками блокировок.

Для каждого конкретного обхода блокировок, мы будем устанавливать свой список сайтов и ip адресов для обхода. Изменять любой из этих списков будет достаточно легко (через телеграм бот, либо вручную, но тоже несложно), потому не пугайтесь. Частью функционала Вы можете и не пользоваться - Ваше право. Весь код будет в открытом доступе, информация о Ваших данных будет храниться на локальном роутере.

Статья разбита на 2 части. Первая для тех, кому "побыстрее чтоб работало", и для тех, кто хочет покопаться в настройках и понять как это всё работает. Так что не пугайтесь размеров статьи

## Что необходимо

- Любой Keenetic с поддержкой USB;  
- Актуальная версия KeeneticOs (на данный момент 3.8.3);  
- Flash-накопитель размером от 1Гб;  
- Не побояться прочитать инструкцию;  
- Около 30 минут времени, попивая кофе. Основная часть работы это будет время ожидания установки.
## Подготовка Flash-накопителя, роутера и установка Entware

1. Используем [инструкцию](https://help.keenetic.com/hc/ru/articles/360000184259-%D0%9A%D0%B0%D0%BA-%D0%BF%D0%BE%D0%B4%D0%B3%D0%BE%D1%82%D0%BE%D0%B2%D0%B8%D1%82%D1%8C-USB-%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C-%D0%B4%D0%BB%D1%8F-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F-%D0%B2-%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%B5-%D1%85%D1%80%D0%B0%D0%BD%D0%B8%D0%BB%D0%B8%D1%89%D0%B0-%D0%B8-%D0%BE%D0%B4%D0%BD%D0%BE%D0%B2%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%BD%D0%BE-%D1%80%D0%B0%D1%81%D1%88%D0%B8%D1%80%D0%B5%D0%BD%D0%B8%D1%8F-%D0%BE%D0%B1%D1%8A%D0%B5%D0%BC%D0%B0-%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%BE%D0%B9-%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D0%B8-%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82-%D1%86%D0%B5%D0%BD%D1%82%D1%80%D0%B0-) на сайте Keenetic. Для корректной работы телеграм-бота нам необходим будет файл подкачки. Возможно на "старших" моделях роутера это будет и необязательно, тогда можно воспользоваться [предыдущей](https://habr.com/ru/post/663862/) инструкцией (без файла подкачки), но на моём Keenetic Extra 1711 файл подкачки необходим. На флешке необходимо создать два раздела, один Linux Swap, второй - Ext4. Можно вместо Ext4 использовать NTFS, но для этого необходимо будет установить [соответствующий компонент](https://help.keenetic.com/hc/ru/articles/360000799559-%D0%9F%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-USB-%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8F). Для работы с разделами в данной статье используется  [MiniTool Partition Wizard](https://www.minitool.com/partition-manager/). Если что на всем известных сайтах можно найти взломанную версию, хотя, может, и бесплатная сработает.
2. Для установки Entware воспользуемся [инструкцией](https://help.keenetic.com/hc/ru/articles/360021214160-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B-%D0%BF%D0%B0%D0%BA%D0%B5%D1%82%D0%BE%D0%B2-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F-Entware-%D0%BD%D0%B0-USB-%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) на официальном сайте Keenetic.

- Скачиваем [mipsel](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz).
- Вставляем отформатированную флешку в роутер.
- Заходим в раздел Управление – Приложения и выбираем нашу флешку.
	В _настройках роутера предварительно должно быть включено приложение "_[_Сервер SMB_](https://help.keenetic.com/hc/ru/articles/https://help.keenetic.com/hc/ru/articles/360000812220)_" для доступа к подключаемым USB-дискам по сети._
- Создаём папку install:


![|400](Media/Telegram_Bot/3d755e07f304a0a2150d390e9e1595af.png)

- Ставим курсор на новую папку и импортируем туда файл mipsel с компьютера с помощью третьей иконки:

![|300](Media/Telegram_Bot/b71806385c67d6577dff7990a5a50289.png)

- В настройках роутера заходим в раздел Управление – OPKG, выбираем нашу флешку и удаляем сценарий, если он есть и нажимаем кнопку Сохранить:

![|500](Media/Telegram_Bot/6312b2016b1e47daba0a472a372c7c21.png)

- Примерно спустя минуту заходим обратно в Управление – Приложения и выбираем нашу флешку. Видим, что у нас установился entware по наличию некоторого количества папок. Можно также в Диагностике посмотреть ход установки:

![|500](Media/Telegram_Bot/b1877e1b2a5a55fd3e8b19a3ae529b0a.png)

3. Установим необходимые компоненты роутера. В настройках роутера заходим в Общие настройки -> Изменить набор компоненты:

![|500](Media/Telegram_Bot/815aec88d281fde9df1e15c554c230d1.png)

- Поиском ищем следующие компоненты "Прокси-сервер DNS-over-TLS", "Прокси-сервер DNS-over-HTTPS", "Протокол IPv6", "SSTP VPN-сервер", "Подготовка открытых пакетов OPKG" и "Сервер SSH" затем, после обновления и перезагрузки роутера ещё следующие компоненты: "Модули ядра подсистемы Netfilter", "Пакет расширения Xtables-addons для Netfilter" и ещё раз перезагружаем роутер.
- Заходим в "Сетевые правила" --> "Интернет-фильтр" и добавляем серверы DNS-over-TLS и DNS-over-HTTPS. У TLS адрес сервера **8.8.8.8:853**, доменное имя TLS **dns.google.** У HTTPS сервер dns **https://dns.google/dns-query**. Должно получиться как на картинке:

![|800](Media/Telegram_Bot/98cc156dbaa4ac0c01f4a24e751d828e.png)

- **UPD 02.01.2022:** я рекомендую добавить все dns-over-http и *-tls, указанные в [этой](https://help.keenetic.com/hc/ru/articles/360007687159-DNS-over-TLS-and-DNS-over-HTTPS-proxy-servers-for-DNS-requests-encryption) статье
- Скачиваем [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) (на данный момент актуально putty-64bit-0.76-installer.msi) и запускаем её. Простенькие настроечки (если что их можно сохранить кнопкой Save):

![|400](Media/Telegram_Bot/ba0906165d4ec16c894e8b8b2f6583e0.png)

При возможных предупреждениях соглашаемся (кнопка Accept).

- Вводим логин «root» (без кавычек), нажимаем Enter, пароль «keenetic» (также без кавычек) (при вводе пароля курсор не двигается – это нормально), также Enter. Должно отобразиться:
    

![|500](Media/Telegram_Bot/e972eaafb3a737a125454758c516adfd.png)

> P.S. здесь и далее - для копирование команды в командную строку необходимо скопировать текст на этом сайте и вставить в командную строку с помощью правой кнопкой мыши

- Вводим команду:
```shell
passwd
```

и дважды вводим пароль. Курсор при вводе пароля также не двигается.

- Обновим opkg:
```shell
opkg update
```

![|500](Media/Telegram_Bot/da5490258cbef8fc8fb30bdc2ffb231d.png)
## Установка необходимых компонентов

1. Начинаем установку необходимых компонентов.

- Вводим команду для установки необходимых компонентов Entware.
    Сначала устанавливаем необходимые пакеты opkg, затем скачиваем [pip](https://pypi.org/project/pip/) для python'a (почему-то он не устанавливается корректно через opkg) и устанавливаем с помощью скрипта. Некоторое время у Вас это займёт, дождитесь. В конце установим три пакета расширения python.

```shell
opkg install mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables wget wget-ssl obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config python3 python3-pip v2ray trojan
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificatepython get-pip.py
pip install pyTelegramBotAPI
pip install telethon
```

2. Устанавливаем и настраиваем бота. Он будет скачан с сайта [гитхаба](https://github.com/tas-unn/bypass_keenetic/blob/main/bot.py), это сделано для простоты обновления. Если что, [там](https://github.com/tas-unn/bypass_keenetic/blob/main/bot.py) всегда будет крайняя версия скрипта. Внутри установочника некоторые файлы будут также скачиваться с сайта (по той же причине), но об этом позже.

```shell
wget https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/bot.py --no-check-certificate -O /opt/etc/bot.py
mcedit /opt/etc/bot_config.py 
```

3. В редакторе нашего бота нам необходимо:

- Установить api ключ, который даст вам бот BotFather (в поиске телеграма его можно найти), спросить его команду /newbot, выбрать свободное имя и скопировать необходимый ключ в поле token

![|300](Media/Telegram_Bot/68d789b10ca57329e5db1e1660581126.png)

- Копируем Username (логин) телеграма. Он будет использоваться для администрирования. Можно добавить несколько администраторов:

![|300](Media/Telegram_Bot/3559831bbac5d20e3e72aadc166d9735.png)

- И последние две обязательные настроечки берутся с сайта [https://my.telegram.org/apps](https://my.telegram.org/apps):

![|600](Media/Telegram_Bot/b28e1a884806a988a9158e8538d9dfda.png)

- Обратите внимание, все свои настройки Вы вбиваете и сохраняете на своём роутере. В конце концов код можете посмотреть сами, если умеете это делать.
- Все данные записываем в файл в нужные места:

![|800](Media/Telegram_Bot/5c8847aa57ada300c555272815de6061.png)

- Это были необходимые минимальные настройки. Дело в том, что бот за Вас будет запрашивать мосты для ТОРа. Вам в телеграм будут лишь приходить уведомления (отключите звук и другие оповещения, чтоб они Вас не раздражали).
- Ключи для Shadowsocks, Vmess и Trojan необходимо устанавливать будет вручную
- Чуть ниже этих строк есть настройки, которые можно оставить по умолчанию, но на всякий случай просмотрите их.

4. Запускаем бота:

```shell
python /opt/etc/bot.py
```

- Заходим в свой телеграм-бот, если необходимо нажимаем /start и выбираем сначала _Установку и удаление_, а затем _Установку \ переустановку_:

![|800](Media/Telegram_Bot/54963bb4d49e7f79d64ec1dc143d117c.png)

- В программе Putty можете наблюдать внутренние команды, а в телеграм-боте ход установки, а также полученные ключи от двух ботов. **ВНИМАНИЕ**: при включенной двухфакторной авторизации телеграма, Вам необходимо будет ввести данные в Putty. Не пугайтесь, всё работает исключительно на Вашем роутере.
- После фразы, что установка завершена нам необходимо чуть-чуть донастроить роутер.

5. Отключение штатного DNS-сервера и перезагрузка маршрутизатора.

- Запускаем командную строку в Windows (открываем пуск и начинаем писать «Командная строка» или «cmd»).
- Пишем (ip роутера поменяете если другой).

 ```shell
telnet 192.168.1.1
 ```

- Логин с паролем вводим от роутера, а не entware (скорее всего admin, а пароль лично Ваш).
- Вписываем поочерёдно 3 команды:

```shell
opkg dns-override
system configuration save
system reboot
```

- Роутер перезагрузится и Вы сможете пользоваться ботом работы.
- **Внимание**: если захотите переустановить флешку с нуля, то Вам необходимо в Putty ввести следующие команды и после перезагрузки роутера приступать к созданию флешки:

```shell
no opkg dns-override
system configuration save
system reboot
```

## Описание работы телеграм-бота

1. При старте бот имеет 3 кнопки "Установка и удаление", "Ключи и мосты "и "Списки обхода".
2. Первой кнопкой мы частично пользовались при установке.
3. Кнопка "Ключи и мосты" переустанавливает\устанавливает ключи Shadowsocks, Vmess, Trojan, а также мосты Tor. Для мостов Tor существует получение в автоматическом режиме с помощью телеграм.
4. В пункте меню "Списки обхода" создаются кнопки, соответствующие названием файла и папки /opt/etc/unblock/. При изначальной установке там находятся 4 файла shadowsocks.txt, trojan.txt, vmess.txt и tor.txt, поэтому у нас будет 4 кнопки
5. При нажатии на любую из них будет возможность показать конкретный список разблокировок, добавить сайт или ip адрес в список, либо его удалить оттуда.

![|800](Media/Telegram_Bot/f594d6ee8aaf798ebaf1f8f50a2a2789.png)

6. При добавлении существует возможность ЛИБО добавить обход блокировок соцсетей (скачивается вот [отсюда](https://github.com/tas-unn/bypass_keenetic/blob/main/socialnet.txt) и может редактироваться в случае необходимости), ЛИБО написать доменное имя сайта, либо IP-адрес боту:
    

![|800](Media/Telegram_Bot/f7ff52dca76bc2f1d43ec9203c07e93e.png)

7. Для удаления просто вписываете необходимый адрес и отправляете его боту.
## Подключение к своему роутеру, используя его как собственный VPN

- На устройствах из дома (wifi, по проводу) всё уже работает, но существует возможность подключаться к вашему роутеру и пользоваться теми же сайтами, которые Вы указали в списках разблокировок.
- Для этого нужно воспользоваться вот [этой](https://help.keenetic.com/hc/ru/articles/360000594640-VPN-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80-SSTP) инструкцией на сайте Keenetic.
- А потом можно подключаться через [Android](https://help.keenetic.com/hc/ru/articles/360019377479), [Windows](https://help.keenetic.com/hc/ru/articles/360000029659), [MacOS](https://help.keenetic.com/hc/ru/articles/4415732965394), [IOs](https://apps.apple.com/ru/app/sstp-connect/id1543667909) (только платный).
## Установка обхода завершена! Можете пользоваться на здоровье!

- Донаты приветствуются) куда переводить - можно найти в первых строчках бота в комментариях) но всё, естественно, по желанию.
- Пишите в комментариях чего Вы хотите в следующих версиях.
## О чём будет следующая часть статьи:

1. Рассказ о внутренних особенностях установленной системы. Если кто-то хочет покопаться, либо дать совет в настройке - милости просим.
2. Данный обход блокировок сейчас настроен на 2 сервиса - один [Hi!Load VPN](https://hi-l.im/) с помощью технологии [Shadowsocks](https://en.wikipedia.org/wiki/Shadowsocks), второй - [Тор](https://www.torproject.org/), но Вы можете сами настроить необходимые Вам сервисы вручную, подключив их к своему телеграм-боту и он также сможет работать!
3. Те люди, которые не хотят тратить на это время, могут этого не делать. Остальные - welcome :)
4. Для тех, кто до сих пор пользуется программой teamviewer, есть способ чтобы он продолжил работать.
## Детальная настройка и всё что с этим связано

1. Для установки VPN сервисов, которые поддерживаются роутером Keenetic ([OpenVPN](https://help.keenetic.com/hc/ru/articles/360000632239-%D0%9A%D0%BB%D0%B8%D0%B5%D0%BD%D1%82-OpenVPN), [Wireguard](https://help.keenetic.com/hc/ru/articles/360010592379-WireGuard-VPN), [IpSec](https://help.keenetic.com/hc/ru/articles/360000422620-IPSec-VPN-%D0%BA%D0%BB%D0%B8%D0%B5%D0%BD%D1%82-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80), [PPTP](https://help.keenetic.com/hc/ru/articles/360000604720-VPN-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80-PPTP), [L2TP](https://help.keenetic.com/hc/ru/articles/360000684919-VPN-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80-L2TP-IPsec) воспользуйтесь инструкциями на официальном сайте Keenetic. Shadowsocks и Tor уже были настроены с помощью установочника телеграм-бота, здесь будет лишь отписание.
2. Через Putty заходим по SSH (см самое начало статьи).
3. Инициализируем ipset, создание множества IP-адресов unblock (100-ipset.sh).

- Проверьте, что в системе вашего маршрутизатора есть поддержка множества hash:net:
```shell
ipset create test hash:net
```

- Если команда никаких ошибок и сообщений не выдала, значит поддержка есть, и просто следуйте инструкции дальше. В противном случае (есть ошибка) в следующем скрипте вам нужно заменить **hash:net** на **hash:ip**. При этом вы потеряете возможность разблокировки по диапазону и CIDR.
    Скорее всего ошибок не будет у Вас.
- Создайте пустое множество адресов с именем unblock при загрузке маршрутизатора. Для этого создайте файл /opt/etc/ndm/fs.d/100-ipset.sh:

```
mcedit /opt/etc/ndm/fs.d/100-ipset.sh
```

- Вставляем содержимое с помощью сочетания клавиш **Shift+Insert**. Далее в этой инструкции мы также будем использовать это сочетания клавиш.
- **Внимание**: _в данном файле мы создаём ровно столько множеств для обхода блокировок, сколько нам надо. В инструкции показано 3 обхода (shadowsocks, tor и какой-то VPN, подключенный исходя из инструкций на официальном сайте), но их может быть бесконечное множество. Если Вам нужно добавить ещё один обход VPN, то Вам нужно добавить ещё одну строку в следующем файле (по аналогии с 3-5 строками). Также можно удалить 1-2 строки, если будете использовать меньшее количество обходов_.

```shell
#!/bin/sh
[ "$1" != "start" ] && exit 0
ipset create unblocksh hash:net -exist
ipset create unblocktor hash:net -exist
ipset create unblocktroj hash:net -exist
ipset create unblockvmess hash:net -exist
#ipset create unblockvpn hash:net -exist #если нужно раскомментируемexit 0
```

- [Ссылка](https://github.com/tas-unn/bypass_keenetic/blob/main/100-ipset.sh) на скачивание (там будет храниться всегда актуальная информация).
- После этого нажимаем сохранить (**клавиша F2**), соглашаемся (**Enter**) и выход (**клавиша F10**). Эти сочетания также будут использоваться далее.
- Дайте права на исполнение:

```shell
chmod +x /opt/etc/ndm/fs.d/100-ipset.sh
```

4. Настройка Shadowsocks на примере [Highload-VPN](https://hi-l.im/). Не является рекламой. Пока там всё бесплатно, они обещают бесплатный доступ с небольшими ограничениями, а есть также платный доступ, доступ к российскому vpn (если например Вы из-за границы и хотите воспользоваться госуслугами или подобными сервисами). Вы можете использовать любой другой сервис, либо настроить самостоятельно Shadowsocks на своём сервере, например по [этой](https://www.youtube.com/watch?v=Ml6PKWpJunw) инструкции. За основу этого пункта взята [эта](https://telegra.ph/HighLoad-VPN-na-routere-Keenetic-s-Entware-03-21) инструкция
- Используем [телеграм-бота](https://t.me/hlvpnbot) для получения ключа
- Через некоторое время Вам в телеграм придёт ключ вида:

```
ss:/password@serverip:port/?outline=1
```

Есть 2 способа создать файл настроек. Первый через [python](https://onlinegdb.com/XKqOqf9Ho), вставив полученный ключ в переменную k. Второй "ручками":

![|](Media/Telegram_Bot/bdb4f64bca041447496934e707263694.png)

- В данном ключе есть **3 позиции**, которые нам интересны: первая часть до значка собачки (красная), вторая - после собачки до двоеточия (синяя), третья цифры после двоеточия (зелёная).
    
- Первая часть это пароль, который закодирован в кодировке base64, поэтому нам нужно её раскодировать. Можем использовать [этот](https://www.base64decode.org/) сайт. В верхнее поле вставляем первую ("красную") часть нашей ссылки и нажимаем кнопку Decode. Появится декодированная строка. Нас будет интересовать пароль, который находится после двоеточия.
    

- Возвращаемся в Putty и выполняем команду:
    

```
mcedit /opt/etc/shadowsocks.json
```

- Редактируем наш файл. Изменяем строку server (в моём случае 5.5.5.5) на ip адрес (или доменное имя) из ключа, который мы получили на сайте (см вторую картинку наверх). Это "синяя" часть нашего ключа. "Зелёную" часть нашего ключа копируем в server_port (в моём случае 666). В поле password мы копируем пароль из декодированной строки. local_port изменяем на любой свободный порт. Можно оставить этот:
    

```
{    "server":["5.5.5.5"],    "mode":"tcp_and_udp",    "server_port":666,    "password":"mypass",    "timeout":86400,    "method":"chacha20-ietf-poly1305",    "local_address": "::",    "local_port": 1082,    "fast_open": false,    "ipv6_first": true}
```

Сохраняем и выходим (напомню F2,F10).

- Редактируем исполняемый файл Shadowsocks:
```
mcedit /opt/etc/init.d/S22shadowsocks
```

- Меняем ss-local на ss-redir:

![](Media/Telegram_Bot/31c65c45e2d0bfaf73c25ef0355faaa5.png)

Сохраняем и выходим.

5. Настройка Tor. Эта часть инструкции взята вот [отсюда](https://habr.com/ru/post/428992/), включая саму статью и комментарии.

- Удаляем содержимое конфигурационного файла:
```
cat /dev/null > /opt/etc/tor/torrc
```

- Ищем мосты для Тора. Их можно найти вот [тут](https://bridges.torproject.org/bridges?transport=obfs4) или вот [тут](https://t.me/GetBridgesBot).  
- Открываем файл конфигурации Тор. Актуальный (только без актуальных мостов) можно всегда скачать [отсюда](https://github.com/tas-unn/bypass_keenetic/blob/main/torrc).
```
mcedit /opt/etc/tor/torrc
```

- Вставьте (Shift+Insert) содержимое (сразу не закрывайте, дочитайте ещё один пункт):
```
User rootPidFile /opt/var/run/tor.pidExcludeExitNodes {RU},{UA},{AM},{KG},{BY}StrictNodes 1TransPort 0.0.0.0:9141ExitRelay 0ExitPolicy reject *:*ExitPolicy reject6 *:*GeoIPFile /opt/share/tor/geoipGeoIPv6File /opt/share/tor/geoip6DataDirectory /opt/tmp/torVirtualAddrNetwork 10.254.0.0/16DNSPort 127.0.0.1:9053AutomapHostsOnResolve 1UseBridges 1ClientTransportPlugin obfs4 exec /opt/sbin/obfs4proxy managed
```

- В конец этого файла вставляем мосты, полученные через сайт или через телеграм-бот. Перед каждым мостом (строкой) нужно написать слово "Bridge" и поставить пробел. Например:
```
Bridge obfs4 15.18.22.16:123 C06700D83A2D cert=q34/VfQ+hrUTBto/WhJnwB+BO9jFwBZhNfA iat-mode=0
Bridge obfs4 19.9.1.9:56789 CAF61C9210E5B7638ED00092CD cert=qMUhCi4u/80ecbInGRKAUvGU0cmsiaruHbhaA iat-mode=0
```

- Сохраняем и выходим.

6. Установочником бота создана папка /opt/etc/unblock. Там располагаются файлы со списками для наших различных обходов. Если Вы устанавливаете вручную, то нужна следующая команда для создания папки:

```
mkdir /opt/etc/unblock
```

- Создаём сами списки. Их должно быть ровно столько, сколько обходов мы собираемся создавать. Именно их названия будут использоваться в телеграм-боте для создания списков разблокировок. Напомню, в нашем случае их 3 (вводим последовательно):
```
mcedit /opt/etc/unblock/shadowsocks.txtmcedit /opt/etc/unblock/tor.txtmcedit /opt/etc/unblock/trojan.txtmcedit /opt/etc/unblock/vmess.txtmcedit /opt/etc/unblock/vpn1.txt
```

- В разные файлы мы можем вносить разные домены и ip-адреса. Предлагаю два из них заполнить только одним сайтом, который будет отображать ip адрес, а один из них наполнить основным списком адресов. В моём случае первый файл будет основным, а тор и vpn будет "запасными". В основной вводим свои сайты примерно в таком виде:

```
rutracker.org
kinozal.tv
2ip.ru
chess.com

#facebooktwitterinstagram
facebook.com
twitter.com
instagram.com
cdninstagram.com
cdnfacebook.com
facebook.net
ads-twitter.com
static.ads-twitter.com

###Пример разблокировки по IP (убрать # в начале строки)
#195.82.146.214
###Пример разблокировки по CIDR (убрать # в начале строки)
#103.21.244.0/22
###Пример разблокировки по диапазону (убрать # в начале строки)
#100.100.100.200-100.100.100.210
```

- В таком виде фейсубокотвиттероинстаграммы должны открываться через браузер, как и другие сайты из этого списка. Если что мой актуальный список будет [тут](https://github.com/tas-unn/bypass_keenetic/blob/main/socialnet.txt).
    Пока нет способа, который будет работать по маске. Кстати, чтобы узнать какие конкретные домены должны быть внесены в этот список, проще всего зайти через обычный тор-браузер, нажать F12 и зайти на нужный сайт. Во вкладке Network будет список различных доменов, которые используются. Это нужно для тех сайтов, где используется различные другие домены внутри основного сайта.
- В другие два для проверки добавим по одному сайту: myip.ru и whatismyipaddress.com, а для тора ещё сайт check.torproject.org. В конце концов, изменить списки вы сможете всегда по Вашему желанию либо через Putty, либо через телеграм-бот.
- Кстати для обхода teamviewer в любой из списков обхода добавить следующие адреса (актуальные взял вот [отсюда](https://www.teamviewer.com/en/remote-management/web-monitoring/ip-addresses/), предварительно добавив в список обхода основной сайт [teamviewer.com](http://teamviewer.com), чтоб данный список можно было посмотреть ):

```
teamviewer.com
217.146.28.192/27
37.252.239.128/27
213.227.180.128/27
188.172.221.96/27
131.100.3.192/27
162.250.7.160/27
188.172.251.192/27
162.220.222.192/27
188.172.214.128/27
162.250.2.192/27
162.220.223.160/27
94.16.21.192/27
185.228.150.128/27
188.172.245.32/27
188.172.192.160/27
213.227.162.64/27
217.146.23.96/27
37.252.227.128/27
185.116.99.128/27
37.252.230.160/27
178.255.155.224/27
213.227.181.64/27
188.172.222.0/27
188.172.223.160/27
217.146.13.96/27
94.16.102.128/27
213.227.178.128/27
94.16.26.64/27
213.227.185.192/27
188.172.235.192/27
37.252.245.96/27
213.227.167.160/27
188.172.201.160/27
217.146.11.128/27
37.252.229.192/27
188.172.203.64/27
37.252.244.192/27
37.252.243.160/27
```

Сохраняем списки и выходим. Создайте хотя бы пустые списки, иначе телеграм-бот их не увидит.

5. Скрипт для заполнения множества unblock IP-адресами заданного списка доменов (unblock_ipset.sh) и дополнительного конфигурационного файла dnsmasq из заданного списка доменов (unblock_dnsmasq.sh).

- Создадим скрипт /opt/bin/unblock_ipset.sh:
```
mcedit /opt/bin/unblock_ipset.sh
```

- Обратите внимание, здесь код разделён на 4 части, т.к. у нас 4 обхода блокировок. Если что добавляем ещё подобные строки, заменяя названия ipset'ов и файлов со списком адресов:
```
#!/bin/shuntil ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; donewhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')  if [ ! -z "$cidr" ]; then    ipset -exist add unblocksh $cidr    continue  fi  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$range" ]; then    ipset -exist add unblocksh $range    continue  fi  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$addr" ]; then    ipset -exist add unblocksh $addr    continue  fi  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocksh "$1)}'done < /opt/etc/unblock/shadowsocks.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')  if [ ! -z "$cidr" ]; then    ipset -exist add unblocktor $cidr    continue  fi  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$range" ]; then    ipset -exist add unblocktor $range    continue  fi  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$addr" ]; then    ipset -exist add unblocktor $addr    continue  fi  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktor "$1)}'done < /opt/etc/unblock/tor.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')  if [ ! -z "$cidr" ]; then    ipset -exist add unblockvmess $cidr    continue  fi  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$range" ]; then    ipset -exist add unblockvmess $range    continue  fi  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$addr" ]; then    ipset -exist add unblockvmess $addr    continue  fi  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvmess "$1)}'done < /opt/etc/unblock/vmess.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')  if [ ! -z "$cidr" ]; then    ipset -exist add unblocktroj $cidr    continue  fi  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$range" ]; then    ipset -exist add unblocktroj $range    continue  fi  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$addr" ]; then    ipset -exist add unblocktroj $addr    continue  fi  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktroj "$1)}'done < /opt/etc/unblock/trojan.txt#script0
```

- В конце файла я оставил место под скрипты для доп. обходов (нашего vpn1), их нужно вставлять например вместо строки #script0, #script1 итд в зависимости от количества обходов. Актуальную часть скрипта можно [отсюда](https://github.com/tas-unn/bypass_keenetic/blob/main/add_unblock_ipset.sh), а на данный момент:
```
# unblockvpn - множество# vpn1.txt - название файла со списком обходаwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')  if [ ! -z "$cidr" ]; then    ipset -exist add unblockvpn $cidr    continue  fi    range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$range" ]; then    ipset -exist add unblockvpn $range    continue  fi    addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')  if [ ! -z "$addr" ]; then    ipset -exist add unblockvpn $addr    continue  fi  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvpn "$1)}'done < /opt/etc/unblock/vpn1.txt
```

- Даём права на использование:
```
chmod +x /opt/bin/unblock_ipset.sh
```

- Создадим скрипт /opt/bin/unblock_dnsmasq.sh:
```
mcedit /opt/bin/unblock_dnsmasq.sh
```

```
#!/bin/shcat /dev/null > /opt/etc/unblock.dnsmasqwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue  echo "ipset=/$line/unblocktor" >> /opt/etc/unblock.dnsmasq  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasqdone < /opt/etc/unblock/tor.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue  echo "ipset=/$line/unblocksh" >> /opt/etc/unblock.dnsmasq  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasqdone < /opt/etc/unblock/shadowsocks.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue  echo "ipset=/$line/unblockvmess" >> /opt/etc/unblock.dnsmasq  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasqdone < /opt/etc/unblock/vmess.txtwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue  echo "ipset=/$line/unblocktroj" >> /opt/etc/unblock.dnsmasq  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasqdone < /opt/etc/unblock/trojan.txt#script0#script1#script2#script3#script4#script5#script6#script7#script8#script9
```

- Здесь аналогичная картина - код разбит на 4 частиDYBVF. При необходимости увеличиваем за счёт #script0 и т.д пока так (актуальную знаете где [взять](https://github.com/tas-unn/bypass_keenetic/blob/main/add_unblock_dnsmasq)):
    

```
#vpn1 и unblockvpn меняемwhile read line || [ -n "$line" ]; do  [ -z "$line" ] && continue  [ "${line:0:1}" = "#" ] && continue  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue  echo "ipset=/$line/unblockvpn" >> /opt/etc/unblock.dnsmasq  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasqdone < /opt/etc/unblock/vpn1.txt
```

Сохраняем и выходим.

- Даём права на использование:
    

```
chmod +x /opt/bin/unblock_dnsmasq.sh
```

- Запускаем скрипт и затем проверяем создался ли файл. Здесь 2 команды, вводим последовательно:
    

```
unblock_dnsmasq.sh
cat /opt/etc/unblock.dnsmasq
```

Картина будет примерно такая:

![](Media/Telegram_Bot/4511db2ba92d2bc0b2721758f82f9bd8.png)

6. Скрипт ручного принудительного обновления системы после редактирования списка доменов (unblock_update.sh). [Создаём его](https://github.com/tas-unn/bypass_keenetic/edit/main/unblock_update.sh):
    

```
mcedit /opt/bin/unblock_update.sh
```

- Записываем содержимое, сохраняем и закрываем:
    

```
#!/bin/shipset flush unblocktoripset flush unblockshipset flush unblockttrojipset flush unblockvmess#ipset flush unblockvpn # добавляем столько сколько надо и раскомментируем/opt/bin/unblock_dnsmasq.sh/opt/etc/init.d/S56dnsmasq restart/opt/bin/unblock_ipset.sh &
```

- Даём права на использование:
    

```
chmod +x /opt/bin/unblock_update.sh
```

7. Скрипт автоматического заполнения множества unblock при загрузке маршрутизатора (S99unblock). Создаём его:
    

```
mcedit /opt/etc/init.d/S99unblock
```

- Записываем содержимое, сохраняем и закрываем:
    

```
#!/bin/sh[ "$1" != "start" ] && exit 0/opt/bin/unblock_ipset.sh cd /opt/etcpython /opt/etc/bot.py &
```

- Даём права на использование:
    

```
chmod +x /opt/etc/init.d/S99unblock
```

8. Перенаправление пакетов с адресатами.
    

- **ВНИМАНИЕ! Эта часть кода сейчас не работает, если есть спецы в iptables, то милости просим!** Если кроме тора, trojan, vmess и shadowsocks мы используем другие VPN, то нам нужно узнать их имена. Вводим команду:
    

```
ifconfig
```

- Список будет большим (может потребоваться прокрутка), но по тем параметрам, которые видны, Вы должны догадаться какой выбрать. У меня это **ppp1**, поэтому в следующем файле будем использовать его.
    

![.](https://habrastorage.org/r/w1560/getpro/habr/upload_files/2da/6e6/295/2da6e62958e0fbc6fe27fdf0cfaa8d91.png ".")

.

- Здесь будут отображаться все созданные Вами vpn (кроме shadowsocks и tor).
    
- Создаём ещё один [файл](https://github.com/tas-unn/bypass_keenetic/blob/main/100-redirect.sh), который будет перенаправлять пакеты с адресатами:
    

```
mcedit /opt/etc/ndm/netfilter.d/100-redirect.sh
```

```
#!/bin/sh[ "$type" == "ip6tables" ] && exit 0ip4t() {    if ! iptables -C "$@" &>/dev/null; then        iptables -A "$@"    fi}if [ -z "$(iptables-save 2>/dev/null | grep unblocksh)" ]; then    ipset create unblocksh hash:net -exist    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082fiif [ -z "$(iptables-save 2>/dev/null | grep "udp \-\-dport 53 \-j DNAT")" ]; then    iptables -w -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.1.1    iptables -w -t nat -I PREROUTING -i sstp0 -p udp --dport 53 -j DNAT --to 192.168.1.1fiif [ -z "$(iptables-save 2>/dev/null | grep "tcp \-\-dport 53 \-j DNAT")" ]; then    iptables -w -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.1.1    iptables -w -t nat -I PREROUTING -i sstp0 -p tcp --dport 53 -j DNAT --to 192.168.1.1fiif [ -z "$(iptables-save 2>/dev/null | grep unblocktor)" ]; then    ipset create unblocktor hash:net -exist    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141fiif [ -z "$(iptables-save 2>/dev/null | grep unblockvmess)" ]; then    ipset create unblockvmess hash:net -exist    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810fiif [ -z "$(iptables-save 2>/dev/null | grep unblocktroj)" ]; then    ipset create unblocktroj hash:net -exist    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829fi#script0
```

- По аналогии внизу (вместо #script0 и т.д.) нам необходимо вставить дополнительный код (актуальный всегда [тут](https://github.com/tas-unn/bypass_keenetic/blob/main/add100redirect.sh)). **ВНИМАНИЕ! Эта часть кода сейчас не работает, если есть спецы в iptables, то милости просим!** Тут аккуратненько) вместо ppp1 вставляем нужное нам название интерфейса (чуть повыше я писал):
    

```
if [ -z "$(iptables-save 2>/dev/null | grep unblockvpn)" ]; then    ipset create unblockvpn hash:net -exist    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1fiexit 0
```

Сохраняем и даём права на использование:

```
chmod +x /opt/etc/ndm/netfilter.d/100-redirect.sh
```

9. Настройка dnsmasq и подключение дополнительного конфигурационного файла к dnsmasq.
    

- Удалим содержимое конфигурационного файла dnsmasq и создадим вновь (команды вводим последовательно):
    

```
cat /dev/null > /opt/etc/dnsmasq.confmcedit /opt/etc/dnsmasq.conf
```

- Записываем [содержимое](https://github.com/tas-unn/bypass_keenetic/blob/main/dnsmasq.conf). При необходимости меняем ip роутера. Сохраняем и закрываем.
    

```
user=nobodybogus-privno-negcacheclear-on-reloadbind-dynamiclisten-address=192.168.1.1listen-address=127.0.0.1min-port=4096cache-size=1536expand-hostslog-asyncconf-file=/opt/etc/unblock.dnsmasqno-resolvserver=127.0.0.1#40500server=127.0.0.1#40508server=/onion/127.0.0.1#9053ipset=/onion/unblocktor
```

10. Добавление задачи в cron для периодического обновления содержимого множества unblock.
    

- Откроем файл:
    

```
mcedit /opt/etc/crontab
```

- В конец добавляем строку:
    

```
00 06 * * * root /opt/bin/unblock_ipset.sh
```

- При желании остальные строчки можно закомментировать, поставив решётку в начале. Затем сохраняем и закрываем:
    

```
SHELL=/bin/shPATH=/sbin:/bin:/usr/sbin:/usr/bin:/opt/bin:/opt/sbinMAILTO=""HOME=/# ---------- ---------- Default is Empty ---------- ---------- ##*/1 * * * * root /opt/bin/run-parts /opt/etc/cron.1min#*/5 * * * * root /opt/bin/run-parts /opt/etc/cron.5mins#01 * * * * root /opt/bin/run-parts /opt/etc/cron.hourly#02 4 * * * root /opt/bin/run-parts /opt/etc/cron.daily#22 4 * * 0 root /opt/bin/run-parts /opt/etc/cron.weekly#42 4 1 * * root /opt/bin/run-parts /opt/etc/cron.monthly00 06 * * * root /opt/bin/unblock_ipset.sh
```

11. После перезагрузки роутера у меня почему-то пропал доступ по 222 порту через putty по ssh. В итоге я подключаюсь по 22 порту через тот же putty, ввожу логин с паролем от роутера, пишу команду:
    

```
exec sh
```

а затем:

```
su - root
```

и можно использовать любые команды Entware по типу тех, которые мы вводили в данной инструкции.

## Заключение

Надеюсь Вам всё понравилось) Пишите в комментариях что бы Вы хотели улучшить, Ваши замечания. "Спасибки" и прочее также приветствуются).