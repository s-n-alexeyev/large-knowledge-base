>устанавливаем пакет для работы от root
```sh
sudo apt install gksu
```

>создаем папку, если таковой нет
```sh
mkdir -p ~/.local/share/file-manager/actions/
```

>открыть папку от root
```
cat<<EOF>>~/.local/share/file-manager/actions/open-folder-as-root.desktop
[Desktop Entry]
Type=Action
Tooltip=Open Folder As Root
Name=Open Folder As Root
Name[ru]=Открыть папку с правами root
Profiles=profile-zero;
Icon=gtk-dialog-authentication

[X-Action-Profile profile-zero]
MimeTypes=inode/directory;
Exec=gksu /usr/bin/pcmanfm %u
Name=Default profile
EOF
```

>открыть папку или текстовый файл (в leafpad) как root
```
cat<<EOF>>~/.local/share/file-manager/actions/open-as-root.desktop
[Desktop Entry]
Type=Action
Profiles=profile-zero;profile-1;profile-2;
Name[en_US]=Open As Root
Name[en]=Open As Root
Name[C]=Open As Root
Tooltip[en_US]=Open As Root
Tooltip[en]=Open As Root
Tooltip[C]=Open As Root
ToolbarLabel[en_US]=Open As Root
ToolbarLabel[en]=Open As Root
ToolbarLabel[C]=Open As Root

Icon[en_US]=stop
Icon[en]=stop
Icon[C]=stop

[X-Action-Profile profile-zero]
MimeTypes=inode/directory;
Exec=gksu /usr/bin/pcmanfm %u
Name[en_US]=Open Folder As Root
Name[en]=Open Folder As Root
Name[C]=Open Folder As Root

[X-Action-Profile profile-1]
MimeTypes=all/allfiles;!text/plain;
Exec=gksu /usr/bin/pcmanfm %d
Name[en_US]=Open Folder As Root
Name[en]=Open Folder As Root
Name[C]=Open Folder As Root

[X-Action-Profile profile-2]
MimeTypes=text/plain;
Exec=gksu /usr/bin/leafpad %f
Name[en_US]=Edit File As Root
Name[en]=Edit File As Root
Name[C]=Edit File As Root
EOF
```

>установить в качестве обоев
```
cat<<EOF>>~/.local/share/file-manager/actions/set-as-wallpaper.desktop
[Desktop Entry]
Type=Action
ToolbarLabel[en_US]=Set As Wallpaper
ToolbarLabel[en]=Set As Wallpaper
ToolbarLabel[C]=Set As Wallpaper
Name[en_US]=Set As Wallpaper
Name[en]=Set As Wallpaper
Name[C]=Set As Wallpaper
Profiles=profile-zero;
Icon=gtk-orientation-landscape

[X-Action-Profile profile-zero]
MimeTypes=image/*;
Exec=pcmanfm -w %f
Name[en_US]=Default profile
Name[en]=Default profile
Name[C]=Default profile
EOF
```
Сохраняем, меняем сеанс ("выйти" или "сменить пользователя") и проверяем, появился ли новый пункт в контекстном меню pcmanfm. Проверять на любой папке не из каталога /home.