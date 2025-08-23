```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
---
## Патчи
### 17
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x81/\xeb\x7b\xe8\x81/g' /opt/resolve/bin/resolve
```

### 18
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x41\x20/\xeb\x7b\xe8\x41\x20/g' /opt/resolve/bin/resolve
```

### 18.1
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x31\x1f\x00\x00/\xeb\x7b\xe8\x31\x1f\x00\x00/g' /opt/resolve/bin/resolve
```

### 18.1.1
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x21\x1f\x00\x00/\xeb\x7b\xe8\x21\x1f\x00\x00/g' /opt/resolve/bin/resolve
```

### 18.5
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x51\x26\x00\x00/\xeb\x7b\xe8\x51\x26\x00\x00/g' /opt/resolve/bin/resolve
```

### 18.6
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x61\x26\x00\x00/\xeb\x7b\xe8\x61\x26\x00\x00/g' /opt/resolve/bin/resolve
```

### 19
```bash
sudo /usr/bin/perl -pi -e 's/\x74\x11\xe8\x21\x23\x00\x00/\xeb\x11\xe8\x21\x23\x00\x00/g' /opt/resolve/bin/resolve
```

### 20
```bash
cd /opt/resolve/libs && sudo mkdir disabled-libraries && sudo mv libglib* libgio* libgmodule* disabled-libraries  
cd /opt/resolve/  
sudo perl -pi -e 's/\x00\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00/\x00\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00/g' bin/resolve  
sudo perl -pi -e 's/\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B\x55/\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B\x55/g' bin/resolve  
sudo echo -e "LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted\nhostid=ANY issuer=ANY customer=ANY issued=20-Mar-2025\n akey=0000-0000-0000-0000-0000_ck=00 sig=\"00\"\n" > .license/blackmagic.lic
```

### 20.1
```bash
cd /opt/resolve/libs && sudo mkdir disabled-libraries && sudo mv libglib* libgio* libgmodule* disabled-libraries  
cd /opt/resolve/  
perl -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/g' bin/resolve  
perl -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/g' bin/resolve  
perl -pi -e 's/\x74\x11\xE8\x31\x25\x00\x00\x48\x89\xC7\xE8\x09\xBA\x02\x00\x84/\x75\x11\xE8\x31\x25\x00\x00\x48\x89\xC7\xE8\x09\xBA\x02\x00\x84/g' bin/resolve
```

### Other
```bash
cd /opt/resolve  
sudo perl -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/g' bin/resolve  
sudo perl -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/g' bin/resolve  
sudo echo -e "LICENSE blackmagic davinciresolvestudio 009599 permanent uncounted\nhostid=ANY issuer=AHH customer=AHH issued=03-Apr-2024\n akey=3148-9267-1853-4920-8173_ck=00 sig=\"00\"\n" > .license/blackmagic.lic
```

---
## Сжатие h264
Можно почитать https://trac.ffmpeg.org/wiki/Encode/H.264
Для примера восьмиминутный клип, рендерим его в h264/mp3 при дефолтных настройках и получил файл: __2.3G clip02.mov__
Потом в параметрах качества указалываем ограничение до 8000 Kbit/s, preset - very slow, tuning - high quality, two pass - full и получил файл:
__505M clip03.mov__
Как видите разница огромная. Поэтому рекомендую поэкспериментировать один раз и подобрать приемлемые параметры для Вас.

-----
## Ошибка */usr/lib/libpango-1.0.so.0: undefined symbol: g_string_free_and_steal*

`/opt/resolve/bin/resolve: symbol lookup error: /usr/lib/libpango-1.0.so.0: undefined symbol: g_string_free_and_steal`

Решение:
```bash
sudo cp /lib64/libglib-2.0.* /opt/resolve/libs/
```
или
```bash
LD_PRELOAD=/usr/lib64/libglib-2.0.so /opt/resolve/bin/resolve
```

---
## Ошибка */usr/lib/libgdk_pixbuf-2.0.so.0: undefined symbol: g_task_set_static_name*

`/opt/resolve/bin/resolve: symbol lookup error: /usr/lib/libgdk_pixbuf-2.0.so.0: undefined symbol: g_task_set_static_name`

Решение:
```bash
cd /opt/resolve/libs && sudo mkdir disabled-libraries && sudo mv libglib* libgio* libgmodule* disabled-libraries
```
