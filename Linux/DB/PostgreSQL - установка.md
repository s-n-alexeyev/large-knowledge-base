В этом руководстве мы покажем вам, как установить PostgreSQL на Manjaro 20. Для тех из вас, кто не знал, PostgreSQL — это система управления реляционными базами данных, которая обеспечивает реализацию языка запросов SQL. Он соответствует стандартам и имеет множество дополнительных функций, таких как надежные транзакции и параллелизм без блокировок чтения.

В этой статье предполагается, что у вас есть хотя бы базовые знания Linux, вы знаете, как использовать оболочку, и, что наиболее важно, вы размещаете свой сайт на собственном VPS. Установка довольно проста и предполагает, что вы работаете с учетной записью root, в противном случае вам может потребоваться добавить ‘ `sudo`‘ к командам для получения привилегий root. Я покажу вам пошаговую установку PostgreSQL на Manjaro 20 ( Nibia ).

## Установка PostgreSQL на Manjaro

## Шаг 1. Перед тем, как запустить руководство, приведенное ниже, убедитесь, что наша система обновлена:

```shell
sudo pacman -Syu
sudo pacman -S git
```
## Шаг 2. Установка PostgreSQL на Manjaro

Теперь мы запускаем следующую команду, чтобы установить PostgreSQL:

```shell
sudo pacman -S postgresql postgis
```

После завершения установки продолжите выполнение следующей команды:

```shell
sudo su postgres -l # or sudo -u postgres -i
initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data/'
exit
```

По умолчанию служба PostgreSQL запускается автоматически после установки. Вы можете подтвердить, что он запущен, с помощью команды:

```shell
sudo systemctl status postgresql
```

Вы можете проверить версию PostgreSQL с помощью:

```shell
psql --version
```

## Шаг 3. Доступ к командной строке PostgreSQL.

После установки сервера базы данных PostgreSQL по умолчанию он создает пользователя `postgres`с ролью `postgres`. Он также создает системную учетную запись с тем же именем ‘ `postgres`‘. Итак, чтобы подключиться к серверу Postgres, войдите в свою систему как пользователь Postgres и подключите базу данных:

```shell
su - postgres
psql
```

Создайте нового пользователя и базу данных:

### For example, let us create a new user called “meilana” with password “maria”, and database called “meilanadb”. ###
```shell
sudo -u postgres createuser -D -A -P meilana
sudo -u postgres createdb -O maria meilanadb
```