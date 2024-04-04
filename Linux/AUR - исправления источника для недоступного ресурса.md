на примере liberica java 21
на территории РФ ресурсы bell-sw.com заблокированы, выдает ошибку 403
можно использовать VPN или изменить на другой, не заблокированный источник 

1. пытаемся установить liberica java 21
```shell
yay -S liberica-jdk-21-full-bin
```

2. получаем ошибку что файл недоступен
`curl: (22) The requested URL returned error: 403`
`ОШИБКА: Ошибка при загрузке 'https://download.bell-sw.com/java/21.0.2+14/bellsoft-jdk21.0.2+14-linux-amd64-full.tar.gz'`

3. открываем файл сборки
```bash
kate /home/user/.cache/yay/liberica-jdk-21-full-bin/PKGBUILD
```

4. находим строчку 
```ini
source_x86_64=(https://download.bell-sw.com/java/$_pkgver/bellsoft-jdk$_pkgver-linux-amd64-full.tar.gz)
```

5. заменяем на 
```ini
source_x86_64=(https://github.com/bell-sw/Liberica/releases/download/$_pkgver/bellsoft-jdk$_pkgver-linux-amd64-full.tar.gz)
```

6. собираем и устанавливаем
```bash
cd /home/user/.cache/yay/liberica-jdk-21-full-bin
makepkg -si
```

7. если по какой-то причине контрольные суммы не совпадают, то можно на свой страх и риск добавить ключ для игнорирования контрольных сумм
`--skipinteg`