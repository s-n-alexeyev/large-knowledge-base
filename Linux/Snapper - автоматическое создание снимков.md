# Автоматическое создание снимков при помощи Snapper

2023-03-19
[Оригинальная статья](https://uhanov.org/posts/automate-btrfs-snapshots/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

В комментариях был вопрос о том, зачем ставить систему на subvolume BTRFS. Одна из приятных возможностей, которые открываются при таком подходе, гибкое использование снимков. Давайте автоматизируем их создание при помощи Snapper. Он из коробки создаёт снимки при работе APT. Один до и один после. Так можно точно увидеть что изменилось в процессе работы пакетного менеджера. Разделение файловой системы на subvolume позволяет точно разделять котлет от мух.

Возьмём систему с двумя subvolume :

- @rootfs для корневой файловой системы. Тут ты всё сам понимаешь. Именно в этом subvolume будут происходить изменения когда ты что-то устанавливаешь или обновляешь.
- @home для домашних каталогов. Ты же не хочешь при откате обновлений системы потерять свои документы или фото? Поэтому отделяем.

## Установка Snapper

Мы будем использовать Snapper - инструмент, упрощающий и автоматизирующий работу со снимками. Он позволяет удобно создать снимок subvolume как вручную, так и автоматически. Автоматически снимки создаются по таймеру, при загрузке и при работе пакетного менеджера APT. Начнём.

```bash
sudo apt install snapper
```

Если мы работаем в графическом режиме, ставим GUI

```bash
sudo apt install snapper-gui
```

Надо создать начальную конфигурацию под каждый subvolume

```bash
sudo snapper -c root create-config /
sudo snapper -c home create-config /home
```

## Использование

Снимки бывают трёх типов:

- Single. Просто одиночный снимок, созданный вручную или автоматически.
- Pre. Снимок, созданный перед определённым событием. Например, перед работой APT.
- Post. Снимок, созданный после определённого события. Например, после работы APT. Обязательно ссылается на pre снимок.

Например я установлю Midnight Commander:

```bash
sudo apt install mc
```

После чего просмотрю снимки:

```bash
sudo snapper list
```

![Alt text](/Media/Snapper/Alt_text.webp)

Snapper-Gui надо запускать через sudo, иначе снимков не видно. Вот снимки после установки MC:

![Alt text](/Media/Snapper/Alt_text-4.webp)

### Просмотр изменений
Увидеть что изменилось можно командой сравнения двух снимков. Для этого надо указать номера снимков.

```bash
snapper status 1..2
```

Вывод команды покажет изменения в снимках:

![Alt text](/Media/Snapper/Alt_text-1.webp)

В Snapper-Gui выделяем два снимка и нажимаем кнопку Changes:

![Alt text](/Media/Snapper/Alt_text-5.webp)

Можно увидеть и разницу в файлах:

```bash
sudo snapper diff 1..2
```

![Alt text](/Media/Snapper/Alt_text.webp)

В Snapper-Gui всё это удобнее и тоже хорошо видно на скриншоте выше.

### Отмена изменений

```bash
sudo snapper undochange 1..2
```

Секунда и APT не знает ни про какой MC.

![Alt text](/Media/Snapper/Alt_text-3.webp)

В снимок можно зайти с правами суперпользователя как в каталог и забрать руками нужные файлы.

![Alt text](/Media/Snapper/Alt_text-2.webp)

Это простые BTRFS снимки и в случае невозможности загрузиться в систему можно можно загрузиться с флешки и восстановить систему из снимка.