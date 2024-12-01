
2019-01-26  
[Источник](https://devsimple.ru/posts/bat/)

```table-of-contents
title: Содердание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

В UNIX подобных системах `cat` используется для последовательного считывания и вывода содержимого файлов в стандартный вывод. В этой статье мы разберем похожую утилиту, являющуюся клоном `cat`, но с дополнительными улчшениями, такими как подсветка синтаксиса и интеграция с [GIT](https://git-scm.com/).

![Bat and Cat comparison](/Media/Pictures/Bat/a386acd300fa107d6f0a374d6f6f2277_MD5.png)
## Установка

### Ubuntu

Скачайте последнюю версию `.deb` пакета [отсюда](https://github.com/sharkdp/bat/releases) и выполните команду:

```bash
# замените имя пакета, на скаченный вами
sudo dpkg -i bat_0.9.0_amd64.deb
```

### MacOS

Установите `bat` с помощью пакетного менеджера [Homebrew](https://docs.brew.sh/Installation):

```bash
brew install bat
```

### Arch Linux

Установите пакет `bat` из официального репозитория:

```bash
pacman -S bat
```

### Другие системы

Если в списке выше вы не нашли своей операционной системы, то загляните в [репозитрий](https://github.com/sharkdp/bat#installation).

## Использование

Чтобы посмотреть содержимое файла, нужно выполнить команду:

```bash
bat file01.md
```

Вы также можете посмотреть содержимое сразу нескольких файлов:

```bash
bat file01.md file02.md
```

Или соединить несколько файлов в один:

```bash
bat file01.md file02.md > multifile.md
```

Перейдем к основным преимуществам `bat`.
### Интеграция с Git

Если внести изменения в файл, который находится под контролем системы управления версиями [Git](https://git-scm.com/), то в колонке слева будут отображаться изменения.

![Bat Git integration](/Media/Pictures/Bat/69171218385d8b56a95ea4c17a62a0ad_MD5.png)
### Подсветка синтаксиса

`bat` поддерживает подсветку синтаксиса для большого кол-ва языков разметки и программирования.

```bash
bat posts_controller.rb
```

С полным списком можно познакомиться, написав команду:

```bash
bat --list-languages
```

![bat-list-languages](/Media/Pictures/Bat/743fd16ff18c3340515b9721ff9e93eb_MD5.png)
## Конфигурация

Если вам не нравится тема по умолчанию, вы можете её поменять. Для того чтобы посмотреть список всех доступных команд запустите команду:

```bash
bat --list-themes
```

![bat-list-themes](/Media/Pictures/Bat/77174f470e8b20a1d03a907995c05d1f_MD5.png)
Для использования темы, для примера возьмем `Monokai Extended Origin`, запустите:

```
bat --theme="Monokai Extended Origin" posts_controller.rb
```

![bat-custom-theme](/Media/Pictures/Bat/161df48c7aa420b620e068ee3612ab82_MD5.png)
Для того, чтобы изменить тему по умолчанию, можно присвоить переменной окружения `BAT_THEME` понравившуюся тему:

```bash
export BAT_THEME="TwoDark"
```

### Добавление новой темы

Первое, что нужно сделать, это создать папку, где мы будем хранить новые темы:

```bash
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
```

Теперь ищем тему с расширением `*.tmTheme`, например по этой [ссылке](https://github.com/filmgirl/TextMate-Themes), скачиваем, копируем в только что созданную папку и обновляем кэш:

```bash
# Перемещаем скачанную тему Railscasts.tmTheme
mv ~/Downloads/Railscasts.tmTheme .

# Обновляем кэш
bat cache --build
```

После этого новая тему будет доступна для выбора.
![bat-railscasts-theme](/Media/Pictures/Bat/50b9d650bb11e14f98ca91c797b192aa_MD5.png)
### Файл конфигурации

Есть еще один вариант изменения настроек по умолчанию, использовать файл настроек. Для этого нужно создать файл `bat.conf` и через переменную окружения `BAT_CONFIG_PATH` указать путь к этому файлу:

```bash
export BAT_CONFIG_PATH="/path/to/bat.conf"
```

Пример такого файла:

```bash
# Установить тему по умолчанию "TwoDark"
--theme="TwoDark"

# Показать номера строк, изменения Git и отобразить имя файла
--style="numbers,changes,header"
```