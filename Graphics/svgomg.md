```bash
git clone https://github.com/jakearchibald/svgomg
```

sudo mv ./svgomg /opt 

```markdown
## Cloning and Moving SVGOMG

Чтобы начать, вам потребуется клонировать репозиторий SVGOMG с GitHub. Это можно сделать с помощью следующей команды:

```bash
git clone https://github.com/jakearchibald/svgomg
```

After cloning the repository, it's a good practice to move the cloned directory to a more appropriate location on your system. In this case, moving it to `/opt` is recommended as it is commonly used for installing software packages that are not part of the default distribution.

Команда для перемещения каталога SVGOMG в /opt выглядит следующим образом:

```bash
sudo mv ./svgomg /opt
```

This command requires superuser privileges, hence the use of `sudo`. It moves the entire SVGOMG directory from its current location to `/opt`.

## Следующие шаги

После того как вы переместили каталог SVGOMG в `/opt`, вы можете продолжить с настройкой и конфигурацией приложения в соответствии с вашими потребностями. Это может включать установку зависимостей, настройку переменных окружения или настройку необходимых служб.

Для подробных инструкций по настройке и использованию SVGOMG после перемещения его в `/opt` обратитесь к официальной документации, предоставленной в репозитории.



Ключевые моменты текста:

1. Клонирование репозитория SVGOMG с GitHub:
   ```bash
   git clone https://github.com/jakearchibald/svgomg
   ```

2. Перемещение клонированного каталога в `/opt`:
   ```bash
   sudo mv ./svgomg /opt
   ```

3. Рекомендация использовать `/opt` для установки программных пакетов, не входящих в стандартное распределение.

4. Нужно продолжить настройку и конфигурацию приложения после перемещения каталога, что может включать установку зависимостей, настройку переменных окружения или запуск необходимых служб.

5. Рекомендуется обратиться к официальной документации репозитория для подробных инструкций по настройке и использованию SVGOMG после перемещения в `/opt`.

```markdown
## Настройка и запуск SVGOMG

После того как вы переместили директорию SVGOMG в `/opt`, следующим шагом будет установка зависимостей и настройка приложения. Ниже приведены общие инструкции по этим процессам.

### Установка зависимостей

SVGOMG, вероятно, зависит от некоторых пакетов или библиотек. Чтобы установить необходимые зависимости, вы можете использовать менеджер пакетов вашего дистрибутива Linux. Например, если используется `apt`, команда может выглядеть так:

```bash
sudo apt update
sudo apt install -y build-essential nodejs npm
```

Эти команды обновят список доступных пакетов и установят необходимые инструменты для компиляции и работы с Node.js.

### Установка зависимостей приложения

Перейдите в директорию SVGOMG, которую вы переместили в `/opt`:

```bash
cd /opt/svgomg
```

Теперь установите зависимости приложения, используя npm (Node Package Manager):

```bash
npm install
```

Эта команда скачает и установит все необходимые модули, перечисленные в файле `package.json`.

### Запуск SVGOMG

После установки зависимостей вы можете запустить приложение. Обычно это делается с помощью команды:

```bash
npm start
```

Эта команда запустит сервер, на котором будет работать SVGOMG. По умолчанию он может слушать порт 3000.

### Настройка автозапуска

Для того чтобы приложение запускалось автоматически при старте системы, вы можете создать системный сервис с помощью `systemd`. Создайте файл `/etc/systemd/system/svgomg.service` со следующим содержимым:

```ini
[Unit]
Description=SVGOMG Server
After=network.target

[Service]
ExecStart=/usr/bin/npm start --prefix /opt/svgomg
Restart=always
User=nobody
Environment="NODE_ENV=production"

[Install]
WantedBy=multi-user.target
```

Затем активируйте и запустите сервис:

```bash
sudo systemctl daemon-reload
sudo systemctl enable svgomg.service
sudo systemctl start svgomg.service
```

Эти команды создадут, включат и запустят сервис SVGOMG.

## Заключение

Следуя приведенным выше инструкциям, вы сможете успешно установить, настроить и запустить SVGOMG после перемещения его в директорию `/opt`. Не забудьте ознакомиться с официальной документацией для получения более подробной информации и возможных дополнительных настроек.
