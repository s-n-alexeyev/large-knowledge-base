Настройка беспроводной сети

>Проверяем не заблокирован ли WiFi
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

 >Утилита для работы с wifi
```
iwctl
```

в самой утилите вводим команды

>смотрим ваши WiFi сетевые карты
```
device list
```
- `wlan0`

>сканируем доступные сети
```
station wlan0 scan
```

>выводим список доступных сетей

```
station wlan0 scan
```

 ```
[iwd]# device list
>wlan0
>[iwd]# station wlan0 scan
>[iwd]# station wlan0 get-networks
>Telecom-58321801
>38AB-Beeline и прочие сети ваших соседей [iwd]# station wlan0 connect Telecom-58321801 ↵ и вводим пароль ************* ↵ # Мы в сети, либо ошибка. Чаще всего из-за неверного набора пароля. [iwd]# exit 
```Проверяем соединение пингом ping 8.8.8.8




Утилиты разбивки:
- `cfdisk` - псевдографическая утилита
- `fdisk`
- `gdisk` - для автоматической разметке в таблице GPT

>К примеру `gdisk`
```shell
gdisk /dev/sdX
```
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