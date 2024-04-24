```table-of-contents
title: 
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

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
# Разбивка диска

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

## Утилиты разбивки:
- `cfdisk` - псевдографическая утилита
- `fdisk`
- `gdisk` - для автоматической разметке в таблице GPT

>К примеру `fdisk`
```shell
fdisk /dev/sdX
```

`g` - создание нового GPT раздела, старый раздел будет удален



Ключ на создание раздела: `n` (gpt)
Далее согласиться с разделами по умолчанию. Создаётся их при BTRFS 3
200M - EFI EF00
2G - swap 8200
остальное под файловую систему linux 8300






>Форматирование
```shell
#boot
mkfs.fat -F32 /dev/sda1
#swap
mkswap -L swap /dev/sda2
#btrfs
mkfs.btrfs -L arch /dev/sda3 -f
```

>Включить swap 
```shell
swapon /dev/sda2
```

>Создание тома и подтомов (субволумов)
```shell
mount /dev/sda3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@var
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
```

>Монтируем разделы
```shell
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@ /dev/sda3 /mnt
mkdir -p /mnt/{home,boot,var,.snapshots}
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@var /dev/sda3 /mnt/var
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@home /dev/sda3 /mnt/home
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@snapshots /dev/sda3 /mnt/.snapshots
mount /dev/sda1 /mnt/boot
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

>Открыть локали
```shell
nano /etc/locale.gen
```

>Создать локали
```shell
locale-gen
```

>Настройка языка консоли, добавление Кириллицы
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

>Открыть multilib-репозиторий
```shell
nano /etc/pacman.conf
```
`multilib раскоментировать`

> Обновляем, устанавливаем необходимое
```shell
pacman -Sy
pacman -S mc bash-completion openssh arch-install-scripts networkmanager sudo git wget htop neofetch xdg-user-dirs ntfs-3g
mkinitcpio -p linux
```

>Настройка пользователей
```
nano /etc/sudoers
```
`раскоментировать wheel после root`

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

xorg-server xorg-xinit xorg-drivers nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
```

>KDE: 
```shell
sudo pacman -S plasma kde-applications sddm
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