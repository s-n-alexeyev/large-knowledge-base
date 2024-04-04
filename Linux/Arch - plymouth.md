```shell
sudo nano /etc/default/grub
```

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 systemd.show_status=auto splash rd.udev.log_priority=3 vt.global_cursor_default=0"
```

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

```shell
sudo mkinitcpio -p linux
```

```shell
sudo nano /etc/mkinitcpio.conf
```

```ini
HOOKS=base udev autodetect kms modconf block keyboard keymap consolefont plymouth resume filesystems
```
