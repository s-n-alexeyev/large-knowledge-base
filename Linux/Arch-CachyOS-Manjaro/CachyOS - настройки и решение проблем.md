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

# Зеркало на chaotic.cx
```bash
# Скачиваем пакеты
wget https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar
wget https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst

# Распаковываем gpg ключ из пакета
bsdtar -xvf chaotic-keyring.pkg.tar.zst ./usr/share/pacman/keyrings/chaotic-aur.gpg

# Копируем ключ в систему
sudo cp usr/share/pacman/keyrings/chaotic-aur.gpg /usr/share/pacman/keyrings/

# Импортируем ключ и подписываем локально
sudo pacman-key --add /usr/share/pacman/keyrings/chaotic-aur.gpg
sudo pacman-key --lsign-key 3A40CB5E7E5CBC30

# Теперь можно ставить пакеты нормально
sudo pacman -U chaotic-keyring.pkg.tar.zst chaotic-mirrorlist.pkg.tar.zst
```

---
# Понижение версии

Чтобы понизить версию приложения  в Arch Linux, выполните следующие шаги:

>Устанавливаем `downgrade`
```bash
sudo pacman -S downgrade
```

>Пример понижения пакета `lapack`
```bash
sudo downgrade lapack
```

После запуска вы увидите список доступных версий пакета. Выберите версию нужную и подтвердите установку.