*Ошибка запуска домена: Не удалось получить доступ к файлу хранилища «/run/media/user/Data/VMs/QEMU/Windows10.qcow2» (от имени uid:958, gid:958): Отказано в доступе*

>Правим файл конфигурации
```shell
kate /etc/libvirt/qemu.conf
```

>Изменяем строки
```q
user = "ваш пользователь"
group = "libvirt"
```

>Перезапускаем службу
```shell
sudo systemctl restart libvirtd
```