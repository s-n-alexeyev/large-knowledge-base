
2023-06-26
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Установка

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
sudo usermod -s /bin/fish $USER
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
![|400](/Media/Pictures/Fish/tide.png)

>Устанавливаем plugin менеджер `fisher` и шрифты
```shell
#Arch/Manjaro
sudo pacman -S fisher

#Other
curl -sL \
https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | \
source && fisher install jorgebucaran/fisher
```

```bash
# шрифты со значками, подойдут любые на вкус
yay -S ttf-firacode-nerd
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

>Сами значки в obsidian не отображаются (если не настроен шрифт со значками), копируем содержимое, затем повторно выполняем `tide configure`
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

# Два способа добавить алиасы

## Способ №1. Создание отдельного файлов для алиасов

Данный способ, как мне кажется, могут использовать пользователи, у которых очень много алиасов, причем все они разносторонние и связаны как с управлением самим дистрибутивом, так и конкретным ПО. Способ подразумевает создание отдельных файлов с алиасами и подключение их через основной конфигурационный файл.

Чтобы воспользоваться им, перейдите в директорию, где хранятся все конфиги Fish:

```bash
cd $HOME/.config/fish
```

Здесь необходимо создать файл, в котором будут находиться нужные алиасы. Например, я создам файл, где будут храниться только системные алиасы (то есть, сокращения, позволяющие быстро установить или удалить пакет, обновить дистрибутив и пр.):

**nano system.fish**

В созданном файле описываем необходимые алиасы, используя уже привычный формат:

```
alias <имя_алиаса>=<команда>
```

![Файл system.fishействия с дистрибутивом](/Media/Pictures/Fish/system.fish.png)

Файл `system.fish`, содержащий основные алиасы для взаимодействия с дистрибутивом

После создания нужного файла, открываем файл config.fish, который находится в этой же директории и вставляем туда следующий фрагмент:

```
# Aliases
if [ -f $HOME/.config/fish/system.fish ]
       source $HOME/.config/fish/system.fish
end
```

Под знаком решетки указано название раздела, который настраиваем, чтобы когда файл разрастется, знать за настройку чего отвечает определенный кусок кода, далее идет проверка того, что файл system.fish существует и если да, то происходит его исполнение и подключение к основному конфигу.

![Подключаем файл с алиасами в основной конфиг Fish](/Media/Pictures/Fish/alias_config.png)

Подключаем файл с алиасами в основной конфиг Fish

Аналогичным образом можно подключить все необходимые файлы с алиасами. Например, алиасы, отвечающие за конкретную программу (например, консольный файловый менеджер или GIT), работу с VPN-соединением (если вы подключаетесь по VPN через консоль), действия с файлами и директориями.

После сохранения и выхода из консольного текстового редактора нужно перезапустить оболочку. В Fish это можно сделать также, как и в ZSH:

```bash
exec fish
```

После созданные алиасы подхватятся оболочкой и будут работать, а также появятся в автодополнении.

## Способ №2. Перечисление алиасов напрямую в конфигурационном файле

Этот вариант выбрал я, так как количество необходимых алиасов в моем случае, не сильно большое. Поэтому их я разместил сразу в файле config.fish.

![Размещение алиасов сразу в основном конфиге](/Media/Pictures/Fish/main_config.png)

Размещение алиасов сразу в основном конфиге

Далее выполняем также сохранение внесенных изменений, закрытие файла конфига и последующий рестарт оболочки все той же командой:

```bash
exec fish
```

Результат будет точно таким же, как и при использовании первого способа.

## Пример алиас `ls`  

>устанавливаем `eza`
```bash
#arch
yay -S eza

#debian
sudo apt install eza

#fedora
sudo dnf install eza
```

>редактируем `config.fish`
```bash
sudo nano ~/.config/fish/config.fish
```

```
if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls="eza --tree --level=1 --icons=always --group-directories-first"
```

>перегружаем оболочку
```bash
exec fish
```

>так теперь выглядит команда `ls`
![eza|600](/Media/Pictures/Fish/eza.png)