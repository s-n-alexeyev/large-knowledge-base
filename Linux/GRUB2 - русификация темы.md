2024-04-23

Репозиторй на [Github](https://github.com/AdisonCavani/distro-grub-themes/)

В AUR очень много тем на любой вкус
```
grub-theme-almalinux
grub-theme-aorus
grub-theme-apple
grub-theme-arch-linux
grub-theme-arco-linux
grub-theme-artix-linux
grub-theme-asrock
grub-theme-asus
grub-theme-bedrock-linux
grub-theme-centos
grub-theme-chromeos
grub-theme-debian
grub-theme-deepin
grub-theme-dell
grub-theme-elementaryos
grub-theme-endeavouros
grub-theme-fedora
grub-theme-framework
grub-theme-freebsd
grub-theme-garuda
grub-theme-gentoo
grub-theme-gigabyte
grub-theme-hp
grub-theme-huawei
grub-theme-kde-neon
grub-theme-kingston
grub-theme-kubuntu
grub-theme-legion
grub-theme-lenovo
grub-theme-lg
grub-theme-lubuntu
grub-theme-manjaro2
grub-theme-medion
grub-theme-linux-mint
grub-theme-msi
grub-theme-mx-linux
grub-theme-nixos
grub-theme-opensuse
grub-theme-parabola
grub-theme-pop-os
grub-theme-razer
grub-theme-rocky-linux
grub-theme-samsung
grub-theme-slackware
grub-theme-solus
grub-theme-system76
grub-theme-thinkpad
grub-theme-toshiba
grub-theme-ubuntu-mate
grub-theme-ultramarine
grub-theme-vaio
grub-theme-ventoy
grub-theme-void-linux
grub-theme-windows-10
grub-theme-windows-11
grub-theme-xero-linux
grub-theme-zorin-os
```

>Устанавливаем тему из AUR, например 
```shell
yay -S grub-theme-msi
```

>Редактируем удобным для вас способом картинку заднего фона, который располагается по адресу `/boot/grub/themes/Msi/background.png`, (необходимы права администратора),
стираем все надписи на картинке на английском языке, можно воспользоваться GIMP:
![|800](/Media/Grub2_Theme/image_1.png)

>Получаем такое:
![|800](/Media/Grub2_Theme/image_2.png)

- Не забываем сохранить под тем же именем по тому же пути `/boot/grub/themes/Msi/background.png`

>Заменяем содержимое файла конфигурации темы `/boot/grub/themes/Msi/theme.txt`, необходимы права администратора
```q
# Main options
title-text: ""
desktop-image: "background.png"
desktop-color: "#000000"
terminal-font: "Terminus Regular 14"
terminal-box: "terminal_box_*.png"
terminal-left: "0"
terminal-top: "0"
terminal-width: "100%"
terminal-height: "100%"
terminal-border: "0"

# Boot menu
+ boot_menu {
  left = 15%
  top = 40%
  width = 55%
  height = 65%
  item_font = "Ubuntu Regular 20"
  item_color = "#cccccc"
  selected_item_color = "#ffffff"
  icon_width = 36
  icon_height = 36
  item_icon_space = 20
  item_height = 40
  item_padding = 2
  item_spacing = 10
  selected_item_pixmap_style = "select_*.png"
}

# Title label
+ label {
  left = 15%
  top = 24%
  align = "left"
  text = "Выберите операционную систему для загрузки"
  color = "#ffffff"
  font = "Ubuntu Regular 20"
}

# Countdown label
+ label {
  left = 15%
  top = 31%
  align = "center"
  id = "__timeout__"
  text = "Загрузка выбранного пункта через %d сек."
  color = "#cccccc"
  font = "Ubuntu Regular 17"
}

# Navigation keys hint
+ label {
  left = 0
  top = 98%-30
  width = 100%
  align = "center"

  # RU
  text = "Используйте клавиши ↑ и ↓ для изменения выбора, Enter для подтверждения"
  color = "#ffffff"
  font = "Terminus Regular 14"
}
```

>Обновляем GRUB
```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

