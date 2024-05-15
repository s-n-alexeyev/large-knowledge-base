2023-02-22

[Оригинальная статья](https://habr.com/ru/articles/718632/)

Термин Microsoft Active Directory Domain Services включает в себя множество технологий, поэтому сразу уточню, в этой статье речь пойдет про использование контроллера домена только для аутентификации пользователей. То есть в финале, нужна возможность любому сотруднику предприятия сесть за любую рабочую станцию Linux, используя свой доменный логин и пароль.

Начиная с Windows 2000 Server для аутентификации пользователей домена используется протокол Kerberos, разработанный еще в 80-х годах прошлого столетия, алгоритм работы которого, ИМХО, являет собой пример отличного инженерного [хака, в хорошем (изначальном:) смысле этого слова](https://royallib.com/book/levi_stiven/hakeri_geroi_kompyuternoy_revolyutsii.html). В конце статьи есть ссылка на описание его работы, а сейчас надо сказать, что имеется несколько реализаций этого протокола и решение из этой статьи не привязано только к Microsoft Active Directory

Итак, на предприятии уже развернут контроллер домена, вероятнее всего - Microsoft Active Directory и перед нами - рабочая станция Linux (примеры будут для Debian, но работать будет и в других дистрибутивах и, даже, в моей любимой FreeBSD:). Как ввести ее в домен?

>Да очень просто:
```shell
sudo apt install krb5-user -y
```

>В Debian даже не понадобится редактировать, но убедитесь, и, при необходимости укажите эти строки в файле конфигурации Kerberos клиента (достаточно только их)
```shell
sudo nano /etc/krb5.conf
```

```q
[libdefaults]
        default_realm = CORP.RU
```

Вместо CORP.RU должно быть имя домена (Kerberos сферы) Вашего предприятия

>И все, можно “входить” в домен:
```shell
kinit ivanovii
```

```q
Password for ivanovii@CORP.RU:
```

```shell
klist
```

```q
Ticket cache: FILE:/tmp/krb5cc_1000
Default principal: ivanovii@CORP.RU
Valid starting       Expires              Service principal
02/22/2023 00:09:13  02/22/2023 10:09:13  krbtgt/CORP.RU@CORP.RU
renew until 02/23/2023 00:09:09
```

ivanovii - зарегистрированный в домене логин пользователя, замените его на тот, который есть у Вас, можно, даже, использовать Administrator. В результате работы команды kinit была осуществлена аутентификация пользователя и получен Ticket-Granting Ticket (TGT) “билет на выдачу билетов”, позволяющий, в дальнейшем, получить билеты на доступ к зарегистрированным в домене сервисам, реализуя таким образом технологию единого входа - single sign-on (SSO).

В оснастке “Active Directory Users and Computers” никакой рабочей станции Linux не появилось, как же так? Контроллер домена по прежнему ничего не знает о нашей рабочей станции, фактически, наоборот, это наша рабочая станция, благодаря параметру default_realm = CORP.RU и соответствующим SRV записям в DNS

```shell
nslookup -q=SRV _kerberos._udp.corp.ru
```

```
...
kdc.corp.ru    internet address = A.B.C.D
```

знает местоположение контроллера домена, и этого достаточно для работы с его Kerberos подсистемой. Для чего может понадобиться регистрация Linux системы в Active Directory и как это сделать - тема отдельной статьи, а сейчас вернемся к нашей задаче - вход доменной учетной записью в Linux систему

За процесс аутентификации пользователей при входе в Linux отвечает библиотека PAM (Pluggable Authentication Modules) использование которой я упоминал в [этой статье](https://habr.com/ru/post/713582). В нашем случае добавим в систему модуль, использующий Kerberos аутентификацию:

```shell
sudo apt install libpam-krb5 -y
```

>В Debian новый модуль добавится в конфигурацию PAM автоматически, сперва логин/пароль будут проверяться в Kerberos, и, в случае неудачи, в локальной базе пользователей:
```
student@debian:~$ less /etc/pam.d/common-auth
```

```
...
auth    [success=2 default=ignore]      pam_krb5.so minimum_uid=1000
auth    [success=1 default=ignore]      pam_unix.so nullok try_first_pas
...
```

>попытка войти в систему доменным пользователем закончится неудачно:
```
student@debian:~$ sudo login
debian login: ivanovii
Password:
Authentication failure
```

>в журнале видна причина:
```shell
sudo tail /var/log/auth.log
```

```
...
Feb 22 01:18:43 debian login[1587]: pam_krb5(login:auth): user ivanovii authenticated as ivanovii@CORP.RU
Feb 22 01:18:43 debian login[1587]: pam_unix(login:account): could not identify user (from getpwnam(ivanovii))
...
```

>аутентификация прошла успешно, но дальше, система ничего не знает о нашем пользователе (ни UID, ни GID ни прочих атрибутов)
```shell
id ivanovii
```

```
id: ‘ivanovii’: no such user
```

Если начать искать традиционное решение этой задачи, то, скорее всего, Вы узнаете о библиотеке Name Service Switch (NSS) и модулях LDAP, WinBIND или SSSD для нее. Но что если … просто создать учетную запись после успешной аутентификации?

>Оказывается, библиотеку PAM можно расширять своими собственными скриптами, используя модуль pam_script. Давайте добавим его в систему:
```shell
sudo apt install libpam-script -y
```

>Здесь авторы пакета для Debian не угадали наш замысел, расположив модули в таком порядке:
```shell
less /etc/pam.d/common-auth
```

```
...
auth    [success=3 default=ignore]      pam_krb5.so minimum_uid=1000
auth    sufficient                      pam_script.so
auth    [success=1 default=ignore]      pam_unix.so nullok try_first_pass
...
```

>Если честно, то такая конфигурация не только не подходит для нашей задачи, но и очень не хороша с точки зрения безопасности, легко довести ее до ситуации, когда будет достаточно знать логин локального пользователя, например root, для подключения к системе, пароль подойдет любой (вот за это любил FreeBSD, она за нас никогда ничего не делает:) Поэтому, поправьте конфигурацию расположив модули так:
```shell
sudo nano /etc/pam.d/common-auth
```

```q
auth    [success=2 default=ignore]      pam_krb5.so minimum_uid=1000
auth    [success=2 default=ignore]      pam_unix.so nullok_secure try_first_pass
auth    requisite                       pam_deny.so
auth    sufficient                      pam_script.so
auth    required                        pam_permit.so
```

В этом случае, после успешной аутентификации учтённой записи в Kerberos, выполнение “перепрыгнет” два следующих шага и запустит модуль pam_script. Остается только написать скрипт, который проверит наличие учетной записи, и, в случае ее отсутствия в системе - создаст:

```shell
sudo nano /usr/share/libpam-script/pam_script_auth
```

```
#!/bin/bash

id "$PAM_USER" &>/dev/null || useradd -m -s /bin/bash "$PAM_USER"
```

```shell
sudo chmod +x /usr/share/libpam-script/pam_script_auth
```

Проверяем:
```
student@debian:~$ sudo login
debian login: ivanovii
Password:
...
ivanovii@debian:~$ id
uid=1001(ivanovii) gid=1001(ivanovii) groups=1001(ivanovii)

ivanovii@debian:~$ klist
Ticket cache: FILE:/tmp/krb5cc_1001_0zzvqR
Default principal: ivanovii@CORP.RU
Valid starting       Expires              Service principal
02/22/2023 04:14:30  02/22/2023 14:14:30  krbtgt/CORP.RU@CORP.RU
renew until 02/23/2023 04:14:30
```

Ну вот и все, мы в системе, и TGT у нас в кармане:)  
Очевидным недостатком данного решения является то, что после удаления учётной записи пользователя из домена, она останется на всех рабочих станциях, за которыми он работал. Но, поскольку воспользоваться этими учтёнными записями будет невозможно (в локальной базе пользователей они заблокированы), можно пока оставить все как есть.