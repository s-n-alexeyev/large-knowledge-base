# Автоматическая установка прав `0751` на `/run/media/user`

## В чём проблема
При входе в систему демон `udisks2` динамически создаёт каталог `/run/media/<имя_пользователя>` с правами `0750` (`drwxr-x---`). Из-за этого сетевые службы (например, Samba при публикации папки в Dolphin) не могут пройти по пути к примонтированному разделу и требуют изменить права при каждой перезагрузке.

## Решение через `systemd.path`
Системный юнит отслеживает появление каталога `/run/media/user` и от имени `root` сразу выставляет для него права `0751` (`drwxr-x--x`).

> **Примечание:** Если ваше имя пользователя отличается от `user`, замените `user` на свой логин в путях ниже.

---

### 1. Создание `.service`-файла
Создайте юнит, который выполняет смену прав:

```bash
sudo tee /etc/systemd/system/fix-media-perm.service << 'EOF'
[Unit]
Description=Set 0751 permissions on /run/media/user

[Service]
Type=oneshot
ExecStart=/bin/chmod 0751 /run/media/user
EOF
```

### 2. Создание `.path`-наблюдателя
Создайте юнит, который запускает сервис сразу при появлении каталога:

```bash
sudo tee /etc/systemd/system/fix-media-perm.path << 'EOF'
[Unit]
Description=Watch for /run/media/user creation

[Path]
PathExists=/run/media/user

[Install]
WantedBy=multi-user.target
EOF
```

### 3. Активация и проверка
Перечитайте конфигурацию `systemd` и включите наблюдатель:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now fix-media-perm.path
```

Проверьте текущие права на каталог:

```bash
ls -ld /run/media/user
```

Ожидаемый вывод:
```text
drwxr-x--x 3 root root 60 ... /run/media/user
```

---

### Откат изменений (если понадобится)
Чтобы отключить и удалить юниты:

```bash
sudo systemctl disable --now fix-media-perm.path
sudo rm -f /etc/systemd/system/fix-media-perm.{path,service}
sudo systemctl daemon-reload
```