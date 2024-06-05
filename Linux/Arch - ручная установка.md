2024-04-24

[Автор](https://github.com/s-n-alexeyev/)

![|400](/Media/Arch/image_1.png)

```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---
# Подготовка к установке
Скачиваем образ дистрибутива [Arch Linux](https://archlinux.org/download/)

Утилиты для записи образа на флеш-накопитель:
- Linux - [balenaEtcher](https://etcher.balena.io/)  
- Windows - [Rufus](https://rufus.ie/ru/)  
- Кроссплатформенный [Ventoy](https://ventoy.net/en/download.html) (рекомендовано)

Руководство на Habr как записать образ на флеш-накопитель с помощью [Ventoy](https://habr.com/ru/companies/ruvds/articles/584670/)  
Видео на YouTube по использованию [Ventoy](https://www.youtube.com/watch?v=UJ1D_MByDu0)

Если вы пользуетесь проводным соединением, то пропускаем настройку беспроводной сети и переходим к [[# Проверяем работу сети]]
# Настройка беспроводной сети
## Проверяем не заблокирован ли WiFi
```bash
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
# Проверяем работу сети
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
- *Если видите подобное, двигаемся дальше, в противном случае решаем проблему доступа к Internet*
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
- *в качестве примера будем использовать диск `sda`*
## План разделов GPT для UEFI на SSD 240 GB

![|500](/Media/Arch/image_2.png)

| Раздел | Название | Формат |   Размер | Назначение      |
| -----: | -------- | ------ | -------: | --------------- |
|   sda1 | efi      | FAT32  |  300 MiB | Загрузочный efi |
|   sda2 | boot     | EXT4   |    1 GiB | Ядра linux      |
|   sda3 | swap     | SWAP   |    8 GiB | Раздел подкачки |
|   sda4 | root     | BTRFS  | ~230 GiB | Система, данные |
- *при использовании `btfrs`, если не разделить `efi` и `boot` на разные разделы, не получится настроить `grub` для автоматической загрузки последнего удачного входа, будет загружаться всегда пункт меню по умолчанию*  
- *а именно не будут работать эти параметры в файле `/etc/default/grub`:*
*`GRUB_DEFAULT=saved`*
*`GRUB_SAVEDEFAULT=true`*
## План разделов GPT для BIOS на SSD 240 GB

![|500](/Media/Arch/image_3.png)

| Раздел | Название | Формат |   Размер | Назначение       |
| -----: | -------- | ------ | -------: | ---------------- |
|   sda1 | bios     | BIOS   |    1 MiB | Загрузочный bios |
|   sda2 | boot     | EXT4   |    1 GiB | Ядра linux       |
|   sda3 | swap     | SWAP   |    8 GiB | Раздел подкачки  |
|   sda4 | root     | BTRFS  | ~230 GiB | Система, данные  |
- *если на компьютере нет поддержки efi или по какой-то причине вам нужна legacy загрузка* 
## Подготовка диска
В распоряжении имеются следующие утилиты для разбивки диска:
- `cfdisk`
- `fdisk`
- `gdisk` 

>Будем использовать `fdisk`
```shell
fdisk /dev/sdX
```
- *где `sdX` ваш диск, в качестве примера везде будет `sda`*
### Разбивка для UEFI

**Команда `g` - создание нового GPT раздела, старый раздел будет удален**

Command (m for help): `g`  

`Created a new GPT disklabel (GUID: 73749F7E-1B28-874D-94AE-DED4CE70D269)`

**Команда  `n` - создание раздела**

- *раздел EFI (300M)*  
Command (m for help): `n`  
Partition number (1-128, default 1):`↵`  
First sector (2048-500118158, default 2048):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-500118158, default 500117503): `+300M`  
`Created a new partition 1 of type 'Linux filesystem' and of size 300 MiB. `

- *раздел BOOT (1G)*  
Command (m for help): `n`  
Partition number (2-128, default 2):`↵`  
First sector (616448-500118158, default 616448):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (616448-500118158, default 500117503): `+1G`  
`Created a new partition 1 of type 'Linux filesystem' and of size 1 GiB.`

- *раздел SWAP (8G) размер выбираем равным оперативной памяти*  
Command (m for help): `n`  
Partition number (3-128, default 3):`↵`  
First sector (2713600-500118158, default 2713600):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2713600-500118158, default 500117503): `+8G`  
`Created a new partition 1 of type 'Linux filesystem' and of size 8 GiB.`

