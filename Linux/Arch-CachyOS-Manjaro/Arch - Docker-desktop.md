```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

Раньше разработчик создавал приложение, тестировал и запускал его в одной операционной системе. Приложение, перенесенное для использования в системе другого пользователя, может работать не полностью, поскольку для этого могут потребоваться другие библиотеки, не предоставляемые хостом системы. Это также может привести к ошибкам. Это утомительно, особенно если приложение должно использоваться несколькими пользователями, у которых может быть разный опыт работы с приложением из-за разницы в вычислительной среде. Раньше это было непросто, и в основном она состояла из одного мэйнфрейма, который имел программное обеспечение и мог использоваться разными пользователями с разной периодичностью. Однако контейнеризация решила эту проблему.

Контейнеризация - это форма виртуализации, которая включает упаковку кода приложения с его собственными двоичными файлами, библиотеками, файлами конфигурации и зависимостями, необходимыми для его запуска в любой инфраструктуре. Эти исполняемые пакеты называются контейнерами, которые должны быть легковесными и выполняться независимо от операционной системы хоста. Их можно запускать в любой инфраструктуре, включая "голый металл", облако или внутри виртуальных машин, без необходимости что-либо менять. Контейнеризация позволяет разработчикам быстрее и безопаснее разрабатывать и развертывать приложения в различных инфраструктурах и при этом обеспечивать высокую эффективность.

### Что такое Docker & Docker Desktop?

Docker - это платформа, которая позволяет создавать, тестировать и запускать контейнеры. С помощью Docker вы можете быстро развертывать и масштабировать приложения в любой среде, которую вы хотите, и код будет выполняться без сбоев. Использование Docker позволяет отправлять ваш код в 7 раз быстрее по сравнению с пользователями, не являющимися пользователями docker, стандартизировать работу приложения и беспрепятственно перемещать ваш код из локальной среды разработки в облачную среду. Docker - это платформа с открытым исходным кодом, но для установки, настройки, исправления и обслуживания контейнерных сервисов используются инженерные ресурсы.

#### Рабочий стол Docker

Docker Desktop - это простая в использовании платформа контейнеризации, которую разработчики используют для устранения трудностей, связанных с настройкой сложных сред для создания современных приложений. Docker Desktop прост в настройке и обслуживании, поскольку имеет единый установщик, который позволяет вам за считанные секунды настроить docker в ваших системах и приступить к разработке на вашем локальном компьютере. Docker desktop хранит контейнеры и образы в изолированном хранилище внутри виртуальной машины, обеспечивая контроль и ограничение ее ресурсов.

Docker Desktop предлагает механизм для включения общего доступа к файлам между хостом и виртуальной машиной Docker Desktop. Docker Desktop бесплатен для малых предприятий с численностью сотрудников 250 человек и младше, для личного и некоммерческого использования, а для крупных предприятий он предлагает премиальные функции с минимальной ежемесячной стоимостью в 5 долларов. Это надежная мультиплатформенная платформа, доступная в Windows, macOS и Linux для создания, доставки и масштабируемого запуска современных облачных приложений в производство.

**_Некоторые из его особенностей включают в себя;_**

- Docker имеет простой пользовательский интерфейс для управления всеми конфигурациями,
- Включает расширения Docker, которые преобразуют и оптимизируют рабочие процессы, такие как отладка, тестирование, создание сетей и безопасность.
- Управление томами позволяет администраторам определять использование свободного места и удалять ненужные файлы.
- Docker Desktop включает в себя программу сканирования уязвимостей на базе Snyk, которая сканирует ваши контейнеры и предоставляет полезную информацию.
- Интегрирован с экземплярами контейнеров Azure, что упрощает разработку кода для облачных приложений.
- Безопасный доступ только к официальным изображениям Docker и проверенным издателям Docker. Это функция Docker Business.

Docker Desktop и Docker Engine имеют огромные различия, когда вы сравниваете их. Прежде всего, Docker Desktop содержит единый установщик, который настраивает все необходимое для быстрого использования Docker за считанные секунды, в то время как Docker Engine требует других ресурсов для настройки, установки и исправления своих компонентов. Другие функции, предлагаемые Docker Desktop и отсутствующие в Docker Engine, показаны ниже;

|   |   |   |
|---|---|---|
|**_Особенность_**|**_Докерный Двигатель_**|**_Рабочий стол Docker_**|
|Интегрирован с новым гипервизором Apple, Docker Compose 2.0 и дистрибутивом Microsoft WSL2 Linux|НЕТ|ДА|
|Автоматизированные исправления безопасности|НЕТ|ДА|
|Интерфейс командной строки (CLI) для управления жизненным циклом контейнера|ДА|ДА|
|Привязать файлы монтирования к хост-виртуальной машине|НЕТ|ДА|
|Встроенный контроль ресурсов локальной хост-системы|НЕТ|ДА|

Основные различия в функциях между Docker Desktop и Docker Engine

## Установите и используйте Docker Desktop в Arch Linux[](https://docs.docker.com/desktop/install/linux-install/#system-requirements)

Для успешной установки Docker Desktop ваш хост Linux должен соответствовать следующим требованиям:

- поддержка 64-разрядного ядра и центрального процессора для виртуализации.
- Поддержка виртуализации KVM.
- **QEMU должен быть версии 5.2 или новее** .
- systemd инициализирует систему.
- Среда рабочего стола Gnome или KDE.
- Не менее 4 ГБ оперативной памяти.

Мы установим Docker Desktop на Arch Linux.

## Шаг 1) Поддержка виртуализации KVM

Docker Desktop запускает виртуальную машину, для которой требуется KVM. Мы должны проверить, поддерживает ли наша система KVM. Загрузите модуль KVM с помощью следующей команды

```
sudo modprobe kvm
```

В зависимости от процессора главной машины должен быть загружен соответствующий модуль:

```
sudo modprobe kvm_intel  # Intel processors
sudo modprobe kvm_amd    # AMD processors
```

Чтобы проверить, включены ли модули KVM, запустите

```shell
$ lsmod | grep kvm
kvm_intel             360448  0
kvm                  1085440  1 kvm_intel
irqbypass              16384  1 kvm
```

Настройте разрешение пользователя KVM, добавив своего пользователя в группу KVM, чтобы получить доступ к устройству KVM:

```shell
sudo usermod -aG kvm $USER
```

Использование `kvm` группа пользователей в системе.

```shell
newgrp kvm
```

Установите gnome-terminal, если ваша среда рабочего стола не является Gnome, с помощью следующей команды.

```shell
sudo pacman -S gnome-terminal
```

## Шаг 2) Установите Docker Engine

Обновите свои системные пакеты самыми новыми доступными версиями

```shell
sudo pacman -Sy
```

У Docker нет репозитория пакетов Arch, поэтому пользователи должны вручную устанавливать двоичный файл клиента Docker в своих системах.

```shell
sudo pacman -S docker
```

Запустите и включите docker для запуска при загрузке.

```shell
sudo systemctl start docker
sudo systemctl enable docker
```

Проверьте статус сервиса.

```
$ systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: d>
     Active: active (running) since Wed 2022-10-26 23:27:34 EAT; 16s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 1900 (dockerd)
      Tasks: 17 (limit: 9521)
     Memory: 29.2M
        CPU: 267ms
