## Предупреждение!

Будьте внимательны, делайте резервную копию! При неправильных действиях можно повредить загрузку системы!
## Правим Grub

```shell
sudo nano /etc/default/grub
```

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 systemd.show_status=auto splash rd.udev.log_priority=3 vt.global_cursor_default=0"

#nvidia - добавть nvidia-drm.modeset=1
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 systemd.show_status=auto splash rd.udev.log_priority=3 vt.global_cursor_default=0 nvidia-drm.modeset=1"
```

> Обновляем Grub
```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
## Правим mkinitcpio.conf

```shell
sudo nano /etc/mkinitcpio.conf
```

```ini
HOOKS=(base udev autodetect kms modconf block keyboard keymap consolefont plymouth resume filesystems)

#в случае intel 
MODULES=(i915)

#в случае nvidia
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

>Смотрим доступные ядра
```shell
ls /etc/mkinitcpio.d/
```

>Сборка ядра,  где `linux` - ваше ядро
```shell
sudo mkinitcpio -p linux
```
## Выбор темы

Plymouth настраивается через файл `/etc/plymouth/plymouthd.conf`. Значения по умолчанию описаны в файле `/usr/share/plymouth/plymouthd.defaults`.

Plymouth поставляется со следующими темами:

1. **BGRT**: Вариант Spinner, который использует OEM-логотип, если он доступен (BGRT означает Boot Graphics Resource Table)
2. **Fade-in**: "Простая тема с затухающими и разгорающимися мерцающими звездами"
3. **Glow**: "Производственная тема, показывающая процесс загрузки в виде круговой диаграммы"
4. **Script**: "Пример скрипта" (Несмотря на описание, выглядит очень симпатичной темой с логотипом Arch)
5. **Solar**: "Космическая тема, голубая звезда с протуберанцами"
6. **Spinner**: "Простая тема с вращающимся индикатором загрузки"
7. **Spinfinity**: "Простая тема, показывающая вращающийся знак бесконечности в центре экрана"
8. **Tribar**: "Текстовый режим с трёхцветной полосой прогресса"
9. _(**Text**: "Текстовый режим с трёхцветной полосой прогресса")_
10. _(**Details**: "Резервная тема с подробностями загрузки")_

>По умолчанию используется тема **bgrt**. Чтобы выбрать другую, пропишите её в настройках
```shell
sudo nano /etc/plymouth/plymouthd.conf
```

>Например
```ini
[Daemon]
Theme=fade-in
```

>Или выберите тему с помощью команды:
```shell
plymouth-set-default-theme -R _тема_
```

При каждой смене темы необходимо пересобирать `initrd`. Это произойдёт автоматически при выборе темы командой `plymouth-set-default-theme` с опцией `-R` (в противном случае [пересоберите образ initramfs](https://wiki.archlinux.org/title/Mkinitcpio_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)#%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BE%D1%87%D0%BD%D0%BE%D0%B3%D0%BE_%D0%BE%D0%B1%D1%80%D0%B0%D0%B7%D0%B0 "Mkinitcpio (Русский)") самостоятельно).
## Установка новых тем

Дополнительные темы доступны в [AUR](https://wiki.archlinux.org/title/Arch_User_Repository_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9) "Arch User Repository (Русский)"). [[1]](https://aur.archlinux.org/packages?K=plymouth-theme-) Также [plymouth-kcm](https://archlinux.org/packages/?name=plymouth-kcm) добавляет интеграцию с настройками KDE Plasma и предлагает темы, отсутствующие в AUR.

>Список установленных тем можно получить командой:
```shell
plymouth-set-default-theme -l
# или
ls /usr/share/plymouth/themes
```

`bgrt  details  fade-in  glow  script  solar  spinfinity  spinner  text  tribar`
### Задержка отображения

>Plymouth позволяет добавить задержку перед отображением графического экрана загрузки:
```shell
sudo nano /etc/plymouth/plymouthd.conf
```

```ini
[Daemon]
ShowDelay=5
```

Если система загружается настолько быстро, что загрузочная анимация успевает лишь моргнуть до запуска DM, можно установить задержку появления экрана загрузки в параметре `ShowDelay` (в секундах) больше чем длительность загрузки системы, чтобы вместо мерцания отображался просто пустой экран. По умолчанию время задержки 0 секунд.
### HiDPI

>Пропишите коэффициент масштабирования (целое число) в настройках:
```shell
sudo nano /etc/plymouth/plymouthd.conf
```

```ini
DeviceScale=_коэффициент-масштабирования_
```

и пересобираем initrd.
## Дополнительно

>Для абсолютно чистой загрузки правим на свой страх и риск
```shell
sudo nano /etc/grub.d/10_linux
```

в функции `linux_entry ()` находим `'echo '$(echo "$message" | grub_quote)'` и удаляем

>Проделать изменение можно скриптом запущенным от root
```shell
#!/bin/bash

# Искомая строка
search_string="'\$(echo \"\$message\" | grub_quote)'"

# Путь к файлу
file_path='/etc/grub.d/10_linux'

# Проверка существования файла
if [ ! -f "$file_path" ]; then
    echo "Файл $file_path не существует."
    exit 1
fi

# Удаление строки из файла
sed -i "/$search_string/d" "$file_path"

echo "Строка '$search_string' удалена из файла $file_path."
```

>После чего заново обновляем Grub
```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```