- *раздел ROOT (отдаем оставшееся место)*  
Command (m for help): `n`  
Partition number (4-128, default 4):`↵`  
First sector (19490816-500118158, default 19490816):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (19490816-500118158, default 500117503): ):`↵`  
`Created a new partition 1 of type 'Linux filesystem' and of size 229.2 GiB.`

**Команда `t` - задать тип раздела, если не задавать то по умолчанию тип 20 `Linux filesystem`**

- *задаем тип EFI разделу*  
Command (m for help): `t`  
Partition number (1-4, default 4): `1`  
Partition type or alias (type L to list all): `1`  
`Changed type if partition 'Linux filesystem' to 'EFI filesystem'.`

- *задаем тип SWAP разделу*  
Command (m for help): `t`  
Partition number (1-4, default 4): `3`  
Partition type or alias (type L to list all): `19`  
`Changed type if partition 'Linux filesystem' to 'Linux swap'.`

- *остальные разделы не трогаем*

**Команда  `p` - отобразить информацию о разделах**  
```q
Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 5001118192 sectors
Disk model: Apacer AS340 240GB     
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 73749F7E-1B28-874D-94AE-DED4CE70D269

Device         Start       End   Sectors   Size Type
/dev/sda1       2048    616447    614400   300M EFI System
/dev/sda2     616448   2713599   2097152     1G Linux filesystem
/dev/sda3    2713600  19490815  16777216     8G Linux swap
/dev/sda4   19490816 500117503 480626688 229.2G Linux filesystem
```

**Команда `w` - сохранить таблицу разделов**  
```q
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
### Разбивка для BIOS

- *раздел BIOS (1M)*  
Command (m for help): `n`  
Partition number (1-128, default 1):`↵`  
First sector (2048-500118158, default 2048):`↵`  
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-500118158, default 500117503): `+1M`  
`Created a new partition 1 of type 'Linux filesystem' and of size 1 MiB.`


- *задаем тип BIOS разделу*  
Command (m for help): `t`  
Partition number (1-4, default 4): `1`  
Partition type or alias (type L to list all): `4`  
`Changed type if partition 'Linux filesystem' to 'BIOS boot'.`

- *Первый раздел создается под BIOS вместо EFI, остальные разделы создаются подобно EFI разбивке*
### Форматируем разделы

>Форматируем efi
```shell
mkfs.fat -F32 /dev/sda1
```
- *в случае использования раздела `bios` форматировать `sda1` не нужно*

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
# Монтируем разделы

>Создаем тома и подтома (subvolumes)
```shell
mount /dev/sda4 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@var
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
```

>Монтируем разделы для BIOS и EFI
```shell
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@ /dev/sda4 /mnt
mkdir -p /mnt/{home,boot,var,.snapshots}
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@var /dev/sda4 /mnt/var
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@home /dev/sda4 /mnt/home
mount -o noatime,compress=lzo,space_cache=v2,ssd,subvol=@snapshots /dev/sda4 /mnt/.snapshots
mount /dev/sda2 /mnt/boot
```
- *для загрузки BIOS этого достаточно*

>Для EFI загрузки добавляем следующее
```shell
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```
# Начальная настройка

>Устанавливаем базовую часть системы для новых поколений ПК, самое новое ядро
```shell
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode amd-ucode nano
```

>Устанавливаем базовую часть системы для ядра с длительной поддержкой (lts)  
>Актуально для не очень новых ПК
```shell
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware intel-ucode amd-ucode nano
```

>Генерируем fstab
```shell
genfstab -pU /mnt >> /mnt/etc/fstab
```

>Меняем корневой каталог на `/mnt`
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
- *остальные локали на ваше усмотрение*

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

>Инициализируем пакетный менеджер pacman
```shell
pacman-key --init
```

>Загружаем ключи
```shell
pacman-key --populate archlinux
```

>Настраиваем pacman
```shell
nano /etc/pacman.conf
```

>Раскомментируем в содержимом файла `pacman.conf`
```q
[multilib]
Include = /etc/pacman.d.mirrorlist
```

>Опционально можно включить следующие опции в секции `# Misc options`:  
>`color` - цветная подсветка pacman;  
>`ParallelDownloads` - количество параллельных загрузок, рекомендация не ниже 5;  
>`ILoveCandy` - можно добавить забавный прогрессбар загрузки пакетов в стиле игры Pacman 😀  
```q
Color
ParallelDownloads = 10
ILoveCandy
```

