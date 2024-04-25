2024-04-24
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---
# Настройка беспроводной сети
## Проверяем не заблокирован ли WiFi
```shell
rfkill
```

>Если видим что что заблокирован wlan,
```
ID TYPE      DEVICE      SOFT      HARD  
0 bluetooth hci0   unblocked unblocked  
1 wlan      phy0     blocked unblocked
```

>... то выполняем команду
```shell
rfkill unblock wifi
```

>Теперь все OK
```
ID TYPE      DEVICE      SOFT      HARD  
0 bluetooth hci0   unblocked unblocked  
1 wlan      phy0   unblocked unblocked
```

## Утилита `iwctl` для работы с WiFi
```shell
iwctl
```

В самой утилите `iwctl` вводим команды:

>Смотрим ваши WiFi сетевые карты
```
[iwd]# device list
```
- `wlan0`

>Сканируем доступные сети
```
[iwd]# station wlan0 scan
```

>Выводим список доступных сетей
```
[iwd]# station wlan0 get-networks
```

>Например получаем такое, видим там свою сеть
```
                              Available networks
--------------------------------------------------------------------------------
  Network name                    Security          Signal
--------------------------------------------------------------------------------
  Ace                             psk               ****
  Nazok                           psk               ***
  Artem                           psk               ***
```

>Соединяемся с нашей сетью
```
[iwd]# station wlan0 connect Ace
```

>Вводим пароль
```
Type the network passphrase for Ace psk.
Passphrase: ********
```

>Выходим из `iwctl`
```
[iwd]# exit
```
## Проверяем работу сети
```shell
ping archlinux.org -c3
```

```q
PING archlinux.org (95.217.163.246) 56(84) bytes of data.  
64 bytes from archlinux.org (95.217.163.246): icmp_seq=1 ttl=50 time=98.4 ms  
64 bytes from archlinux.org (95.217.163.246): icmp_seq=2 ttl=50 time=98.3 ms  
64 bytes from archlinux.org (95.217.163.246): icmp_seq=3 ttl=50 time=98.4 ms  
  
--- archlinux.org ping statistics ---  
3 packets transmitted, 3 received, 0% packet loss, time 2003ms  
rtt min/avg/max/mdev = 98.302/98.356/98.413/0.045 ms
```
# Работа с носителем

## Определяем наш диск

>Команда для просмотра SATA/USB дисков
```shell
lsblk --scsi
```

```q
NAME HCTL       TYPE VENDOR   MODEL                          REV SERIAL               TRAN
sda  0:0:0:0    disk ATA      Apacer AS340 240GB            V4.7 J28485R004707        sata
sdb  1:0:0:0    disk ATA      Samsung SSD 840 EVO 250GB EXT0DB6Q S1DBNSAFB46994Z      sata
sdc  6:0:0:0    disk Multi    Flash Reader                  1.00 058F63666471         usb
sdd  8:0:0:0    disk Generic  Flash Disk                    8.07 FB2DD809             usb
```

>Команда для просмотра NVME дисков
```shell
lsblk --nvme
```

```q
NAME    TYPE MODEL                   SERIAL                    REV TRAN   RQ-SIZE  MQ  
nvme0n1 disk Viper M.2 VPN110 1024GB VPN110EBBB2208190124 42BBT9BB nvme      1023   8  
nvme1n1 disk KINGSTON SNV2S1000G     50026B77857A8C32     SBM02103 nvme       255   8
```

>Еще вариант просмотра информации о дисках
```shell
fdisk -l
```
## План разделов GPT

| №   | Раздел | Формат | Размер    | Назначение      |
| --- | ------ | ------ | --------- | --------------- |
| 1   | efi    | FAT32  | 300MiB    | Загрузочный efi |
| 2   | boot   | EXT4   | 1 GiB     | Ядра linux      |
| 3   | swap   | SWAP   | 8 GiB     | Раздел подкачки |
| 4   | root   | BTRFS  | 229.2 GiB | Система, данные |
- при использовании btfrs, если не разделить efi и boot на разные разделы, не получится настроить grub для автоматической загрузки последнего удачного входа
## Разбивка диска
В распоряжении имеются следующие утилиты для разбивки диска:
- `cfdisk`
- `fdisk`
- `gdisk` 

>Будем использовать `fdisk`
```shell
fdisk /dev/sdX
```
- где `sdX` ваш диск, в качестве примера везде будет `sda`

Команда `g` - создание нового GPT раздела, старый раздел будет удален

