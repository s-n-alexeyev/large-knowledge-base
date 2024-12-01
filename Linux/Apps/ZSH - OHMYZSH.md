```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---

![|800](/Media/Pictures/ZSH/image_1.png)
## Шрифты

>Для ARCH подходят
```shell
yay -S ttf-hack-nerd
# или
yay -S ttf-meslo-nerd-font-powerlevel10k
# или
yay -S ttf-firacode-nerd
```
## Установите пакет ZSH

> ARCH 
```shell
sudo pacman -Sy zsh zsh-completions
```

>UBUNTU 
```shell
sudo apt-get install zsh -y
```

>FEDORA
```shell
sudo dnf install zsh
```
## После переходим к настройкам

>Install Oh My Zsh
```shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

> Install PowerLevel10k
```shell
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```

>Установка темы
```shell
sudo nano ~/.zshrc
```

```shell
ZSH_THEME="powerlevel10k/powerlevel10k"
```

> Если после перезагрузки настройки не включились автоматически введите команду
```shell
p10k configure
```
## Плагины

> Подсветка синтаксиса
```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

> Автодополнение
```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

> Включаем плагины
```shell
sudo nano ~/.zshrc
```

```ini
plugins=( git zsh-syntax-highlighting zsh-autosuggestions )
```
## Замена стандартных команд (опционально)

## ls - установите пакет `eza`
```shell
yay -S eza
```

>Для всех alias правим `в ~/.zshrc` откройте настройки shell
```shell
sudo nano ~/.zshrc
```

>Добавьте в самый низ эти строки
```shell
if [ -x "$(command -v eza)" ]; then
    alias ls="eza --tree --level=1 --icons=always --group-directories-first"
fi
```
## cat - установите пакет `bat`

>Добавьте в самый низ эти строки
```shell
alias cat="bat"
```
## df - установите пакет `duf`

>Добавьте в самый низ эти строки
```shell
alias df="duf"
```
## find - установите пакет `fd`

>Добавьте в самый низ эти строки
```shell
alias find="fd"
```
## man - установите пакет `tldr`

>Добавьте в самый низ эти строки
```shell
alias man="tldr"
```
## top - установите пакет `btop`

>Добавьте в самый низ эти строки
```shell
alias top="btop"
```
## du - установите пакет `ncdu`

>Добавьте в самый низ эти строки
```shell
alias du="ncdu"
```
## ping - установите пакет `gping`

>Добавьте в самый низ эти строки
```shell
alias ping="gping"
```
## Включить подсветку в `nano`

```shell
nano ~/.nanorc
```

```shell
include /usr/share/nano/*.nanorc
```
