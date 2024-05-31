Сегодня мы будем настраивать FTP сервер на OpenWRT. В этом качестве я выбрал [vsftpd](http://vsftpd.beasts.org/).

Установим его:  
```shell
opkg update && opkg install vsftpd
```

Для доступа к серверу я хочу использовать отдельного пользователя и логинясь под ним иметь доступ ко всему внешнему накопителю. Создадим нового пользователя добавив его в к остальным в файл `/etc/passwd`:

```shell
vim /etc/passwd
```
... 
`newuser:*:1000:1000:newuser:/mnt/path_here/path/:/bin/false`

Можно попробовать добавить пользователя в группу 'nobody' и пропустить следующий шаг. Например так:

`newuser:*:1000:65534:newuser:/mnt/path_here/path/:/bin/false`

Добавим также одноимённую группу:

```shell
vim /etc/group
```
`newuser:x:1000:`

Устанавливаем пароль для пользователя:

```shell
passwd newuser
```

И теперь можно приступать к конфигурированию самого сервера. vsftpd позволяет задать список пользователей, которым будет позволено подключаться к ftp. Используем эту возможность:

```shell
vim /etc/vsftpd.conf
```
`userlist_enable=YES`
`userlist_deny=NO`
`userlist_file=/etc/vsftpd.users`

Согласно конфигурации, список пользователей располагается в файле `/etc/vsftpd.users`. Остаётся добавить пользователя в список.

```shell
echo newuser >> /etc/vsftpd.users
```

И изменить права на его домашнюю директорию

```shell
chown -R newuser:newuser /mnt/path_here/path/
```

Теперь настроим анонимный доступ. Для этого создадим папку:

```shell
mkdir /mnt/**path_here**/public
```

Добавим anonymous в список разрешенных пользователей:

```shell
echo anonymous >> /etc/vsftpd.users
```

Изменим некоторые параметры в конфигурации самого сервера:

```shell
vim /etc/vsftpd.conf
```
`anonymous_enable=YES`
`no_anon_password=YES`
`anon_root=/mnt/**path_here**/public`

Настроим права для папки с анонимным доступом:  

```shell
chown -R ftp:ftp /mnt/path_here/public/
chmod 555 /mnt/path_here/public/
```

Также потребуется изменить домашнюю папку пользователя ftp, т.к. иначе будет выдаваться ошибка (домашней папки ftp в OpenWRT попросту не существует).

```shell
vim /etc/passwd
```
`ftp:*:55:55:ftp:/mnt/path_here:/bin/false`

Запустим FTP сервер и добавим его в автозагрузку:  

```shell
/etc/init.d/vsftpd start
/etc/init.d/vsftpd enable
```

Осталось добавить настройки firewall для возможности доступа к серверу из интернета. Я использовал для этого интерфейс Luci, но никто не мешает вам вручную добавить правила iptables в `/etc/firewall.user` и перезапустить демон.

Итак, перейдём в веб-интерфейсе 'Сеть' -> 'Межсетевой экран' -> вкладка 'Правила для трафика'

![|600](/Media/OpenWRT_vsftpd/image_1.png)

Создадим правила для FTP открыв порты 20 и 21.

![|600](/Media/OpenWRT_vsftpd/image_2.png)

