
- Правим Grub
```shell
sudo nano /etc/default/grub
```

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 systemd.show_status=auto splash rd.udev.log_priority=3 vt.global_cursor_default=0"

#nvidia - добавть nvidia-drm.modeset=1
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 systemd.show_status=auto splash rd.udev.log_priority=3 vt.global_cursor_default=0 nvidia-drm.modeset=1"
```

- Обновляем Grub
```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

- Правим mkinitcpio.conf
```shell
sudo nano /etc/mkinitcpio.conf
```

```ini
HOOKS=(base udev autodetect kms modconf block keyboard keymap consolefont plymouth resume filesystems)

#nvidia - добавить модули
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

- Смотрим доступные ядра
```shell
ls /etc/mkinitcpio.d/
```

- Обновляем ядро,  где `linux` - ваше ядро
```shell
sudo mkinitcpio -p linux
```