```

Чтобы запускать команды командной строки docker для пользователя, не являющегося пользователем root, добавьте пользователя в группу docker.

```shell
sudo usermod -aG docker $USER
newgrp docker
```

Убедитесь, что вы можете запускать контейнеры, выполнив следующую команду. Команда загружает последний образ Arch Linux и использует его для запуска программы Hello World в контейнере:

```
$ docker run -it --rm archlinux bash -c "echo hello world"
Unable to find image 'archlinux:latest' locally
latest: Pulling from library/archlinux
eebb07dfd16c: Pull complete 
ec2ee4e22db4: Pull complete 
Digest: sha256:71df376dbf28d6eaecbe9de04e394566afeba74e8cac2b2fdf36e05c5ae0b1e7
Status: Downloaded newer image for archlinux:latest
hello world
```

## Шаг 3) Установите Docker Desktop на Arch Linux

Загрузите последнюю версию дистрибутива Arch Linux со страницы [выпуска](https://docs.docker.com/desktop/release-notes/) или воспользуйтесь для этого утилитой wget.

```shell
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.15.0-x86_64.pkg.tar.zst
```

Затем установите пакет с помощью следующей команды.

```shell
sudo pacman -U ./docker-desktop-*.pkg.tar.zst
```

После успешной установки Docker Desktop вы можете проверить версии этих двоичных файлов, выполнив следующие команды:

```
$ docker compose version
Docker Compose version v2.12.0

$ docker --version
Docker version 20.10.20, build 9fdeb9c3de

$ docker version
Client:
 Cloud integration: v1.0.29
 Version:           20.10.20
 API version:       1.41
 Go version:        go1.19.2
 Git commit:        9fdeb9c3de
 Built:             Sat Oct 22 19:31:23 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.20
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.19.2
  Git commit:       03df974ae9
  Built:            Sat Oct 22 19:30:29 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.6.8
  GitCommit:        9cd3357b7fd7218e4aec3eae239db1f68a5a6ec6.m
 runc:
  Version:          1.1.4
  GitCommit:        
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

Установите Docker Desktop таким образом, чтобы он запускался при входе в систему.

```shell
sudo systemctl --user enable docker-desktop
```

Запустите Docker Desktop с помощью следующей команды.

```shell
sudo systemctl --user start docker-desktop
```

В качестве альтернативы вы можете запустить его из меню Приложений.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-2.png?ezimgfmt=rs:436x228/rscb7/ng:webp/ngcb7)

