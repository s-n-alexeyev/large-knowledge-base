Утилиты разбивки:
- cfdisk - псевдографическая утилита
- fdisk
- gdisk - для автоматической разметке в таблице GPT
- 
К примеру gdisk
gdisk /dev/sdX
Ключ на создание раздела: n (gpt)
Далее согласиться с разделами по умолчанию. Создаётся их при BTRFS 3
200M - EFI EF00
2G - swap 8200
остальное под файловую систему линукс 8300
Форматирование
Boot-раздел - mkfs.fat -F32 /dev/sda1
SWAP mkswap -L swap /dev/sda2
Включить swap swapon /dev/sda2
Создание тома и подтомов (субволумов)
mkfs.btrfs -L arch /dev/sda3 -f
mount /dev/sda3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@var
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
mount -o noatime,compress=lzo,space_cache,ssd,subvol=@ /dev/sda3 /mnt
mkdir -p /mnt/{home,boot,var,.snapshots}
mount -o noatime,compress=lzo,space_cache,ssd,subvol=@var /dev/sda3 /mnt/var
mount -o noatime,compress=lzo,space_cache,ssd,subvol=@home /dev/sda3 /mnt/home
mount -o noatime,compress=lzo,space_cache,ssd,subvol=@snapshots /dev/sda3 /mnt/.snapshots
mount /dev/sda1 /mnt/boot
Настройка зеркала
nano /etc/pacman.d/mirrorlist
Https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch
Установка базовой части системы
pacstrap /mnt base base-devel linux linux-firmware nano
Генерируем fstab
genfstab -pU /mnt >> /mnt/etc/fstab
После того, как первая часть отработала, лезем в chroot
arch-chroot /mnt
После этого ставится пароль root
passwd

Даем машине имя
nano /etc/hostname
Настраиваем временную зону
ln -sf /usr/share/zoneinfo/Asia/Vladivostok /etc/localtime
Открыть локали
nano /etc/locale.gen
Сгенерировать локали
locale-gen
Настройка языка консоли, добавление Кириллицы
nano /etc/vconsole.conf
KEYMAP=ru
FONT=cyr-sun16
Установка языка системы по умолчанию
nano /etc/locale.conf
LANG="ru_RU.UTF-8"
Запуск пакетного менеджера
pacman-key --init
Загрузка популярных ключей
pacman-key --populate archlinux
Открыть multilib-репозиторий
nano /etc/pacman.conf
(multilib-раскоментировать)

pacman -Sy
pacman -S mc bash-completion openssh arch-install-scripts networkmanager sudo git wget htop
neofetch xdg-user-dirs ntfs-3g
mkinitcpio -p linux
Настройка пользователей
nano /etc/sudoers - раскоментировать wheel после root
useradd -m -g users -G wheel (имя_пользователя)
passwd (имя пользователя)
Старт сетевого менеджера
systemctl enable NetworkManager.service
Ставим загрузчик
pacman -S grub efibootmgr grub-btrfs os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

Выход с chroot
Ctrl+D
umount -R /mnt
reboot
Получаем root
Поднимаем иксы и графику nvidia
sudo pacman -S (для виртуальной машины xf86-video-vesa, для процессора intel: xf86-video-intel)
xorg-server xorg-xinit xorg-drivers nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
KDE: plasma kde-applications sddm (выполнить дважды)
Запуск службы загрузчика, иначе графика не поднимется
systemctl enable sddm
XFCE: pacman -S xfce4 xfce4-goodies lxdm ttf-liberation ttf-dejavu network-manager-applet ppp
pulseaudio-alsa gvfs thunar-volman
systemctl enable lxdm
ВАЖНО: в конце установки надо поправить fstab
sudo nano /etc/fstab
убираем в строках слова
subvolid=***
Сохраняем, выходим.
Установка AUR-yay
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si