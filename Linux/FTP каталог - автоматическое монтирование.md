## Устанавливаем curlftpfs
```bash
sudo pacman -S curlftpfs
```
## Создаем файл паролей
```bash
sudo cat<<EOF>>/root/.netrc
machine nakakal.duckdns.org
login root
password PvBsPvBy12345!
EOF
```
## Тестируем монтирование файловой системы
```bash
mkdir /run/media/user/ftp
sudo curlftpfs -o allow_other nakakal.duckdns.org /run/media/ftp  
sudo ls /run/media/user/ftp
sudo fusermount -u /run/media/ftp
```
## Настраиваем автомонтирование

- Создаем файл с точкой монтирования для systemd:
```bash
sudo cat<<EOF>>/etc/systemd/system/run-media-ftp.mount
[Unit]
Description=FTP nakakal.duckdns.org
After=network.target remote-fs.target

[Mount]
What=curlftpfs#nakakal.duckdns.org
Where=run/media/ftp
Type=fuse
Options=rw,nosuid,uid=1000,gid=1000,allow_other

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
EOF
```
- Создаем сервис для автомонтирования:
```bash
sudo cat<<EOF>>/etc/systemd/system/run-media-ftp.automount
[Unit]
Description=Automount nanakal.duckdns.org

[Automount]
Where=/run/media/ftp
TimeoutIdleSec=10

[Install]
WantedBy=multi-user.target

EOF
```

## Включаем и проверяем автомонтирование
```bash
systemctl daemon-reload
sudo systemctl enable run-media-ftp.mount
sudo systemctl enable run-media-ftp.automount
sudo systemctl start run-media-ftp.automount
sudo ls /run/media/ftp
sudo mount | grep /run/media/ftp
```