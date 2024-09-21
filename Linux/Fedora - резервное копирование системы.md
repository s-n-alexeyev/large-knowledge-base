

### Устанавливаем приложение и зависимости
```bash
sudo dnf install snapper inotify-tools btrfs-assistant python3-dnf-plugin-snapper
```
### Snapper

>Настраиваем `snapper`, добавляем конфигурации
```bash
# система
sudo snapper -c root create-config /

# если нужно добавляем каталог пользоватеей
sudo snapper -c home create-config /home
```

>Делаем снимок системы из консоли
```bash
sudo snapper create --description "test snapshot from console"
```

>Генерируем загрузчик
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
### Grub-Btrfs

>Клонируем репозиторий
```bash
git clone https://github.com/Antynea/grub-btrfs
```

>Делаем необходимые изменения
```bash
cd grub-btrfs

sed -i \
-e '/#GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS/a \
GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="systemd.volatile=state"' \
-e '/#GRUB_BTRFS_GRUB_DIRNAME/a \
GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"' \
-e '/#GRUB_BTRFS_MKCONFIG=/a \
GRUB_BTRFS_MKCONFIG=/usr/sbin/grub2-mkconfig' \
-e '/#GRUB_BTRFS_SCRIPT_CHECK=/a \
GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check' \
config
```

>Устанавливаем
```bash
sudo make install
```
- *не забываем удалить* каталог с исходными файлами

>Обновляем `grub.cfg` включаем сервис `grub-btrfsd.service.`
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo systemctl enable --now grub-btrfsd.service
```

