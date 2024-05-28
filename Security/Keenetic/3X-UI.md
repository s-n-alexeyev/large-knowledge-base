2024-05-28

Заходим на свой сервер VDS по SSH

Первым делом обновляемся и устанавливаем `curl`

>Debian/Ubuntu
```shell
apt update && apt upgrade && apt install curl -y
```

>RHEL/CentOS
```shell
dnf check-update && dnf upgrade && dnf install curl
```




Устанавливаем 3X-UI с помощью скрипта
```shell
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

