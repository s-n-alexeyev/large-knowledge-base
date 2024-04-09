## Устанавливаем curlftpfs
```shell
sudo pacman -S curlftpfs
```

- чтобы корректно распознавались пробелы в именах надо ставить
```shell
yay -S curlftpfs-ng
```
## Создаем файл паролей
```shell
sudo cat<<EOF>>/root/.netrc
machine 192.168.1.1
login root
password <<YOUR PASSWORD>>
EOF
```
## Тестируем монтирование файловой системы
```shell
sudo mkdir /run/media/user/ftp
sudo curlftpfs -o allow_other 192.168.1.1 /run/media/user/ftp  
sudo ls /run/media/user/ftp
sudo fusermount -u /run/media/user/ftp
```
## Настраиваем автомонтирование

- Создаем файл с точкой монтирования для systemd:
```shell
sudo cat<<EOF>>/etc/systemd/system/run-media-user-ftp.mount
[Unit]
Description=FTP 192.168.1.1
After=network.target remote-fs.target

[Service]
ExecStartPre=/bin/mkdir -p /run/media/user/ftp

[Mount]
What=curlftpfs#192.168.1.1
Where=run/media/user/ftp
Type=fuse
Options=rw,nosuid,uid=1000,gid=1000,allow_other

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
EOF
```

- Создаем сервис для автомонтирования:
```shell
sudo cat<<EOF>>/etc/systemd/system/run-media-user-ftp.automount
[Unit]
Description=Automount 192.168.1.1

[Automount]
Where=/run/media/user/ftp
TimeoutIdleSec=10

[Install]
WantedBy=multi-user.target
EOF
```

## Включаем и проверяем автомонтирование
```shell
sudo systemctl daemon-reload
sudo systemctl enable run-media-user-ftp.mount
sudo systemctl enable run-media-user-ftp.automount
sudo systemctl start run-media-user-ftp.automount
sudo ls /run/media/user/ftp
sudo mount | grep /run/media/user/ftp
```