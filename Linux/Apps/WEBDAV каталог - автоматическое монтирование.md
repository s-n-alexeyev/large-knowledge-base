## Устанавливаем curlftpfs

>ARCH
```shell
sudo pacman -S davfs2
```




## Создаем файл паролей

>возможно предварительно нужно будет войти в оболочку root (`sudo su`)
```shell
sudo nano /etc/davfs2/secrets
```

Добавляем наш пароль в конц файла

```
/run/media/user/webdav   YOUR_LOGIN   YOUR_PASSWORD
```
## Тестируем монтирование файловой системы

>выполняем следующие команды
```shell
sudo mkdir /run/media/user/ftp
sudo curlftpfs -o allow_other 192.168.1.1 /run/media/user/ftp  
sudo ls /run/media/user/ftp
sudo fusermount -u /run/media/user/ftp
```
## Настраиваем автомонтирование

>Создаем файл с точкой монтирования для systemd:
```shell
sudo cat<<'EOF'>/etc/systemd/system/run-media-user-webdav.mount
[Unit]
Description=WebDAV sarkin.freemyip.com:8443
After=network-online.target remote-fs.target
Wants=network-online.target

[Mount]
What=https://sarkin.freemyip.com:8443/webdav/
Where=/run/media/user/webdav
Type=davfs
Options=rw,nosuid,nodev,_netdev,uid=1000,gid=1000,dir_mode=0775,file_mode=0664

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
EOF
```

>Создаем сервис для автомонтирования:
```shell
sudo cat<<'EOF'> /etc/systemd/system/run-media-user-webdav.automount
[Unit]
Description=Automount WebDAV to /run/media/user/webdav
After=run-media-user-webdav-mkdir.service
Requires=run-media-user-webdav-mkdir.service

[Automount]
Where=/run/media/user/webdav
TimeoutIdleSec=10

[Install]
WantedBy=multi-user.target
EOF
```

## Включаем и проверяем автомонтирование
```shell
sudo systemctl daemon-reload
sudo systemctl enable run-media-user-ftp.automount
sudo systemctl start run-media-user-ftp.automount
sudo ls /run/media/user/ftp
sudo mount | grep /run/media/user/ftp
```

## Решение ошибки "Error setting curl" в curlftpfs

```bash
# 1. Установите утилиту downgrade (если не установлена)
yay -S downgrade

# 2. Запустите откат curl
sudo downgrade curl

# 3. Выберите версию 8.16.0 из списка
#    - В появившемся меню найдите и выберите `curl 8.16.0-1`
#    - Подтвердите установку

# 4. Заблокируйте обновление curl
sudo nano /etc/pacman.conf
# Добавьте строку: IgnorePkg = curl

# 5. Проверьте результат
curl --version
# Должна отображаться версия 8.16.0
```