2025-01-05

[Источник](https://openwrt.org/docs/guide-user/services/vpn/tailscale/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

Tailscale создает виртуальную сеть между хостами. Он может использоваться как простой механизм для удаленного администрирования без пересылки портов или быть настроенным таким образом, чтобы узлы в вашей виртуальной сети могли проксировать трафик через подключенные устройства как временный VPN.

Вы можете узнать больше о том, как работает Tailscale [тут](https://tailscale.com/blog/how-tailscale-works/ "https://tailscale.com/blog/how-tailscale-works/").
### Установка

```bash
opkg update
opkg install tailscale
```

Обратите внимание, что в зависимости от вашей версии OpenWRT пакет может быть устаревшим и не содержать обновлений безопасности. Вы можете найти инструкции о том, как обновиться до последней версии пакета Tailscale на странице вашего административного консоли Tailscale.
### Подготовительная настройка

После установки Tailscale выполните команду ниже и завершите регистрацию устройства, вставив предоставленную ссылку в веб-браузер и аутентифицируясь с помощью поддерживаемого метода.

```bash
tailscale up
```

После регистрации соединение устройства можно просмотреть с помощью команды "статус":

```bash
tailscale status
```

Дополнительная конфигурация может потребоваться для взаимодействия с другими машинами вашего Tailnet в зависимости от ваших стандартных правил пересылки. Ниже приведены инструкции, которые можно использовать для добавления нового неуправляемого интерфейса и зоны брандмауэра, чтобы вы могли классифицировать и применять правила пересылки к трафику Tailscale.

Создайте новый неуправляемый интерфейс через LuCI.: **Network** → **Interfaces** → **Add new interface**
- Name: **tailscale**  
- Protocol: **Unmanaged**  
- Device: **tailscale0**

Проверьте, что интерфейсу был назначен ваш адрес Tailscale:

```bash
ip address show tailscale0
```

Если адрес не был назначен (версии Tailscale до 1.58.2-1):

Создать новую зону брандмауэра через LuCI: **Network** → **Firewall** → **Zones** → **Add**

- Name: **tailscale**  
- Input: **ACCEPT** (default)  
- Output: **ACCEPT** (default)  
- Forward: **ACCEPT**  
- Masquerading: **on**  
- MSS Clamping: **on**  
- Covered networks: **tailscale**  
- Allow forward to destination zones: Выберите ваш **LAN** (и/или другие внутренние зоны или Интернет, если вы планируете использовать этот устройство как выходной узел).)  
- Allow forward from source zones: Выберите ваш **LAN** (или другие внутренние зоны, или оставьте пустым, если не хотите маршрутизировать трафик ЛАН на других хостах Tailscale).  

Нажми **Save & Apply**
### Доступ к OpenWrt через SSH

Если требуется доступ по SSH к OpenWrt через Tailscale, настройте перенаправление портов с созданного интерфейса Tailscale и локальной сети на локальный IP-адрес OpenWrt (по умолчанию 192.168.1.1) и порт 22 как для входящих, так и для исходящих соединений.
### Проблема iptables-nft

Начиная с версии OpenWrt 22.03 и позднее, используется [nftables](https://openwrt.org/docs/guide-user/firewall/misc/nftables "docs:guide-user:firewall:misc:nftables") (заменяющий iptables) в качестве бэкенда для [firewall4](https://openwrt.org/releases/22.03/notes-22.03.0#firewall4_based_on_nftables "releases:22.03:notes-22.03.0"). Tailscale самостоятельно не может автоматически настроить nftables, что мешает демону tailscale инициализироваться правильно и пересылать трафик. Необходимо установить дополнительные пакеты (версии OpenWrt 22 или 23):

```bash
opkg install iptables-nft kmod-ipt-conntrack kmod-ipt-conntrack-extra kmod-ipt-conntrack-label kmod-nft-nat kmod-ipt-nat

# Пакеты kmod-ipt-conntrack поступили из https://github.com/openwrt/openwrt/issues/13859
```

Версии 22.x только:

Перезапустить демона.

```bash
service tailscale restart
```

Проверьте, чтобы не возникало ошибок ядра:

```bash
tailscale status
```

Завершите настройку как обычно.

### Настройка подсети маршрутизатора/выходного узла

Чтобы Tailscale хорошо сотрудничал с LuCI, вам нужно создать новый управляемый интерфейс и зону брандмауэра для Tailscale.

- Добавьте интерфейс и зону брандмауэра в соответствии с разделом [Initial Setup](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#initial_setup "docs:guide-user:services:vpn:tailscale:start ↵").  
- Перезапустите `tailscale` и добавьте маршруты, которые вы хотите рекламировать пирсам, используя опцию `--advertise-routes` с запятой разделённым списком адресов сетей и CIDR. Опция `--accept-routes` будет управлять добавлением статических маршрутов для других подсетей в вашем tailnet.

```bash
tailscale up --advertise-routes=10.0.0.0/24,10.0.1.0/24 --accept-routes
```

Вы также можете использовать здесь параметр `--advertise-exit-node`, чтобы предложить вашей сети Tailscale как маршруты подсетей, так и шлюз для Интернета.

```bash
tailscale up --advertise-routes=10.0.0.0/24,10.0.1.0/24 --accept-routes --advertise-exit-node
```

>[!warning] Если вы используете OpenWrt версии 22.03, вам также потребуется указать `--netfilter-mode=off`. Для более поздних версий его не следует включать.

- Open the [Machines](https://login.tailscale.com/admin/machines "https://login.tailscale.com/admin/machines") page in the Tailscale admin interface. Once you've found the machine from the ellipsis icon menu, open the `Edit route settings..` panel, and approve exported routes and or enable the `Use as exit node` option.

![|200](/Media/Pictures/OpenWRT_Tailscale/d5ed117ab6ce0c0a9aa84a58495a2e45_MD5.png)

![|400](/Media/Pictures/OpenWRT_Tailscale/ddc755ae943b13551472b17a4fbd7d0b_MD5.png)

- Устройства на любом подсети должны иметь возможность маршрутизировать трафик через VPN. Если вы настроили это устройство как выходной узел, оно теперь будет доступно в вашем приложении Tailscale как `Выходной Узел`. Вы можете проверить подключение с помощью инструментов типа `ping` или `traceroute`.

### Перенаправление сетевого трафика через выходной узел

Использовать устройство в качестве шлюза VPN можно, настроив Tailscale для использования выходного узла. Это перенаправит всю трафик с локальной сети через ваш выходной узел.

>[!warning]  If you're using OpenWrt == 22.03 you will also need to specify `--netfilter-mode=off`. For versions 23+ do _NOT_ include netfilter-mode.

```bash
tailscale up --exit-node=MY-EXIT-NODE --exit-node-allow-lan-access=true
```

Добавьте интерфейс и зону брандмауэра в соответствии с разделом [Начальная настройка](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#initial_setup "docs:guide-user:services:vpn:tailscale:start ↵").

- Отключить пересылку пакетов по умолчанию: **Network** → **Firewall** → **General Settings**  
    - Forward: **reject**  
- Disable LAN-to-WAN forwarding: **Network** → **Firewall** → **Zones** → **lan** → **Edit**  
    - Разрешить пересылку в зоны назначения: убедитесь, что ваша зона **WAN** **не отмечена**..  
- Включить Tailscale NAT: **Network** → **Firewall** → **Zones** → **tailscale** → **Edit**
    - Разрешить пересылку в зоны назначения: Не указано (все не отмечены)  
    - Убедитесь, что выбрана опция "Маскировка" (это позволяет трафику с локальной сети появляться как адрес Tailscale роутера (подобно работе WAN)).
- Включить пересылку сети от LAN в Tailscale **Сеть**→ **Firewall** → **Zones** → **lan** → **Edit**
    - Разрешить пересылку в зоны назначения: убедитесь, что ваша зона **Tailscale** выбрана.

Вы можете проверить, что все трафик перенаправляется через ваш удалённый выходной узел Tailscale, запустив traceroute. Вы должны увидеть ваш узел выхода Tailscale во втором или третьем сегменте маршрута. Если ваш роутер OpenWRT, подключенный к Tailscale, отправляет всё трафик на выходной узел, но не клиентам локальной сети:
- Проверьте еще раз, чтобы зона фаервола для локальной сети не включала широковещательную сеть для пересылки назначения.  
- У вас могут быть неожиданные устаревшие правила iptables или nftables. Перезагрузите ваше устройство OpenWRT, чтобы получить чистый запуск и применение правил.

