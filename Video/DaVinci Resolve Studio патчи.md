```table-of-contents
title: 
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

### 18.6.3
```bash
sudo perl -pi -e 's/\x74\x7b\xe8\x61\x26\x00\x00/\xeb\x7b\xe8\x61\x26\x00\x00/g' /opt/resolve/bin/resolve
```

-----
## Сжатие h264
Можно почитать https://trac.ffmpeg.org/wiki/Encode/H.264
Для примера восьмиминутный клип, рендерим его в h264/mp3 при дефолтных настройках и получил файл: __2.3G clip02.mov__
Потом в параметрах качества указалываем ограничение до 8000 Kbit/s, preset - very slow, tuning - high quality, two pass - full и получил файл:
__505M clip03.mov__
Как видите разница огромная. Поэтому рекомендую поэкспериментировать один раз и подобрать приемлемые параметры для Вас.

-----
## Ошибка *undefined symbol: g_string_free_and_steal*

*/opt/resolve/bin/resolve: symbol lookup error: /usr/lib/libpango-1.0.so.0: undefined symbol: g_string_free_and_steal*

Решение:
```sh
sudo cp /lib64/libglib-2.0.* /opt/resolve/libs/
```
или
```sh
LD_PRELOAD=/usr/lib64/libglib-2.0.so /opt/resolve/bin/resolve
```