Command (m for help): `g`  
`Created a new GPT disklabel (GUID: 73749F7E-1B28-874D-94AE-DED4CE70D269)`  

Команда  `n` - создание раздела

- раздел EFI (300M)  
Command (m for help): `n`  
Partition number (1-128, default 1):`↵`  
First sector (2048-500118158, default 2048):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-500118158, default 500117503): `+300M`  
`Created a new partition 1 of type 'Linux filesystem' and of size 300 MiB.`  

- раздел BOOT (1G)  
Command (m for help): `n`  
Partition number (2-128, default 2):`↵`  
First sector (616448-500118158, default 616448):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (616448-500118158, default 500117503): `+1G`  
`Created a new partition 1 of type 'Linux filesystem' and of size 1 GiB.`  

- раздел SWAP (8G) размер выбираем равным оперативной памяти  
Command (m for help): `n`  
Partition number (3-128, default 3):`↵`  
First sector (2713600-500118158, default 2713600):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2713600-500118158, default 500117503): `+8G`  
`Created a new partition 1 of type 'Linux filesystem' and of size 8 GiB.`  

- раздел ROOT (отдаем оставшееся место)  
Command (m for help): `n`  
Partition number (4-128, default 4):`↵`  
First sector (19490816-500118158, default 19490816):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (19490816-500118158, default 500117503): ):`↵`  
`Created a new partition 1 of type 'Linux filesystem' and of size 229.2 GiB.`  

Команда `t` - задать тип раздела, если не задавать то по умолчанию тип 20 `Linux filesystem`

- задаем тип EFI разделу  
Command (m for help): `t`  
Partition number (1-4, default 4): `1`  
Partition type or alias (type L to list all): `1`  
Changed type if partition 'Linux filesystem' to 'EFI filesystem'.  

- задаем тип SWAP разделу  
Command (m for help): `t`  
Partition number (1-4, default 4): `3`  
Partition type or alias (type L to list all): `19`  
Changed type if partition 'Linux filesystem' to 'Linux swap'.  

- остальные разделы не трогаем

Команда  `p` - отобразить информацию о разделах

```q
Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 5001118192 sectors
Disk model: Apacer AS340 240GB     
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 73749F7E-1B28-874D-94AE-DED4CE70D269

Device         Start       End   Sectors   Size Type
/dev/sdb1       2048    616447    614400   300M EFI System
/dev/sdb2     616448   2713599   2097152     1G Linux filesystem
/dev/sdb3    2713600  19490815  16777216     8G Linux swap
/dev/sdb4   19490816 500117503 480626688 229.2G Linux filesystem
```

Команда `w` - сохранить таблицу разделов

