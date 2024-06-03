```shell
opkg update
```

```shell
opkg remove dnsmasq
```

```shell
opkg install dnsmasq-full
```

С помощью приведенной выше команды вы получите сообщение «Собранные ошибки», которое не является конкретной и важной ошибкой. По сути, это уведомление.

Продолжайте команды следующим образом:

```
opkg install kmod-nft-socket kmod-nft-tproxy kmod-nft-nat wget-ssl
```

```shell
wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
```

```shell
opkg-key add passwall.pub
```

Для следующей команды выберите и скопируйте все 7 строк, вставьте их в командную строку и нажмите Enter.

```shell
read release arch << EOF
$(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
for feed in passwall_luci passwall_packages passwall2; do
  echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done
```

и следующая команда:

```shell
opkg update
```

Как и раньше, он снова выдает сообщение «Собраны ошибки», что не важно. И мы снова набираем следующую команду.

✅ Обновление 09:54-1403/01/05: К сожалению, в последних обновлениях возникают проблемы с установкой PassWall 2. Кроме того, протокол Брука был удален начиная с версии 1.28-2. Я не знаю причину, и я думаю, что это бизнес-проблемы. По этой причине я разделил способ установки на 2 режима. А и Б.

#### А- Установка PassWall 2 с возможностью протокола Brook

Используйте следующие 3 команды:

```shell
wget https://github.com/xiaorouji/openwrt-passwall2/releases/download/1.28-1/luci-23.05_luci-app-passwall2_1.28-1_all.ipk
```

```
opkg install luci-۲۳.۰۵_luci-app-passwall2_1.۲۸-۱_all.ipk
```

```
opkg update
```

#### Б- Установка PassWall 2, последней версии, без возможности протокола Brook

Последняя версия PassWall 2 будет установлена ​​для вас с помощью следующих команд:

```shell
opkg install luci-app-passwall2
```

Иногда из-за ситуации с Интернетом во время установки может возникнуть ошибка. В этом случае повторяйте приведенную выше команду до тех пор, пока установка не завершится без ошибок и без получения сообщения об ошибке.

И затем следующая команда:

```
opkg update
```

Другой способ — установить версию Brook, а затем выполнить обновление из OpenWrt и меню «Система/Программное обеспечение/Списки обновлений». Та же часть, которая используется для обновления всех приложений OpenWrt.

Возвращаемся в браузер. Если мы вошли в OpenWrt, выходим из системы и авторизуемся снова. В OpenWrt было добавлено новое меню под названием «Сервисы», и PassWall 2 находится в этом меню.

Теперь прочитайте следующий абзац: «Настройка PaaWall 2 для пропуска фильтрации».