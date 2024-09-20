### Устанавливаем и конфигурируем `Grub-Btrfs`

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

>Обновляем `grub.cfg` включаем сервис `grub-btrfsd.service.`
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo systemctl enable --now grub-btrfsd.service
```

### Устанавливаем остальные приложения
```bash
sudo dnf install snapper btrfs-assistant python3-dnf-plugin-snapper
```

>Настраиваем `snapper`
```bash
sudo snapper create-config /
```

>Делаем снимок системы из консоли
```bash
sudo snapper create --description "spapshot from console"
```

>Генерируем загрузчик
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```