Приложение откроется с окном лицензионного соглашения. Примите лицензионное соглашение, установив флажок и нажав Принять.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-1.png?ezimgfmt=rs:680x424/rscb7/ng:webp/ngcb7)

Панель мониторинга откроется, как показано ниже.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-3.png?ezimgfmt=rs:696x503/rscb7/ng:webp/ngcb7)

## Шаг 4) Запустите контейнер

Попробуйте запустить образец контейнера. Скопируйте следующую команду и запустите ее на своем терминале.

```
$ docker run -d -p 80:80 docker/getting-started
Unable to find image 'docker/getting-started:latest' locally
latest: Pulling from docker/getting-started
df9b9388f04a: Pull complete 
5867cba5fcbd: Pull complete 
4b639e65cb3b: Pull complete 
061ed9e2b976: Pull complete 
bc19f3e8eeb1: Pull complete 
4071be97c256: Pull complete 
79b586f1a54b: Pull complete 
0c9732f525d6: Pull complete 
Digest: sha256:b558be874169471bd4e65bd6eac8c303b271a7ee8553ba47481b73b2bf597aae
Status: Downloaded newer image for docker/getting-started:latest
638cebd19a8e52b9eace4d676a7215637dd937a3c57859c67e745c47d11f7edf
```

Затем вернитесь к интерфейсу Docker Desktop, чтобы найти запущенный конструктор. Имя может отличаться, поскольку оно является случайным.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-4.png?ezimgfmt=rs:696x502/rscb7/ng:webp/ngcb7)

## Шаг 5) Настройте Docker Desktop

Вы можете дополнительно настроить интерфейс рабочего стола Docker в настройках.

В разделе "Общие настройки" вы можете включить запуск Docker Desktop при входе в систему и изменить тему интерфейса

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-5.png?ezimgfmt=rs:696x453/rscb7/ng:webp/ngcb7)

Вкладка Ресурсы позволяет изменять различные настройки, включая используемые ресурсы, настраивать прокси-серверы и каталоги для общего доступа к файлам.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-6.png?ezimgfmt=rs:696x473/rscb7/ng:webp/ngcb7)

Вы также можете включить Kubernetes.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-7.png?ezimgfmt=rs:696x453/rscb7/ng:webp/ngcb7)

Вы также можете проверить наличие обновлений из интерфейса.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-8.png?ezimgfmt=rs:696x442/rscb7/ng:webp/ngcb7)

И настроить расширения:

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-9.png?ezimgfmt=rs:696x470/rscb7/ng:webp/ngcb7)

Значок устранения неполадок откроет следующий экран, который позволит вам перезапустить, очистить данные или сбросить настройки Docker Desktop.

![](https://techviewleo.com/wp-content/uploads/2022/10/Install-Docker-Desktop-ArchLinux-10.png?ezimgfmt=rs:696x498/rscb7/ng:webp/ngcb7)

## Переключение между рабочим столом Docker и движком Docker Engine

Docker Desktop и Docker Engine могут быть установлены на одном компьютере, поскольку Docker desktop работает на изолированной виртуальной машине, которая обеспечивает контроль и ограничивает использование системных ресурсов. Однако рекомендуется останавливать Docker Engine во время использования Docker Desktop, чтобы предотвратить потребление ресурсов Docker Engine и предотвратить конфликты.

Чтобы остановить службу Docker Engine, используйте следующую команду.

```
sudo systemctl stop docker docker.socket containerd
```

Чтобы отключить его автоматический запуск, используйте следующую команду.

```
sudo systemctl disable docker docker.socket containerd
```

Когда Docker Desktop установлен, он устанавливает свой собственный контекст _desktop-linux_ в качестве текущего контекста, а последующие команды Docker CLI нацелены на Docker Desktop.

Используйте следующую команду, чтобы просмотреть, какие контексты доступны и какой используется в данный момент (тот, который отмечен звездочкой *)

```
docker context ls
```

Используйте _команду docker context use_ для переключения между контекстами Docker Desktop и Docker Engine.

Используйте контекст по _умолчанию_ для взаимодействия с Docker Engine:

```
docker context use default
```

Используйте контекст _desktop-linux_ для взаимодействия с Docker Desktop:

```
docker context use desktop-linux
```

## Заключение

Docker Desktop отличается высокой надежностью и простотой в использовании. Он предлагает все функции в одном установщике, его легко настроить за считанные секунды и использовать Docker на вашем локальном компьютере. Он имеет простой пользовательский интерфейс, который недоступен в других альтернативах DIY Docker Engine. При использовании Docker Desktop следует учитывать общую стоимость владения. Каким бы большим ни казалось это количество для некоторых компаний, подумайте о технических ресурсах, которые используются с альтернативами DIY Docker для установки, настройки и исправления платформы docker. И помните, что он по-прежнему находится в свободном доступе для малого бизнеса, личного использования и некоммерческого использования.
