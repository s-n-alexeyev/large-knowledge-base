## Bluetooh 5.0 USB dongle realtek
```shell
yay -S rtl8761usb
```

---
## Xbox one Controller
>ARCH
```shell
yay -S xpadneo-dkms
```

---
## PS4 Gamepad
>для работы с датчиками
```shell
pipx install https://github.com/TheDrHax/ds4drv-cemuhook/archive/master.zip
ds4drv --hidraw --udp
```

---
## Замена имени домашней директории и поддиректорий обратно на английский
>Откройте терминал и запустите
```shell
LANG=C xdg-user-dirs-update --force
```

Выйдите и войдите снова, чтобы применить новую конфигурацию.
Это просто настроит и создаст новые папки, но не затронет ваши старые папки и не скопирует файлы. Вы должны сами переместить файлы из старых папок в новые.

---
## Импорт ключа
публичные сервера
http://keyserver.ubuntu.com/
https://keyring.debian.org/
http://keys.gnupg.net/
https://pgp.mit.edu/

> arch, manjaro
```shell
sudo gpg --keyserver keys.gnupg.net --recv-keys <ключ>
```

> ubuntu, kali
```shell
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <ключ>
```

---
## Игнорировать обновление pacman
```shell
sudo nano/etc/pacman.conf
```

>пример
```
IgnorePkg = vlc
```

---
## При отправки картинки в Librewolf дает полосатую картинку
отключить параметр 
- [ ] Enable ResistFingerprinting

---
## Синхронизация времени
```shell
sudo ntpdate pool.ntp.org
```

---
## Установка репозиторя yandex browser

> заходим от администратора
```shell
sudo su
```

> создаем репозиторий и добавляем запись
```shell
cat<<EOF>>/etc/apt/sources.list.d/yandex-browser.list
deb [arch=amd64] http://repo.yandex.ru/yandex-browser/deb stable main
EOF
```

> добавляем ключ
```shell
wget https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG && sudo apt-key add YANDEX-BROWSER-KEY.GPG && rm YANDEX-BROWSER-KEY.GPG
```

> устанавливаем
```shell
sudo apt update && sudo apt install yandex-browser-stable
```

---
## Установка нескольких раскладок клавиатуры
### X11
```shell
sudo nano /etc/default/keyboard
```

```
#KEYBOARD CONFIGURATION FILE

#Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="us,ru"
XKBVARIANT=","
XKBOPTIONS="grp_led:scroll,grp:caps_toggle,grp:win_space_toggle,grp:alt_shift_toggle,terminate:ctrl_alt_bksp"

BACKSPACE="guess"
```
### Wayland
```shell
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space', 'Caps_Lock','XF86Keyboard']"
```

---
## Обновление системы (DEB)
```shell
sudo apt update && sudo apt full-upgrade -y &
```

---
## Замена видеокарты
Достаточно удалить в директории */etc/X11/xorg.conf.d/* конфиг отвечающий за настройку видеокарты, перегрузить, система сама подберет видеодрайвер.

---
## Пропал звук (dummy output) DEB
Kind of Excellent question. I think your linux sound is not working. First check if your audio speaker is working or not. Is your audio output fine? Then if audio output is disable then enable it. If it is enabled then keep sure to check if your device is mute by the mute key. Hmm! If you have voice that you can up and down then let's go to another alternate. Open the terminal and:

```shell
systemctl --user enable pulseaudio
systemctl --user start pulseaudio
sudo gedit .bashrc
pulseaudio -D
```

Hope so now your system reboots and the sounds works. Hmm not yet working. Oof! I got another alternate.

Sound can be fixed at the cost of microphone. It seem that there is some detection issued while booting that causes whole audio in/out devices block to be undetected.Easiest option is to add snd_hda_intel.dmic_detect=0 to /etc/default/grub.

All the options should look like:

```ini
GRUB_DEFAULT=2
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet snd_hda_intel.dmic_detect=0"
GRUB_CMDLINE_LINUX=""
```

Hope so Grub.cfg must be updated before. If you have not updated the grub then just update-grub.

Suppose this did not work either then I have just one last option. If it does not work then definetly the speaker I use has a issue.

```shell
sudo grub-update
sudo grub-install /dev/sda
``` 
#Notice: /dev/sda is the disk your "/" is mounted.
```shell
reboot
```
## Librewolf (Firefox) не запускается
Ошибка Missing chrome or resource URL: resource://gre/modules/UpdateListener.jsm
Также браузер запускается при удалении строки user_pref("media.ffmpeg.vaapi.enabled", true); из файла prefs.js из каталога профиля firefox.

---
## Разгон монитора X11 (нестрандарные частоты Nvidia)
Статья с [wiki.archlinux.org](https://wiki.archlinux.org/title/Qnix_QX2710#Fixing_X11_with_Nvidia)
По умолчанию в некоторых графических драйверах QX2710 переходит в режим отладки и переключает цвета при запуске X. Причина этого заключается в том, что у драйвера возникают проблемы с считыванием EDID с монитора.

Эта проблема с чтением EDID не возникает в Windows, поэтому прочитанный EDID можно получить с помощью [Live Windows Media](https://www.entechtaiwan.com/util/moninfo.shtm). Пример файла EDID, который был экспортирован с помощью [Monitor Asset Manager](https://www.entechtaiwan.com/util/moninfo.shtm) для Windows (7-11), пример доступен для загрузки [QX2710.bin](https://archive.org/download/qx-2710-edid/QX2710.bin)
Как альтернативу можно использовать програаму [Custom Resolution Utility (CRU)](https://www.monitortests.com/download/cru/cru-1.5.2.zip) по адресу https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU
Можно использовать в Linux в среде Wine.

Скопируйте файл сгенерируемой программой Monitor Asset Manager в Windows (имя расширение значения не имеют) и поместите в */etc/X11/edid* (при необходимости создайте каталог). Удалите все сгенерированные nvidia конфигурации xorg в */etc/X11/xorg.conf.d*

