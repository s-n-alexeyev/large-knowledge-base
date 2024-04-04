## Arch
---
>Ставим шрифт и скрипт для правильного отображения
```shell
yay -S noto-color-emoji-fontconfig noto-fonts-emoji
fc-cache -vf
```

>Альтернатива для ARCH значки от MacOS
```shell
yay -S ttf-apple-emoji
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

##  Debian
---
>Шрифт
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

![](data:image/png;base64,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)

