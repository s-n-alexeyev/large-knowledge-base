
```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Отключение SELinux

>Open the `/etc/selinux/config` file in a text editor of your choice, for example:
```bash
sudo nano /etc/selinux/config
```
   
>Configure the SELINUX=disabled option: 
```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#       targeted - Targeted processes are protected,
#       mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

>Save the change, and restart your system:
``` bash
reboot
```

---
# Настройка DNF

Редактируем конфигурационный файл dnf
```bash
sudo nano /etc/dnf/dnf.conf
```

```
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
```

Для жителей РФ и СНГ параметр `fastestmirror=True` нужно попробовать включить и отключить и посмотреть как будет лучше. Некоторые пользователи заметили, что dnf пытается подключаться к серверам Yandex, а какие-то пакеты там могут отсутствовать и поэтому могут сыпаться различные ошибки.

Далее выполняем:
```bash
sudo dnf autoremove && sudo dnf clean all
```


Добавляем автоматическое обновление зеркал в фоне (по идеи должно ускорить dnf)

```
sudo dnf install dnf-automatic
```

```
sudo systemctl enable dnf-automatic.timer
```

---
