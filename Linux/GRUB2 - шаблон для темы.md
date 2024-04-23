
устанавливаем тему из AUR, например 
```shell
yay -S grub-theme-msi
```


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