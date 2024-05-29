
>Если во время запуска службы PostgreSQL:
```shell
sudo systemctl start postgresql.service
```

это не получилось и появилось следующее сообщение:

*Job for postgresql.service failed because the control process exited with error code.*
*See "systemctl status postgresql.service" and "journalctl -xe" for details.*

>То проверьте статус данной службы:
```shell
sudo systemctl status postgresql.service
```

В моём случае это:

*● postgresql.service - PostgreSQL database server*
     *Loaded: loaded (/usr/lib/systemd/system/postgresql.service; disabled; vendor preset: disabled)*
     *Active: failed (Result: exit-code) since Mon 2020-04-20 12:23:08 MSK; 8s ago*
    *Process: 63126 ExecStartPre=/usr/bin/postgresql-check-db-dir ${PGROOT}/data (code=exited, status=1/FAILURE)*

*апр 20 12:23:08 HackWare systemd[1]: Starting PostgreSQL database server...*
*апр 20 12:23:08 HackWare postgres[63126]: An old version of the database format was found.*
*апр 20 12:23:08 HackWare postgres[63126]: See https://wiki.archlinux.org/index.php/PostgreSQL#Upgrading_PostgreSQL*
*апр 20 12:23:08 HackWare systemd[1]: postgresql.service: Control process exited, code=exited, status=1/FAILURE*
*апр 20 12:23:08 HackWare systemd[1]: postgresql.service: Failed with result 'exit-code'.*
*апр 20 12:23:08 HackWare systemd[1]: Failed to start PostgreSQL database server.*

[![|800](/Media/PostgreSQL_error_An_old_version/image_1.png)](https://blackarch.ru/wp-content/uploads/2020/04/postgresql.service-error.png)

Ключевой в этом выводе является строка:

*An old version of the database format was found.*

Она говорит о том, что найдена база данных старого формата.

Для решения проблемы предлагается перейти по ссылке: [https://wiki.archlinux.org/index.php/PostgreSQL#Upgrading_PostgreSQL](https://wiki.archlinux.org/index.php/PostgreSQL#Upgrading_PostgreSQL)

Обновление баз данных не требуется при минорных обновлениях PostgreSQL, но может потребоваться при мажорных обновлениях, поскольку из-за нововведений можем поменяться их схема.

Обновление можно сделать с сохранением имеющейся информации, а также без её сохранения — фактически, удалив и заново инициализировав базу данных. Второй вариант подходит для тех, у кого пакет PostgreSQL был установлен давно, но необходимость его использования возникла значительно после его установки. В результате вы обнаружили, что служба PostgreSQL не работает, хотя она никогда и не использовалась.
## Как обновить базы данных PostgreSQL с сохранением информации  

Для обновления баз данных используется утилита **pg_upgrade**. Данная утилита включена в пакет **postgresql**. Данная утилита может обновлять базы данных начиная с 8.4.X.

Обратите внимание, что каталог кластера баз данных не меняется от версии к версии, поэтому перед запуском **pg_upgrade** необходимо переименовать существующий каталог данных и перейти в новый каталог. Новый кластер баз данных необходимо инициализировать.

>Перед обновлением остановите службу, если она ещё запущена:
```shell
sudo systemctl stop postgresql.service
sudo systemctl status postgresql.service
```

>Для обновления баз данных необходимы исполнительные файлы предыдущей версии PostgreSQL, они находятся в пакете **postgresql-old-upgrade**, установите его и обновите PostgreSQL:
```shell
sudo pacman -S postgresql postgresql-libs postgresql-old-upgrade
```

>Переместите старые данные и инициализируйте базу данных:
```shell
sudo mv /var/lib/postgres/data /var/lib/postgres/olddata
sudo mkdir /var/lib/postgres/data /var/lib/postgres/tmp
sudo chown postgres:postgres /var/lib/postgres/data /var/lib/postgres/tmp
cd /var/lib/postgres/tmp
sudo -u postgres initdb -D /var/lib/postgres/data
```

>Следующая команда выполнит перенос данных из старого кластера в новой, в этой команде вам нужно заменить **PG_VERSION** на версию предыдущей базы данных:
```shell
sudo -u postgres pg_upgrade -b /opt/pgsql-PG_VERSION/bin -B /usr/bin -d /var/lib/postgres/olddata -D /var/lib/postgres/data
```

>Например:
```shell
sudo -u postgres pg_upgrade -b /opt/pgsql-12/bin -B /usr/bin -d /var/lib/postgres/olddata -D /var/lib/postgres/data
```

>После этого вновь запустите службу и проверьте её статус:
```shell
sudo systemctl start postgresql.service
sudo systemctl status postgresql.service
```

## Как обновить базы данных PostgreSQL без сохранения информации  

>Итак, чтобы инициировать базу данных нового формата PostgreSQL выполните следующие команды:
```shell
sudo mv /var/lib/postgres/data /var/lib/postgres/olddata
sudo mkdir /var/lib/postgres/data /var/lib/postgres/tmp
sudo chown postgres:postgres /var/lib/postgres/data /var/lib/postgres/tmp
cd /var/lib/postgres/tmp
sudo -u postgres initdb -D /var/lib/postgres/data
```

>После этого вновь запустите службу и проверьте её статус:
```shell
sudo systemctl start postgresql.service
sudo systemctl status postgresql.service
```

[![|800](/Media/PostgreSQL_error_An_old_version/image_2.png)](https://blackarch.ru/wp-content/uploads/2020/04/postgresql.service-running.png)

Больше информации вы найдёте в официальной Вики: [https://wiki.archlinux.org/index.php/PostgreSQL#Upgrading_PostgreSQL](https://wiki.archlinux.org/index.php/PostgreSQL#Upgrading_PostgreSQL)
### Возможные ошибки и их исправление  

>1. Если во время выполнения команды
```shell
sudo mv /var/lib/postgres/data /var/lib/postgres/olddata
```

вы столкнулись с ошибкой

*mv: cannot move '/var/lib/postgres/data' to '/var/lib/postgres/olddata/data': Directory not empty*

то она означает, что вы уже обновляли базу данных с сохранением предыдущей базы данных в директорию **/var/lib/postgres/olddata/data**. Вы можете сохранить очередную базу данных в другую директорию, либо просто удалите имеющуюся:

```shell
sudo rm -rf /var/lib/postgres/olddata/data
```

>2. Если во время выполнения команды
```shell
sudo mkdir /var/lib/postgres/data /var/lib/postgres/tmp
```

вы столкнулись с ошибкой

*mkdir: cannot create directory ‘/var/lib/postgres/tmp’: File exists*

