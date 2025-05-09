```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

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
## Network/Interfaces

Переходим в раздел `Network/Interfaces` и нажимаем кнопку `Add new interface...`

В появившемся окне указываем название `AWG` и тип `AmneziaWG VPN`. После нажатия кнопки `Create Interface` появится окно `Interfaces/AWG`.

### Interfaces/AWG/General Settings

В окне `Interfaces/AWG` перейдите на закладку `General Settings`.

- Значение "Protocol" = "AmneziaWG VPN"
- Значение "Bring up on boot" = `enabled`
- Значение "Private Key" возьмите из файла `my_router.conf` (параметр "Interfaces/PrivateKey").
- Значение "Public Key" возьмите из файла `my_router.conf` (параметр "Interfaces/_PublicKey").
- Значение "Listen Port" не указывайте (пусть порт на клиенте будет случайным).
- Значение "IP-Addresses" возьмите из файла `my_router.conf` (параметр "Interfaces/Address") вместе с маской.
- Значение "No Host Routes" = `not active` **(это заставит абсолютно весь трафик идти через туннель AWG)**

**Примечание:** Если вы планируете использовать частичное перенаправление трафика (например при помощи `RuAntiBlock`, либо [podkop](https://podkop.net/docs/install/)), то значение параметра `No Host Routes` должно быть `enabled` (это заставит AWG не создавать маршруты для перенаправления трафика).

### Interfaces/AWG/Advanced Settings

Переходим на вкладку `Advanced Settings`.

- Значение "MTU" = 1420
- Значение "Use default gateway" = `enabled`
- Значение "Use custom DNS servers" = "8.8.8.8" (будем работать в обход провайдерского DNS).

### Interfaces/AWG/AmneziaWG Settings

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

### Interfaces/AWG/Peers

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

![](/Media/Pictures/OpenWRT_AmneziaWG/a4053d4c749473542a983948da4edb06_MD5.png)

После добавления нового интерфейса AWG на страничке `Status/AmneziaWG` (либо на `VPN/AmneziaWG`) появится новое соединение с именем "my_router".

При правильной настройке и работающем VDS-сервере сражу же должны появиться удачные рукопожатия (Latest handshake).

![](/Media/Pictures/OpenWRT_AmneziaWG/ea1f45f786ca686154823ea71de050db_MD5.png)

Для проверки работоспособности можно в терминале ввести команду `ping -I AWG facebook.com`

![](/Media/Pictures/OpenWRT_AmneziaWG/6fc8af2d0b08f076e84c4013d36e81da_MD5.png)

## Network/Firewall/General Settings

Теперь нужно перейти на вкладку `Network/Firewall/General Settings` и нажать кнопку "Add" (в разделе `Zones`).

### Firewall - Zone settings

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

![](/Media/Pictures/OpenWRT_AmneziaWG/4d0c191f28ccef264772fc85a9759ec3_MD5.png)

**После этого можно приступать к настройке `RuAntiBlock`, либо к настройке [podkop](https://podkop.net/docs/install/)'а.**

---
# Автоматическая настройка AmneziaWG для OpenWRT версии 23.05.0 и более новых

Для автоматической настройки рекомендую использовать [скрипт](https://github.com/itdoginfo/domain-routing-openwrt) от пользователя itdog. Этот скрипт позволяет автоматически скачать нужные пакеты из собранных здесь и настроить [точечный обход блокировок по доменам](https://habr.com/ru/articles/767464/).

Если же вам нужно только установить пакеты, я добавил скрипт amneziawg-install - он автоматически скачает пакеты из этого репозитория под ваше устройство (только для стабильной версии OpenWRT), а также предложит сразу настроить интерфейс с протоколом AmneziaWG. Если пользователь согласится, нужно будет ввести параметры конфига, которые запросит скрипт. При этом скрипт создаст интерфейс, настроит для него правила фаерволла, а также **включит перенаправление всего траффика через тунель AmneziaWG** (установит в настройках Peer галочку Route Allowed IPs). Для запуска скрипта подключитесь к роутеру по SSH, введите команду и следуйте инструкциям на экране:

```shell
sh <(wget -O - https://raw.githubusercontent.com/Slava-Shchipunov/awg-openwrt/refs/heads/master/amneziawg-install.sh)
```

# Сборка пакетов для всех устройств, поддерживающих OpenWRT


В репозиторий добавлен скрипт, который парсит данные о поддерживаемых платформах со страницы OpenWRT и автоматически запускает сборку пакетов AmneziaWG для всех устройств. На данный момент я собрал пакеты для всех устройств для OpenWRT версий:

1. [23.05.0](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.0)
2. [23.05.1](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.1)
3. [23.05.2](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.2)
4. [23.05.3](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.3)
5. [23.05.4](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.4)
6. [23.05.5](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v23.05.5)

И собрал пакеты для популярных устройств для OpenWRT [SNAPSHOT](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/SNAPSHOT)

Также запускал сборку для версии [22.03.7](https://github.com/Slava-Shchipunov/awg-openwrt/releases/tag/v22.03.7), но там для двух платформ сборка завершилась ошибкой. Так как это достаточно старая версия OpenWRT, я не стал разбираться, в чем проблема.

В дальнейшем при выходе новых релизов OpenWRT будут автоматически создаваться релизы с пакетами AmneziaWG и запускаться сборка пакетов под все устройства, поддерживаемые новой версией. Github action для проверки появления нового релиза запускается автоматически раз в 3 дня, а также может быть запущен вручную.

## Автоматическая сборка пакетов для SNAPSHOT версии

В репозитории настроен github action, который запускается каждые 4 часа и проверяет [страницу снапшотов](https://downloads.openwrt.org/snapshots/targets/) сайта OpenWRT. При этом, если для какой-то платформы обнаруживается снапшот с более новой версией ядра, запускается сборка пакетов под эту платформу, а новые файлы заменяют старые. В целях экономии ресурсов и ускорения процесса сборки, пакеты собираются только для популярных платформ, которые указаны в массиве `SNAPSHOT_SUBTARGETS_TO_BUILD` в файле index.js.

## Выбор пакетов для своего устройства

В соответствии с пунктом [Указываем переменные для сборки](https://github.com/itdoginfo/domain-routing-openwrt/wiki/Amnezia-WG-Build#%D1%83%D0%BA%D0%B0%D0%B7%D1%8B%D0%B2%D0%B0%D0%B5%D0%BC-%D0%BF%D0%B5%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%BD%D1%8B%D0%B5-%D0%B4%D0%BB%D1%8F-%D1%81%D0%B1%D0%BE%D1%80%D0%BA%D0%B8) определить `target` и `subtarget` вашего устройства. Далее перейти на страницу релиза, соответствующего вашей версии OpenWRT, затем поиском по странице (Ctrl+F) найти 3 пакета, название которых оканчивается на `target_subtarget.ipk`, соответствующие вашему устройству.

## Как запустить сборку для всех поддерживаемых устройств


1. Создать форк этого репозитория
2. Переключиться на вкладку Actions и включить Github actions (по умолчанию для форков они выключены)
3. Затем перейти на вкладку Code => Releases (в правой части экрана) => Draft a new release
4. Нажать Choose a tag и создать новый тег формата vX.X.X, где вместо X.X.X нужно подставить требуемую версию OpenWRT, например, v23.05.4
5. Выбрать в качестве target ветку `master`
6. Ввести Release title
7. Нажать внизу зеленую кнопку Publish release

Для публичных репозиториев Github предоставляет неограниченное по времени использование раннеров, у меня запускалось до 20 параллельных джоб. Каждая джоба выполняется около 2 часов, общее время на сборку около 10 часов. В случае возникновения ошибок в одной джобе, будут отменены все незавершенные - в этом случае на вкладке Actions можно выбрать неудавшийся запуск и нажать Re-run failed jobs

## Сборка пакетов под определенную платформу


Как запустить сборку пакетов для определенной платформы можно посмотреть в [инструкции на вики](https://github.com/itdoginfo/domain-routing-openwrt/wiki/Amnezia-WG-Build). Сборка под одно устройство займет около 2 часов.
