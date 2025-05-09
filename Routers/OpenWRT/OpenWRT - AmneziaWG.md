# Установка AmneziaWG на OpenWRT-устройстве

Подразумевается что у вас уже есть сервер AmneziaVPN 

**Если у вас на роутере установлена версия OpenWrt ниже чем 23.05, то следует обновиться!**
Скачайте необходимые IPK-пакеты по любой из ссылок:

1. [https://github.com/lolo6oT/awg-openwrt/releases](https://github.com/lolo6oT/awg-openwrt/releases)
2. [https://github.com/Slava-Shchipunov/awg-openwrt/releases](https://github.com/Slava-Shchipunov/awg-openwrt/releases)

Нужно скачать 3 файла под вашу платформу (архитектура процессора, который установлен в роутере):

```
kmod-amneziawg.ipk
amneziawg-tools.ipk
luci-proto-amneziawg.ipk (либо luci-app-amneziawg.ipk)
```

Откройте в браузере панель управления вашим OpenWRT-роутером и залогиньтесь.

Перейдите на вкладку `System/Software` и нажмите на `"Update lists..."`. Дождитесь обновления списка пакетов.

На той же вкладке `System/Software` нажмите на `"Upload Package..."` и последовательно установите все 3 ранее скаченные IPK-файла.

Перезагрузите роутер.

После входа в LuCI должен появится новый раздел `Status/AmneziaWG` (либо `VPN/AmneziaWG`).

## `Network/Interfaces`

Переходим в раздел `Network/Interfaces` и нажимаем кнопку `Add new interface...`

В появившемся окне указываем название `AWG` и тип `AmneziaWG VPN`. После нажатия кнопки `Create Interface` появится окно `Interfaces/AWG`.

### `Interfaces/AWG/General Settings`

В окне `Interfaces/AWG` перейдите на закладку `General Settings`.

- Значение "Protocol" = "AmneziaWG VPN"
- Значение "Bring up on boot" = `enabled`
- Значение "Private Key" возьмите из файла `my_router.conf` (параметр "Interfaces/PrivateKey").
- Значение "Public Key" возьмите из файла `my_router.conf` (параметр "Interfaces/_PublicKey").
- Значение "Listen Port" не указывайте (пусть порт на клиенте будет случайным).
- Значение "IP-Addresses" возьмите из файла `my_router.conf` (параметр "Interfaces/Address") вместе с маской.
- Значение "No Host Routes" = `not active` **(это заставит абсолютно весь трафик идти через туннель AWG)**

**Примечание:** Если вы планируете использовать частичное перенаправление трафика (например при помощи `RuAntiBlock`, либо [podkop](https://podkop.net/docs/install/)), то значение параметра `No Host Routes` должно быть `enabled` (это заставит AWG не создавать маршруты для перенаправления трафика).

### `Interfaces/AWG/Advanced Settings`

Переходим на вкладку `Advanced Settings`.

- Значение "MTU" = 1420
- Значение "Use default gateway" = `enabled`
- Значение "Use custom DNS servers" = "8.8.8.8" (будем работать в обход провайдерского DNS).

### `Interfaces/AWG/AmneziaWG Settings`

Переходим на вкладку `AmneziaWG Settings`.

- Значение "Jc" возьмите из файла `my_router.conf` (параметр "Interfaces/Jc").
- Значение "Jmin" возьмите из файла `my_router.conf` (параметр "Interfaces/Jmin").
- Значение "Jmax" возьмите из файла `my_router.conf` (параметр "Interfaces/Jmax").
- Значение "S1" возьмите из файла `my_router.conf` (параметр "Interfaces/S1").
- Значение "S2" возьмите из файла `my_router.conf` (параметр "Interfaces/S2").
- Значение "H1" возьмите из файла `my_router.conf` (параметр "Interfaces/H1").
- Значение "H2" возьмите из файла `my_router.conf` (параметр "Interfaces/H2").
- Значение "H3" возьмите из файла `my_router.conf` (параметр "Interfaces/H3").
- Значение "H4" возьмите из файла `my_router.conf` (параметр "Interfaces/H4").

### `Interfaces/AWG/Peers`

Переходим на вкладку `Peer` и нажимаем кнопку `Add Peer`, что бы появилось окно `Interfaces/AWG/Peers`.

В появившемся окне `Interfaces/AWG/Peers` указываем:

- Значение "Peer disabled" = not active
- Значение "Description" = "my_router" (можете любое название указать).
- Значение "Peer disabled" = `not active`
- Значение "Public Key" возьмите из файла `my_router.conf` (параметр "Peer/PublicKey").
- Значение "Private Key" не указывайте ничего.
- Значение "Preshared Key" не указывайте ничего.
- Значение "Allowed IPs" = "0.0.0.0/0"
- Значение "Route Allowed IPs" = `not active`
- Значение "Endpoint Host" возьмите из файла `my_router.conf` (параметр "Peer/Endpoint") только IP-адрес.
- Значение "Endpoint Port" возьмите из файла `my_router.conf` (параметр "Peer/Endpoint") только номер порта.
- Значение "Persistent Keep Alive" = 60 (можете указать иное значение).

После нажатия кнопки "Save" в списке Peers появится новая строка с именем, которое было указано в поле "Description".

Далее снова нажимайте "Save", что бы интерфейс `AWG` создался.

В текущем окне `Network/Interfaces` нажмите кнопку `Save & Apply`, что бы ваши настройки сохранились и применились.

![](/Media/Pictures/OpenWRT_AmneziaWG/a4053d4c749473542a983948da4edb06_MD5.png]]

После добавления нового интерфейса AWG на страничке `Status/AmneziaWG` (либо на `VPN/AmneziaWG`) появится новое соединение с именем "my_router".

При правильной настройке и работающем VDS-сервере сражу же должны появиться удачные рукопожатия (Latest handshake).

![](/Media/Pictures/OpenWRT_AmneziaWG/ea1f45f786ca686154823ea71de050db_MD5.png)

Для проверки работоспособности можно в терминале ввести команду `ping -I AWG facebook.com`

![](/Media/Pictures/OpenWRT_AmneziaWG/6fc8af2d0b08f076e84c4013d36e81da_MD5.png]]

## `Network/Firewall/General Settings`

Теперь нужно перейти на вкладку `Network/Firewall/General Settings` и нажать кнопку "Add" (в разделе `Zones`).

### `Firewall - Zone settings`

В появившемся окне `Firewall - Zone settings` нужно заполнить поля на вкладке `General Settings`:

- Значение "Name" = "awg"
- Значение "Input" = "reject"
- Значение "Output" = "accept"
- Значение "Forward" = "reject"
- Значение "Masquerading" = enabled
- Значение "MSS clamping" = enabled
- Значение "Covered networks" = "AWG"
- Значение "Allow forward to destination zones" = пусто
- Значение "Allow forward from source zones" = "lan"

Нажимаем кнопку "Save".

В окне `"Network/Firewall"` нажимаем кнопку "Save & Apply", что бы ваши настройки сохранились и применились.

Теперь в разделе `Zones` можно наблюдать новые правила для трафика.

![](/Media/Pictures/OpenWRT_AmneziaWG/4d0c191f28ccef264772fc85a9759ec3_MD5.png]]

**После этого можно приступать к настройке `RuAntiBlock`, либо к настройке [podkop](https://podkop.net/docs/install/)'а.**
