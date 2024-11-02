
>Отключите и удалите старый файл подкачки (если он существует):
```bash
sudo swapoff /swapfile
sudo rm /swapfile
```

>создаем пустой файл
```bash
sudo touch /swapfile
```

>устанавливаем атрибут `nocow`
```bash
sudo chattr +C /swapfile
```

>задаем правильные права доступа для файла подкачки:
```bash
sudo chmod 600 /swapfile
```

>задаем размер, например 64GB
```bash
sudo fallocate -l 64G /swapfile
```

>форматируем файл как файл подкачки:
```bash
sudo mkswap /swapfile
```

>активируем файл подкачки:
```bash
sudo swapon /swapfile
```

>добавляем файл подкачки в /etc/fstab, чтобы он автоматически подключался при перезагрузке системы (если его там нет):
```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

> проверка файла на фрагментацию
```bash
sudo filefrag /swapfile
```

```
/swapfile: 2 extents found
```
