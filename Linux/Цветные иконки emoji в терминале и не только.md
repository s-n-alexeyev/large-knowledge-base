
```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

# Шрифт Noto

>Для Arch/manjaro шрифт и скрипт для правильного отображения
```shell
yay -S noto-color-emoji-fontconfig noto-fonts-emoji
fc-cache -vf
```

>Для Debian/Ubuntu
```shell
sudo apt-get -y install fonts-noto-color-emoji
```

>Правим отображение
```shell
kate ~/.config/fontconfig/fonts.conf
```

>Содержимое
```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <alias>
   <family>sans-serif</family>
   <prefer>
     <family>Noto Sans</family>
     <family>Twemoji</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
   </prefer> 
 </alias>

 <alias>
   <family>serif</family>
   <prefer>
     <family>Noto Serif</family>
     <family>Twemoji</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
   </prefer>
 </alias>

 <alias>
```

## Значки от macOS

>Альтернатива для ARCH 
```shell
yay -S ttf-apple-emoji
fc-cache -vf
```

> Для других сборок значки от macOS
```bash
mkdir -p ~/.local/share/fonts && \
curl -L -o ~/.local/share/fonts/AppleColorEmoji.ttf https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf && \
fc-cache -vf
```

>Правим файл `/etc/fonts/conf.d/75-apple-color-emoji.conf`
```shell
kate /etc/fonts/conf.d/75-apple-color-emoji.conf
```

>Содержимое файла `75-apple-color-emoji.conf`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <!--
    Based on https://aur.archlinux.org/packages/ttf-twemoji

    Treat this file as a reference and modify as necessary if you are not satisfied with the results.

    This config attempts to guarantee that colorful emojis from Apple will be displayed,
    no matter how badly the apps and websites are written.

    It uses a few different tricks, some of which introduce conflicts with other fonts.
    -->


    <!--
    This adds a generic family 'emoji',
    aimed for apps that don't specify specific font family for rendering emojis.
    -->
    <match target="pattern">
        <test qual="any" name="family"><string>emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <!--
    This adds Apple Color Emoji as a final fallback font for the default font families.
    In this case, Apple Color Emoji will be selected if and only if no other font can provide a given symbol.

    Note that usually other fonts will have some glyphs available (e.g. Symbola or DejaVu fonts),
    causing some emojis to be rendered in black-and-white.
    -->
    <match target="pattern">
        <test name="family"><string>sans</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="append"><string>Apple Color Emoji</string></edit>
    </match>

    <!--
    If other fonts contain emoji glyphs, they could interfere and make some emojis rendered in wrong font (often in black-and-white).
    For example, DejaVu Sans contains black-and-white emojis, which we can remove using the following trick:
    -->
    <match target="scan">
        <test name="family" compare="contains">
            <string>DejaVu</string>
        </test>
        <edit name="charset" mode="assign" binding="same">
            <minus>
                <name>charset</name>
                <charset>
                    <range>
                        <int>0x1f600</int>
                        <int>0x1f640</int>
                    </range>
                </charset>
            </minus>
        </edit>
    </match>

    <!--
    Recognize legacy ways of writing EmojiOne family name.
    -->
    <match target="pattern">
        <test qual="any" name="family"><string>EmojiOne</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Emoji One</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiOne Color</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiOne Mozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <!--
    Use Apple Color Emoji when other popular fonts are being specifically requested.

    It is quite common that websites would only request Apple and Google emoji fonts.
    These aliases will make Apple Color Emoji be selected in such cases to provide good-looking emojis.

    This obviously conflicts with other emoji fonts if you have them installed.
    -->
    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Noto Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>NotoColorEmoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Android Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Noto Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <!--
    <match target="pattern">
        <test qual="any" name="family"><string>JoyPixels</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
    -->

    <match target="pattern">
        <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>TwemojiMozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiTwo</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Emoji Two</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiSymbols</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Symbola</string></test>
        <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
    </match>
</fontconfig>
```

>Текст со значками для проверки, просто вставляем в терминал, должны появиться значка как на картинке
```test
🤷 Person Shrugging
♡ White Heart Suit
❤ Red Heart
😂 Face With Tears of Joy
🤔 Thinking Face
😍 Smiling Face With Heart-Eyes
😊 Smiling Face With Smiling Eyes
🔥 Fire
👍 Thumbs Up
```

![](/Media/Color_Icons/image_1.png)

