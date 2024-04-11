>Устанавливаем MariaDB
```bash
sudo pacman -Syu && sudo pacman -S mariadb
```

>Перед запуском службы проинициализируем MariaDB-сервера базу данных
```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

>Добавляем в автозагрузку службу MariaDB
```bash
sudo systemctl enable --now mariadb
```

>Стартуем службу
```bash
sudo systemctl start --now mariadb
```

>Проверяем работоспособность
```bash
sudo systemctl status --now mariadb
```

>Заходим на сам сервер
```bash
sudo mysql -u root
```

>В самой БД создаем нового пользователя с правами root введя следующие команды
```bash
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ВАШ_ПАРОЛЬ';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ВАШ_ПАРОЛЬ');
```

>Выходим
```bash
exit
```