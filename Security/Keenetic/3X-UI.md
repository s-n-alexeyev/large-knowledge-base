2024-05-28

Заходим на свой сервер VDS по SSH

Первым делом обновляемся и устанавливаем `curl`

>Debian/Ubuntu
```shel
apt update && apt upgrade && apt install curl
```

>RHEL/CentOS
```
dnf check-update && dnf upgrade && dnf install curl
```




Устанавливаем 3X-UI с помощью скрипта
```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

