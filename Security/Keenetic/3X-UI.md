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

>На запрос 
```
Install/update finished! For security it's recommended to modify panel settings    
Do you want to continue with the modification [y/n]?:
```
отвечаем отрицательно `n`

>Записываем сгенерированные данные
```
set username and password success  
This is a fresh installation, will generate random login info for security concerns:  
###############################################  
Username: F92M6aia  
Password: 9/fHDY37  
WebBasePath: mBDNYtiG  
###############################################  
If you forgot your login info, you can type x-ui and then type 8 to check after installation
```

