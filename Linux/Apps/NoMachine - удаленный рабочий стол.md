# NoMachine cheatsheet: Linux → Windows по локальной сети

## 1. Что ставить
- На Windows: NoMachine
- На Linux: NoMachine
- Подключение обычно: Protocol NX, Port 4000

## 2. Узнать IP Windows
На Windows в cmd:

`ipconfig`

Нужен IPv4, например: `192.168.1.25`

## 3. Проверить порт с Linux

`nc -zv 192.168.1.25 4000`

Если видишь `open`, порт доступен.

## 4. Если порт закрыт — открыть firewall на Windows
PowerShell от администратора:

`New-NetFirewallRule -DisplayName "NoMachine TCP 4000" -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow`

## 5. Подключение с Linux
В клиенте NoMachine:
- Host: `IP_Windows`
- Protocol: `NX`
- Port: `4000`

## 6. Важная особенность: вход без пароля Windows
Если у локального пользователя Windows пустой пароль, обычный удалённый вход не пройдёт.

Для NoMachine нужен отдельный вариант:
- включить `NX user DB`
- включить `NX password DB`
- создать отдельный пароль только для NoMachine

Это не меняет пароль Windows.

## 7. Включить отдельную базу пользователей NoMachine
Открыть от администратора файл:

`C:\Program Files\NoMachine\etc\server.cfg`

Убедиться, что есть строки:

`EnableUserDB 1`  
`EnablePasswordDB 1`

Если строки закомментированы через `#`, убрать `#`.

## 8. Перезапустить NoMachine
В cmd от администратора:

`cd C:\ProgramData\NoMachine\nxserver`  
`nxserver.exe --restart`

## 9. Добавить пользователя в NoMachine DB
В cmd от администратора:

`cd C:\ProgramData\NoMachine\nxserver`  
`nxserver.exe --useradd Usert`

Где `Usert` — имя локального пользователя Windows.

## 10. Задать пароль только для NoMachine

`nxserver.exe --passwd Usert`

Это пароль для входа через NoMachine, не пароль Windows.

## 11. Проверить, включилась ли NX-аутентификация

`nxserver.exe --userauth Usert`

Правильный результат должен показывать, что:
- `NX user DB: on`
- `NX password DB: on`

Если видишь:
- `NX user DB is: off`
- `NX password DB is: off`
- `Authentication ... is: system`

значит `server.cfg` не применился.

## 12. Вход с Linux в таком режиме
В NoMachine client:
- Username: `Usert`
- Password: пароль, заданный через `nxserver.exe --passwd Usert`

## 13. Полезные команды

### Проверить пользователя Windows
`echo %USERNAME%`  
`whoami`

### Посмотреть список NX-пользователей
`nxserver.exe --userlist`

### Проверить доступность порта с Linux
`nc -zv IP_WINDOWS 4000`

## 14. Частые проблемы

### Порт 4000 закрыт
Открыть firewall на Windows.

### Не принимает логин с пустым паролем Windows
Это нормально. Нужен отдельный пароль через `NX password DB`.

### `nxserver.exe --passwd Usert` ничего не меняет
Скорее всего:
- `EnableUserDB 1` не включён
- `EnablePasswordDB 1` не включён
- NoMachine не перезапущен

### Пишет `Authentication is: system`
Значит NoMachine всё ещё использует обычную аутентификацию Windows, а не свою базу.

## 15. Минимальная рабочая последовательность

`notepad "C:\Program Files\NoMachine\etc\server.cfg"`

Проверить строки:

`EnableUserDB 1`  
`EnablePasswordDB 1`

Потом выполнить:

`cd C:\ProgramData\NoMachine\nxserver`  
`nxserver.exe --restart`  
`nxserver.exe --useradd Usert`  
`nxserver.exe --passwd Usert`  
`nxserver.exe --userauth Usert`

После этого подключаться с Linux.