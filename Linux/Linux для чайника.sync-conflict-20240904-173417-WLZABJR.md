```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Бенчмарк  в попугаях
Много лет назад на одном популярном англоязычном форуме, ныне покойном, предложили гениально простой способ нагреть проц и посчитать его скорость в попугаях.

```shell
time echo "scale=5000; 4*a(1)" | bc -l
```

bc - Си-подобный интерактивный интерпретатор. 
Подгружаем в bc математическую библиотеку опцией -l и просим выдать число π с точностью 5000 знаков после запятой.

---
# Просмотр известных портов
```shell
cat /etc/services | less
```

---
# Отрезаем расширение у файла

Стандартный способ — использовать утилиту `basename`, который отрезает весь путь слева, а если указать дополнительный параметр, то дополнительно отрежет справа и суффикс. Например пишем file.txt и суффикс .txt

```shell
basename file.txt .txt
```

>Получаем: file

Но можно обойтись внутренними преобразованиями в bash 
```shell
filename=file.txt; echo ${filename%.*}
```

>Получаем: file

Или наоборот, отрезать имя файла и оставить только расширение:
```shell
filename=file.txt; echo ${filename##*.}
```

>Получаем: txt

---
# Наблюдаем за командами 

Если вам необходимо следить за командами с изменяющимися выводимыми данными, используйте команду watch. 

>Например, чтобы следить за средней загрузкой, выполняем: 
```bash
watch "cat /proc/loadavg"
```
Каждые две секунды watch будет запускать команду cat. (Для завершения выполнения команды нажмите сочетание клавиш CTRL+C). 

>Чтобы увеличить частоту обновления до 10 секунд, выполняем: 
```bash
watch -n 10 "ls -l"
```

>Чтобы выделить разницу между обновлениями на экране, выполните:
```bash
watch -d "ls -l"
```

>Выводит список открытых файлов и сокетов, связанных с сетевыми соединениями.
```bash
watch lsof -i@192.168.0.2 -n -P
```

Для выполнения выделения необходимо, чтобы файлы изменялись.

---
# Как завершилась последняя команда — успешно или нет?

Можно получить статус завершения последней команды из переменной среды '$?', в ней хранится код завершения. Например:

```shell
ls -l /var/
echo $?
```
0

или

```shell
ls -l /var/wwer
echo $?
```
2

Код завершения 0 означает что команда выполнена успешно, любое отличное от нуля число свидетельствует об ошибке.

---
# Цветной вывод в консоли

После установки:
`sudo apt install lolcat`

Смотрим имеющиеся возможности:
`lolcat -h`

Можем использовать утилиту в комплекте с любой другой командой. К примеру:
`ping google.com | lolcat`

`ps | lolcat`

`cal | lolcat`

или выдать анимированный текст:
`echo Hello World | lolcat -a -d 500`

Пользы никакой, для развлечения, получается

---
# Команда find

Находим файлы размером более 10 МБ в каталоге /usr:
```shell
find /usr -size +10M
```

Находим в каталоге /home файлы, которые были изменены 120 дней назад:
```shell
find /home -mtime +120
```

Находим в каталоге /var файлы, к которым не обращались в течение 90 дней:
```shell
find /var \! -atime -90
```

Находим файл "core" во всем дереве каталогов. Если он найден, удаляем его без запроса:
```shell
find / -name core -exec rm {} \
```

---
# Команда uname

Ядро Linux и дистрибутивы, основанные на нем, разрабатываются отдельно от другого, поэтому у ядра есть своя схема управления версиями. Некоторые выпуски ядра достигают известной популярности, поэтому нет ничего необычного в том, что несколько независимых дистрибутивов используют одно и то же ядро. 

Чтобы узнать, в каком ядре работает данная система, выполните команду: 
`uname -r`

Остальные ключи:
`-s`   Имя ядра
`-n`   Имя узла системы (имя хоста). Это имя, которое система использует при общении по сети. Выдает тот же вывод, что и команда hostname
`-v`   Версия ядра
`-m`   Аппаратное имя
`-p`   Архитектура процессора
`-i`   Аппаратная платформа
`-o`   Распечатать название операционной системы. В системах Linux это «GNU / Linux»
`-a`   Ведет себя так же, как если бы были заданы: `-snrvmo`

---
# Монтирование файловой системы

Файловую систему необходимо смонтировать до того, как она станет видимой для процессов. 

Точкой монтирования для ФС может быть любой каталог. 

Например, команда 
```shell
sudo mount /dev/sda1 /mnt/temp
```

монтирует ФС в разделе, представленном файлом устройства /dev/sda1 в каталоге /mnt, который является традиционным для временных точек монтирования. 

Размер файловой системы можно проверить с помощью команды df.  Например:
```shell
df -h /mnt/web1
```

В приведенном примере флаг -h используется для выдачи результатов в понятном для человека виде.

---
# Команда date
Отобразит текущее системное значение в форматировании по умолчанию:
`date`

Пример форматированного вывода:
`date +"Day: %d, Month: %m, Year: %Y"`

Весь список по %.. смотрим в date --help

Строка даты принимает значения, такие как «завтра», «пятница», «последняя среда», «следующий вторник», «следующий месяц», «следующая неделя» .. и т. д.
`date -d "next sunday"`
или
`date -d "15 days ago"`

Самостоятельно устанавливать дату и время - крайне не рекомендуется, но сделать это можно так:
`date --set="19691228 16:25"`

Пример использования date в скриптах (взят с losst):
Если текущий день месяца — последний, сформировать отчет о занятости дискового пространства корневого и домашнего каталога в файл report.
`#!/bin/bash`
`if [[ $(date --date='next day' +%d) = '01' ]]; then`
`df -h / /home > report`

---
# Когда система подтормаживает, разобраться поможет:


`ps aux --sort=-%cpu | grep -m 11 -v 'whoami'`
Этой командой получим список из 10 (не ваших) процессов, которые больше всего нагружают процессор.

Либо можем получить весь список процессов, которые были запущены не вами:
`ps aux | grep -v 'whoami'`

Так смотрим список самых загруженных (в более читаемом виде):
`ps -eo pid,ppid,%mem,%cpu,comm --sort=-%cpu | head`

----
# Форк бомба

Один из способов издевательства над системой - Форк бомба

`:(){`
` :|:&`
`};:`

Это скрипт, который создает множество процессов, пока компьютер не зависнет.
Единственным решением остается отключение питания.

Что к чему:
`:()`  Определение функции.
`{`  Открытие функции.
`:|:`  Далее, загружает копию функции «:» в память тем самым, будет вызывать само себя рекурсивно. Передает результат на другой вызов функции.
‘:’   Худшая часть — функция, вызываемая два раза, чтобы «бомбить» вашу систему.
&  Помещает вызов функции в фоновом режиме, чтобы fork (дочерний процесс) не мог «умереть» вообще, тем самым это начнет есть системные ресурсы.
`}`  Закрытие функции.
`;`  Завершает определение функции. Разделяет команды.
`:`  Запускает функцию которая порождает fork bomb().

Некоторые дистрибутивы способны предотвращать такую атаку путем ограничения количества процессов от одного пользователя.

---
# Команда rm

(В приведенных примерах находимся в месте расположения файла)
Для удаления файла some_file используем rm с именем файла в качестве аргумента:
```shell
rm some_file
```

Можно сразу несколько:
```shell
rm some_file1 some_file2 some_file3
```

Удалить все файлы в текущей директории:
```shell
rm *
```

Выдавать запрос перед удалением каждого файла:
```shell
rm -i *
```

Удаляем директорию и ее содержимое:
```shell
rm -r mydir
```

Удаляем все файлы в каталоге, которые не соответствуют определенному расширению:
```shell
rm !(*.html | *.css | *.php | *.png)
```

---
# Арифметические операторы в сценариях оболочки

Если необходимо использовать арифметические операторы в сценариях оболочки, поможет команда expr (которая выполняет даже некоторые операции со строками). 

Например: expr 5 + 2 выводит результат 7. 

Полный перечень операций: expr --help

expr не хранит результат, а по умолчанию просто печатает ответ. Но никто не запрещает сохранять результат в переменные: 
```shell
A=$( expr 12 - 7 )
echo $A # 5
```

Применение команды expr — это неуклюжий и медленный способ выполнения математических вычислений. 

Если вам часто приходится заниматься ими, то, лучше использовать что-то вроде Python.

---
# Команда split
Разбить файл на части можно используя команду split

Для примера создадим файл с цифрами от 1 до 1000 в столбик командой:
`echo {1..1000} | tr ' ' '\n' > some_file`

Разделим этот файл по 200 строк в каждом, командой:
`split -200 some_file`

Цифру можно задать свою. Исходный some_file останется, рядом создадутся 5 (потому что на 200  делили) файлов. Подумай, какие названия им даст ОС?

Команду можно также использовать для разделения файлов на части по размеру информации, например: 
`split -b100b some_file2`
`split -b100k some_file2` 
`split -b100m some_file2`

Первая команда разделит файл на части по 100 байтов каждая, вторая - на части по 100 Кбайт каждая, третья - по 100 Мбайт каждая.

---
# Атрибуты файла

В Linux кроме прав доступа есть еще и атрибуты файла, подобно атрибутам файла в других ОС. 

 Просмотреть установленные атрибуты можно командой: `chattr some_file`

Основные полезные атрибуты:
`i` Запрет на изменений, переименование и удаление файла. Обычно ставится для критических конфиг. файлов. Установить и сбросить может только root (либо процесс с CAP_LINUX_IMMUTABLE)

`u` При удалении файла с установленным атрибутом u его содержимое хранится на жестком диске, что позволяет легко восстановить файл.

`c` Файл будет сжиматься. Рекомендуется для больших несжатых данных, но крайне не желателен для файлов БД т.к. доступ будет медленнее. 

`S` Данные, записываемые в файл, сразу будут сброшены на диск. Аналогично выполнению команды sync сразу после каждой операции записи в файл.

`s` Прямо противоположен атрибуту u. После удаления файла, принадлежащие ему блоки будут обнулены и восстановить их уже не получится.

Пример установки атрибута: `chattr +i config_file`
Пример сброса атрибута: `chattr -i config_file

---
# Команда fuser

Чтобы узнать, какой процесс открыл тот или иной ресурс, например, файл или сетевой порт, можно воспользоваться командой `fuser`. Например: 
 
```shell
fuser -va 23/tcp
```

Получим идентификатор процесса, открывшего ТСР порт 23
```shell
fuser -va /chroot/etc/resolv.conf
```

Во втором  случае получим идентификатор процесса, открывшего файл /chroot/ etc/resolv.conf.

Что делать далее - решать вам, например, можно убить этот процесс командой `kill`.

---
# IP адрес

Существует два типа IP-адресов: локальные и публичные.

Локальный IP присваивается системой, и его можно посмотреть с помощью команды:
```shell
hostname -I
```

Если же вы хотите узнать публичный IP вашего ПК, который провайдер присваивает вашему интерфейсу, то при подключённом интернете выполните в командной строке:
```shell
curl ifconfig.co
#или
curl ifconfig.me
```

Команда обращается к серверу `ifconfig.me`, который возвращает обратно IP-шник одной строкой вместо полноценной веб-страницы.

---
# Примеры использования команды wget

Скачивание одного файла:
```shell
wget https://www.example.com/file.zip
```

Скачивание файла с указанием имени:
```shell
wget https://www.example.com/file.zip -O newname.zip
```

Скачивание нескольких файлов из списка:
```shell
wget -i filelist.txt
```
- где filelist.txt содержит список URL-адресов файлов, каждый адрес на новой строке.

Скачивание файла из защищенного соединения:
```shell
wget --user=user --password=password https://www.example.com/file.zip
```

Скачивание файла с использованием прокси-сервера:
```shell
wget --proxy=on --proxy-user=user --proxy-passwd=password https://www.example.com/file.zip
```

Ограничение скорости загрузки:
```shell
wget --limit-rate=100k https://www.example.com/file.zip
```

Продолжение загрузки файла после обрыва связи:
```shell
wget -c https://www.example.com/file.zip
```

Загрузка файла только в случае, если он изменен:
```shell
wget --timestamping https://www.example.com/file.zip
```

Извлечение только определенных типов файлов:
```shell
wget -r -A.png,.jpg https://www.example.com/images/
```

Загрузка файла с использованием определенного User-Agent:
```shell
wget --user-agent="Mozilla/5.0" https://www.example.com/file.zip
```

---
# Бинарные файлы внутри скриптов

Из скрипта можно извлекать предварительно записанные в них бинарные файлы, например архивы. Особенность при создании такого скрипта в том, что сначала надо написать сам скрипт, а потом с помощью команды cat загнать в него необходимый файл. 

После того, как будет написана последовательность команд скрипта, необходимо в конце вставить пустую строку, сохранить скрипт и выполнить в терминале нечто вроде:

```shell
cat my_arch.tar.gz >> my_script.sh
```

После выполнения этой команды архив my_arch.tar.gz станет частью скрипта my_script.sh. Для извлечения архива в приведенном примере используется команда:
```shell
tail -n +30 "$0" > $DEPLOY_PATH/$ARCH_NAME
```
которая в данном случае извлекает бинарные данные и перенаправляет вывод в файл `./libs/jar/odfdom-simple/odfdom-libs.tar.gz. `
Параметр -n +30 означает, что выводить данные надо начиная с 30 строки файла, а под "$0" скрывается имя выполняющегося скрипта.

После того как данные извлечены, можно распаковывать архив, распихивать файлы по каталогам, создавать симлинки и в общем делать всё, что нужно для развертывания вашей системы. Самое главное не забудьте вызвать команду exit до того, как начнутся бинарные данные, иначе bash попытается выполнить и их

(Пример скрипта, который извлекает из себя архив с jar-файлами, распаковывает его и удаляет архив)
![](data:image/jpg;base64,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)

---
# Отображение зависимостей

С помощью команды ldd можно отобразить список динамических библиотек, необходимых для работы вашей программы. Она помогает выявлять отсутствующие зависимости и решать проблемы совместимости.

Основной синтаксис команды ldd выглядит следующим образом:
`ldd [опция]... [файл]...`

Чтобы увидеть список динамических библиотек, необходимых для работы команды /bin/ls, нужно выполнить команду:
```shell
ldd /bin/ls
```

ldd имеет несколько опций, которые могут изменить его поведение:
`--version`: Показать версию ldd.
`--verbose:` Вывести всю информацию, включая информацию о версиях символов.
`--help`: Показать справочное сообщение и выйти.

---
# Отображения дерева зависимостей динамических библиотек

Команда lddtree, являющаяся частью пакета pax-utils, предназначена для отображения зависимостей, необходимых для работы исполняемых файлов или других динамических библиотек. 

lddtree отображает иерархическую структуру зависимостей, что облегчает понимание взаимосвязей между библиотеками.

Чтобы увидеть дерево зависимостей для программы /bin/ls. В этом случае команда будет выглядеть следующим образом:
```shell
lddtree /bin/ls
```

Если у вас ещё не установлен pax-utils, который включает в себя lddtree, вы можете установить его с помощью менеджера пакетов:
Debian или Ubuntu:
```shell
sudo apt-get update
sudo apt-get install pax-utils
```
Fedora:
```shell
sudo dnf install pax-utils
```

---
# Основные сетевые команды Linux:

• `ping`: Проверяет подключение к удаленному хосту, отправляя пакеты ICMP.
• `traceroute`: Определяет путь, по которому пакеты проходят от вашего компьютера к удаленному хосту.
• `netstat`: Отображает информацию о сетевых подключениях, маршрутах и статистике.
• `ifconfig`: Отображает и настраивает сетевые интерфейсы.
• `route`: Управляет таблицей маршрутизации.
• `nslookup`: Выполняет поиск в системе доменных имен (DNS).
• `dig`: Более продвинутый инструмент поиска DNS, предоставляющий подробную информацию.
• `arp`: Отображает и управляет таблицей сопоставления IP-адресов и MAC-адресов.
• `tcpdump`: Захватывает и анализирует сетевой трафик.
• `wireshark`: Графический инструмент для захвата и анализа сетевого трафика.
# Управление сетевыми интерфейсами:

• `ifup`: Включает сетевой интерфейс.
• `ifdown`: Выключает сетевой интерфейс.
• `dhclient`: Получает IP-адрес и другую информацию о конфигурации от сервера DHCP.
• `ip`: Управляет сетевыми интерфейсами и адресами с помощью командной строки.
# Настройка сети:

• `hostname`: Устанавливает или отображает имя хоста компьютера.
• `resolv.conf`: Настраивает параметры DNS-сервера.
• `/etc/network/interfaces`: Основной файл конфигурации сети в большинстве дистрибутивов Linux.
# Мониторинг сети:

• `vnstat`: Мониторинг использования полосы пропускания в режиме реального времени.
• `iptraf`: Графический инструмент для мониторинга сетевого трафика.
• `nethogs`: Отображает процессы, использующие сетевое соединение.

---
# Системные  переменные

## Общие системные переменные:
`$SHELL`: Оболочка, используемая текущим процессом.
`$HOME`: Домашний каталог текущего пользователя.
`$PATH`: Список каталогов, в которых оболочка ищет исполняемые файлы.
`$USER`: Имя текущего пользователя.
`$UID`: Идентификатор пользователя (UID) текущего пользователя.
`$PWD`: Текущий рабочий каталог.
`$HOSTNAME`: Имя хоста системы.
`$TERM`: Тип терминала, используемого текущим процессом.
`$LANG`: Языковые настройки системы.
`$LC_ALL`: Настройки локали для всех категорий.
## Переменные окружения, связанные с оболочкой:
`$PS1:` Строка приглашения оболочки.
`$PS2`: Строка продолжения оболочки.
`$IFS`: Внутренний разделитель полей, используемый оболочкой для разделения слов в строке.
`$CDPATH`: Список каталогов, в которых оболочка выполняет команду cd.
`$EDITOR`: Редактор, используемый оболочкой по умолчанию.
`$PAGER`: Программа просмотра, используемая оболочкой по умолчанию.
## Переменные окружения, связанные с командами:
`$0`: Имя текущей команды.
`$1`, `$2`, ...: Аргументы, переданные текущей команде.
`$#`: Количество аргументов, переданных текущей команде.
`$?`: Код выхода последней выполненной команды.
## Переменные окружения, связанные с процессами:
`$PPID`: Идентификатор родительского процесса.
`$PID`: Идентификатор текущего процесса.
`$PPWD`: Текущий рабочий каталог родительского процесса.
## Переменные окружения, связанные с системой:
`$OSTYPE`: Тип операционной системы.
`$ARCH`: Архитектура процессора.
`$KERNELRELEASE`: Версия ядра.
`$VERSION`: Версия дистрибутива Linux.
## Пользовательские переменные окружения:
Пользователи могут создавать свои собственные переменные окружения, используя команду `export`. 
Например: export `MY_VARIABLE=value`

---
# Список открытых файлов и сокетов
Отобразить список открытых файлов и псевдофайлов, в том числе и сокетов, как локальных, так и протоколов TCP и UDP, можно с помощью команды `lsof` 

К примеру, показать все TCP и UDP сокеты 
```shell
lsof -i 
```

Показать все TCP и UDP сокеты, связанные с адресом 192.168.1.5. 
```shell
lsof -i@192.168.1.5 
```

Тоже самое, но при отображении не преобразовывать адреса хостов и номера портов в доменные имена и названия сервисов. 
```shell
lsof -i@192.168.1.5 -n -P 
```

Показать все TCP сокеты; при отображении не преобразовывать адреса хостов и номера портов. 
```shell
lsof -i TCP -n -P 
```

Показать все UDP сокеты, связанные с адресом 192.168.1.5; при отображении не преобразовывать адреса хостов и номера портов. 
```shell
lsof -i UDP@192.168.1.5 -n -P
```

## Чем занимается устройство

Чтобы определить, чем занимается устройство, которое нужно размонтировать, существует полезный инструмент — команда `lsof`. 

>Введите ее с именем нужного раздела, например:
```bash
lsof /mnt/test
```

>Выходные данные покажут, какие команды удерживают файлы открытыми в этом разделе. Таким же образом можно использовать команду: 
```bash
fuser-v /mnt/test
```

---
# Замена традиционной команды ls

`exa` - замена для команды `ls`, написанная на Rust, используется для отображения списка файлов и каталогов. Призвана предоставлять более удобные по умолчанию форматирование и цвета, а также дополнительные функции, такие как дерево каталогов. 

Примеры:
Отобразить список файлов с подробной информацией:
```shell
exa -l
```

Отобразить список файлов, включая скрытые, с подробной информацией:
```shell
exa -la
```

Показать древовидный вывод содержимого каталога:
```shell
exa --tree
```

Показать древовидный вывод содержимого каталога с указанием уровня вложенности:
```shell
exa --tree --level=2
```

Отобразить файлы с информацией о Git-статусе:
```shell
exa -l --git
```

Установка exa зависит от вашего дистрибутива Linux. Например, для дистрибутивов на основе Debian:
```shell
sudo apt install exa
```

---
# Команды системной информации

>отобразить архитектуру компьютера
```shell
arch
```

```shell
uname -m
```

>отобразить используемую версию ядра
```shell
uname -r
```

>показать аппаратные системные компоненты — (SMBIOS / DMI)
```
dmidecode -q
```  

>вывести характеристики жесткого диска
```shell
hdparm -i /dev/hda
```

>протестировать производительность чтения данных с жесткого диска
```shell
hdparm -tT /dev/sda
```

>отобразить информацию о процессоре
```shell
cat /proc/cpuinfo
```

>показать прерывания
```shell
cat /proc/interrupts
```

>проверить использование памяти
```shell
cat /proc/meminfo
```

>показать файл(ы) подкачки
```shell
cat /proc/swaps
```

>вывести версию ядра
```shell
cat /proc/version
```

>показать сетевые интерфейсы и статистику по ним
```shell
cat /proc/net/dev
```

>отобразить смонтированные файловые системы
```shell
cat /proc/mounts
```

>показать в виде дерева PCI устройства
```shell
lspci -tv
```

>показать в виде дерева USB устройства
```shell
lsusb -tv
```

>вывести системную дату
```shell
date
```

>вывести таблицу-календарь 2024-го года
```shell
cal 2024
```

>установить системные дату и время ММДДЧЧммГГГГ.СС (МесяцДеньЧасМинутыГод.Секунды)
```shell
date 052012002024.00
```

>сохранить системное время в BIOS
```shell
clock -w
```

---
# Команда xargs

Возможность объединения нескольких команд Linux в терминале и использования их в качестве конвейера, когда каждая следующая команда получает вывод предыдущей - очень мощный и гибкий инструмент. Но команды можно объединять не только так. С помощью утилиты xargs вывод предыдущей команды можно передать в аргументы следующей.

Синтаксис команды:
команда1 | xargs опции команда2 аргументы

Сначала выполняется любая первая команда и весь её вывод по туннелю передается в xargs. Затем этот вывод разбивается на строки и для каждой строки вызывается вторая команда, а полученная строка передаётся ей в аргументах.

С помощью этой команды можно например вывести все имена файлов из папки ~/folder:
```bash
ls ~/folder | xargs -t -L1 echo
```

`-t` — используется, чтобы подробнее понять, что происходит
`-L1` — указывает сколько строк надо передавать в одну команду

---
# Модули ядра Linux

Ядро Linux — является монолитным ядром. 
Это значит, что весь исполняемый код сосредоточен в одном файле. Такая архитектура имеет некоторые недостатки, например, невозможность установки новых драйверов без пересборки ядра. Но разработчики нашли решение и этой проблеме, добавив систему модулей.

Модули ядра Linux собираются только под определенную версию ядра и находятся в папке /lib/modules/.

Основные команды для управления модулями.
 ⁃ `lsmod` - посмотреть загруженные модули
 ⁃ `modinfo` - информация о модуле
 ⁃ `insmod` - загрузить модуль
 ⁃ `rmmod` - удалить модуль

Чтобы посмотреть все установленные модули ядра Linux (DEB) в системе:
```bash
dpkg -S *.ko | grep /lib/modules
```

---
# История команд
Если открыть окно терминала и ввести несколько команд, а после открыть второе окно, то история команд bash во втором окне не будет содержать команд из первого. К тому же, если закрыть первый терминал, а затем второй, то история команд из первого терминала будет перезаписана вторым. 

Так происходит из-за того, что история команд записывается только при закрытии терминала, а не после каждой команды. Это можно исправить.

Отредактируем файл `.bashrc` 

добавив в него строки:

```
shopt -s histappend

PROMPT_COMMAND='history -a'
```

Так история команд будет добавляться к старой, а не перезаписывать ее, и запись будет происходить каждый раз в момент отображения подсказки bash.

---
# Справка по важным спецсимволам bash

`;` Отделение команд друг от друга  
`:` Команда оболочки, ничего не делает  
`.` Запуск оболочки без собственного командного подпроцессора (.file соответствует исходному файлу) 
`#` Ввод комментария 
`#!/bin/sh` Идентификация оболочки, в которой будет выполняться программа 
`&` Выполнение команды в фоновом режиме (com &) 
`&&` Выполнение одной команды в зависимости от результата другой (com1 && com2) 
`&>` Переадресация стандартного вывода и ошибок (соответствует >&) 
`|` Создание программных каналов (com1 | com2) 
`||` Выполнение одной команды в зависимости от результата другой (com1 || com2) 
`*` Джокерный символ для имен файлов (любое количество символов) 
`?` Джокерный символ для имен файлов (любой символ) 
`[abc] Джокерный символ для имен файлов (любой символ из abc) 
`[ expression ]` Сокращенный вариант записи test expression
`(...)` Выполнение команд в той же оболочке ((сom1; сom2)) 
`{...}` Группирование команд 
`{ , , }` Объединение нескольких последовательностей символов (a{1,2,3} → a1 a2 a3) 
`{a..b}` Объединение нескольких последовательностей символов (b{4..6} → b4 b5 b6) 
`~` Сокращенное обозначение домашнего каталога 
`>` Переадресация вывода в файл (com > file)
`>>` Переадресация вывода и добавление его в существующий файл 
`>&` Переадресация стандартного вывода и ошибок (соответствует &>) 
`2>` Переадресация стандартного вывода ошибок 
`<` Переадресация ввода из файла (com < file) 
`<< end` Переадресация ввода из активного файла до завершения 
`$` Обозначение переменных (echo $var) 
`$!` Номер PID последнего процесса, запущенного в фоновом режиме 
`$$ PID` актуальной оболочки 
`$0` Имя выполняемого в данный момент сценарного файла оболочки
`$1–$9` Первые девять параметров, переданных команде 
`$#` Количество параметров, переданных программе оболочки 
`$*` или `$@` Совокупность всех переданных параметров 
`$?` Возвращаемое значение последней команды (0=OK или номер ошибки) 
`$(...)` Подстановка команд (echo $(ls)) 
`${...}` Различные специальные функции для обработки последовательностей символов 
`$[...]` Арифметические вычисления (echo $[2+3]) 
`"..."` Предотвращение интерпретации большинства специальных символов 
`'...'` Предотвращение интерпретации всех специальных символов 
\``...`\` Подстановка команд (echo \`ls\`)

---
# Журнал ядра

Для просмотра сообщений ядра используем команду
```bash
journalctl -k 
```

Команда покажет все сообщения ядра для текущей загрузки. 

Такую команду можно комбинировать с опцией `-b`, чтобы просмотреть сообщения ядра во время предыдущей загрузки:
```bash
journalctl -k -b -2
```

Но бывает такое, что в некоторых системах boot logging отключен и вместо лога предыдущих загрузок получаем сообщение: `"Specifying boot ID has no effect, no persistent journal was found"`

Исправляем ситуацию так: 
В файле /etc/systemd/journald.conf  параметр  Storage выставляем в persistent - Storage=persistent
И перезапускаем сервис командой:
```bash
systemctl restart systemd-journald
```

Должно сработать:
`journalctl -k -b -0` - текущая загрузка
`journalctl -k -b -1` - предыдущая
`journalctl -k -b -2` - предыдущая предыдущая
`journalctl -k -b -n` - и т. д.
