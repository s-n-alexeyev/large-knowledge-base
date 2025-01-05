2025-01-05

**Устанавливаем необходимые зависимости**

>Для компиляции Nano потребуются компилятор и инструменты сборки.
```bash
sudo apt update
sudo apt install build-essential libncurses-dev gettext wget
```

 **Скачиваем исходный код Nano**

>Переходим на официальный сайт [Nano](https://www.nano-editor.org/download.php) или скачайте архив с исходным кодом напрямую:
```bash
wget https://www.nano-editor.org/dist/v8/nano-8.3.tar.xz
```

 >Распаковываем архив:
```bash
tar -xvf nano-8.3.tar.xz
cd nano-8.3
```

**Настраиваем сборку Nano**

>Команда конфигурирования:
```bash
./configure
```

>Собираем и устанавливаем Nano:
```bash
make
sudo make install
```

**Проверяем установленную версию**

>После успешной установки проверьте версию Nano:
```bash
nano --version
```

**Настройка подсветки синтаксиса**

После компиляции Nano, подсветку синтаксиса нужно настроить.
Файлы подсветки синтаксиса можно найти в исходном коде Nano. Они находятся в директории `syntax/

>Для копирования содержимого директории `syntax` вместе с её поддиректориями в `/usr/local/share/nano/`, создавая при этом необходимые каталоги, можно использовать команду **`cp`** с опцией `-r` (рекурсивное копирование).
```bash
sudo cp -r syntax/ /usr/local/share/nano/
```

>Подключение файлов подсветки текущего пользователя:
```bash
echo "include /usr/local/share/nano/*.nanorc" >> ~/.nanorc
```