>Найдите идентификатор монитора с помощью следующей команды
```shell
nvidia-xconfig --query-gpu-info
```

>Другая возможность посмотреть активый идентификатор монитора по команде
```shell
cat /var/log/Xorg.0.log
```

[    10.129] (--) NVIDIA(GPU-0): DFP-0: disconnected
[    10.129] (--) NVIDIA(GPU-0): DFP-0: Internal TMDS
[    10.129] (--) NVIDIA(GPU-0): DFP-0: 330.0 MHz maximum pixel clock
[    10.129] (--) NVIDIA(GPU-0): 
[    10.129] (--) NVIDIA(GPU-0): DFP-1: disconnected
[    10.129] (--) NVIDIA(GPU-0): DFP-1: Internal TMDS
[    10.129] (--) NVIDIA(GPU-0): DFP-1: 165.0 MHz maximum pixel clock
[    10.129] (--) NVIDIA(GPU-0): 
[    10.130] (--) NVIDIA(GPU-0): BenQ (__DFP-2): connected__
[    10.130] (--) NVIDIA(GPU-0): BenQ (DFP-2): Internal DisplayPort
[    10.130] (--) NVIDIA(GPU-0): BenQ (DFP-2): 1440.0 MHz maximum pixel clock
[    10.130] (--) NVIDIA(GPU-0): 
[    10.132] (--) NVIDIA(GPU-0): DFP-3: disconnected
[    10.132] (--) NVIDIA(GPU-0): DFP-3: Internal TMDS
[    10.132] (--) NVIDIA(GPU-0): DFP-3: 165.0 MHz maximum pixel clock

>Создаем */etc/X11/xorg.conf.d/60-qnix-edid.conf* и добавьте к нему следующее (не забудьте изменить DFP-0 на свой идентификатор монитора). 
```shell
sudo su
touch /etc/X11/xorg.conf.d/60-qnix-edid.conf
```

```shell
cat<<EOF>>sudo /etc/X11/xorg.conf.d/60-qnix-edid.conf
Section "Device"
     Identifier     "Device0"
     Option         "CustomEDID" "DFP-2:/etc/X11/edid/имяФайла"
EndSection
EOF
```
Сохраните файл, затем перезапустите X сервер. Теперь ваш монитор должен работать.

---
## Русский шрифт в терминале вместо квадратов
Каждый раз setfont cyr-sun16
или:

После установки Manjaro рано или поздно возникает необходимость работы в терминалах tty (Ctrl-Alt-F2) вне Х.
Редактируем vconsole.conf:
```shell
sudo nano /etc/vconsole.conf
```

```ini
KEYMAP="ruwin_alt_sh-UTF-8"
LOCALE="ru_RU.UTF-8"
CONSOLEMAP=
FONT="cyr-sun16"
USECOLOR="yes"
```

---
## Отключаем действие крышки ноутбука
```shell
gedit /etc/systemd/logind.conf
```

