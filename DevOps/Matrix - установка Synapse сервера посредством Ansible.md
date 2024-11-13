2024-05-19
[Оригинальная статья](https://kiberlis.ru/matrix-docker-ansible-deploy/)

```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
Данная инструкция предполагает полную установку Synapse на собственный сервер (или VPS) и базовую настройку всех его функций. Для установки Synapse используется множество Docker контейнеров разворачиваемых совместно с cистемой управления конфигурациями Ansible. Официальную документацию по данному методу установки и ссылки на неё, вы можете найти на [Github](https://github.com/spantaleev/matrix-docker-ansible-deploy) и [Matrix.org](https://matrix.org/docs/projects/other/matrix-docker-ansible-deploy).

Synapse — это домашний сервер для общения через Matrix с открытым исходным кодом, написанный и поддерживаемый Matrix.org Foundation. Для общения через Matrix используются следующие мессенджеры [https://matrix.org/clients/](https://matrix.org/clients/)

Метод установки Synapse с помощью Ansible и Docker я выбрал в связи с тем что он наиболее легкий в плане установки и настройки дополнительных зависимостей и расширений Synapse, а также данный способ предполагает автоматическую установку nginx, ssl, postgresql.

Вкратце, Matrix — это открытый стандарт для связи в Интернете используемый для [мессенджеров](https://matrix.org/clients/), поддерживающий федерацию, шифрование, голосовую и видео связь, видеоконференции. Также возможны интеграции с Telegram, Discord, Whatsapp и т.д., полный список возможных интеграций вы найдете тут: [https://github.com/spantaleev/matrix-docker-ansible-deploy#bridges](https://github.com/spantaleev/matrix-docker-ansible-deploy#bridges)

На текущий момент Matrix возможно использовать как для Приватного общения между друзьями и близкими, так и для полноценной замены Whatsapp, Telegram и т.д., или вообще для корпоративной связи, но с одним большим отличием от популярных мессенджеров, а именно:

1. Вы можете использовать для связи собственный сервер с собственным ключом шифрования и усиленной защитой перехвата данных. Все популярные мессенджеры используют собственные сервера и ключи шифрования, которые могут быть доступны некоторым гос. структурам и мошенникам
2. Несмотря на использование собственного сервера, вы можете коммуницировать с пользователями других серверов Matrix (функционал федерации)
3. Вы можете настроить мост и общаться с пользователями любого другого мессенджера, к примеру Telegram или Whatsapp
4. Полное отсутствие слежки со стороны системы
5. Качественная и максимально стабильная аудио и видео связь при достаточных характеристиках сервера на который установлен Synapse
6. Усиленная защита от сбора личных данных и кражи ваших переписок
7. Минимальная верификация в сети, вы можете не использовать свой номер телефона или почту для регистрации (кроме некоторых публичных серверов, часто требуется ввод электронной почты) Пример использования публичного сервера Matrix тут [https://habr.com/ru/post/665766/](https://habr.com/ru/post/665766/)

То есть Synapse позволяет вам присоединиться к сети Matrix, используя ваш собственный идентификатор @<имя пользователя>:<ваш-домен>, и все они размещены на вашем собственном сервере или арендованном VPS.

Все службы запускаются в контейнерах Docker что позволяет нам иметь предсказуемую и актуальную настройку. Установка (обновления) и некоторые задачи обслуживания автоматизированы с помощью Ansible.

## **Системные требования**

**Без видеоконференций (jitsi):**  
4ГБ оперативной памяти (или 2ГБ+swap), процесcор 2 ядра (с частотой не ниже 3,4 ГГц)

**С видеоконференциями (jitsi):**  
6ГБ оперативной памяти (или 4ГБ+swap), процессор 2 ядра (с частотой не ниже 3,4 ГГц)

**Поддерживаемые ОС:**  
CentOS 7  
Debian (9, 10, 11)  
Ubuntu (16.04 и новее)  
Archlinux

Лично устанавливал только на Ubuntu 24.04 LTS и Debian 11-12.

Сервер с 2ГБ ОЗУ без swap также может работать с Synapse, но только для личных звноков (без видео) и личных переписок (проверено, но с некоторыми ограничениями). Федеративные чаты с множеством подписок перегрузят сервер с подобными характеристиками намертво (придется перезагружать сервер и экстренно удалять Synapse с последующей переустановкой)

Покупка домена

**Приобретаем домен** для вашего сервера Matrix, я рекомендую покупать домен у [hostland.ru](https://www.hostland.ru/services/domain/?r=3dd32695)
## Аренда сервера VPS

**Для аренды VPS я рекомендую следующих провайдеров:**

[aeza.net](https://aeza.net/?ref=379564) — хостер с серверами в разных странах, рекомендация из чата поддержки, подходит для VPN с каналом в 1 гигабит. Для Synapse желательно выбирать Hi-CPU сервера.

[vdsina.ru](https://vdsina.ru/?partner=v3qnf7r21j) — (скидка 10% по ссылке) хостер с серверами в разных странах, рекомендация из чата поддержки, подходит для VPN с каналом в 1 гигабит

[timeweb.com](https://timeweb.com/ru/services/hosting?utm_source=cc33022&utm_medium=timeweb&utm_campaign=timeweb-bring-a-friend) — (300 рублей подарок на счет по ссылке) хороший хостер, но я им давно не пользуюсь. Канал 200 мегабит

## Настройка записей DNS на домене

После покупки домена и аренды сервера, необходимо сразу же прописать указанные ниже записи DNS для вашего домена. Сделать это нужно как можно быстрее, так как вам придется ждать от 3 часов до 3 суток обновление записей DNS, обычно обновление длится меньше суток.

Основной домен использоваться для Synapse не будет, так как он обычно используется под основной сайт или блог. Для Synapse будут использоваться поддомены типа matrix.example.ru и element.example.ru

Вместо example.ru подставьте свой домен подготовленный для Synapse.

**Необходимые записи DNS для домена:**

ТИП ХОСТ ПРИОРИТЕТ ВЕС ПОРТ ЗНАЧЕНИЕ  
A matrix — — — matrix-server-IP  
CNAME element — — — matrix.example.ru  
CNAME dimension — — — matrix.example.ru  
CNAME jitsi — — — matrix.example.ru  
SRV _matrix-identity._tcp 10 0 443 matrix.example.ru

**Пример настройки записей DNS домена в панели управления Hostland.ru:**

[![](https://kiberlis.ru/wp-content/uploads/2023/02/nastrojka-dns-1024x471.jpg)](https://kiberlis.ru/wp-content/uploads/2023/02/nastrojka-dns.jpg)
Проверку обновления записей DNS для домена можно провести тут [https://2ip.ru/dig/](https://2ip.ru/dig/)

## Подготовка системы

Обновляем систему

```bash
apt update -y && 
apt upgrade -y
```

Усиливаем безопасность сервера и отключаем вход по паролю по следующей памятке при помощи SSH ключа:

> [Памятка по безопасности VPS, VDS сервера Ubuntu, Debian](https://kiberlis.ru/pamyatka-po-bezopasnosti-vps-vds-servera-ubuntu-debian/)

**Устанавливаем необходимые зависимости (Python3-pip, ansible и pwgen для генерации паролей):**

```bash
apt install pipx
pipx ensurepath
pipx install ansible
apt install pwgen
```

Перегружаем сервер:

```bash
reboot
```

Также для установки Ansible в качестве альтернативного способа можно воспользоваться официальной документацией [https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian)

## Установка Matrix Synapse

### Загрузка установочных файлов

Загружаем установочные файлы на сервер

```bash
git clone https://github.com/spantaleev/matrix-docker-ansible-deploy.git
```

### Настройка Ansible Playbook

#### Загрузка шаблона базовой конфигурации

Ansible Playbook в данной инструкции мы будем запускать непосредственно на сервере, для этого нам нужно скопировать шаблон конфигурации в каталог конфигурации Synapse и указать настройки SSH подключения в файле matrix-docker-ansible-deploy/inventory/hosts

Переходим в директорию с установочными файлами

```bash
cd matrix-docker-ansible-deploy
```

Создаем каталог для конфигурации нашего сервера (вместо example.ru укажите свой домен)

```bash
mkdir -p inventory/host_vars/matrix.example.ru
```

Копируем шаблонные файлы конфигурации vars.yml и hosts (вместо example.ru укажите свой домен)

```bash
cp examples/vars.yml inventory/host_vars/matrix.example.ru/
cp examples/hosts inventory/hosts
```

#### Настройка SSH подключения Ansible к серверу

Для редактирования конфигурационного файла подключения к серверу выполните команду:

```bash
nano inventory/hosts
```

Содержимое файла должно быть таким если вы воспользовались [памяткой безопасности](https://kiberlis.ru/pamyatka-po-bezopasnosti-vps-vds-servera-ubuntu-debian/), т.к. в ней используется ключ SSH вместо пароля и изменен порт для SSH подключения:

```
[matrix_servers]
matrix.example.ru ansible_host=IP-сервера ansible_ssh_user=root ansible_ssh_port=ПОРТ-SSH ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Вместо example.ru укажите свой домен приобретенный ранее.

В ansible_host укажите внешний IP адрес своего сервера.

В ansible_ssh_user укажите имя пользователя используемого для SSH (по умолчанию root и я не менял его, пользователь может быть отличным от root). Также если у вас используется sudo вам нужно будет в конце команд установки Ansible добавлять ключ -K

В ansible_ssh_port укажите свой порт SSH (по умолчанию 22, но я изменил его и рекомендую вам сделать также согласно [памятке безопасности](https://kiberlis.ru/pamyatka-po-bezopasnosti-vps-vds-servera-ubuntu-debian/))

В ansible_ssh_private_key_file укажите путь к ключу SSH (по умолчанию ~/.ssh/id_rsa, в [памятке](https://kiberlis.ru/pamyatka-po-bezopasnosti-vps-vds-servera-ubuntu-debian/) используется такой же путь)

Если SSH ключ не используется и порт SSH не изменен, то содержимое будет таким (но это не наш случай так как мы заботимся о безопасности):

```
[matrix_servers]
matrix.example.ru ansible_host=IP-сервера ansible_ssh_user=root
```

#### Генерация ключей для Matrix Synapse и Jitsi

Заранее сгенируйте ключи для конфигурации Matrix Synapse, вам понадобится для этого 10 ключей. Сгенериуйте ключи следующей командой и сохраните их в на компьютере в блокнот:

```bash
pwgen -s 64 1
```

#### Настройка основных параметров Synapse

Основные параметры Synapse содержатся в файле vars.yml по пути matrix-docker-ansible-deploy/inventory/host_vars/matrix.example.ru

Для редактирования vars.yml выполните следующую команду (вместо example.ru укажите свой домен):

```bash
nano inventory/host_vars/matrix.example.ru/vars.yml
```

Вы можете использовать готовый шаблон конфигурации vars.yml приведенный ниже полностью заменив все строки файла и заполнить его своими данными.

Вам необходимо заменить example.ru на свой домен и добавить ранее сгенерированные ключи вместо ‘большой ключ’.

_В шаблоне используется основной домен, а не поддомен для того чтобы иметь красивые адреса типа @login:example.com без приставки matrix._

```yaml
#Обязательное
matrix_domain: example.ru
matrix_homeserver_implementation: synapse
matrix_homeserver_generic_secret_key: 'большой ключ'
# matrix_ssl_lets_encrypt_support_email: 'ssl@example.ru'
# matrix_coturn_turn_static_auth_secret: 'большой ключ'
# matrix_synapse_macaroon_secret_key: 'большой ключ'
matrix_playbook_reverse_proxy_type: playbook-managed-traefik
traefik_config_certificatesResolvers_acme_email: 'ssl@example.ru'
postgres_connection_password: 'любой безопасный пароль для базы данных'


#Регистрация по приглашению
matrix_registration_enabled: true

#Админка
matrix_registration_admin_secret: "большой ключ"
matrix_synapse_admin_enabled: true

#Если у вас нет сайта на основном домене example.ru, то использовать данный параметр для автоматической настройки nginx, в противном случае закомментируйте его и настройте nginx самостоятельно
matrix_static_files_container_labels_base_domain_enabled: true
#matrix_nginx_proxy_base_domain_serving_enabled : true

#Jitsi - раскомментируйте (стереть #) строки ниже если у вас достаточно характеристик сервера для видеоконференций
#jitsi_enabled: true
#jitsi_jicofo_component_secret: большой ключ
#jitsi_jicofo_auth_password: большой ключ
#jitsi_jvb_auth_password: большой ключ
#jitsi_jibri_recorder_password: большой ключ
#jitsi_jibri_xmpp_password: большой ключ
```

Указанный шаблон конфигурации содержит:

- Synapse homeserver — сервер Matrix Synapse
- PostgreSQL — база данных
- Coturn STUN/TURN — сервер для маршрутизации трафика видео\аудиозвонков
- Let’s Encrypt SSL — бесплатный SSL сертификат для домена
- Element Web — веб версия клиента Matrix доступная по адресу element.exapmle.ru настроенный по умолчанию на ваш сервер (вместо example.ru укажите свой домен)
- ma1sd — собственный сервер идентификацииExim почтовый сервер для отправки уведомлений
- Exim — почтовый сервер для отправки уведомлений
- Nginx — веб-сервер
- Synapse-admin — веб интерфейс панели администрирования клиентов и комнат
- Matrix-registration — регистрация новых пользователей с помощью приглашения
- Jitsi — модуль видеоконференции

После заполнения шаблона своими данными нужно запустить установку. Если что-то вам не нужно просто удалите строчку из конфигурационного файла или закмментируйте её.

#### Запуск установки Matrix Synapse

Установите ansible-core:

```bash
pipx install ansible-core
```

Перезагрузите сервер:

```
reboot
```

Установите роли Ansible необходимые для установки Synapse:

```bash
rm -rf roles/galaxy &&
ansible-galaxy install -r requirements.yml -p roles/galaxy/ --force
```

Установите модули Ansible Galaxy community.general, ansible.posix и community.docker:

```
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.docker
```

Устанавливаем, если пользователь в hosts не root и нужно получить пароль от sudo, добавьте в конце команды ключ -K и во всех командах его добавлять нужно будет

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

Дальше можно запустить проверку конфигурации

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=self-check
```

Если у вас возникают ошибки, то возможно обновился Matrix Synapse Ansible и вам необходимо актуализировать указанный шаблон относительно examples/vars.yml (просьба написать об этом в комментариях) Также всегда внимательно и осмысленно читайте текст ошибки чтобы исключить ваш человеческий фактор.

## Документация и дополнительные настройки Matrix Synapse Ansible

### Регистрация первого пользователя и делаем его администратором

Для создания пользователя с правами администратора выполните команду:

```bash
ansible-playbook -i inventory/hosts setup.yml --extra-vars='username=логин password=пароль admin=yes' --tags=register-user
```

### Установка Dimension

Модуль для Matrix позволяющий добавлять виджеты в беседы. При помощи него можно добавить аккуратную кнопку для видеоконференций Jitsi в шапке беседы.

Зарегистрируйте нового пользователя для dimension без прав администратора

```bash
ansible-playbook -i inventory/hosts setup.yml --extra-vars='username=dimension password=хорошийпароль admin=no' --tags=register-user
```

Теперь нужно получить его токен, что бы сервис работал из под него. Есть два способа как это сделать через curl или через клиент

**Через клиент:**

Откройте Element, можно веб-версию https://element.example.ru (вместо example.ru ваш домен)  
Авторизуйтесь под пользователем dimension  
Нажмите на имя вверху где аватарка, затем нажмите «Все настройки»  
В настройках найдите пункт «Помощь и о программе», пролистайте вниз до «Подробности» и найдите пункт «Токен доступа», раскройте его нажатием и скопируйте токен в блокнот.  
Просто закройте браузер, не разлогиневайтесь!

**Через curl**

```bash
curl -X POST --header 'Content-Type: application/json' -d '{
    "identifier": { "type": "m.id.user", "user": "YourDimensionUsername" },
    "password": "YourDimensionPassword",
    "type": "m.login.password"
}' 'https://matrix.example.com/_matrix/client/r0/login'
```

В команде замените «YourDimensionUser/Pass» URL на свои значения.

Добавляем в конфигурацию строки для активации Dimension

```bash
nano inventory/host_vars/matrix.example.ru/vars.yml
```

Добавьте строчки:

```yaml
matrix_dimension_enabled: true
matrix_dimension_admins: '@логин:example.com'
matrix_dimension_access_token: "ВАШ ТОКЕН который копировали"
```

Для matrix_dimension_admins пропишите первую учетную запись с правами администратора которую вы создали.

Проведите повторную сборку Ansible с помощью команды:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

### Ативация виджета Jitsi

Так как Jitsi у нас локальный, а плейбук не умеет править конфиг чтобы виджет jitsi создавался сразу с локальным jitsi. Нужно самому руками это поправить в клиенте.

Откройте клиент Element, откройте любой чат, любую комнату и нажмите на инфу о ней справа вверху. Там будет ссылка добавить виджеты>Откроется экран Widgets жмакайте на шестеренку справа вверху>Widgets>Jitsi Conference карандашек>тут замените домен на свой jitsi.example.ru в обоих окошках не стирая остального на счёт рубилнька не уверен, может глючить. Сохраните. Данный пункт повзаимствовал [тут](https://vipadmin.club/22191-ustanovka-matrix-servera-s-pomoschju-playbook-2021.html), сам не тестировал так как на моем сервере не хватает характеристик для Jitsi.

[![Установка Matrix сервера с помощью playbook 2021](/Media/Synapse/Установка_Matrix_сервера_с_помощью_playbook_2021.webp)](https://vipadmin.club/uploads/posts/2022-02/-.webp)
### Регистрация по приглашению

Данная функция уже включена в шаблоне вашей конфигурации. Для создания ссылки-приглашениявоспользуйтесь следующей командой:

```bash
ansible-playbook -i inventory/hosts setup.yml \
--tags=generate-matrix-registration-token \
--extra-vars="one_time=yes ex_date=2022-12-31"
```

one_time=ставьте «no» если вам нужно приглашение без ограничения срока действия. Я рекомендую ставить значение «yes» и прописывать дату для ex_date= в формате как в образце команды

После запуска вышеупомянутой команды вы получите ссылку на регистрацию для ваших друзей.

### Панель администратора

Доступна по адресу (/ в конце обязательно):

[https://matrix.example.ru/synapse-admin/](https://matrix.example.com/synapse-admin/)

### Правила фаервола

Используемые правила фаервола (нужно согласовать с уже установленными правилами в системе. См. [памятка безопасности](https://kiberlis.ru/pamyatka-po-bezopasnosti-vps-vds-servera-ubuntu-debian/) пункт 5):

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow ВАШ-SSH-ПОРТ/tcp
sudo ufw allow 5349/tcp
sudo ufw allow 5349/udp
sudo ufw allow 3478/tcp
sudo ufw allow 3478/udp
sudo ufw allow 8448/tcp
sudo ufw allow 49152:49172/udp
sudo ufw allow 4443/tcp
sudo ufw allow 10000/udp
sudo ufw enable
```

Проверяем статус:

```bash
sudo ufw status verbose
```

### Конфигурация Nginx вручную

Если основной домен используется вашим сайтом, то вам необходимо выполнить донастройку nginx вручную.

В конфиг nginx нужно вставить настройку, что бы всем сказать, что этот домен обслуживает сервер matrix находящийся по адрсесу matrix.example.ru и все и клиенты и федерация прозрачно работали, когда вы указываете адрес сервера example.ru

```
location /.well-known/matrix {
proxy_pass https://matrix.example.ru/.well-known/matrix;
proxy_set_header X-Forwarded-For $remote_addr;
}
```

Проверьте, что федерация работает:

[https://federationtester.matrix.org/](https://federationtester.matrix.org/)

Еще можно проверить правильно ли работает настройка TURN STUN для видео и аудио звонков, тут токен можно подсунуть или логин и пароль от учетки матриксовской врменной, url вводить matrix.example.com:

[https://test.voip.librepush.net/](https://test.voip.librepush.net/)

### Обновление и обслуживание

С помощью Ansible можно не только проводить установку, но и устанавливать обновления Synapse и его модулей.

Канал, что бы следить за уведомлениями о новых версиях [#homeowners:matrix.org](https://matrix.to/#/#homeowners:matrix.org).

Для обновления перейдите в каталог с ранее загруженным Matrix Synapse и запустите скачивание свежих файлов командой:

```bash
cd matrix-docker-ansible-deploy
git pull
```

Проведите повторную сборку Ansible с помощью команды:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

Версию базы данных Postgres обновить возможно только вручную.

### Удаление Synapse

Для удаления Synapse введите следующую команду:

```bash
sh /matrix/bin/remove-all
```

затем скопировать и вставить для подтверждения текст «Yes, I really want to remove everything!»