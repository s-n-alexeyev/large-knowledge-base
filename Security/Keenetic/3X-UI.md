2024-05-28

Заходим на свой сервер VDS по SSH

Первым делом обновляемся

>Debian/Ubuntu
```shel
apt update && apt upgrade
```

>RHEL/CentOS
```
dnf check-update && dnf upgrade
```

Устанавливаем 3X-UI с помощью скрипта
```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

