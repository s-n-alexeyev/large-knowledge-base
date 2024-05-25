
Обновлено 03/10/2023 07:01

Для установки OpenWRT-пакетов на Keenetic необходимо сначала подготовить внешний USB-накопитель и установить на него систему пакетов репозитория Entware.

1. Подключите жесткий диск к ПК и подготовьте его разделы. Для работы менеджера пакетов OPKG диск должен быть отформатирован в файловой системе EXT. Мы рекомендуем использовать современную и актуальную журналируемую файловую систему [EXT4](https://ru.wikipedia.org/wiki/Ext4). Выполните форматирование диска, как показано в инструкции "[Использование файловой системы EXT4 на USB-накопителях](https://help.keenetic.com/hc/ru/articles/115005875145)".

2. В роутере Keenetic установите нужные компоненты [OPKG](https://help.keenetic.com/hc/ru/articles/213968029). Основным и обязательным является компонент "Поддержка открытых пакетов".

В веб-интерфейсе Keenetic предыдущих поколений, с версией KeeneticOS до 2.11:

![opkg1.png](https://help.keenetic.com/hc/article_attachments/360025302159)

В моделях Keenetic с версией KeeneticOS 2.12 и выше:

![opkg2.png](https://help.keenetic.com/hc/article_attachments/360025399660)

NOTE: **Важно!** Установка OPKG-пакетов возможна на моделях с USB-портами, c поддержкой работы USB-накопителей. Это актуальные модели 4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra SE (KN-2510), Giga SE (KN-2410), Ultra (KN-1810/1811), Viva (KN-1910/1912), Hero 4G (KN-2310), DSL (KN-2010), Duo (KN-2110), Ultra SE (KN-2510), Giant (KN-2610), Peak (KN-2710), Hopper (KN-3810), Hopper DSL (KN-3610) и модели прошлых поколений Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II.

3. Теперь нужно установить репозиторий системы пакетов [Entware](https://forum.keenetic.net/topic/4299-entware/).

TIP: **Справка:** Для моделей 4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912), Giant (KN-2610), Hero 4G (KN-2310), Hopper (KN-3810) и Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II используйте для установки архив **mipsel** — [mipsel-installer.tar.gz](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz)  
  
Для моделей Ultra SE (KN-2510), Giga SE (KN-2410), DSL (KN-2010), Duo (KN-2110), Ultra SE (KN-2510), Hopper DSL (KN-3610) и Zyxel Keenetic DSL, LTE, VOX используйте для установки архив **mips** — [mips-installer.tar.gz](https://bin.entware.net/mipssf-k3.4/installer/mips-installer.tar.gz)  
  
Для моделей Peak (KN-2710), Ultra (KN-1811) используйте архив **aarch64** — [aarch64-installer.tar.gz](https://bin.entware.net/aarch64-k3.10/installer/aarch64-installer.tar.gz)

4. В нашем примере рассмотрим установку архива **mipsel**.

Подключите уже подготовленный накопитель c файловой системой [EXT4](https://help.keenetic.com/hc/ru/articles/115005875145) к USB-порту роутера. Диск должен отобразиться на странице "Приложения" в разделе "Диски и принтеры".

![opkg-disk.png](https://help.keenetic.com/hc/article_attachments/360025364320)

На компьютере с помощью файлового менеджера подключитесь к диску по сети (в ОС Windows можно использовать Проводник). В настройках роутера предварительно должно быть включено приложение "[Сервер SMB](https://help.keenetic.com/hc/ru/articles/360000812220)" для доступа к подключаемым USB-дискам по сети.

В корне раздела диска создайте директорию **install**, куда положите файл mipsel-installer.tar.gz.

![opkg3.png](https://help.keenetic.com/hc/article_attachments/4405710499602)

5. В веб-интерфейсе роутера перейдите на страницу OPKG для выбора накопителя и добавления скрипта initrc.

Если у вас Keenetic с версией KeeneticOS 2.12 и выше, перейдите к пункту 6 данной инструкции.

Для Keenetic предыдущих поколений, с версией KeeneticOS до 2.11, перейдите в меню **Приложения** на вкладку **OPKG** и выполните следующие настройки:

- Включите менеджер пакетов OPKG
- В поле "Использовать накопитель" выберите диск OPKG (метка EXT4-раздела)

Нажмите **Применить**.

![opkg4.png](https://help.keenetic.com/hc/article_attachments/4405713841042)

6. Для Keenetic с версией KeeneticOS 2.12 и выше, перейдите на страницу **OPKG** и выполните следующие настройки:

- В поле "Накопитель" выберите диск OPKG (метка EXT4-раздела)

Нажмите **Сохранить**.

![opkg5.png](https://help.keenetic.com/hc/article_attachments/4405707344018)

7. Перейдите на страницу "[Диагностика](https://help.keenetic.com/hc/ru/articles/360000873379)" и откройте Системный журнал роутера. В нем вы должны увидеть следующие записи при установке системы пакетов Entware:

I [Aug 26 16:21:43] ndm: Opkg::Manager: disk is set to: OPKG:/.  
I [Aug 26 16:21:43] ndm: Opkg::Manager: init script reset to default: /opt/etc/initrc.  
I [Aug 26 16:21:43] ndm: Core::System::Configuration: saving (http/rci).  
I [Aug 26 16:21:43] kernel: EXT4-fs (sda4): re-mounted. Opts: (null)  
I [Aug 26 16:21:43] ndm: Opkg::Manager: /tmp/mnt/f3bf1e25-78d8-d601-900d-1e2578d8d601 mounted to /tmp/mnt/f3bf1e25-78d8-d601-900d-1e2578d8d601.  
I [Aug 26 16:21:43] ndm: Opkg::Manager: /tmp/mnt/f3bf1e25-78d8-d601-900d-1e2578d8d601 mounted to /opt/.  
I [Aug 26 16:21:43] npkg: inflating "mipsel-installer.tar.gz".  
I [Aug 26 16:21:44] ndm: Opkg::Manager: /tmp/mnt/f3bf1e25-78d8-d601-900d-1e2578d8d601 initialized.  
I [Aug 26 16:21:44] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:21:44] ndm: Core::Session: client disconnected.  
I [Aug 26 16:21:44] installer: [1/5] Начало установки системы пакетов "Entware"...  
I [Aug 26 16:21:44] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:21:45] ndm: Core::Session: client disconnected.  
I [Aug 26 16:21:45] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:21:46] ndm: Core::Session: client disconnected.  
I [Aug 26 16:21:46] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:21:47] ndm: Core::Session: client disconnected.  
I [Aug 26 16:21:47] installer: Info: Раздел пригоден для установки.  
I [Aug 26 16:21:47] installer: Info: "ping google.com"...  
I [Aug 26 16:21:48] ndm: Core::System::Configuration: configuration saved.  
I [Aug 26 16:21:49] installer: Info: "ping google.com" ..... OK  
I [Aug 26 16:21:50] installer: Info: "ping bin.entware.net"...  
I [Aug 26 16:21:52] installer: Info: "ping bin.entware.net" ..... OK  
I [Aug 26 16:21:53] installer: Info: Создание каталогов...  
I [Aug 26 16:21:53] installer: [2/5] Загрузка и установка основных пакетов...  
I [Aug 26 16:21:54] installer: Info: Устанавливается пакет "libgcc"...  
I [Aug 26 16:21:55] installer: Info: Пакет "libgcc" установлен.  
I [Aug 26 16:21:56] installer: Info: Устанавливается пакет "libc"...  
I [Aug 26 16:21:59] installer: Info: Пакет "libc" установлен.  
I [Aug 26 16:22:00] installer: Info: Устанавливается пакет "libpthread"...  
I [Aug 26 16:22:01] installer: Info: Пакет "libpthread" установлен.  
I [Aug 26 16:22:03] installer: Info: Устанавливается пакет "librt"...  
I [Aug 26 16:22:04] installer: Info: Пакет "librt" установлен.  
I [Aug 26 16:22:05] installer: Info: Устанавливается пакет "entware-release"...  
I [Aug 26 16:22:06] installer: Info: Пакет "entware-release" установлен.  
I [Aug 26 16:22:07] installer: Info: Устанавливается пакет "findutils"...  
I [Aug 26 16:22:08] installer: Info: Пакет "findutils" установлен.  
I [Aug 26 16:22:09] installer: Info: Устанавливается пакет "grep"...  
I [Aug 26 16:22:11] installer: Info: Пакет "grep" установлен.  
I [Aug 26 16:22:12] installer: Info: Устанавливается пакет "ldconfig"...  
I [Aug 26 16:22:14] installer: Info: Пакет "ldconfig" установлен.  
I [Aug 26 16:22:15] installer: Info: Устанавливается пакет "locales"...  
I [Aug 26 16:22:17] installer: Info: Пакет "locales" установлен.  
I [Aug 26 16:22:18] installer: Info: Устанавливается пакет "ndmq"...  
I [Aug 26 16:22:19] installer: Info: Пакет "ndmq" установлен.  
I [Aug 26 16:22:20] installer: Info: Устанавливается пакет "opkg"...  
I [Aug 26 16:22:22] installer: Info: Пакет "opkg" установлен.  
I [Aug 26 16:22:23] installer: Info: Устанавливается пакет "zoneinfo-asia"...  
I [Aug 26 16:22:24] installer: Info: Пакет "zoneinfo-asia" установлен.  
I [Aug 26 16:22:25] installer: Info: Устанавливается пакет "zoneinfo-europe"...  
I [Aug 26 16:22:27] installer: Info: Пакет "zoneinfo-europe" установлен.  
I [Aug 26 16:22:28] installer: Info: Устанавливается пакет "opt-ndmsv2"...  
I [Aug 26 16:22:30] installer: Info: Пакет "opt-ndmsv2" установлен.  
I [Aug 26 16:22:31] installer: Info: Устанавливается пакет "dropbear"...  
I [Aug 26 16:22:32] installer: Info: Пакет "dropbear" установлен.  
I [Aug 26 16:22:33] installer: Info: Устанавливается пакет "poorbox"...  
I [Aug 26 16:22:35] installer: Info: Пакет "poorbox" установлен.  
I [Aug 26 16:22:36] installer: Info: Устанавливается пакет "busybox"...  
I [Aug 26 16:22:42] installer: Info: Пакет "busybox" установлен.  
I [Aug 26 16:22:43] installer: Info: Установка пакетов прошла успешно!  
I [Aug 26 16:22:43] installer: [3/5] Генерация SSH-ключей...  
I [Aug 26 16:22:43] installer: Info: Генерируется ключ "rsa"...  
I [Aug 26 16:22:49] installer: Info: Ключ "rsa" создан.  
I [Aug 26 16:22:50] installer: Info: Генерируется ключ "ecdsa"...  
I [Aug 26 16:22:50] installer: Info: Ключ "ecdsa" создан.  
I [Aug 26 16:22:51] installer: Info: Генерируется ключ "ed25519"...  
I [Aug 26 16:22:51] installer: Info: Ключ "ed25519" создан.  
I [Aug 26 16:22:52] installer: [4/5] Настройка сценария запуска, установка часового пояса и запуск "dropbear"...  
I [Aug 26 16:22:52] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:22:52] ndm: Opkg::Manager: configured init script: "/opt/etc/init.d/rc.unslung".  
I [Aug 26 16:22:52] ndm: Core::Session: client disconnected.  
I [Aug 26 16:22:52] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [Aug 26 16:22:52] ndm: Core::System::Configuration: saving (ndmq/ci).  
I [Aug 26 16:22:52] ndm: Core::Session: client disconnected.  
I [Aug 26 16:22:52] installer: Можно открыть SSH-сессию для соединения с устройством (логин - root, пароль - keenetic, порт - 222).  
I [Aug 26 16:22:52] installer: [5/5] Установка системы пакетов "Entware" завершена! Не забудьте сменить пароль и номер порта!

  
8. Скачайте терминальную программу [Putty](http://www.putty.org/) для работы с протоколами SSH и Telnet.

9. Запустите Putty, выберите тип подключения **SSH**, впишите **IP-адрес** роутера в домашнем сегменте Home (по умолчанию 192.168.1.1), укажите **222**-й порт и нажмите кнопку **Open**.

![putty-ssh.png](https://help.keenetic.com/hc/article_attachments/360025321760)

Дополнительную информацию по работе с Putty вы найдете в инструкции "[Терминальная программа для Windows](https://help.keenetic.com/hc/ru/articles/213966029)".

NOTE: **Важно!** 222-й порт используется, если в роутере установлен компонент "Сервер SSH". Если он не установлен, используйте 22-й порт для подключения к Entware.

Подтвердите добавление ключа безопасности в кэш программы Putty для продолжения установки соединения.

![2019-10-31_14-29-49.png](https://help.keenetic.com/hc/article_attachments/360025321880)

При загрузке подтвердите вход, нажав **Да**.

Далее перейдите в настройки роутера при помощи протокола Secure Shell (SSH).

Для авторизации введите:

login as: **root  
**root@192.168.111.1's password: **keenetic**

  
![putty-01.png](https://help.keenetic.com/hc/article_attachments/360025322239)

Можно установить свой пароль. Для этого введите команду **passwd**:

New password: впишите свой пароль  
Retype password: подтвердите пароль

~ # **passwd**  
Changing password for root  
New password:  
Bad password: too weak  
Retype password:  
passwd: password for root changed by root

  
![putty-02.png](https://help.keenetic.com/hc/article_attachments/360025322279)

10. При успешной авторизации вы окажетесь в оболочке BusyBox v1.27.2 () built-in shell (ash). Теперь нужно обновить opkg-пакет, для этого введите команду **opkg update**:

/ # **opkg update**  
Downloading http://bin.entware.net/mipselsf-k3.4/Packages.gz  
Updated list of available packages in /opt/var/opkg-lists/entware  
Downloading http://bin.entware.net/mipselsf-k3.4/keenetic/Packages.gz  
Updated list of available packages in /opt/var/opkg-lists/keendev

  
![putty-opkg-update.png](https://help.keenetic.com/hc/article_attachments/360025322299)

Далее можно приступать к установке нужного OpenWRT пакета.

Например, для установки файлового менеджера Midnight Commander выполните команду:

opkg install mc