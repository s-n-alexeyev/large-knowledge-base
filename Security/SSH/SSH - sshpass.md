В SSH нет простого способа передачи паролей через стандартный ввод, что затрудняет автоматизацию.  
Хотя это не идеально с точки зрения безопасности, вы можете автоматизировать аутентификацию пароля SSH в сценариях bash с помощью утилиты sshpass.  
Прежде чем мы начнем – использование автоматических паролей для SSH не зря считается плохой практикой.  
Почти во всех случаях лучше использовать SSH-ключ, что мы покажем ниже.  

[🔬 Как обменяться ключом SSH для аутентификации без пароля между серверами Linux](https://itsecforu.ru/2019/07/24/%f0%9f%94%8f-%d0%ba%d0%b0%d0%ba-%d0%be%d0%b1%d0%bc%d0%b5%d0%bd%d1%8f%d1%82%d1%8c%d1%81%d1%8f-%d0%ba%d0%bb%d1%8e%d1%87%d0%be%d0%bc-ssh-%d0%b4%d0%bb%d1%8f-%d0%b0%d1%83%d1%82%d0%b5%d0%bd%d1%82%d0%b8/)  
[🔐 Настройка входа по SSH без пароля для нескольких удаленных серверов с помощью скрипта](https://itsecforu.ru/2020/10/05/%f0%9f%94%90-%d0%bd%d0%b0%d1%81%d1%82%d1%80%d0%be%d0%b9%d0%ba%d0%b0-%d0%b2%d1%85%d0%be%d0%b4%d0%b0-%d0%bf%d0%be-ssh-%d0%b1%d0%b5%d0%b7-%d0%bf%d0%b0%d1%80%d0%be%d0%bb%d1%8f-%d0%b4%d0%bb%d1%8f-%d0%bd/)

Однако у паролей есть преимущество: их легче использовать, запоминать и распространять среди членов команды.  
Все это одновременно является недостатком для безопасности, но это тот компромисс, который вы можете выбрать.
### Использование SSHPass

Обычная команда ssh не имеет флага –password, чтобы вы могли легко автоматизировать эту процедуру.  
Вам придется установить инструмент под названием sshpass для явной обработки этого действия.  

>Вы можете загрузить его из большинства менеджеров пакетов Linux; для систем на базе Debian, таких как Ubuntu, это:  
```shell
sudo apt-get install sshpass
```

>Если вы используете sshpass внутри скрипта, вы можете передать его непосредственно с флагом -p, за которым следует ваша стандартная команда SSH:
```shell
sshpass -p 'password' ssh user@remote
```

Однако это не очень хорошая практика по нескольким причинам:

- Если он используется вне файла скрипта, показывается пароль в открытом виде в истории команд Linux и других систем. Другие пользователи Linux могут увидеть его.
- Может быть неясно, что в этом файле скрипта скрыт пароль, что может привести к тому, что неправильные разрешения файлов могут раскрыть его.
- Он может быть случайно отслежен в системе контроля версий

В связи с этим пароль следует хранить в файле.

>Обязательно установите права на него, чтобы он не был доступен другим пользователям.
```shell
echo "password" > password_file
chmod 600 password_file
```

>Затем передайте это в sshpass с параметром -f:
```shell
sshpass -f password_file ssh user@remote
```

### Настройка ключей SSH вместо этого

Ключи SSH предпочтительнее для большинства систем.  
Они гораздо длиннее, а также их труднее случайно утечь, что делает их идеальными для обеспечения безопасности.  
Они также способствуют аутентификации на основе идентификации, поскольку SSH-ключи обычно привязаны к машине, на которой они созданы.  
SSH хранит ваш открытый ключ в ~/.ssh/id_rsa.pub, который он использует для всех запросов.  

>Создать новый файл ключа очень просто:
```shell
ssh-keygen
```

Вам нужно добавить его в файл ~/.ssh/authorized_keys на сервере, к которому вы хотите подключиться.

>Существует встроенная команда SSH, которая может легко сделать это за вас:
```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub user@host
```

После этого пароль больше не будет запрашиваться.  
Вы можете скопировать этот ключ на другие машины, но обычно достаточно просто добавить несколько ключей.