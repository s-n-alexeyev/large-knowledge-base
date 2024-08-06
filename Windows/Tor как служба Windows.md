Для начала нам понадобится сам Torbundle его можно взять тут

https://www.torproject.org/ru/download/tor/

Нам нужен именно Windows Expert Bundle (Экспертный пакет Tor)

Если заблокирован доступ, то можно взять непосредственно с репозитория  
![Torbundle Windows](../Files/tor-expert-bundle-windows-x86_64-13.0.13.tar.gz)  

>Скачиваем данный архив переходим в директорию нашего пользователя командой
```cmd
mkdir %USERPROFILE%\.TOR
```

Создаем папочку TOR и распаковываем туда содержимое скаченного архива.

>Дальше нужно создать файл **torrc** внутри директории .TOR\\tor со следующим содержимым
```ini
DataDirectory C:\Users\user\.TOR\Data\
SocksPort 127.0.0.1:9050
```

>Можно ввести по очереди в консоли эти 2 команды чтобы создать этот файл

```powershell
@( "DataDirectory $env:USERPROFILE\.TOR\data\", "SocksPort 127.0.0.1:9050" ) | ForEach-Object { Add-Content -Path "$env:USERPROFILE\.TOR\tor\torrc" -Value $_ }
```

```powershell
echo DataDirectory %USERPROFILE%\.TOR\data\ >> %USERPROFILE%\.TOR\tor\torrc
```

```powershell
echo SocksPort 127.0.0.1:9050 >> %USERPROFILE%\.TOR\tor\torrc
```

дальше нам нужно запустить `CMD` от имени Администратора и установить tor в качестве службы.

>выполнив данную команду.
```powershell
sc create TOR binPath= ""%USERPROFILE%\.TOR\Tor\tor.exe" --nt-service -f "%USERPROFILE%\.TOR\Tor\torrc""
```

>добавляем в автозапуск
```powershell
sc config TOR start= auto
```

> запуск службы
```powershell
net start TOR
```

>остановка службы
```powershell
net stop TOR
```

>удаление службы
```powershell
sc delete TOR
```

> Если ваш провайдер блокирует tor, то нужно воспользоваться мостами, добавить в `torrc` следующие параметры:
```ini
DataDirectory C:\Users\user\.TOR\Data\
SocksPort 127.0.0.1:9050

ClientTransportPlugin obfs4 exec C:\Users\user\.TOR\tor\pluggable_transports\lyrebird.exe
UseBridges 1

Bridge obfs4 95.217.45.150:8364 17D88EC9D3196D3C5CA126E85C41B2B28B58783C cert=ggBNji0pxQFTlZ4ShZufg597tPOG5w32XUeLx3tPmxch9AQ8hF50703oZWhJVBwNRGc0Xw iat-mode=0
Bridge obfs4 207.188.129.151:9339 C16DA5F7C8FDC6BF2F3C3ABF59E8E3677914F172 cert=0YqPLLoRumc0Pza4rZ3PLSySlK+S44z21un6s0rRxhcxdP+AqL7BWUFKM34KDojM0JbREA iat-mode=0
```

Мосты (Bridges) берутся со страницы [BridgeDB](https://bridges.torproject.org/bridges?transport=obfs4&lang=ru)

![|400](/Media/Torctl/image_1.png)

![|400](/Media/Torctl/image_2.png)

Для автоматизации смены мостов (если их заблокировали или перестали работать) можно воспользоваться утилитой `Tor Bridges Updater` ![Tor Bridges Updater](/Media/Files/TorBridgesUpdater_v0.1.6_Windows.zip)  
- В настройках указываем путь к файлу конфигурации `torrc`.



```powershell
echo ClientTransportPlugin obfs4 exec %USERPROFILE%\.TOR\tor\pluggable_transports\lyrebird.exe  >> %USERPROFILE%\.TOR\tor\torrc
echo UseBridges 1 >> >> %USERPROFILE%\.TOR\tor\torrc
```

```powershell
@( ""DataDirectory $env:USERPROFILE\.TOR\data\", "SocksPort 127.0.0.1:9050", ClientTransportPlugin obfs4 exec $env:USERPROFILE\.TOR\tor\pluggable_transports\lyrebird.exe", "UseBridges 1" ) | ForEach-Object { Add-Content -Path "$env:USERPROFILE\.TOR\tor\torrc" -Value $_ }
```

```powershell
# URL каталога с дистрибутивами Tor
$baseUrl = "https://tor.askapache.com/dist/torbrowser/"

# Каталог для сохранения и распаковки
$destinationFolder = "$env:USERPROFILE\.TOR"

# Убедитесь, что каталог назначения существует
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder
}

# Отправка HTTP-запроса и получение HTML-контента каталога
$htmlContent = Invoke-WebRequest -Uri $baseUrl

# Извлечение каталогов из HTML-контента
$dirs = $htmlContent.Links | Where-Object { $_.href -match "^[0-9]+\.[0-9]+\.[0-9]+\/$" } | Select-Object -ExpandProperty href

# Извлечение версий из каталогов
$versions = $dirs | ForEach-Object {
    if ($_ -match "^([0-9]+\.[0-9]+\.[0-9]+)\/$") {
        [PSCustomObject]@{
            Directory = $_
            Version = [Version]$matches[1]
        }
    }
}

# Определение последней версии
$latestVersion = $versions | Sort-Object -Property Version -Descending | Select-Object -First 1

# Полный URL последней версии
$latestUrl = $baseUrl + $latestVersion.Directory + "tor-expert-bundle-windows-x86_64-" + $latestVersion.Version + ".tar.gz"

# Локальный путь для сохранения скачанного файла
$localFile = "$destinationFolder\tor-expert-bundle-windows-x86_64-$($latestVersion.Version).tar.gz"

# Скачивание файла
Invoke-WebRequest -Uri $latestUrl -OutFile $localFile

# Распаковка файла с использованием встроенной утилиты tar
$tarPath = "tar.exe" # Убедитесь, что tar.exe доступен в PATH

# Распаковка .tar.gz файла
Start-Process -FilePath $tarPath -ArgumentList "-xzf `"$localFile`" -C `"$destinationFolder`"" -NoNewWindow -Wait

# Удаление архива после распаковки
Remove-Item -Path $localFile -Force

Write-Output "Последняя версия ($($latestVersion.Version)) скачана и распакована в $destinationFolder"
Write-Output "Архив $localFile был удалён после распаковки"

# Настройка конфигурации torrc
@( "DataDirectory $env:USERPROFILE\.TOR\data\", "", "SocksPort 127.0.0.1:9050", "ClientTransportPlugin obfs4,webtunnel exec $env:USERPROFILE\.TOR\tor\pluggable_transports\lyrebird.exe", "UseBridges 1" ) | ForEach-Object { Add-Content -Path "$env:USERPROFILE\.TOR\tor\torrc" -Value $_ }
```

```powershell
Start-Process -FilePath "sc.exe" -ArgumentList "create TOR binPath= `"`"$env:USERPROFILE\.TOR\Tor\tor.exe`" --nt-service -f `"$env:USERPROFILE\.TOR\Tor\torrc`"`"" -NoNewWindow -Wait
```