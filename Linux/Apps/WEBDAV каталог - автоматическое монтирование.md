## Устанавливаем davfs2

>ARCH
```shell
sudo pacman -S davfs2
```
## Создаем файл паролей

>возможно предварительно нужно будет войти в оболочку root (`sudo su`)
```shell
sudo nano /etc/davfs2/secrets
```

>Добавляем наш пароль в конц файла

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
>нужно будет войти в оболочку root (`sudo su`)
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
>нужно будет войти в оболочку root (`sudo su`)
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
sudo systemctl enable --now run-media-user-webdav-mkdir.service
sudo systemctl enable --now run-media-user-webdav.automount
```