```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

---
## Очистка кэша DNS
```shell
sudo systemctl restart nscd
```

---
## Запуск с русской локалью (квадратики)
>перед запуском программы необходимо указать переменную окружения указывающую на русскую локаль например:
```shell
env LC_ALL=ru_RU.UTF-8 man
```

---
## MONO импорт сертификата SSL
```shell
p11-kit extract --format=pem-bundle --filter=ca-anchors --comment --purpose server-auth ./tls-ca-bundle.$(date -d "today" +"%Y%m%d%H%M").pem
```

>Импорт в систему
```shell
cert-sync --user ./tls-ca-bundle.$(date -d "today" +"%Y%m%d%H%M").pem
```

>Импорт для текущего пользователя
```shell
sudo cert-sync ./tls-ca-bundle.$(date -d "today" +"%Y%m%d%H%M").pem
```

---
## Переключение версий JAVA в Arch/Manjaro

>Проверка установленных версий
```shell
archlinux-java status
```

>Переключение на другую версию
```shell
sudo archlinux-java set java-11-openjdk
```

---
## Компиляция CH340/CH341 для ядра 6.1
драйвер с github с инструкцией
https://github.com/juliagoda/CH341SER
Обновленный драйвер
https://elixir.bootlin.com/linux/v6.1.1/source/drivers/usb/serial/ch341.c

---
## Автозагрузка скрипта от root
нужно добавить пользователя в группу users (если это еще не сделано) — sudo gpasswd -a имя_пользователя users
настроить crontab — sudo crontab -e и в конце добавить запись @reboot полный_путь_до_скрипта
если после команды sudo crontab -e в терминале откроется черный экран без возможности ввода значит у вас не установлен редактор по умолчанию, чтобы установить его введите export EDITOR=/usr/bin/nano
Чтобы после перезагрузки настройки не сбивались — echo export EDITOR=«nano» >> ~/.bashrc
или просто воспользуйтесь командой sudo EDITOR=nano crontab -e

---
##  Manjaro (KDE) - Отключение открытия Меню в запуска приложений клавишей Super (Win)
```shell
kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta ""
```
или
```shell
kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta ""
qdbus org.kde.KWin /KWin reconfigure
```

---
## Монтирование ntfs разделов без запроса пароля root
```shell
sudo su
usermod -a -G plugdev <ИМЯ>
```
или
```shell
gpasswd -a <ИМЯ> plugdev
```

---
## Проблема с opencl и onettb
```shell
sudo pacman -Rc intel-oneapi-tbb
yay -S tbb2020
```

---
## Удаление проблемного пакета (DEB)
>Для удаления проблемного пакета используйте следующую команду:
```shell
sudo dpkg --remove --force-remove-reinstreq пакет
```

>Могут также помочь следующие команды
```shell
sudo dpkg -i --force-overwrite /var/cache/apt/archives/*.deb
sudo apt-get --fix-broken install
```

---
## Обновление ключей Yandex Браузера
```shell
wget https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG -O- | sudo apt-key add -
```

---
## Пропал звук в - рестарт pulseaudio.service
```shell
systemctl --user restart pulseaudio.service
```

---
## Очистка грязного бита в NTFS
При появлении ошибки *bad superblock on /dev/sdb2, missing codepage or helper program, or other error*, возможной причиной является "Грязный бит" который можно очистить командой:
```shell
sudo ntfsfix -d /dev/sdb2
```
Где sdb2 ваш раздел с NTFS

---
## Использование iPhone как USB-модема (DEB)
 в Ubuntu. Для настройки работу iPhone в качестве модема через USB, необходимо установить свежие версии libimobiledevice, ipheth (iPhone USB Ethernet Driver) и gvfs из PPA-репозитория
 ```shell
pmcenery sudo add-apt-repository ppa:pmcenery/ppa
sudo aptitude update
sudo aptitude install libimobiledevice libimobiledevice-utils ipheth-utils gvfs
```

---
## Установка python приложений в общую среду
необходимо добавить параметр *--break-system-packages*

>например:
```shell
pip install diffusers==0.23.0 --break-system-packages
```

---
## xterm - русские буквы
>В *~/.Xresources* добавить строки  
```ini
XTerm*VT100*utf8Title: true
XTerm*VT100*faceName: Mono
```

>Выставить размер шрифта (например 8)
```ini
xterm*faceSize: 8
```

>Выполнить команду
```shell
xrdb ~/.Xresources
```

-----
## Tomcat conf permission (Arch, Manjaro)
```shell
sudo chmod -R 755 /usr/share/tomcat8/conf/
```

-----
##  Монтирование раздела диска без ввода пароля
[Ссылка на wiki](https://wiki.archlinux.org/title/Polkit#Allow_mounting_a_filesystem_on_a_system_device_for_a_group)

>создаем правило
```shell
sudo nano /usr/share/polkit-1/rules.d/10-enable-mount.rules
```

>правило для всех вставить содержимое
```js
polkit.addRule(function(action) {
    if (action.id == "org.freedesktop.udisks2.filesystem-mount-system") {
        return polkit.Result.YES;
    }
});
```

>Пример с разрешением для группы есть в той же wiki, а это для отдельного пользователя
```js
polkit.addRule(function(action, subject) {
        if (action.id == 'org.freedesktop.udisks2.filesystem-mount-system' && subject.user == '%username%') {
            return polkit.Result.YES;
        }
    }
);
```

-----
## Как убрать/оставить заголовок окна (kwin)? (Garuda)
```shell
kate ~/.config/kwinrc
```

```ini
[Windows]
BorderlessMaximizedWindows=fasle
```

---
## Остуствует kdesu (DEB)
```shell
ln -s /usr/lib/x86_64-linux-gnu/libexec/kf5/kdesu /usr/bin/kdesu
```

---
## Если забыли пароль root

При загрузке GRUB жмете `E` на пункте arch/manjaro  
добавляете к опциям ядра после rw  
`systemd.unit=rescue.target`
грузитесь и получите  root с пустым паролем, можете поменять пароль если надо

---
## Снятие блокировки после неудачных попыток ввода пароля

```shell
faillock --user $USER --reset
```
