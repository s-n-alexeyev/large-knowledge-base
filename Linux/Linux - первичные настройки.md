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
## [Ссылка на добавление поисковых систем](https://mycroftproject.com)
## Librewolf

### Librewolf ARCH

```bash
yay -S librewolf-bin
```
### Librewolf RPM

>создаем репозиторий и добавляем запись
```bash
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
```

>устанавливаем
```bash
sudo dnf install --refresh librewolf
```
#### Тонкие настройки
 
 about:config -- вход с настройки браузера  
 - gfx.webrender.all = TRUE
 - webgl.disabled = FALSE
 - apz.gtk.kinetic_scroll.enabled = TRUE
 - mousewheel.default.delta_multiplier_x = 500
 - mousewheel.default.delta_multiplier_y = 500
 - mousewheel.default.delta_multiplier_z = 500

 about:support -- просмотр поддержек
#### Плагины для браузера

| Название                     | Перевод/ссылка                                                                                                       |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Plasma Integration           | [воспроизведение в трее](https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/)                         |
| Dark Reader                  | [страницы в тёмных тонах](https://addons.mozilla.org/en-US/firefox/addon/darkreader/)                                |
| Control Panel for YouTube    | [управление youtube](https://addons.mozilla.org/en-US/firefox/addon/control-panel-for-youtube/)                      |
| SponsorBlock                 | [пропуск рекламы внутри видео youtube](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)                 |
| Yet Another Smooth Scrolling | [плавный скролинг страниц](https://addons.mozilla.org/en-US/firefox/addon/yass-we/)                                  |
| Censor Tracker               | [антиблокиратор сайтов РФ](https://addons.mozilla.org/ru-RU/firefox/addon/censor-tracker/)                           |
| Save Page We                 | [сохраниение страницы](https://addons.mozilla.org/en-US/firefox/addon/save-page-we/)                                 |
| Kepassxc                     | [компаньон для менеджера паролей](https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/)                 |
| Touch VPN                    | [VPN клиент](https://addons.mozilla.org/en-US/firefox/addon/touch-vpn/)                                              |
| User-agent Switcher          | [переключалка user-agent](https://addons.mozilla.org/en-US/firefox/addon/user-agent-string-switcher/)                |
| Privacy Badger               | [борьба с трекингом](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/)                               |
| Noscrypt                     | [блокировщик JS скриптов сайта](https://addons.mozilla.org/en-US/firefox/addon/noscript/)                            |
| Flagfox                      | [информация о местоположении сайта](https://addons.mozilla.org/en-US/firefox/addon/flagfox/)                         |
| Disconnect                   | [борьба с поиском и историей просмотра](https://addons.mozilla.org/en-US/firefox/addon/disconnect/)                  |
| Popup Blocker                | [блокировщик всплывающих окон](https://addons.mozilla.org/en-US/firefox/addon/popup-blocker/)                        |
| Canvas Blocker               | [блокировщик холста](https://addons.mozilla.org/en-US/firefox/addon/canvasblocker/)                                  |
| Hacktools                    | [инструменты хакера](https://addons.mozilla.org/en-US/firefox/addon/hacktools/)                                      |
| Zero Omega                   | [переключатель прокси](https://addons.mozilla.org/en-US/firefox/addon/zeroomega/)<br>для TOR - SOCKS5 127.0.0.1:9050 |
| Tampermonkey                 | [пользовательские скрипты JS](https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/)                          |
- для правильной работы Plasma Integration
```bash
ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts
sudo ln -s /usr/lib/mozilla/native-messaging-hosts /usr/lib/librewolf/native-messaging-hosts
```
#### Скрипты для Tampermonkey

| Название                                         | Ссылка                                                                                                                           |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| голосовой перевод от Яндекс                      | https://raw.githubusercontent.com/ilyhalight/voice-over-translation/master/dist/vot.user.js                                      |
| блокировка об отключении рекламодавки на Youtube | https://greasyfork.org/en/scripts/459541-youtube%E5%8E%BB%E5%B9%BF%E5%91%8A-youtube-ad-blocker                                   |
| возвращение дизлайков Youtube                    | https://greasyfork.org/en/scripts/436115-return-youtube-dislike/code                                                             |
| отключение Ambient для Youtube                   | https://greasyfork.org/scripts/453801-disable-youtube-glow-ambilight/code/Disable%20YouTube%20GlowAmbilight.user.js              |
| запрет возрастных ограничений Youtube            | https://github.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/raw/main/dist/Simple-YouTube-Age-Restriction-Bypass.user.js |
| запрет YouTube Shorts                            | https://greasyfork.org/ru/scripts/437721-hide-youtube-shorts                                                                     |

---
## Thorium

>отличный форк Chromium для использования в качестве альтернативы Google Chrome
```shell
yay -R thorium-browser-bin
```

>включение плавного скролинга
```q
chrome://flags/#smooth-scrolling
```
---
##  Yandex browser

### Yandex browser DEB

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
### Yandex browser RPM

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

---

#  PortProton

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

>KDE Arch
```bash
sudo pacman -S kdeplasma-addons
```

---
# Расширение Discord (Vencord)
```shell
sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
```

---
# Список трекеров для торрентов
```text
udp://bt.e-burg.org:2710/announce
```

---
