```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# cachyos: подпись от "CachyOS <admin@cachyos.org>" некорректна

>(signature from “CachyOS admin@cachyos.org” is invalid)
```bash
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver [keyserver.ubuntu.com](http://keyserver.ubuntu.com)

sudo pacman-key --lsign-key F3B607488DB35A47
```

>или
```bash
sudo su

sudo rm -rf /etc/pacman.d/gnupg/
sudo pacman-key --init
sudo pacman-key --populate

sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47
```

---
# Обновление зеркал

```bash
sudo cachyos-rate-mirrors
```

---

# Понижение версии

Чтобы понизить версию приложения  в Arch Linux, выполните следующие шаги:

1. **Убедитесь, что у вас установлен `downgrade`**  
Если вы еще не установили `downgrade`, выполните команду:
```bash
sudo pacman -S downgrade

```