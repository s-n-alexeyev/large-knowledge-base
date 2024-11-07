Откройте файл конфигурации sysctl для редактирования:

```bash
sudo nano /etc/sysctl.conf
```

Добавьте следующие строки в конец файла, чтобы отключить IPv6:

```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

Примените изменения:

```bash
sudo sysctl -p
```
