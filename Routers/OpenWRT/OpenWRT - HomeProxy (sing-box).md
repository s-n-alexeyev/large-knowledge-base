
2023-09-13
[Оригинальная статья](https://habr.com/ru/articles/760622/)
```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
# Обход блокировок на OpenWRT с помощью HomeProxy (sing-box)

[HomeProxy](https://github.com/immortalwrt/homeproxy) или luci-app-homeproxy это часть проекта [ImmortalWRT](https://firmware-selector.immortalwrt.org/), графическая надстройка для [sing-box](https://habr.com/ru/articles/756178/) позволяющая настроить подключение к shadowsocks, xray, vless, vmess, trojan.

В данной статье будет рассматриваться установка luci-app-homeproxy на **OpenWRT 23.05.0-rc3** (поддерживаются версии 23.05.0 или SNAPSHOT).  
Можно использовать как чистую версию OpenWRT так и от проекта ImmortalWRT.  
Потребуется роутер со свободными **30 Мб памяти** и **минимум 256 Мб** **ОЗУ** (Работающий HomeProxy занимает **от 70Мб** **ОЗУ**).

**Оглавление:**

- **1. Установка luci-app-homeproxy**  
- **2. Настройка homeproxy**  
## 1. Установка luci-app-homeproxy

Для установки сначала необходимо добавить дополнительные репозитории от проекта ImmortalWRT (если вы используете сборку от ImmortalWRT этот шаг пропускаем)

```shell
VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '"' '{print $2}')
ARCH=$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/$VERSION_ID/packages/$ARCH/routing" >> /etc/opkg/customfeeds.conf
echo "src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/$VERSION_ID/packages/$ARCH/packages" >> /etc/opkg/customfeeds.conf
echo "src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/$VERSION_ID/packages/$ARCH/luci" >> /etc/opkg/customfeeds.conf
echo "src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/$VERSION_ID/packages/$ARCH/base" >> /etc/opkg/customfeeds.conf
```

После чего обновляем список пакетов и устанавливаем luci-app-homeproxy

```shell
opkg update && opkg install luci-app-homeproxy
```

Если установка прошла успешно, переходим к настройке.  
_При возникновении проблем, замените $VERSION_ID на значение из Releases_ [_Index of /releases/ (immortalwrt.org)_](https://downloads.immortalwrt.org/releases/) _или отредактируйте файл /etc/opkg/customfeeds.conf с учётом актуального совместимого релиза ImmortalWRT_

## 2. Настройка Homeproxy

Переходим в раздел Службы - Homeproxy

![|800](/Media/Pictures/HomeProxy/95845a17636f89ee6faf10d3603e9c49.png)

Сперва нужно добавить сервер, для этого переходим во вкладку **Node Settings**

![|800](/Media/Pictures/HomeProxy/c72806ff1925aac7cecb3f797476f9ce.png)

Нажимаем **Import share links** и добавляем конфигурацию shadowsocks ([outline](https://habr.com/ru/articles/748408/)), vless, trojan или иную.

![|800](/Media/Pictures/HomeProxy/9e6bd1c7f0b2c18c7a071ce43eb293f1.png)

После добавления нажимаем **Импорт**

![|800](/Media/Pictures/HomeProxy/3fc9e07e03f2d4236205f573edc27d43.png)

**Применяем изменения.**

В качестве Main Node выбираем добавленный сервер.  
DNS сервер на ваше усмотрение.

Routing Mode — **Global** (проксирование подключений к любым IP/ доменам, работу обхода блокировок в РФ по "**GFWList**" не проверял, теоретически это список большинства заблокированных в Китае и теперь в РФ ресурсов). **"Bypass mainland China"** и **"Only proxy mainland China"** это проксировать все адреса кроме адресов материкового Китая и и проксировать только адреса материкового Китая соответственно. **Custom Routing** - настройка проксирования согласно дополнительным правилам Access Control (ничего не проксируется по умолчанию)

![|600](/Media/Pictures/HomeProxy/896511ed5b23b7b7ba4a7be5ef25fdab.png)

Routing Ports — All Ports, если хотите перенаправлять все порты в Main Node или Common ports only (порты до 1024, всё что выше будет идти через шлюз по умолчанию).

![|600](/Media/Pictures/HomeProxy/8afd7426ce37b861219d9a431b168781.png)

![|700](/Media/Pictures/HomeProxy/9cfe79a0c2531a46e32ba25d2de89efd.png)

Proxy Mode — Redirect TCP (перенаправление только TCP трафика, согласно правилам Homeproxy, а не основного firewall).  
Redirect TCP + TProxy UDP тоже самое + проксирование UDP трафика через прокси.  
Redirect TCP + Tun UDP как Redirect TCP + TProxy UDP, но UDP трафик идёт через интерфейс singtun и регулируется основными правилами firewall.  
Tun TCP/UDP — весь трафик регулируется правилами firewall, **этот вариант выбирал я, чтобы использовать его с BGP**.  
Поддержка IPv6 — по умолчанию выключена, при включении могут быть сложности с обходом блокировок, т.к. списки BGP и Access List в первую очередь ориентированы на IPv4, поэтому включайте на своё усмотрение.

![|400](/Media/Pictures/HomeProxy/b1d5db76c61be324755f30f4889e33f1.png)

При выборе Tun TCP/UDP появится пункт Main UDP Node — UDP трафик можно направлять в тот же нод (**Same as main node**), в другой из списка или направлять в шлюз по умолчанию (**Отключить**).  
Если вы выбрали что‑то кроме Tun TCP/UDP тогда нужно настроить Access Control, переходим туда.

![|700](/Media/Pictures/HomeProxy/49a679ecbaa9bcd6e904789ce3962372.png)

Здесь настраивается входной и выходной интерфейс, по умолчанию остаётся пустым и определяется автоматически

![|600](/Media/Pictures/HomeProxy/64efa9d35f6b948ec0e72f9f3df16569.png)

Proxy filter mode — имеет опции:  
**Proxy listed only** — проксирует трафик только для IP/MAC из списка.  
**Proxy all except listed** — проксирует трафик для всех, кроме IP/MAC из списка.  
**Gaming mode IPv4/MAC** — не проксирует UDP трафик для выбранных устройств.  
**Global Proxy IPv4/MAC** — проксирует весь трафик для выбранных устройств.  

![|600](/Media/Pictures/HomeProxy/c6a7efde21bcd518c73776084251025b.png)

Диапазоны адресов для WAN для проксирования (Proxy IPv4 IP-s) / направления в шлюз по умолчанию (Direct IPv4 IP-s).

![|800](/Media/Pictures/HomeProxy/a242f142c356a18b223bfd72496023f9.png)

В Proxy Domain List и Direct Domain List можно скопировать списки адресов для проксирования (Proxy IPv4 IP‑s) / направления в шлюз по умолчанию (Direct IPv4 IP‑s).

**Сохраняем, Применяем изменения.**

Статус HomeProxy должен измениться на RUNNING

![|400](/Media/Pictures/HomeProxy/7d9b87f5aaf699223f07865a5e984dfa.png)

![|500](/Media/Pictures/HomeProxy/55d51ce1f2790fc91f0b11b23f05fec6.png)

Проверить статус работы и логи, а также подключение к Baidu и Google можно во вкладке **Статус Службы**.

Если вы выбрали Tun TCP/UDP необходимо перейти в раздел Сеть - Межсетевой Экран -

![|400](/Media/Pictures/HomeProxy/b781fdf409c22a83296403436b976aa6.png)

**Добавить новый интерфейс.**

![|800](/Media/Pictures/HomeProxy/dffdcf757bc9fe828051a37abb6f0845.png)

Выбрать Протокол неуправляемый, из списка устройств singtun0, присвоить название, например Proxy и **Создать интерфейс**.  
После чего перейти в настройки интерфейса singtun0 (**Изменить**)

![|800](/Media/Pictures/HomeProxy/6dc286fae472e3642e3b18814d175bbf.png)

Настройки межсетевого экрана — wan (или нужный вам вариант).

На этом основная настройка окончена.