```q
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
## Форматируем разделы

>Форматируем efi
```shell
mkfs.fat -F32 /dev/sda1
```

>Форматируем boot
```shell
mkfs.ext4 -L boot /dev/sda2
```

>Форматируем и включаем swap
```shell
mkswap -L swap /dev/sda3
swapon /dev/sda3
```

>Форматируем root
```shell
mkfs.btrfs -L arch /dev/sda4 -f
```

>Создаем тома и подтома (subvolumes)
```shell
mount /dev/sda4 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@var
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
```

>Монтируем разделы
```shell
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@ /dev/sda4 /mnt
mkdir -p /mnt/{home,boot,var,.snapshots}
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@var /dev/sda4 /mnt/var
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@home /dev/sda4 /mnt/home
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@snapshots /dev/sda4 /mnt/.snapshots
mount /dev/sda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```
# Начальная настройка

>Настраиваем зеркала (опционально)
```shell
nano /etc/pacman.d/mirrorlist
```

`Https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch`

>Устанавливаем базовую часть системы для новых поколений ПК, самое новое ядро
```shell
pacstrap /mnt base base-devel linux linux-headers linux-firmware nano
```

>Устанавливаем базовую часть системы для ядра с длительной поддержкой (lts)
>Актуально для не очень новых ПК
```shell
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware nano
```

>Генерируем fstab
```shell
genfstab -pU /mnt >> /mnt/etc/fstab
```

>Меняем корневой каталог на /mnt
```shell
arch-chroot /mnt
```

>Задаем пароль root
```shell
passwd
```

>Даем имя ПК
```shell
nano /etc/hostname
```

>Настраиваем временную зону
```shell
ln -sf /usr/share/zoneinfo/Asia/Almaty /etc/localtime
```

>Открываем файл с локалями
```shell
nano /etc/locale.gen
```

>Раскомментируем в содержимом файла `locale.gen`
```q
ru_RU.UTF8 UTF8
en_US.UTF8 UTF8
```
- остальные локали на ваше усмотрение

>Создаем локали
```shell
locale-gen
```

>Настраиваем язык консоли, добавляем кириллицу
```shell
nano /etc/vconsole.conf
```

```q
KEYMAP=ru
FONT=cyr-sun16
```

>Устанавливаем язык системы по умолчанию
```shell
nano /etc/locale.conf
```

```q
LANG="ru_RU.UTF-8"
```

>Инициализируем пакетный менеджер
```shell
pacman-key --init
```

>Загружаем популярные ключи
```shell
pacman-key --populate archlinux
```

>Включаем multilib-репозиторий
```shell
nano /etc/pacman.conf
```

>Раскомментируем в содержимом файла `pacman.conf`
```q
[multilib]
Include = /etc/pacman.d.mirrorlist
```

> Обновляем, устанавливаем необходимое
```shell
pacman -Sy
pacman -S bash-completion openssh arch-install-scripts networkmanager sudo git wget curl htop neofetch xdg-user-dirs pacman-contrib ntfs-3g
```

>Создаем начальный загрузочный диск
```shell
mkinitcpio -p linux
```

>... в случае lts ядра
```shell
mkinitcpio -p linux-lts
```

>Разрешаем пользователю применять права root
```shell
nano /etc/sudoers
```
>Раскомментируем в содержимом файла `sudoers`
```q
%wheel ALL=(ALL:ALL) ALL
```

>Создаем пользователя
```shell
useradd -m -g users -G wheel <<имя_пользователя>>
```
- где `<<имя_пользователя>>` непосредственно заданное имя, например `user`

>Задаем пароль пользователю
```shell
passwd <<имя_пользователя>>
```

>Добавляем в загрузку сетевой менеджер
```shell
systemctl enable NetworkManager.service
```

>Ставим загрузчик Grub
```shell
pacman -S grub efibootmgr grub-btrfs os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
```

>Выходим с chroot
```q
Ctrl+D
```

>Рекурсивно размонтируем `/mnt`, перегружаемся в уже установленную систему
```shell
umount -R /mnt
reboot
```
# Установка графических драйверов

>xorg сервер нужен для всех графических адаптеров (если есть проблемы с wayland)
```shell
sudo pacman -S xorg-server xorg-xinit xorg-drivers
```

>Графические драйвера Intel
```shell
sudo pacman -S xf86-video-intel

#для виртуальной машины c процессором intel
sudo pacman -S xf86-video-vesa
```

>AMD
```shell
sudo pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

>NVIDIA
```shell
sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
```
# Среды рабочего стола

## KDE
```shell
sudo pacman -S sddm plasma kdeconnect konsole plasma-nm dolphin konsole kate plasma-pa powerdevil kwalletmanager gwenview okular

#Запуск службы загрузчика sddm
sudo systemctl enable sddm
```
## XFCE
```shell
sudo pacman -S lxdm xfce4 xfce4-goodies ttf-liberation ttf-dejavu network-manager-applet ppp pulseaudio-alsa gvfs thunar-volman

#Запуск службы загрузчика lxdm
sudo systemctl enable lxdm
```

> ВАЖНО: в конце установки надо поправить fstab (может быть неактуально уже)
```shell
sudo nano /etc/fstab
```

>Убираем в файле `fstab` такие строки
```q
subvolid=***
```
# Дополнительные настройки/установки

>Пакетный менеджер `yay` для пользовательского репозитория AUR
```shell
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

>Pamac - графическая оболочка для Pacman, AUR, Flatpak и Snap от разработчиков Manjaro
```shell
yay -S pamac-all
```

>Timeshift - система резервного копирования
```shell
sudo pacman -S timeshift
```

>Скрипт автоматического резервного копирования при обновлениях
```shell
yay -S timeshift-autosnap
```
 
 >Onlyoffice - офис внешне похожий на Microsoft Office
```shell
yay -S onlyoffice-bin
```

>Проверка орфографии
```shell
sudo pacman -S aspell aspell-en aspell-ru
```

>Шрифты от Microsoft
```shell
yay -S ttf-ms-fonts
```

>Основной шрифт с дополнительными значками 
```shell
yay -S ttf-hack-nerd
```

>Stacer - мультиинструмент, очистка диска
```shell
yay -S stacer-bin
```

>Portproton - wine от Valve
```shell
yay -S portproton
```