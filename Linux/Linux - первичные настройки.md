```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Утилиты
- stacer - мультитул
- anydesk - удаленный доступ
- rustdesk - альтернатива anуdesk
- hoptodesk - альтернатива anуdesk, fork rustdesk
- portproton - реализация wine от valve
- smplayer - альтернатива VLC player
- onlyoffice - офис похожий на Microsoft
- qbittorent - клиент torrent
- obsidian - заметки
- keepassxc - менеджер паролей
- inkscape - векторный редактор
- gimp - графический редактор
- krita - графический редактор, ориентированный на художников
# Месенджеры
- telegram - telegram
- skypeforlinux - skype
- whatsie - whatsapp
- Whatstron - whatsapp

---
# Браузеры

## librewolf

 about:config -- настройки
 - gfx.webrender.all = TRUE
 - webgl.disabled = FALSE
 - apz.gtk.kinetic_scroll.enabled = TRUE
 - mousewheel.default.delta_multiplier_x = 500
 - mousewheel.default.delta_multiplier_y = 500
 - mousewheel.default.delta_multiplier_z = 500
 - widget.use-xdg-desktop-portal  = 1 //было 2 (открытие файлов через Dolphin в Firefox/Librewolf)

 about:support -- просмотр поддержек
### плагины для браузера
  - canvas blocker - [блокировщик холста](https://addons.mozilla.org/en-US/firefox/addon/canvasblocker/)
  - popup blocker  - [блокировщик всплывающих окон](https://addons.mozilla.org/en-US/firefox/addon/popup-blocker/)
  - disconnect     - [борьба с поиском и историей просмотра](https://addons.mozilla.org/en-US/firefox/addon/disconnect/)
  - dark reader    - [страницы в тёмных тонах](https://addons.mozilla.org/en-US/firefox/addon/darkreader/)
  - privacy badger - [борьба с трекингом](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/)
  - save page we   - [сохраниение страницы](https://addons.mozilla.org/en-US/firefox/addon/save-page-we/)
  - touch vpn      - [VPN клиент](https://addons.mozilla.org/en-US/firefox/addon/touch-vpn/)
  - return youtube dislike - [показ дизлайков youtube](https://addons.mozilla.org/en-US/firefox/addon/return-youtube-dislikes/)
  - ambient mode disabler - [принудительный запрет Ambient Mode](https://addons.mozilla.org/en-US/firefox/addon/ambient-mode-blocker/)
  - youtube 4k downloader  - [загрузка видео](https://addons.mozilla.org/en-US/firefox/addon/youtube-4k-downloader/)
  - yet another smooth scrolling - [плавный скролинг](https://addons.mozilla.org/en-US/firefox/addon/yass-we/)
  - plasma integration - [воспроизведение в трее](https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/)
  - Control Panel for YouTube - [управление youtube](https://addons.mozilla.org/en-US/firefox/addon/control-panel-for-youtube/)
```bash
ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts
sudo ln -s /usr/lib/mozilla/native-messaging-hosts /usr/lib/librewolf/native-messaging-hosts
```
### настройка proxy для tor
  - proxy switchyomega - [переключатель proxy](https://addons.mozilla.org/en-US/firefox/addon/switchyomega/)
для TOR - SOCKS5 127.0.0.1:9050
### фильтры против рекламы
  - ublock origin - [борьба с рекламой](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
  - adguard - [и еще борьба с рекламой](https://addons.mozilla.org/en-US/firefox/addon/adguard-adblocker/)
 `https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt`

### скрипты для tampermonkey
- tampermonkey - [JS скрипты](https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/)
1. голосовой перевод от Яндекс - https://raw.githubusercontent.com/ilyhalight/voice-over-translation/master/dist/vot.user.js
2. отключение Ambient для Youtube - https://greasyfork.org/scripts/453801-disable-youtube-glow-ambilight/code/Disable%20YouTube%20GlowAmbilight.user.js
3. запрет предупреждения об отключении рекламодавки на Youtube - https://greasyfork.org/en/scripts/459541-youtube%E5%8E%BB%E5%B9%BF%E5%91%8A-youtube-ad-blocker
4. возвращение дизлайков Youtube - https://greasyfork.org/en/scripts/436115-return-youtube-dislike/code
5. установка YouTube в full HD по умолчанию - https://greasyfork.org/en/scripts/23661-youtube-hd
6. запрет возрастных ограничений Youtube - https://github.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/raw/main/dist/Simple-YouTube-Age-Restriction-Bypass.user.js
7. запрет YouTube Shorts - https://greasyfork.org/ru/scripts/437721-hide-youtube-shorts
### плагины особенные
  - kepassxc  - [компаньон для менеджера паролей - [ссылка](https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/)
  - hacktools - [инструменты хакера](https://addons.mozilla.org/en-US/firefox/addon/hacktools/)
  - user-agent switcher - [переключалка user-agent](https://addons.mozilla.org/en-US/firefox/addon/user-agent-string-switcher/)
  - noscrypt - [блокировщик JS скриптов сайта](https://addons.mozilla.org/en-US/firefox/addon/noscript/)
  - flagfox - [информация о местоположении сайта](https://addons.mozilla.org/en-US/firefox/addon/flagfox/)

-----
## thorium

>отличный форк Chromium для использования в качестве альтернативы Google Chrome
```shell
yay -R thorium-browser-bin
```

>включение плавного скролинга
```q
chrome://flags/#smooth-scrolling
```
-----
##  yandex browser

### yandex browser DEB

>заходим от администратора
```bash
sudo su
```

>создаем репозиторий и добавляем запись
```bash
cat<<EOF>>/etc/apt/sources.list.d/yandex-browser.list
deb [arch=amd64] http://repo.yandex.ru/yandex-browser/deb stable main
EOF
```

>добавляем ключ
```bash
wget https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG && sudo apt-key add YANDEX-BROWSER-KEY.GPG && rm YANDEX-BROWSER-KEY.GPG
```

>устанавливаем
```bash
sudo apt update && sudo apt install yandex-browser-stable
```
### yandex browser RPM

>создаем репозиторий и добавляем запись
```bash
sudo dnf config-manager --add-repo http://repo.yandex.ru/yandex-browser/rpm/stable/x86_64
```

>добавляем ключ
```bash
sudo rpmkeys --import https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG
```

>устанавливаем
```bash
sudo dnf install yandex-browser-stable -y
```

-----
##  librewolf

### librewolf RPM

>создаем репозиторий и добавляем запись
```bash
sudo dnf config-manager --add-repo https://rpm.librewolf.net
```

>добавляем ключ
```bash
sudo rpm --import https://keys.openpgp.org/vks/v1/by-fingerprint/034F7776EF5E0C613D2F7934D29FBD5F93C0CFC3
```

>устанавливаем
```bash
sudo dnf install --refresh librewolf
```

---
##  PortProton

>установка универсальная
```shell
wget -c "https://github.com/Castro-Fidel/PortProton_ALT/raw/main/portproton" && sh portproton
```

>ARCH
```shell
yay -S portproton
```

Ссылка на github https://github.com/Castro-Fidel/PortWINE 

---
# Украшательства
##  papirus -  самый популярный набор значков
  есть в репозитории manjaro
https://github.com/PapirusDevelopmentTeam/papirus-folders

>установка темы papirus
```shell
wget -qO- https://git.io/papirus-icon-theme-install | sh
```
## papirus - folders

> установка papirus-folders
```bash
wget -qO- https://git.io/papirus-folders-install | sh
```
### настройка
>показ текущего цвета папок Papirus-Dark
```bash
papirus-folders -l --theme Papirus-Dark
```

>замена екущего цвета папок Papirus-Dark
```bash
papirus-folders -C yellow --theme Papirus-Dark
```

>возврат на цвет по умолчанию Papirus-Dark
```bash
papirus-folders -D --theme Papirus-Dark
```

>восстановление последнего цвета из config файла
```bash
papirus-folders -Ru
```

---
## Тема для GRUB Fallout
```bash
wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh
```

---
## Тема для GRUB Dark Matter
```bash
git clone --depth 1 https://github.com/vandalsoul/darkmatter-grub2-theme.git
cd darkmatter-grub2-theme
sudo python3 install.py
```

---
## Обои на каждый день (DEB)

>XFCE, GNOME ....
```bash
sudo apt install variet
```

>KDE
```shell
sudo apt install plasma-wallpapers-addons
```

---
## Расширение Discord (Vencord)
```shell
sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
```

---
## Список трекеров для торрентов
```text
http://7ece.co.uk:6969/announce
http://bt.poletracker.org:2710/announce
http://craiovatracker.com:80/announce
http://kubanmedia.org:2710/announce
http://p4p.arenabg.com:1337/announce
http://retracker.spark-rostov.ru:80/announce
http://tr.kxmp.cf:80/announce
http://tracker.blazing.de:6969/announce
http://tracker.blazing.de:80/announce
http://tracker.glotorrents.pw:6969/announce
http://tracker4.infohash.org:6969/announce
udp://atrack.pow7.com:80/announce
udp://bt.e-burg.org:2710/announce
udp://bulkpeers.com:2710/announce
udp://craiovatracker.com:80/announce
udp://explodie.org:6969
udp://kubanmedia.org:2710/announce
udp://open.demonii.com:1337/announce
udp://open.demonii.com:6969/announce
udp://pow7.com:80/announce
udp://t2.pow7.com:80/announce
udp://tracker.bittor.pw:1337/announce
udp://tracker.dler.org:6969/announce
udp://tracker.glotorrents.pw:6969/announce
udp://tracker.openbittorrent.com:6969/announce
udp://tracker.seedceo.vn:2710/announce
udp://tracker.torrent.eu.org:451/announce
udp://tracker.vanitycore.co:6969/announce
udp://tracker3.dler.com:2710/announce
udp://tracker4.infohash.org:6969/announce
udp://tracker4.infohash.org:80/announce
```

---
