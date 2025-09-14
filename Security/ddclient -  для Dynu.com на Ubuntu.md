# Настройка ddclient для Dynu.com на Ubuntu

## Установка ddclient
```bash
sudo apt update
sudo apt install ddclient -y
```

## Редактирование конфигурации
```bash
sudo nano /etc/ddclient.conf
```

### Пример содержимого /etc/ddclient.conf
```bash
protocol=dyndns2
use=web, web=checkip.dynu.com/, web-skip='Current IP Address:'
server=api.dynu.com
login=ВАШ_EMAIL_ИЛИ_ЛОГИН
password='ВАШ_API_KEY_ИЛИ_ПАРОЛЬ'
yourdomain.dynu.net
```

## Тестирование
```bash
sudo ddclient -daemon=0 -verbose -noquiet
```

## Запуск как сервиса
```bash
sudo systemctl enable ddclient
sudo systemctl start ddclient
systemctl status ddclient
```

## Логи
```bash
journalctl -u ddclient -f
```
