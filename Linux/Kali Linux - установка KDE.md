# Как установить среду рабочего стола KDE на Kali Linux

В Ubuntu есть среда рабочего стола GNOME, ранее Kali Linux также использовал GNOME в качестве среды рабочего стола по умолчанию, но после обновления Kali Linux 2019.4 Kali перешел на облегченную среду рабочего стола XFCE.
## Установка KDE на Kali Linux

>В последние несколько лет, дистрибутив Kali Linux претерпел большие изменения. Чтобы установить [KDE](https://spy-soft.net/luchshij-kde-distributiv/) на последние версии Kali Linux, нужно использовать следующую команду:
```shell
sudo apt install -y kali-desktop-kde
sudo apt install plasma-wallpapers-addons
```

Начнется загрузка и установка среды рабочего стола KDE . Скачивание почти 500 MB данных может занять некоторое время. После установки может занять более 1300 МБ дискового пространства.

>Если появится запрос на настройку SDDM, нажмите ENTER или OK, как показано на картинке.

[![Диспетчер KDE|800](/Media/Pictures/Kali_KDE/image_1.png)](https://spy-soft.net/wp-content/uploads/configuring-kde-.png)

>Следующее окно предлагает сделать SDDM менеджером отображения по умолчанию. Выберите SDDM и нажмите ENTER.

[![Настройка sddm в качестве среды рабочего стола по умолчанию|800](/Media/Pictures/Kali_KDE/image_2.png)](https://spy-soft.net/wp-content/uploads/configuring-ssdm-on-kde.png)

>Затем необходимо выполнить команду:
```shell
sudo update-alternatives --config x-session-manager
```

[![Установка KDE Kali Linux. X менеджер сеансов|800](/Media/Pictures/Kali_KDE/image_3.png)](https://spy-soft.net/wp-content/uploads/x-session-manager.png)
На приведенном выше скрине видно, что выбран менеджер сеансов (*), то есть XFCE. Выбираем 1 и жмем ENTER.

>Теперь надо перезагрузить систему. Сделать это можно и с помощью команды:
```shell
sudo reboot
```

>После перезагрузки мы окажемся в среде рабочего стола KDE.

[![Среда рабочего стола KDE Kali Linux|800](/Media/Pictures/Kali_KDE/image_4.jpeg)](https://spy-soft.net/wp-content/uploads/kde-desktop-environment-on-kali-linux.jpg)

Вот как просто мы можем установить KDE на [Kali Linux](https://spy-soft.net/kali-linux-live-usb-persistence/). Это настолько просто, что с этим легко справится каждый. Хотя KDE очень продвинутый по сравнению с XFCE, он не такой легкий, как XFCE, из-за этого вы можете почувствовать проседание в производительности.

## Удаление KDE из Kali Linux

>Чтобы вернуться к XFCE, выбрав диспетчер xsession для xfce4, введите команды:
```shell
sudo update-alternatives --config x-session-manager
```

>Затем нужно выбрать опцию xfce4, а после полностью удалить KDE из дистрибутива:
```shell
sudo apt purge --autoremove kali-desktop-kde
```

>Ну, и под конец, выполните команду:
```shell
sudo rm /etc/systemd/system/default.target
```

После перезагрузки мы окажемся в среде рабочего стола XFCE, а среда рабочего стола KDE будет удалена из системы.
