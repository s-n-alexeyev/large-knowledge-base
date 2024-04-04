

Обновлено 06/10/2023 16:07

[ПОДПИСАТЬСЯ](https://help.keenetic.com/hc/ru/articles/360021888880-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-OPKG-Entware-%D0%BD%D0%B0-%D0%B2%D1%81%D1%82%D1%80%D0%BE%D0%B5%D0%BD%D0%BD%D1%83%D1%8E-%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C-%D1%80%D0%BE%D1%83%D1%82%D0%B5%D1%80%D0%B0/subscription.html "Открывает окно входа")

Начиная с версии 3.7.x для некоторых актуальных моделей Keenetic (KN-xxxx) появилась возможность записывать OPKG Entware в раздел с файловой системой [UBIFS](https://ru.wikipedia.org/wiki/UBIFS) флэш-памяти NAND роутера, т.е. на встроенную память роутера.

NOTE: **Важно!** Перед использованием внимательно прочитайте об [особенностях работы NAND](https://forum.keenetic.net/topic/9737-%D0%BE%D1%81%D0%BE%D0%B1%D0%B5%D0%BD%D0%BD%D0%BE%D1%81%D1%82%D0%B8-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B-parallel-nand-flash/) флэш-памяти.  
Информация данной статьи актуальна для современных моделей: Giga (KN-1010/1011), Ultra (KN-1810/1811), Viva (KN-1910/1912), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hero 4G (KN-2310), Hero 4G+ (KN-2311), Giga SE (KN-2410), Ultra SE (KN-2510), Giant (KN-2610), Peak (KN-2710), Skipper 4G (KN-2910), Hopper DSL (KN-3610), Hopper (KN-3810) с версией KeeneticOS 3.7 и выше.

Для поддержки данной возможности вам потребуется установить пакеты:

![opkg-stor-01.png](https://help.keenetic.com/hc/article_attachments/360026609719)

На странице "Приложения" в разделе "Диски и принтеры" нажмите на "Встроенное хранилище" и затем на встроенном разделе **storage** создайте папку _install_:

![opkg-stor-02.png](https://help.keenetic.com/hc/article_attachments/360026609859)

В данный раздел записываете файл установки _mipsel-installer.tar.gz_ или _mips-installer.tar.gz_, в зависимости от устройства: 

TIP: **Справка:** Для моделей Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912), Hero 4G (KN-2310), Hero 4G+ (KN-2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810) используйте для установки архив **mipsel** — [mipsel-installer.tar.gz](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz)  
Для моделей Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610) используйте для установки архив **mips** — [mips-installer.tar.gz](https://bin.entware.net/mipssf-k3.4/installer/mips-installer.tar.gz)  
Для моделей Peak (KN-2710), Ultra (KN-1811) используйте для установки архив **aarch64** — [aarch64-installer.tar.gz](https://bin.entware.net/aarch64-k3.10/installer/aarch64-installer.tar.gz)

![opkg-stor-03.png](https://help.keenetic.com/hc/article_attachments/360026610079)

В [интерфейсе командной строки](https://help.keenetic.com/hc/ru/articles/213965889?source=search&auth_token=eyJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50X2lkIjoxMjE4MzY0LCJ1c2VyX2lkIjozODI5OTgzMzczODAsInRpY2tldF9pZCI6NTQ0MzUzLCJjaGFubmVsX2lkIjo2MywidHlwZSI6IlNFQVJDSCIsImV4cCI6MTYyNDQ2ODg2NX0.YUYdPm77dCcwZE56s4vFeTQ1reqbFkfs_tJ1v0iZ780) (CLI) интернет-центра выбираем системный раздел **storage:/**  для установки OPKG Entware:

(config)> **opkg disk storage:/**  
Opkg::Manager: Disk is set to: storage:/.

  
В логе увидим следующие записи:

**I [May 24 20:36:35] ndm: Opkg::Manager: unmount existing /opt disk: OPKG:/.**  
I [May 24 20:36:37] dropbear[31154]: Early exit: Terminated by signal  
**I [May 24 20:36:37] ndm: Opkg::Manager: disk unmounted.  
****I [May 24 20:36:37] ndm: Opkg::Manager: disk is set to: storage:/.  
****I [May 24 20:36:37] ndm: Opkg::Manager: /storage mounted to /storage.  
****I [May 24 20:36:37] ndm: Opkg::Manager: /storage mounted to /opt/.**​  
**I [May 24 20:36:37] npkg: inflating "mipsel-installer.tar.gz".  
****I [May 24 20:36:43] ndm: Opkg::Manager: /storage initialized.**​  
E [May 24 20:36:43] ndm: Opkg::Manager: invalid initrc "/opt/etc/init.d/rc.unslung": no such file or directory, trying /opt/etc/init.d/.  
I [May 24 20:36:43] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:36:43] ndm: Core::Session: client disconnected.  
I [May 24 20:36:43] installer: [1/5] Начало установки системы пакетов "Entware"...  
I [May 24 20:36:43] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:36:45] ndm: Core::Session: client disconnected.  
I [May 24 20:36:45] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:36:47] ndm: Core::Session: client disconnected.  
I [May 24 20:36:47] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:36:49] ndm: Core::Session: client disconnected.  
I [May 24 20:36:49] installer: Info: Раздел с UBIFS! (!не тестировалось!)  
I [May 24 20:36:49] installer: При возникновении проблем, используйте внешний накопитель с файловой системой ext2/ext3/ext4.  
I [May 24 20:36:49] installer: Info: "ping google.com"...  
I [May 24 20:36:49] ndm: Opkg::Manager: /opt/etc/init.d/doinstall: installer: Info: "ping google.com"...  
I [May 24 20:36:51] installer: Info: "ping google.com" ..... OK  
I [May 24 20:36:52] installer: Info: "ping bin.entware.net"...  
I [May 24 20:36:52] ndm: Opkg::Manager: /opt/etc/init.d/doinstall: installer: Info: "ping bin.entware.net"...  
I [May 24 20:36:54] installer: Info: "ping bin.entware.net" ..... OK  
I [May 24 20:36:55] installer: Info: Создание каталогов...  
I [May 24 20:36:55] installer: [2/5] Загрузка и установка основных пакетов...  
I [May 24 20:36:55] installer: Info: Устанавливается пакет "libgcc"...  
I [May 24 20:36:57] installer: Info: Пакет "libgcc" установлен.  
I [May 24 20:36:58] installer: Info: Устанавливается пакет "libc"...  
I [May 24 20:37:01] installer: Info: Пакет "libc" установлен.  
I [May 24 20:37:02] installer: Info: Устанавливается пакет "libpthread"...  
I [May 24 20:37:04] installer: Info: Пакет "libpthread" установлен.  
I [May 24 20:37:05] installer: Info: Устанавливается пакет "librt"...  
I [May 24 20:37:06] installer: Info: Пакет "librt" установлен.  
I [May 24 20:37:07] installer: Info: Устанавливается пакет "entware-release"...  
I [May 24 20:37:08] installer: Info: Пакет "entware-release" установлен.  
I [May 24 20:37:09] installer: Info: Устанавливается пакет "findutils"...  
I [May 24 20:37:11] installer: Info: Пакет "findutils" установлен.  
I [May 24 20:37:12] installer: Info: Устанавливается пакет "grep"...  
I [May 24 20:37:14] installer: Info: Пакет "grep" установлен.  
I [May 24 20:37:15] installer: Info: Устанавливается пакет "ldconfig"...  
I [May 24 20:37:17] installer: Info: Пакет "ldconfig" установлен.  
I [May 24 20:37:18] installer: Info: Устанавливается пакет "locales"...  
I [May 24 20:37:20] installer: Info: Пакет "locales" установлен.  
I [May 24 20:37:21] installer: Info: Устанавливается пакет "ndmq"...  
I [May 24 20:37:23] installer: Info: Пакет "ndmq" установлен.  
I [May 24 20:37:24] installer: Info: Устанавливается пакет "opkg"...  
I [May 24 20:37:27] installer: Info: Пакет "opkg" установлен.  
I [May 24 20:37:28] installer: Info: Устанавливается пакет "zoneinfo-asia"...  
I [May 24 20:37:29] installer: Info: Пакет "zoneinfo-asia" установлен.  
I [May 24 20:37:30] installer: Info: Устанавливается пакет "zoneinfo-europe"...  
I [May 24 20:37:32] installer: Info: Пакет "zoneinfo-europe" установлен.  
I [May 24 20:37:33] installer: Info: Устанавливается пакет "opt-ndmsv2"...  
I [May 24 20:37:35] installer: Info: Пакет "opt-ndmsv2" установлен.  
I [May 24 20:37:36] installer: Info: Устанавливается пакет "dropbear"...  
I [May 24 20:37:38] installer: Info: Пакет "dropbear" установлен.  
I [May 24 20:37:39] installer: Info: Устанавливается пакет "poorbox"...  
I [May 24 20:37:41] installer: Info: Пакет "poorbox" установлен.  
I [May 24 20:37:42] installer: Info: Устанавливается пакет "busybox"...  
I [May 24 20:37:48] installer: Info: Пакет "busybox" установлен.  
I [May 24 20:37:49] installer: Info: Установка пакетов прошла успешно!  
I [May 24 20:37:49] installer: [3/5] Генерация SSH-ключей...  
I [May 24 20:37:49] installer: Info: Генерируется ключ "rsa"...  
I [May 24 20:37:54] installer: Info: Ключ "rsa" создан.  
I [May 24 20:37:55] installer: Info: Генерируется ключ "ecdsa"...  
I [May 24 20:37:55] installer: Info: Ключ "ecdsa" создан.  
I [May 24 20:37:56] installer: Info: Генерируется ключ "ed25519"...  
I [May 24 20:37:56] installer: Info: Ключ "ed25519" создан.  
I [May 24 20:37:57] installer: [4/5] Настройка сценария запуска, установка часового пояса и запуск "dropbear"...  
I [May 24 20:37:57] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:37:57] ndm: Core::Session: client disconnected.  
I [May 24 20:37:57] dropbear[17854]: Running in background  
I [May 24 20:37:57] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:37:57] ndm: Opkg::Manager: configured init script: "/opt/etc/init.d/rc.unslung".  
I [May 24 20:37:57] ndm: Core::Session: client disconnected.  
I [May 24 20:37:57] ndm: Core::Server: started Session /var/run/ndm.core.socket.  
I [May 24 20:37:57] ndm: Core::System::Configuration: saving (ndmq/ci).  
I [May 24 20:37:57] ndm: Core::Session: client disconnected.  
I [May 24 20:37:57] installer: Можно открыть SSH-сессию для соединения с устройством (логин - root, пароль - keenetic, порт - 222).  
I [May 24 20:37:57] installer: [5/5] Установка системы пакетов "Entware" завершена! Не забудьте сменить пароль и номер порта!

Проверяем доступ не выходя из CLI:

(config)> **exec sh**  
  
BusyBox v1.33.0 () built-in shell (ash)  
/ #

Меняем пароль для root пользователя (по умолчанию логин **_root_**, пароль **_keenetic)_**:

/ # **passwd root**  
Changing password for root  
New password:  
Bad password: too weak  
Retype password:  
passwd: password for root changed by root

  
Пароль изменен, обновляем систему:

/ # **opkg update**  
Downloading http://bin.entware.net/mipselsf-k3.4/Packages.gz  
Updated list of available packages in /opt/var/opkg-lists/entware  
Downloading http://bin.entware.net/mipselsf-k3.4/keenetic/Packages.gz  
Updated list of available packages in /opt/var/opkg-lists/keendev  
/ # **opkg upgrade**

Теперь установите нужный opkg-пакет.  
  
Для удаления OPKG Entware необходимо зайти в [интерфейс командной строки](https://help.keenetic.com/hc/ru/articles/213965889?source=search&auth_token=eyJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50X2lkIjoxMjE4MzY0LCJ1c2VyX2lkIjozODI5OTgzMzczODAsInRpY2tldF9pZCI6NTQ0MzUzLCJjaGFubmVsX2lkIjo2MywidHlwZSI6IlNFQVJDSCIsImV4cCI6MTYyNDQ2ODg2NX0.YUYdPm77dCcwZE56s4vFeTQ1reqbFkfs_tJ1v0iZ780) (CLI) интернет-центра и отключить запуск opkg командой:

(config)> **no opkg disk**  
Opkg::Manager: Disk is unset.

  
После размонтируйте системный раздел **storage:/**  

(config)> **no system mount storage:**  
Core::FileSystem::Repository: "storage:" unmounted.

  
Удалите содержимое системного раздела **storage:/**

(config)> **erase storage:**  
Core::FileSystem::Repository: "storage:" erased.

TIP: **Примечание:** Если возникли проблемы с монтированием раздела, деплоем (развертыванием) системы, тогда необходимо написать в данную тему нашего форума: [https://forum.keenetic.net/topic/9738-установка-opkg-на-встроенную-память/](https://forum.keenetic.net/topic/9738-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-opkg-%D0%BD%D0%B0-%D0%B2%D1%81%D1%82%D1%80%D0%BE%D0%B5%D0%BD%D0%BD%D1%83%D1%8E-%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C/)