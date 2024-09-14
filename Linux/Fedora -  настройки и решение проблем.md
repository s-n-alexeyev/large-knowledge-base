
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
# x11

```bash
sudo dnf install plasma-workspace-x11 kwin-x11
```

---
# RPM Fusion

```bash
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

---
# Installing ONLYOFFICE Desktop Editors from repository

A better option to install desktop editors is to add their repository to your Linux OS. To do that:

1. Add the yum repository with the following command:
```bash
sudo yum install https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm
```

2. Add the EPEL repository with the following command:
```bash
sudo yum install epel-release
```

To install EPEL on RHEL, use the following commands:  
```bash
sudo subscription-manager repos --enable codeready-builder-for-rhel-$REV-$(arch)-rpms
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$REV.noarch.rpm
```

Change $REV to your OS version manually (7 for versions 7.x, 8 for versions 8.x, 9 for versions 9.x and so on).

3. Now the editors can be easily installed using the following command:
```bash
sudo yum install onlyoffice-desktopeditors -y
```

---
# PortProton

```bash
sudo dnf copr enable boria138/portproton

sudo dnf install portproton
```

---
# nVidia

```bash

# and reboot if you are not on the latest kernel
sudo dnf update -y 

# rhel/centos users can use kmod-nvidia 
sudo dnf install akmod-nvidia

#optional for cuda/nvdec/nvenc support
sudo dnf install xorg-x11-drv-nvidia-cuda 
```

---
# java Liberica

```bash
echo | sudo tee /etc/yum.repos.d/bellsoft.repo > /dev/null << EOF
[BellSoft]
name=BellSoft Repository
baseurl=https://yum.bell-sw.com
enabled=1
gpgcheck=1
gpgkey=https://download.bell-sw.com/pki/GPG-KEY-bellsoft
priority=1
EOF
```

---
# Docker

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```

```bash
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---
# Codecs

```bash
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
```

---
# Fonts

Microsoft
```bash
sudo dnf install msttcorefonts
sudo fc-cache -f -v
```

hack-fonts
```bash
sudo dnf copr enable zawertun/hack-fonts
sudo dnf install hack-fonts
```

---
# Syncthing Tray

```bash
dnf config-manager --add-repo https://download.opensuse.org/repositories/home:mkittler/Fedora_40/home:mkittler.repo
dnf install syncthingtray
```

---
# VS-Codium

```bash
sudo tee -a /etc/zypp/repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
```

```bash
sudo dnf install codium
```

---
# Отсутствует libcrypt.so.1

```bash
sudo dnf install libxcrypt-compat
```