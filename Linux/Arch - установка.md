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

>то выполняем команду
```shell
rfkill unblock wifi
```

>теперь все OK
```
ID TYPE      DEVICE      SOFT      HARD  
0 bluetooth hci0   unblocked unblocked  
1 wlan      phy0   unblocked unblocked
```

## Утилита `iwctl` для работы с WiFi
```shell
iwctl
```

В самой утилите вводим команды

>смотрим ваши WiFi сетевые карты:
```
[iwd]# device list
```
- `wlan0`

>сканируем доступные сети:
```
[iwd]# station wlan0 scan
```

>выводим список доступных сетей:
```
[iwd]# station wlan0 get-networks
```

>например получаем такое, видим там свою сеть:
```
                              Available networks
--------------------------------------------------------------------------------
  Network name                    Security          Signal
--------------------------------------------------------------------------------
  Ace                             psk               ****
  Nazok                           psk               ***
  Artem                           psk               ***
```

>соединяемся с нашей сетью:
```
[iwd]# station wlan0 connect Ace
```

>вводим пароль
```
Type the network passphrase for Ace psk.
Passphrase: ********
```

>выходим из `iwctl`
```
[iwd]# exit
```
## Проверяем работу сети
```shell
ping ya.ru -c3
```

```
PING ya.ru (5.255.255.242) 56(84) bytes of data.  
64 bytes from ya.ru (5.255.255.242): icmp_seq=1 ttl=51 time=72.5 ms  
64 bytes from ya.ru (5.255.255.242): icmp_seq=2 ttl=51 time=71.4 ms  
64 bytes from ya.ru (5.255.255.242): icmp_seq=3 ttl=51 time=71.5 ms  
  
--- ya.ru ping statistics ---  
3 packets transmitted, 3 received, 0% packet loss, time 2003ms  
rtt min/avg/max/mdev = 71.363/71.792/72.475/0.487 ms
```
# Работа с диском

## Находим наш диск

>команда для просмотра SATA дисков
```shell
lsblk --scsi
```

```
NAME HCTL       TYPE VENDOR   MODEL                          REV SERIAL               TRAN
sda  0:0:0:0    disk ATA      Apacer AS340 240GB            V4.7 J28485R004707        sata
sdb  1:0:0:0    disk ATA      Samsung SSD 840 EVO 250GB EXT0DB6Q S1DBNSAFB46994Z      sata
sdc  6:0:0:0    disk Multi    Flash Reader                  1.00 058F63666471         usb
sdd  8:0:0:0    disk Generic  Flash Disk                    8.07 FB2DD809             usb
```

>команда для просмотра NVME дисков
```shell
lsblk --nvme
```

```
NAME    TYPE MODEL                   SERIAL                    REV TRAN   RQ-SIZE  MQ  
nvme0n1 disk Viper M.2 VPN110 1024GB VPN110EBBB2208190124 42BBT9BB nvme      1023   8  
nvme1n1 disk KINGSTON SNV2S1000G     50026B77857A8C32     SBM02103 nvme       255   8
```

## Разбивка диска

В распоряжении имеются следующие утилиты для разбивки диска:
- `cfdisk`
- `fdisk`
- `gdisk` 

>Используем `fdisk`
```shell
fdisk /dev/sdX
```
- где `sdX` ваш диск

Будем создавать 4 раздела 
1. EFI
2. BOOT
3. SWAP
4. BTRSF

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

- раздел BTRFS (отдаем оставшееся место)  
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

```
Disk /dev/sdb: 238.47 GiB, 256060514304 bytes, 5001118192 sectors
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

```
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
# Форматирование разделов

>Форматирование EFI
```shell
mkfs.fat -F32 /dev/sda1
```

>Форматирование boot
```
mkfs.ext4 -L boot /dev/sda2
```

>Форматирование и включение swap
```
mkswap -L swap /dev/sda3
swapon /dev/sda3
```

>Форматирование btrfs
```
mkfs.btrfs -L arch /dev/sda4 -f
```

>Создание тома и подтомов (субволумов)
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

>Настройка зеркала (опционально)
```shell
nano /etc/pacman.d/mirrorlist
```

`Https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch`

>Установка базовой части системы
```shell
pacstrap /mnt base base-devel linux linux-firmware nano
```

>Генерируем fstab
```shell
genfstab -pU /mnt >> /mnt/etc/fstab
```

>После того, как первая часть отработала, лезем в chroot
```shell
arch-chroot /mnt
```

>После этого ставится пароль root
```shell
passwd
```

>Даем машине имя
```shell
nano /etc/hostname
```

>Настраиваем временную зону
```shell
ln -sf /usr/share/zoneinfo/Asia/Almaty /etc/localtime
```

>Открываем локали
```shell
nano /etc/locale.gen
```

>Раскоментируем 
```q
ru_RU.UTF8 UTF8
en_US.UTF8 UTF8
```
- остальные на ваше усмотрение

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

>Установка языка системы по умолчанию
```shell
nano /etc/locale.conf
```

```q
LANG="ru_RU.UTF-8"
```

>Запуск пакетного менеджера
```shell
pacman-key --init
```

>Загрузка популярных ключей
```shell
pacman-key --populate archlinux
```

>Открыть multilib-репозиторий, 
```shell
nano /etc/pacman.conf
```

>Раскоментировать
```q
[multilib]
Include = /etc/pacman.d.mirrorlist
```

> Обновляем, устанавливаем необходимое
```shell
pacman -Sy
pacman -S mc bash-completion openssh arch-install-scripts networkmanager sudo git wget curl htop neofetch xdg-user-dirs ntfs-3g
mkinitcpio -p linux
```

>Настройка пользователей
```
nano /etc/sudoers
```

>раскоментировать
```
%wheel ALL=(ALL:ALL) ALL
```

>Создаем пользователя
```shell
useradd -m -g users -G wheel <<имя_пользователя>>
```

>Задаем пароль пользователю
```shell
passwd <<имя_пользователя>>
```

>Старт сетевого менеджера
```shell
systemctl enable NetworkManager.service
```

>Ставим загрузчик
```shell
pacman -S grub efibootmgr grub-btrfs os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
```

>Выход с chroot
`Ctrl+D`
```shell
umount -R /mnt
reboot
```
Получаем root

>Поднимаем иксы и графику nvidia
```shell
sudo pacman -S (для виртуальной машины xf86-video-vesa, для процессора intel: xf86-video-intel)

sudo pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader

pacman-contrib kate xorg-server xorg-xinit xorg-drivers nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
```

>KDE: 
```shell
sudo pacman -S plasma kdeconnect konsole sddm
- plasma-nm
- dolphin
- konsole
- alsa-utils
- plasma-pa
- powerdevil
- kscreen
- kde-gtk-config
- breeze-gtk
- kwalletmanager
- gwenview
- okular
```
(выполнить дважды)

>Запуск службы загрузчика, иначе графика не поднимется
```shell
systemctl enable sddm
```

>XFCE: 
```shell
pacman -S xfce4 xfce4-goodies lxdm ttf-liberation ttf-dejavu network-manager-applet ppp pulseaudio-alsa gvfs thunar-volman
systemctl enable lxdm
```

> ВАЖНО: в конце установки надо поправить fstab
```shell
sudo nano /etc/fstab
```

>убираем в строках слова
```q
subvolid=***
```
Сохраняем, выходим.

>Установка AUR-yay
```shell
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

yay -S timeshift-autosnap