>Обновляем, устанавливаем необходимое
```shell
pacman -Sy
pacman -S bash-completion openssh arch-install-scripts networkmanager git wget htop neofetch xdg-user-dirs pacman-contrib ntfs-3g
```
- *чтобы заработал `bash-completion` при использовании `TAB`, необходимо выйти из `chroot` (`Ctrl+D`) и войти снова `arch-chroot /mnt`*

>Создаем начальный загрузочный диск
```shell
mkinitcpio -p linux
```

>... в случае lts ядра
```shell
mkinitcpio -p linux-lts
```

> ... для всех ядер (`P` - заглавная)
```shell
mkinitcpio -P
```

>Разрешаем пользователю применять права `root`
```shell
nano /etc/sudoers
```

>Раскомментируем в содержимом файла `sudoers`
```q
%wheel ALL=(ALL:ALL) ALL
```

>Создаем пользователя
```shell
useradd -mg users -G wheel <<имя_пользователя>>
```
- *где `<<имя_пользователя>>` непосредственно заданное имя, например `user`*

>Задаем пароль пользователю (рекомендуется отличный от пароля root)
```shell
passwd <<имя_пользователя>>
```

>Добавляем в загрузку сетевой менеджер
```shell
systemctl enable NetworkManager.service
```

>Ставим загрузчик Grub для EFI
```shell
pacman -S grub efibootmgr grub-btrfs os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
```

>Ставим загрузчик Grub для BIOS
```shell
pacman -S grub grub-btrfs os-prober
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```
# Установка графических драйверов

>Графические драйвера Intel
```shell
pacman -S xf86-video-intel

#для виртуальной машины c процессором intel
pacman -S xf86-video-vesa
```

>AMD
```shell
pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

>NVIDIA
```shell
pacman -S nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
```
# Установка среды рабочего стола

## KDE
```shell
pacman -S sddm dolphin kdeconnect konsole konsole kwalletmanager kate plasma plasma-nm plasma-pa powerdevil gwenview okular
```
- *соглашаемся на установку всех дополнительных пакетов*

>Запуск службы загрузчика `sddm`
```
systemctl enable sddm
```
## XFCE
```shell
pacman -S lxdm xfce4 xfce4-goodies ttf-liberation ttf-dejavu network-manager-applet ppp pulseaudio-alsa gvfs thunar-volman
```

>Запуск службы загрузчика `lxdm`
```
systemctl enable lxdm
```
## GNOME
```shell
pacman -S gdm gnome gnome-extra network-manager-applet 
```

>Запуск службы загрузчика `gdm`
```shell
systemctl enable gdm
```
# Финиш

>Выходим с chroot `Ctrl+D`
```shell
#или по старинке
exit
```

>Рекурсивно размонтируем `/mnt`
```shell
umount -R /mnt
```

>Все настройки готовы, можно перегружаться
```shell
reboot
```
# Дополнительно

## Очень полезные дополнения

>Пакетный менеджер `yay` для пользовательского репозитория AUR и ARCH
```shell
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

>Timeshift - система резервного копирования
```shell
sudo pacman -S timeshift
```

>Скрипт автоматического резервного копирования при обновлениях
```shell
yay -S timeshift-autosnap
```

>Автоматическая очистка кэша пакетов
```shell
sudo pacman -S pacman-contrib
sudo systemctl enable paccache.timer
```
## Зеркала
[Статья на wiki](https://wiki.archlinux.org/title/Mirrors_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
Если возникают проблемы с доступом к репозиториям или/и хотим оптимизировать скорость доступа, то есть решение:

>Делаем резервную копию `/etc/pacman.d/mirrorlist`, находим самые быстрые зеркала и сохраняем первые 6
```shell
sudo pacman -S pacman-contrib
sudo su

# при повторном ранжировании зеркал резевную копию делать не нужно, просто переходим к следующей команде
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# команда может быть долгой, может показаться что терминал завис, просто ждите окончания
sudo rankmirrors -n 6 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist
exit
```
## Еще из полезного

>Firefox - известный браузер
```shell
sudo pacman -S firefox
```

>Pamac - графическая оболочка для Pacman, AUR, Flatpak и Snap от разработчиков Manjaro
```shell
yay -S pamac-all
```

 >Onlyoffice - офис внешне похожий на Microsoft Office
```shell
yay -S onlyoffice-bin
```

>Проверка орфографии (английская и русская)
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

Шрифт для отображения иероглифического письма
```shell
sudo pacman -S noto-fonts-cjk
```

>Stacer - мультиинструмент, очистка диска
```shell
yay -S stacer-bin
```

>Portproton - wine от Valve
```shell
yay -S portproton
```

