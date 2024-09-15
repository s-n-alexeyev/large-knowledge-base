>Устанавливаем оболочку
>на Arch
```shell
sudo pacman -S fish
```

>на Debian
```shell
sudo apt install fish
```

> на Fedora
```bash
sudo dnf install fish
```

>Меняем оболочку с `bash` на `fish` и перегружаемся
```shell
chsh -s /bin/fish $USER
# или
usermod -s /bin/fish $USER
```

>Перегружаем
```shell
reboot
```

>Настраиваем оболочку на свой вкус
```shell
fish_config
```

>Запрет приветствия 
```shell
set -U fish_greeting
```

---
## Tide plugin
![|400](/Media/Fish/image_1.png)

>Устанавливаем plugin менеджер `fisher` и шрифты
```shell
#Arch/Manjaro
sudo pacman -S fisher

#Other
curl -sL \
https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | \
source && fisher install jorgebucaran/fisher
```

```
# шрифты со значками, подойдут любые на вкус
ttf-firacode-nerd
# или
yay -S ttf-meslo-nerd-font-powerlevel10k
# или
yay -S ttf-hack-nerd
```

>Устанавливаем plugin `tide`
```shell
fisher install IlanCosman/tide@v6.1.1
```

>Конфигурация `tide`
```shell
tide configure
```

Исправленные файлы со значками для корректного отображения значков из шрифта `ttf-firacode-nerd`
~/.config/fish/functions/tide/configure/choices/all/icons.fish

>Сами значки в obsidian не отображаются, копируем содержимое, затем повторно выполняем `tide configure`
```q
function icons
    _tide_title Icons

    _tide_option 1 'Few icons'
    _tide_display_prompt

    _tide_option 2 'Many icons'
    _enable_icons
    _tide_display_prompt

    _tide_menu (status function)
    switch $_tide_selected_option
        case 'Few icons'
            _disable_icons
    end
    _next_choice all/transient
end

function _enable_icons
    set -p fake_tide_left_prompt_items os
    set -g fake_tide_pwd_icon 
    set -g fake_tide_pwd_icon_home 
    set -g fake_tide_cmd_duration_icon 
    set -g fake_tide_git_icon  
end

function _disable_icons
    _tide_find_and_remove os fake_tide_left_prompt_items
    set fake_tide_pwd_icon
    set fake_tide_pwd_icon_home
    set fake_tide_cmd_duration_icon
    set fake_tide_git_icon
end
```

