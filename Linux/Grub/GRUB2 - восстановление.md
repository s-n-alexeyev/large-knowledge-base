```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

>Войдем под root
```shell
sudo su
```
## Определение разделов
Перед тем как восстановить Grub2, нам нужно понять - на каком разделе установлена система, и на каком разделе были или должны быть файлы загрузчика. Самый простой способ это сделать - воспользоваться утилитой fdisk.

```shell
fdisk -l
```
## Монтирование файловой системы
Предположим раздел с системой sda2 файловая структура  btrfs подраздел @ (manjaro) @rootfs (kali)
>Примонтируем корневой раздел. Выполняем команду (вместо /dev/sda2 вы должны указать свой раздел):
```shell
mount -t btrfs -o subvol=@rootfs /dev/sda2 /mnt
```

>Если для загрузчика у вас выделен отдельный раздел, то нужно примонтировать еще и его (вместо /dev/sdX укажите ваш boot-раздел):
```shell
mount /dev/sdX /mnt/boot
```

>Теперь можно посмотреть содержимое директории /mnt, чтобы убедиться, что мы примонтировали верный раздел:
```shell
ls /mnt
```
## Подготовка к входу в систему
Чтобы восстановить загрузчик linux mint мы будем использовать вашу основную систему Linux, запущенную на ядре от LiveCD. Такую возможность предоставляет команда chroot. Но перед тем, как ее использовать нужно вручную подключить к вашей корневой ФС, смонтированной в /mnt все необходимые файловые системы взаимодействия с ядром — /dev, /sys, /proc:

```shell
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
```

>или другой синтакис
```shell
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
```
## Монтирование EFI-раздела

>Если у вас используется UEFI, то еще нужно примонтировать EFI-раздел в директорию /mnt/boot/efi (см. fdisk -l в котором показан EFI-раздел):
```shell
mount /dev/sda1 /mnt/boot/efi
modprobe efivarfs
```
## Выполняем chroot на /mnt

>На предыдущем шаге мы смонтировали все необходимые директории в директорию /mnt. Теперь переключимся (выполним chroot) на данную директорию. Выполняем команду:
```shell
chroot /mnt
```
## Устанавливаем GRUB

Осталось выполнить установку GRUB на диск. Мы определили раздел на котором у нас установлен GRUB на первом шаге данного руководства. В моем случае это раздел /dev/sda2, который расположен на диске /dev/sda.

Для установки GRUB используется команда grub-install, которой нужно передать в качестве параметра диск, на который будет выполняться установка

>без EFI
```shell
grub-install /dev/sda
```

>с EFI
```shell
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=kali --recheck
```

*в случае manjaro --bootloader-id=manjaro*
## Генерация файла конфигурации GRUB

Для генерации файла конфигурации GRUB используется команда update-grub. Данная команда автоматически определяет файловые системы на вашем компьютере и генерирует новый файл конфигурации. Выполняем команду:

```shell
update-grub
или
sudo grub-mkconfig -o /boot/grub/grub.cfg
```