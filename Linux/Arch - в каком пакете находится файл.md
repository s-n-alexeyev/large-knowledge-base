2020-09-01

[Оригинальная статья](https://blackarch.ru/?p=1210)

Иногда название нужной утилиты не совпадает с названием пакета — особенно такое бывает когда один пакет содержит несколько программ. В результате возникает проблема — найти пакет, в котором присутствует нужный исполнимый файл или файл заголовка (если вы получили ошибку при компиляции из-за отсутствия определённого файла).

Утилита **pkgfile** ищет в метаданных **.files**, созданных **repo-add**, чтобы получить информацию о файлах в пакетах. По умолчанию указанная цель считается именем файла и pkgfile вернёт пакеты, содержащие этот файл. Репозитории, в которых ищет pkgfile, определяются теми, которые включены в **/etc/pacman.conf**.

>Для установки программы выполните команду:
```shell
sudo pacman -S pkgfile
```

>Обновите сохранённые файлы метаданных.
```shell
sudo pkgfile --update
```

>К примеру, мне нужно узнать, в каком пакете находится файл finger. Тогда я запускаю следующую команду:
```shell
pkgfile ifconfig
```
- Как можно увидеть, pkgfile прекрасно справилась со своей задачей — исполнимый файл ifconfig  находится в пакете core/net-tools репозитория arch.

>С помощью опции `-l,` `--list` можно посмотреть содержимое любого пакета:
```shell
pkgfile -l net-tools
```

```
core/net-tools  /usr/  
core/net-tools  /usr/bin/  
core/net-tools  /usr/bin/arp  
core/net-tools  /usr/bin/ifconfig  
core/net-tools  /usr/bin/ipmaddr  
core/net-tools  /usr/bin/iptunnel  
core/net-tools  /usr/bin/mii-tool  
core/net-tools  /usr/bin/nameif  
core/net-tools  /usr/bin/netstat  
core/net-tools  /usr/bin/plipconfig  
core/net-tools  /usr/bin/rarp  
core/net-tools  /usr/bin/route  
core/net-tools  /usr/bin/slattach  
core/net-tools  /usr/share/  
core/net-tools  /usr/share/man/  
core/net-tools  /usr/share/man/man5/  
core/net-tools  /usr/share/man/man5/ethers.5.gz  
core/net-tools  /usr/share/man/man8/  
core/net-tools  /usr/share/man/man8/arp.8.gz  
core/net-tools  /usr/share/man/man8/ifconfig.8.gz  
core/net-tools  /usr/share/man/man8/ipmaddr.8.gz  
core/net-tools  /usr/share/man/man8/iptunnel.8.gz  
core/net-tools  /usr/share/man/man8/mii-tool.8.gz  
core/net-tools  /usr/share/man/man8/nameif.8.gz  
core/net-tools  /usr/share/man/man8/netstat.8.gz  
core/net-tools  /usr/share/man/man8/plipconfig.8.gz  
core/net-tools  /usr/share/man/man8/rarp.8.gz  
core/net-tools  /usr/share/man/man8/route.8.gz  
core/net-tools  /usr/share/man/man8/slattach.8.gz
```

Целью считается имя пакета, а не имя файла, и возвращается содержимое указанного пакета. Это позволяет использовать синтаксис стиля репо/пакет (например, "core/pacman"), чтобы ограничить диапазон поиска, но только когда `--list` используется без параметров `--glob` или `--regex`.
## Эвристика поиска совпадений  

В режиме **--search** и без опции `--regex` или `--glob,` pkgfile попытается сопоставить предоставленную цель как точное имя файла. Если цель содержит символ '/', то будет сделана попытка найти совпадение по полному пути. При включённом поиске **--regex** и `--glob`, pkgfile всегда будет соответствовать полному пути.

В режиме `--list` и без опции `--regex` или `--glob`, pkgfile попытается сопоставить предоставленную цель как точное имя пакета. Если цель содержит символ '/', текст перед косой чертой будет считаться репозиторием, и поиск будет ограничен только этим репозиторием.
## Все опции pkgfile  

>Использование:
```shell
pkgfile [ОПЦИИ] ЦЕЛЬ
```

 **Действия**:
  `-l`, `--list`                показать содержимое пакета
  `-s`, `--search`            поиск пакета, содержащего цель (по умолчанию)
  `-u`, `--update`            обновить репозиторий списков файлов

 **Совпадение**:
  `-b`, `--binaries`        возвращать только файлы, содержащиеся в директории bin
  `-d`, `--directories`  поиск по именам директорий
  `-g`, `--glob`               включить совпадения с подстановочными символами
  `-i`, `--ignorecase`    регистронезависимый поиск
  `-R`, `--repo`               <РЕПОЗИТОРИЙ>  поиск в указанном репозитории
  `-r`, `--regex`             включить поиск по регулярным выражениям

 **Вывод**:
  `-q`, `--quiet`             выводить меньше при листинге
  `-v`, `--verbose`          выводить больше
  `-w`, `--raw`                 отключить выравнивание вывода
  `-0`, `--null`               окончанием вывода является символ null

 **Загрузка**:
  `-z`, `--compress[=ТИП]`   сжать загруженные репозитории

 **Общие**:
  `-C`, `--config`           <ФАЙЛ>     использовать альтернативный конфигурационный файл (по умолчанию: /etc/pacman.conf)
  `-D`, `--cachedir`       <ДИРЕКТОРИЯ>    использовать альтернативную директорию кэширования (по умолчанию: /var/cache/pkgfile)
  `-h`, `--help`               показать справку и выйти
  `-V`, `--version`         показать версию и выйти