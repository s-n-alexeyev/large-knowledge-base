# Настройка общего доступа к папкам через Samba в Dolphin 

## Введение

Данное руководство описывает настройку общего доступа к папкам через Samba с использованием файлового менеджера Dolphin в дистрибутиве CachyOS (Arch-based). После выполнения этих шагов вы сможете расшаривать папки через контекстное меню Dolphin.

## Предварительные требования

- Установленный CachyOS/Arch Linux
- Права суперпользователя (sudo)
- Подключение к локальной сети
## Установка необходимых пакетов

Выполните команду:
```bash
sudo pacman -S samba dolphin-plugins kdenetwork-filesharing
```

Пояснение пакетов:

- samba - сервер общего доступа к файлам
- dolphin-plugins - плагины для файлового менеджера Dolphin
- kdenetwork-filesharing - компоненты KDE для общего доступа к файлам

## Настройка Samba

### 1. Создание директории для usershares

Выполните команду: 
```bash
sudo mkdir -p /var/lib/samba/usershares
```

### 2. Настройка прав доступа

Выполните команды:  
```bash
sudo groupadd sambashare  
sudo chown root:sambashare /var/lib/samba/usershares  
sudo chmod 1770 /var/lib/samba/usershares  
sudo usermod -a -G sambashare $USER
```

### 3. Создание конфигурации Samba

Выполните команду: 
```bash
sudo nano /etc/samba/smb.conf
```

Добавьте следующую конфигурацию:  
```text
[global]  
workgroup = WORKGROUP  
server string = Samba Server  
security = user  
map to guest = bad user  
dns proxy = no  
log file = /var/log/samba/log.%m  
max log size = 1000  
client min protocol = SMB2  
usershare allow guests = yes  
usershare max shares = 100  
usershare owner only = no  
usershare path = /var/lib/samba/usershares  
usershare prefix allow list = /
```

### 4. Запуск и включение служб Samba

Выполните команду:
```bash
sudo systemctl enable --now smb.service nmb.service
```

## Настройка KDE/Dolphin

### 1. Включение общего доступа в системных настройках

Выполните команду: systemsettings5  
Или через меню: System Settings → Sharing → Enable Sharing

### 2. Обновление системных кэшей KDE

Выполните команду: 
```bash
kbuildsycoca5
```

### 3. Перезапуск сессии

Важно: После добавления пользователя в группу sambashare необходимо полностью выйти из системы и войти заново.

## Использование общего доступа в Dolphin

### Способ 1: Через контекстное меню

1. Откройте Dolphin
2. Правый клик на папке → Properties (Свойства)
3. Перейдите на вкладку Share (Публикация)
4. Активируйте опцию Share this folder (Открыть общий доступ к этой папке)
5. Настройте параметры:
    - Share name - имя папки в сети
    - Allow guest access - гостевой доступ
    - Read-only - только для чтения

### Способ 2: Через раздел Sharing в системных настройках

1. System Settings → Sharing
2. File Sharing → Add Share
3. Укажите путь к папке и параметры доступа

## Проверка работоспособности

### 1. Проверка usershares через терминал

Выполните команду: 
```bash
net usershare list --long
```

### 2. Проверка доступа к локальному серверу

Выполните команду:
```bash
smbclient -L localhost
```

### 3. Проверка через Dolphin

В адресной строке Dolphin введите: smb://localhost/

## Решение распространенных проблем

### Ошибка: "/var/lib/samba/usershares не существует"

Выполните команды:  
```bash
sudo mkdir -p /var/lib/samba/usershares  
sudo chown root:sambashare /var/lib/samba/usershares  
sudo chmod 1770 /var/lib/samba/usershares
```

### Ошибка: "usershares are currently disabled"

Убедитесь, что в /etc/samba/smb.conf есть строки:  
```text
usershare allow guests = yes  
usershare path = /var/lib/samba/usershares
```

### Ошибка: "Path not allowed"

Добавьте в конфигурацию: 
```text
usershare prefix allow list = /
```
### Пункт Share не появляется в Dolphin

Выполните команды:  
```bash
sudo pacman -S --needed kdenetwork-filesharing dolphin-plugins  
kbuildsycoca5
```

### Перезапуск служб при проблемах

Выполните команду:
```bash
sudo systemctl restart smb nmb
```

## Дополнительные настройки

### Настройка брандмауэра (если используется)

Выполните команды:  
```bash
sudo firewall-cmd --permanent --add-service=samba  
sudo firewall-cmd --reload
```

### Создание общего доступа с аутентификацией

Выполните команду: 
```bash
sudo smbpasswd -a $USER  
```
В конфигурации папки замените:  
```text
guest ok = no  
valid users = ваш_пользователь
```

## Заключение

После выполнения всех шагов вы сможете:

1. Расшаривать папки через контекстное меню Dolphin
2. Настраивать различные уровни доступа (гостевой, с аутентификацией)
3. Просматривать сетевые ресурсы через Dolphin
4. Управлять общим доступом через графический интерфейс

Для доступа к расшаренным папкам с других устройств в сети используйте адрес: smb://IP-АДРЕС-СЕРВЕРА/