
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

# Два способа добавить алиасы в

## Способ №1. Создание отдельного файлов для алиасов

Данный способ, как мне кажется, могут использовать пользователи, у которых очень много алиасов, причем все они разносторонние и связаны как с управлением самим дистрибутивом, так и конкретным ПО. Способ подразумевает создание отдельных файлов с алиасами и подключение их через основной конфигурационный файл.

Чтобы воспользоваться им, перейдите в директорию, где хранятся все конфиги Fish:

**cd $HOME/.config/fish**

Здесь необходимо создать файл, в котором будут находиться нужные алиасы. Например, я создам файл, где будут храниться только системные алиасы (то есть, сокращения, позволяющие быстро установить или удалить пакет, обновить дистрибутив и пр.):

**nano system.fish**

В созданном файле описываем необходимые алиасы, используя уже привычный формат:

**alias <имя_алиаса>=<команда>**

![Файл system.fish, содержащий основные алиасы для взаимодействия с дистрибутивом](https://dzen.ru/lz5XeGt8f/I9A5ok241/0a1349FVr2/6cW3q-nUrQGkWSLMozy_SAFnK1O_cIbABRG7EayhJgx_5EIcnCnsjqbECMKDjeQWyPR2CeB0S9_vWuAEpkUb4K_U77331-5Rsl4Piblh_UxXb3cH_nOdgEEK6BHtuzgMIowXXIxltNfwqA7EhZLLPOvqAmKWHmOtxCK0HaATAPDs6dKkrdqSIYFbM_zUDbJHKFw_c4hZ8f4cdqgyoscWGlzJRwq9TZfB2Y1WkOzn5yXl3AJ3oS1pgd8GuT6PLlj67_XL4pDTrgSGUgHw7Ba2Wxh9CV21X_72AX2MAbP9Pxhe2WkRmH6B3tSfS4f66_0C7sw6abQ2a6jfJ4Qhgit29sj-5cCN45wOqkgI1v89gXsMbQF5oUbF3TR6lSGQ5TUTfdxJI6hLpuPjpn2E5NreIOnyJmeTDVqd1Tu-CbAoS9Tu-eH8rd-vBIlfE_bXMIxXNkwdb4t6z9EKRKkXm80GP0LXQx6TaIPYwJRanOHM2An97yhvvgRkicwAsiqOGXfr8ff6_qrttCy7XzPPwBW3QyJjD22vZOzrH3eRIZP4NhpBwkEhqHWi_vS5U5na4-M0y9sORZICa6n7HoQAihJ89MHP3ueVwKgvg3Uh3MgrglkJQilZgX3nwQFwkQeZzRk5Ye52N65_sNLjkmql2MD-COTGClidLm2kyQSZNpY-ZO_BwMLVoPaOArRgEff0OYdcJmcHQ6Fr0cc-cr4Vsd0SKnPJZTaVS5zZ4oBznffs2xDIzDBOoQNlncI6nzGrE1f1_-Pc5qPBtQOAcTXn6guxSz9DDVehXebEM0SqEongFwVz7mcqjVOv49q9TJjf6-ISztIpbq8IT5LkNZ4djD9WxP_6yciu3a8lpU8T-voavF08SyRhhnbqwCN9vQOf4AQQRNVjP5lpsvbtunuG0-z8INvoOleaH0i92TyXAogrbNbo_-Lpit63FZRtBt3KLLJZPEktTZp35N8mfYobs8s2IWnRTweyQ7fa37VLneTWxCbM_RhokRVQntc_gyaNBELT7tXawb7CuDGWSBrexS6DTi1DAXidZvv9ImupDr3DKStUzlIDqk6B_vO6ZoD29uYsw8UFb7cmRbPaLbQ0kTpp0ODuyP2e4bUHp1Mo7N0wgHkjdyhcm2nN0Rh9mAOU2D8kQONNKapEtP_UmXi7-OHxFMjtGnuoD36Z9SGENpA1Q_De3fzzqvqMJ71QEtLOHZBmBmQyU55FwsslU60GsN49G3bvSgmzQI_c2IF2uuLs8iLTxSh2vw1fm8UPiCaSB2HUzP_e7rTYvw-xUyHH-z2tTwJCK1-bYuzrA3yTOZb5BCBX_m8mjmKS2OaCaqzY5OAs5-8FX5gEW7npPqUfkhxCzvLf9f2W_7MOqG0H6MMWon8JfilHon38wztRvzmf3R4idsJsFKpHlsH8kGyjzcn-JMXOOke9C12-_x-SDYMoRMf67N7QhOypGJF6P9n6KYNsHnw9W7hL5NAgfYQkieANPWnKQiSWbbLf8bl1mdrA-wDlwAl8lxVCos4LviShGEDk1e_A7qTztTCIfR3vxROiRyt4I3qHS_vDGlaOE5_OFzlW2VcVhVe0zuCSW5P48NsI588UULoifYnINpUXqw1i8vX86vG_2asQsVEd-cI_gFUBez1foVXj2TFZqyCC-zsYXthOMq1QvMjss3OHzcvaJd_vAXyNDmaJ6CWyAJcEZu_-_czgpMy3CKZ9M87dNbx8Al8tbJpr0ssmaYoBncYYKknfTwqGQ6TM7Y1Kr__B_jPp7i9OnRx-nvkHhj6NBWPy8N7mw7P3tSqXbjfl_j6oay57F3eGRc_zB3GaB5zdOR1V-Uo1t2e7weW9WITmw-cI0v8xaoEdfr3pO6ozixNI6dfC78KE8awvo30I0PgZvX8CfBVmiWnJ_x19ihyq3hodf9lkF6pKkNHGvlWg_NjGKeX8Em6_AF6E7x67Ppc2es_X2OLUpPehAoBpGdM)

Файл system.fish, содержащий основные алиасы для взаимодействия с дистрибутивом

После создания нужного файла, открываем файл config.fish, который находится в этой же директории и вставляем туда следующий фрагмент:

**# Aliases**  
**if [ -f $HOME/.config/fish/system.fish ]**  
       **source $HOME/.config/fish/system.fish**  
**end**

Под знаком решетки указано название раздела, который настраиваем, чтобы когда файл разрастется, знать за настройку чего отвечает определенный кусок кода, далее идет проверка того, что файл system.fish существует и если да, то происходит его исполнение и подключение к основному конфигу.

![Подключаем файл с алиасами в основной конфиг Fish](https://avatars.dzeninfra.ru/get-zen_doc/5232637/pub_6498a5b60cc85b6bb91b51bf_6498a9b50cc85b6bb91dee2b/scale_1200)

Подключаем файл с алиасами в основной конфиг Fish

Аналогичным образом можно подключить все необходимые файлы с алиасами. Например, алиасы, отвечающие за конкретную программу (например, консольный файловый менеджер или GIT), работу с VPN-соединением (если вы подключаетесь по VPN через консоль), действия с файлами и директориями.

После сохранения и выхода из консольного текстового редактора нужно перезапустить оболочку. В Fish это можно сделать также, как и в ZSH:

**exec fish**

После созданные алиасы подхватятся оболочкой и будут работать, а также появятся в автодополнении.

## Способ №2. Перечисление алиасов напрямую в конфигурационном файле

Этот вариант выбрал я, так как количество необходимых алиасов в моем случае, не сильно большое. Поэтому их я разместил сразу в файле config.fish.

![Размещение алиасов сразу в основном конфиге](https://avatars.dzeninfra.ru/get-zen_doc/4422773/pub_6498a5b60cc85b6bb91b51bf_6498aafc0cc85b6bb91ec79b/scale_1200)

Размещение алиасов сразу в основном конфиге

Далее выполняем также сохранение внесенных изменений, закрытие файла конфига и последующий рестарт оболочки все той же командой:

**exec fish**

Результат будет точно таким же, как и при использовании первого способа.