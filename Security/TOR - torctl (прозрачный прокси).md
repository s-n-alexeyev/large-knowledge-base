2019-04-02

[Оригинальная статья](https://hackware.ru/?p=10443#55)
## Tor как прозрачный прокси
torctl  - один из самых функциональных скриптов для tor + iptables.  
Эта программа написана для [BlackArch](https://blackarch.ru/), но довольно легко портируется на другие дистрибутивы.

>Установка torctl в DEB/Kali Linux
```shell
sudo apt install tor macchanger secure-delete
git clone https://github.com/BlackArch/torctl
cd torctl
sudo mv service/* /etc/systemd/system/
sudo mv bash-completion/torctl /usr/share/bash-completion/completions/torctl
sed -i 's/start_service iptables//' torctl
sed -i 's/TOR_UID="tor"/TOR_UID="debian-tor"/' torctl
sudo mv torctl /usr/bin/torctl
cd .. && rm -rf torctl/
torctl --help
```

>Установка torctl в Arch
```shell
yay -S torctl
```

необходимо подправить подправить ссылку на git
с `source=("git://github.com/$author/$_gitname.git")`
на `source=("git+https://github.com/$author/$_gitname.git")`

>Чтобы узнать свой текущий IP, выполните:
```shell
torctl ip
```

>Чтобы запустить Tor в качестве прозрачного прокси:
```shell
sudo torctl start
```

[![|500](/Media/Pictures/Torctl/torctl.png)

>Для проверки статуса служб:
```shell
torctl status
```

>Если вы хотите поменять IP в сети Tor:
```shell
sudo torctl chngid
```

>Для работы с Интернетом напрямую, без Tor, запустите:
```shell
sudo torctl stop
```

>Чтобы поменять MAC адреса на всех сетевых интерфейсах выполните команду:
```shell
sudo torctl chngmac
```

>Чтобы вернуть исходные MAC адреса:
```shell
sudo torctl rvmac
```

>Следующая команда добавит службу torctl в автозагрузку, то есть сразу после включения компьютера весь трафик будет пересылаться через Tor:
```shell
sudo systemctl enable torctl-autostart.service
```

>Для удаления службы из автозагрузки выполните:
```shell
sudo systemctl disable torctl-autostart.service
```

>Ещё вы можете включить автоматическую очистку памяти каждый раз при выключении компьютера:
```shell
sudo systemctl enable torctl-autowipe.service
```

>Для отключения это функции:
```shell
sudo systemctl disable torctl-autowipe.service
```

Этот скрипт знает о существовании IPv6 трафика и успешно блокирует его. Запросы DNS перенаправляются через Tor.

## скрипт на YAD (GUI) для tor и torctl

>[!Info]- Тескт скрипта
>```shell
>#!/bin/bash
>
>VERSION="1.1"
>
># Messages array for different languages
>declare -A MESSAGES
>MESSAGES=(
># English
>["en_auth"]="Enter root password"
>["en_wrong_password"]="Incorrect password! Exiting."
>["en_torctl_started"]="torctl service successfully started"
>["en_torctl_start_failed"]="Failed to start torctl service"
>["en_torctl_stopped"]="torctl service successfully stopped"
>["en_torctl_stop_failed"]="Failed to stop torctl service."
>["en_tor_started"]="tor service successfully started"
>["en_tor_start_failed"]="Failed to start tor service"
>["en_tor_stopped"]="tor service successfully stopped"
>["en_tor_stop_failed"]="Failed to stop tor service"
>["en_mac_changed"]="MAC address successfully changed"
>["en_mac_change_failed"]="Failed to change MAC addresses"
>["en_mac_reverted"]="MAC address successfully reverted"
>["en_mac_revert_failed"]="Failed to revert MAC addresses"
>["en_ip_changed"]="IP address in tor network successfully changed"
>["en_ip_change_failed"]="Failed to change IP address in tor network"
>["en_title"]="Control tor/torctl"
>["en_service"]="service"
>["en_active"]="active"
>["en_inactive"]="inactive"
>["en_addresses"]="addresses"
>["en_factory_defaults"]="factory defaults"
>["en_fake"]="fake"
>["en_button_start"]="Start"
>["en_button_stop"]="Stop"
>["en_button_change"]="Change"
>["en_button_revert"]="Revert"
>["en_button_change_ip"]="Change IP"
>["en_dependencies"]="Missing dependencies:"
>
># Russian
>["ru_auth"]="Введите пароль root"
>["ru_wrong_password"]="Неверный пароль! Завершение работы."
>["ru_torctl_started"]="Сервис torctl успешно запущен"
>["ru_torctl_start_failed"]="Не удалось запустить сервис torctl"
>["ru_torctl_stopped"]="Сервис torctl успешно остановлен"
>["ru_torctl_stop_failed"]="Не удалось остановить сервис torctl"
>["ru_tor_started"]="Сервис tor успешно запущен"
>["ru_tor_start_failed"]="Не удалось запустить сервис tor"
>["ru_tor_stopped"]="tor успешно остановлен"
>["ru_tor_stop_failed"]="Не удалось остановить сервис tor"
>["ru_mac_changed"]="MAC адрес успешно изменен"
>["ru_mac_change_failed"]="Не удалось изменить MAC адреса"
>["ru_mac_reverted"]="MAC адрес успешно возвращен"
>["ru_mac_revert_failed"]="Не удалось вернуть MAC адреса"
>["ru_ip_changed"]="IP в сети tor успешно изменен"
>["ru_ip_change_failed"]="Не удалось изменить IP в сети tor"
>["ru_title"]="Управление tor/torctl"
>["ru_service"]="сервис"
>["ru_active"]="активен"
>["ru_inactive"]="неактивен"
>["ru_addresses"]="адреса"
>["ru_factory_defaults"]="заводские"
>["ru_fake"]="фейковые"
>["ru_button_start"]="Старт"
>["ru_button_stop"]="Стоп"
>["ru_button_change"]="Сменить"
>["ru_button_revert"]="Вернуть"
>["ru_button_change_ip"]="Сменить IP"
>["ru_dependencies"]="Отсутствующие зависимости:"
>
># German
>["de_auth"]="Geben Sie das Root-Passwort ein"
>["de_wrong_password"]="Falsches Passwort! Beenden."
>["de_torctl_started"]="torctl-Dienst erfolgreich gestartet"
>["de_torctl_start_failed"]="Fehler beim Starten des torctl-Dienstes"
>["de_torctl_stopped"]="torctl-Dienst erfolgreich gestoppt"
>["de_torctl_stop_failed"]="Fehler beim Stoppen des torctl-Dienstes."
>["de_tor_started"]="tor-Dienst erfolgreich gestartet"
>["de_tor_start_failed"]="Fehler beim Starten des tor-Dienstes"
>["de_tor_stopped"]="tor-Dienst erfolgreich gestoppt"
>["de_tor_stop_failed"]="Fehler beim Stoppen des tor-Dienstes"
>["de_mac_changed"]="MAC-Adresse erfolgreich geändert"
>["de_mac_change_failed"]="MAC-Adressen konnten nicht geändert werden"
>["de_mac_reverted"]="MAC-Adresse erfolgreich zurückgesetzt"
>["de_mac_revert_failed"]="MAC-Adressen konnten nicht zurückgesetzt werden"
>["de_ip_changed"]="IP-Adresse im tor-Netzwerk erfolgreich geändert"
>["de_ip_change_failed"]="IP-Adresse im tor-Netzwerk konnte nicht geändert werden"
>["de_title"]="Tor/torctl steuern"
>["de_service"]="Dienst"
>["de_active"]="aktiv"
>["de_inactive"]="inaktiv"
>["de_addresses"]="Adressen"
>["de_factory_defaults"]="Werkseinstellungen"
>["de_fake"]="falsch"
>["de_button_start"]="Start"
>["de_button_stop"]="Stopp"
>["de_button_change"]="Ändern"
>["de_button_revert"]="Zurücksetzen"
>["de_button_change_ip"]="IP ändern"
>["de_dependencies"]="Fehlende Abhängigkeiten:"
>
># Spanish
>["es_auth"]="Ingrese la contraseña de root"
>["es_wrong_password"]="¡Contraseña incorrecta! Saliendo."
>["es_torctl_started"]="Servicio torctl iniciado correctamente"
>["es_torctl_start_failed"]="Error al iniciar el servicio torctl"
>["es_torctl_stopped"]="Servicio torctl detenido correctamente"
>["es_torctl_stop_failed"]="Error al detener el servicio torctl."
>["es_tor_started"]="Servicio tor iniciado correctamente"
>["es_tor_start_failed"]="Error al iniciar el servicio tor"
>["es_tor_stopped"]="Servicio tor detenido correctamente"
>["es_tor_stop_failed"]="Error al detener el servicio tor"
>["es_mac_changed"]="Dirección MAC cambiada correctamente"
>["es_mac_change_failed"]="Error al cambiar las direcciones MAC"
>["es_mac_reverted"]="Dirección MAC revertida correctamente"
>["es_mac_revert_failed"]="Error al revertir las direcciones MAC"
>["es_ip_changed"]="Dirección IP en la red tor cambiada correctamente"
>["es_ip_change_failed"]="Error al cambiar la dirección IP en la red tor"
>["es_title"]="Controlar tor/torctl"
>["es_service"]="servicio"
>["es_active"]="activo"
>["es_inactive"]="inactivo"
>["es_addresses"]="direcciones"
>["es_factory_defaults"]="configuración de fábrica"
>["es_fake"]="falsa"
>["es_button_start"]="Iniciar"
>["es_button_stop"]="Detener"
>["es_button_change"]="Cambiar"
>["es_button_revert"]="Revertir"
>["es_button_change_ip"]="Cambiar IP"
>["es_dependencies"]="Dependencias faltantes:"
>
># French
>["fr_auth"]="Entrez le mot de passe root"
>["fr_wrong_password"]="Mot de passe incorrect ! Fermeture."
>["fr_torctl_started"]="Service torctl démarré avec succès"
>["fr_torctl_start_failed"]="Impossible de démarrer le service torctl"
>["fr_torctl_stopped"]="Service torctl arrêté avec succès"
>["fr_torctl_stop_failed"]="Impossible d'arrêter le service torctl."
>["fr_tor_started"]="Service tor démarré avec succès"
>["fr_tor_start_failed"]="Impossible de démarrer le service tor"
>["fr_tor_stopped"]="Service tor arrêté avec succès"
>["fr_tor_stop_failed"]="Impossible d'arrêter le service tor"
>["fr_mac_changed"]="Adresse MAC modifiée avec succès"
>["fr_mac_change_failed"]="Impossible de modifier les adresses MAC"
>["fr_mac_reverted"]="Adresse MAC rétablie avec succès"
>["fr_mac_revert_failed"]="Impossible de rétablir les adresses MAC"
>["fr_ip_changed"]="Adresse IP dans le réseau tor modifiée avec succès"
>["fr_ip_change_failed"]="Impossible de changer l'adresse IP dans le réseau tor"
>["fr_title"]="Contrôler tor/torctl"
>["fr_service"]="service"
>["fr_active"]="actif"
>["fr_inactive"]="inactif"
>["fr_addresses"]="adresses"
>["fr_factory_defaults"]="paramètres d'usine"
>["fr_fake"]="fausses"
>["fr_button_start"]="Démarrer"
>["fr_button_stop"]="Arrêter"
>["fr_button_change"]="Changer"
>["fr_button_revert"]="Revenir"
>["fr_button_change_ip"]="Changer IP"
>["fr_dependencies"]="Dépendances manquantes:"
>
># Italian
>["it_auth"]="Inserisci la password di root"
>["it_wrong_password"]="Password errata! Uscita."
>["it_torctl_started"]="Servizio torctl avviato con successo"
>["it_torctl_start_failed"]="Impossibile avviare il servizio torctl"
>["it_torctl_stopped"]="Servizio torctl arrestato con successo"
>["it_torctl_stop_failed"]="Impossibile arrestare il servizio torctl."
>["it_tor_started"]="Servizio tor avviato con successo"
>["it_tor_start_failed"]="Impossibile avviare il servizio tor"
>["it_tor_stopped"]="Servizio tor arrestato con successo"
>["it_tor_stop_failed"]="Impossibile arrestare il servizio tor"
>["it_mac_changed"]="Indirizzo MAC cambiato con successo"
>["it_mac_change_failed"]="Impossibile cambiare gli indirizzi MAC"
>["it_mac_reverted"]="Indirizzo MAC ripristinato con successo"
>["it_mac_revert_failed"]="Impossibile ripristinare gli indirizzi MAC"
>["it_ip_changed"]="Indirizzo IP nella rete tor cambiato con successo"
>["it_ip_change_failed"]="Impossibile cambiare l'indirizzo IP nella rete tor"
>["it_title"]="Controllo tor/torctl"
>["it_service"]="servizio"
>["it_active"]="attivo"
>["it_inactive"]="inattivo"
>["it_addresses"]="indirizzi"
>["it_factory_defaults"]="impostazioni di fabbrica"
>["it_fake"]="falso"
>["it_button_start"]="Avvia"
>["it_button_stop"]="Arresta"
>["it_button_change"]="Cambia"
>["it_button_revert"]="Ripristina"
>["it_button_change_ip"]="Cambia IP"
>["it_dependencies"]="Dipendenze mancanti:"
>
># Portuguese
>["pt_auth"]="Digite a senha de root"
>["pt_wrong_password"]="Senha incorreta! Saindo."
>["pt_torctl_started"]="Serviço torctl iniciado com sucesso"
>["pt_torctl_start_failed"]="Falha ao iniciar o serviço torctl"
>["pt_torctl_stopped"]="Serviço torctl parado com sucesso"
>["pt_torctl_stop_failed"]="Falha ao parar o serviço torctl."
>["pt_tor_started"]="Serviço tor iniciado com sucesso"
>["pt_tor_start_failed"]="Falha ao iniciar o serviço tor"
>["pt_tor_stopped"]="Serviço tor parado com sucesso"
>["pt_tor_stop_failed"]="Falha ao parar o serviço tor"
>["pt_mac_changed"]="Endereço MAC alterado com sucesso"
>["pt_mac_change_failed"]="Falha ao alterar endereços MAC"
>["pt_mac_reverted"]="Endereço MAC revertido com sucesso"
>["pt_mac_revert_failed"]="Falha ao reverter endereços MAC"
>["pt_ip_changed"]="Endereço IP na rede tor alterado com sucesso"
>["pt_ip_change_failed"]="Falha ao alterar endereço IP na rede tor"
>["pt_title"]="Controlar tor/torctl"
>["pt_service"]="serviço"
>["pt_active"]="ativo"
>["pt_inactive"]="inativo"
>["pt_addresses"]="endereços"
>["pt_factory_defaults"]="padrões de fábrica"
>["pt_fake"]="falso"
>["pt_button_start"]="Iniciar"
>["pt_button_stop"]="Parar"
>["pt_button_change"]="Mudar"
>["pt_button_revert"]="Reverter"
>["pt_button_change_ip"]="Mudar IP"
>["pt_dependencies"]="Dependências ausentes:"
>
># Polish
>["pl_auth"]="Wprowadź hasło root"
>["pl_wrong_password"]="Nieprawidłowe hasło! Zamykanie."
>["pl_torctl_started"]="Usługa torctl została pomyślnie uruchomiona"
>["pl_torctl_start_failed"]="Nie udało się uruchomić usługi torctl"
>["pl_torctl_stopped"]="Usługa torctl została pomyślnie zatrzymana"
>["pl_torctl_stop_failed"]="Nie udało się zatrzymać usługi torctl."
>["pl_tor_started"]="Usługa tor została pomyślnie uruchomiona"
>["pl_tor_start_failed"]="Nie udało się uruchomić usługi tor"
>["pl_tor_stopped"]="Usługa tor została pomyślnie zatrzymana"
>["pl_tor_stop_failed"]="Nie udało się zatrzymać usługi tor"
>["pl_mac_changed"]="Adres MAC został pomyślnie zmieniony"
>["pl_mac_change_failed"]="Nie udało się zmienić adresów MAC"
>["pl_mac_reverted"]="Adres MAC został pomyślnie przywrócony"
>["pl_mac_revert_failed"]="Nie udało się przywrócić adresów MAC"
>["pl_ip_changed"]="Adres IP w sieci tor został pomyślnie zmieniony"
>["pl_ip_change_failed"]="Nie udało się zmienić adresu IP w sieci tor"
>["pl_title"]="Kontroluj tor/torctl"
>["pl_service"]="usługa"
>["pl_active"]="aktywny"
>["pl_inactive"]="nieaktywny"
>["pl_addresses"]="adresy"
>["pl_factory_defaults"]="domyślne ustawienia"
>["pl_fake"]="fałszywe"
>["pl_button_start"]="Rozpocznij"
>["pl_button_stop"]="Zatrzymaj"
>["pl_button_change"]="Zmień"
>["pl_button_revert"]="Przywróć"
>["pl_button_change_ip"]="Zmień IP"
>["pl_dependencies"]="Brakujące zależności:"
>
># Czech
>["cs_auth"]="Zadejte heslo root"
>["cs_wrong_password"]="Nesprávné heslo! Ukončení."
>["cs_torctl_started"]="Služba torctl byla úspěšně spuštěna"
>["cs_torctl_start_failed"]="Nepodařilo se spustit službu torctl"
>["cs_torctl_stopped"]="Služba torctl byla úspěšně zastavena"
>["cs_torctl_stop_failed"]="Nepodařilo se zastavit službu torctl."
>["cs_tor_started"]="Služba tor byla úspěšně spuštěna"
>["cs_tor_start_failed"]="Nepodařilo se spustit službu tor"
>["cs_tor_stopped"]="Služba tor byla úspěšně zastavena"
>["cs_tor_stop_failed"]="Nepodařilo se zastavit službu tor"
>["cs_mac_changed"]="MAC adresa byla úspěšně změněna"
>["cs_mac_change_failed"]="Nepodařilo se změnit MAC adresy"
>["cs_mac_reverted"]="MAC adresa byla úspěšně obnovena"
>["cs_mac_revert_failed"]="Nepodařilo se obnovit MAC adresy"
>["cs_ip_changed"]="IP adresa v síti tor byla úspěšně změněna"
>["cs_ip_change_failed"]="Nepodařilo se změnit IP adresu v síti tor"
>["cs_title"]="Ovládání tor/torctl"
>["cs_service"]="služba"
>["cs_active"]="aktivní"
>["cs_inactive"]="neaktivní"
>["cs_addresses"]="adresy"
>["cs_factory_defaults"]="výchozí nastavení"
>["cs_fake"]="falešný"
>["cs_button_start"]="Spustit"
>["cs_button_stop"]="Zastavit"
>["cs_button_change"]="Změnit"
>["cs_button_revert"]="Obnovit"
>["cs_button_change_ip"]="Změnit IP"
>["cs_dependencies"]="Chybějící závislosti:"
>
># Croatian
>["hr_auth"]="Unesite root lozinku"
>["hr_wrong_password"]="Pogrešna lozinka! Izlazak."
>["hr_torctl_started"]="Usluga torctl uspješno pokrenuta"
>["hr_torctl_start_failed"]="Nije uspjelo pokretanje usluge torctl"
>["hr_torctl_stopped"]="Usluga torctl uspješno zaustavljena"
>["hr_torctl_stop_failed"]="Nije uspjelo zaustavljanje usluge torctl."
>["hr_tor_started"]="Usluga tor uspješno pokrenuta"
>["hr_tor_start_failed"]="Nije uspjelo pokretanje usluge tor"
>["hr_tor_stopped"]="Usluga tor uspješno zaustavljena"
>["hr_tor_stop_failed"]="Nije uspjelo zaustavljanje usluge tor"
>["hr_mac_changed"]="MAC adresa uspješno promijenjena"
>["hr_mac_change_failed"]="Nije uspjelo promijeniti MAC adrese"
>["hr_mac_reverted"]="MAC adresa uspješno vraćena"
>["hr_mac_revert_failed"]="Nije uspjelo vratiti MAC adrese"
>["hr_ip_changed"]="IP adresa u tor mreži uspješno promijenjena"
>["hr_ip_change_failed"]="Nije uspjelo promijeniti IP adresu u tor mreži"
>["hr_title"]="Upravljanje tor/torctl"
>["hr_service"]="usluga"
>["hr_active"]="aktivno"
>["hr_inactive"]="neaktivno"
>["hr_addresses"]="adrese"
>["hr_factory_defaults"]="tvorničke postavke"
>["hr_fake"]="lažno"
>["hr_button_start"]="Pokreni"
>["hr_button_stop"]="Zaustavi"
>["hr_button_change"]="Promijeni"
>["hr_button_revert"]="Vrati"
>["hr_button_change_ip"]="Promijeni IP"
>["hr_dependencies"]="Nedostajuće ovisnosti:"
>
># Slovenian
>["sl_auth"]="Vnesite root geslo"
>["sl_wrong_password"]="Napačno geslo! Izhod."
>["sl_torctl_started"]="Storitev torctl uspešno zagnana"
>["sl_torctl_start_failed"]="Zagon storitve torctl ni uspel"
>["sl_torctl_stopped"]="Storitev torctl uspešno ustavljena"
>["sl_torctl_stop_failed"]="Ustavitev storitve torctl ni uspela."
>["sl_tor_started"]="Storitev tor uspešno zagnana"
>["sl_tor_start_failed"]="Zagon storitve tor ni uspel"
>["sl_tor_stopped"]="Storitev tor uspešno ustavljena"
>["sl_tor_stop_failed"]="Ustavitev storitve tor ni uspela"
>["sl_mac_changed"]="MAC naslov uspešno spremenjen"
>["sl_mac_change_failed"]="Sprememba MAC naslovov ni uspela"
>["sl_mac_reverted"]="MAC naslov uspešno povrnjen"
>["sl_mac_revert_failed"]="Povrnitev MAC naslovov ni uspela"
>["sl_ip_changed"]="IP naslov v tor omrežju uspešno spremenjen"
>["sl_ip_change_failed"]="Sprememba IP naslova v tor omrežju ni uspela"
>["sl_title"]="Nadzorovanje tor/torctl"
>["sl_service"]="storitev"
>["sl_active"]="aktivno"
>["sl_inactive"]="neaktivno"
>["sl_addresses"]="naslovi"
>["sl_factory_defaults"]="privzete nastavitve"
>["sl_fake"]="lažno"
>["sl_button_start"]="Začni"
>["sl_button_stop"]="Ustavi"
>["sl_button_change"]="Spremeni"
>["sl_button_revert"]="Povrni"
>["sl_button_change_ip"]="Spremeni IP"
>["sl_dependencies"]="Manjkajoče odvisnosti:"
>
># Hebrew
>["he_auth"]="הזן סיסמת שורש"
>["he_wrong_password"]="סיסמה שגויה! יוצא."
>["he_torctl_started"]="שירות torctl הופעל בהצלחה"
>["he_torctl_start_failed"]="נכשל בהפעלת שירות torctl"
>["he_torctl_stopped"]="שירות torctl עוצר בהצלחה"
>["he_torctl_stop_failed"]="נכשל בעצירת שירות torctl."
>["he_tor_started"]="שירות tor הופעל בהצלחה"
>["he_tor_start_failed"]="נכשל בהפעלת שירות tor"
>["he_tor_stopped"]="שירות tor עוצר בהצלחה"
>["he_tor_stop_failed"]="נכשל בעצירת שירות tor"
>["he_mac_changed"]="כתובת MAC שונתה בהצלחה"
>["he_mac_change_failed"]="נכשל בשינוי כתובות MAC"
>["he_mac_reverted"]="כתובת MAC שוחזרה בהצלחה"
>["he_mac_revert_failed"]="נכשל בשחזור כתובות MAC"
>["he_ip_changed"]="כתובת IP ברשת tor שונתה בהצלחה"
>["he_ip_change_failed"]="נכשל בשינוי כתובת IP ברשת tor"
>["he_title"]="בקר ב tor/torctl"
>["he_service"]="שירות"
>["he_active"]="פעיל"
>["he_inactive"]="לא פעיל"
>["he_addresses"]="כתובות"
>["he_factory_defaults"]="ברירות מחדל יצרן"
>["he_fake"]="מזויף"
>["he_button_start"]="התחל"
>["he_button_stop"]="עצור"
>["he_button_change"]="שנה"
>["he_button_revert"]="החזר"
>["he_button_change_ip"]="שנה IP"
>["he_dependencies"]="תלויות חסרות:"
>
># Tatar
>["tt_auth"]="Root parolını gir"
>["tt_wrong_password"]="Yanlış parol! Çıkış."
>["tt_torctl_started"]="torctl xidmätı üzläñ yürüdülü"
>["tt_torctl_start_failed"]="torctl xidmätını yürütmege täxlämdi"
>["tt_torctl_stopped"]="torctl xidmätı üzläñ toxtatıldı"
>["tt_torctl_stop_failed"]="torctl xidmätını toxtatmağa täxlämdi."
>["tt_tor_started"]="tor xidmätı üzläñ yürüdülü"
>["tt_tor_start_failed"]="tor xidmätını yürütmege täxlämdi"
>["tt_tor_stopped"]="tor xidmätı üzläñ toxtatıldı"
>["tt_tor_stop_failed"]="tor xidmätını toxtatmağa täxlämdi"
>["tt_mac_changed"]="MAC adresı üzläñ yırışlı alıntıldı"
>["tt_mac_change_failed"]="MAC adresnı alıntılab yırışmağa täxlämdi"
>["tt_mac_reverted"]="MAC adresı üzläñ yırışlı tikeltelde"
>["tt_mac_revert_failed"]="MAC adresnı tikeltelgä täxlämdi"
>["tt_ip_changed"]="tor qulınıuı IP adresı üzläñ yırışlı alıntıldı"
>["tt_ip_change_failed"]="tor qulınıuı IP adresnı yırışmağa täxlämdi"
>["tt_title"]="tor/torctl yönete"
>["tt_service"]="xidmät"
>["tt_active"]="aktiw"
>["tt_inactive"]="aktiw eme"
>["tt_addresses"]="adresslar"
>["tt_factory_defaults"]="fabrika defoltarı"
>["tt_fake"]="naql"
>["tt_button_start"]="Başlat"
>["tt_button_stop"]="Toxtat"
>["tt_button_change"]="Üzlä"
>["tt_button_revert"]="Yırtaw"
>["tt_button_change_ip"]="IP yırış"
>["tt_dependencies"]="Sinası alınmamış qılmaslar:"
>
># Georgian
>["ka_auth"]="შეიყვანეთ root პაროლი"
>["ka_wrong_password"]="არასწორი პაროლი! გასვლა."
>["ka_torctl_started"]="torctl მომსახურება წარმატებით ჩაირთა"
>["ka_torctl_start_failed"]="torctl მომსახურების ჩართვა ვერ ხერხდება"
>["ka_torctl_stopped"]="torctl მომსახურება წარმატებით შეჩერებულია"
>["ka_torctl_stop_failed"]="torctl მომსახურების შეჩერება ვერ ხერხდება."
>["ka_tor_started"]="tor მომსახურება წარმატებით ჩაირთა"
>["ka_tor_start_failed"]="tor მომსახურების ჩართვა ვერ ხერხდება"
>["ka_tor_stopped"]="tor მომსახურება წარმატებით შეჩერებულია"
>["ka_tor_stop_failed"]="tor მომსახურების შეჩერება ვერ ხერხდება"
>["ka_mac_changed"]="MAC მისამართი წარმატებით შეიცვალა"
>["ka_mac_change_failed"]="MAC მისამართების შეცვლა ვერ ხერხდება"
>["ka_mac_reverted"]="MAC მისამართი წარმატებით დაბრუნდა"
>["ka_mac_revert_failed"]="MAC მისამართების დაბრუნება ვერ ხერხდება"
>["ka_ip_changed"]="tor ქსელში IP მისამართი წარმატებით შეიცვალა"
>["ka_ip_change_failed"]="tor ქსელში IP მისამართის შეცვლა ვერ ხერხდება"
>["ka_title"]="tor/torctl-ის მართვა"
>["ka_service"]="მომსახურება"
>["ka_active"]="აქტიური"
>["ka_inactive"]="არააქტიური"
>["ka_addresses"]="მისამართები"
>["ka_factory_defaults"]="საქონლის საწყობის მდგომარეობა"
>["ka_fake"]="ზარი"
>["ka_button_start"]="დაწყება"
>["ka_button_stop"]="შეჩერება"
>["ka_button_change"]="შეცვლა"
>["ka_button_revert"]="დაბრუნება"
>["ka_button_change_ip"]="IP შეცვლა"
>["ka_dependencies"]="გამონაკლისების გარეშე:"
>
>#Turkish
>["tr_auth"]="Kök şifresini girin"
>["tr_wrong_password"]="Yanlış şifre! Çıkılıyor."
>["tr_torctl_started"]="torctl servisi başarıyla başlatıldı"
>["tr_torctl_start_failed"]="torctl servisi başlatılamadı"
>["tr_torctl_stopped"]="torctl servisi başarıyla durduruldu"
>["tr_torctl_stop_failed"]="torctl servisi durdurulamadı."
>["tr_tor_started"]="tor servisi başarıyla başlatıldı"
>["tr_tor_start_failed"]="tor servisi başlatılamadı"
>["tr_tor_stopped"]="tor servisi başarıyla durduruldu"
>["tr_tor_stop_failed"]="tor servisi durdurulamadı"
>["tr_mac_changed"]="MAC adresi başarıyla değiştirildi"
>["tr_mac_change_failed"]="MAC adresleri değiştirilemedi"
>["tr_mac_reverted"]="MAC adresi başarıyla geri alındı"
>["tr_mac_revert_failed"]="MAC adresleri geri alınamadı"
>["tr_ip_changed"]="tor ağındaki IP adresi başarıyla değiştirildi"
>["tr_ip_change_failed"]="tor ağındaki IP adresi değiştirilemedi"
>["tr_title"]="tor/torctl kontrolü"
>["tr_service"]="hizmet"
>["tr_active"]="aktif"
>["tr_inactive"]="etkisiz"
>["tr_addresses"]="adresler"
>["tr_factory_defaults"]="fabrika ayarları"
>["tr_fake"]="sahte"
>["tr_button_start"]="Başlat"
>["tr_button_stop"]="Durdur"
>["tr_button_change"]="Değiştir"
>["tr_button_revert"]="Geri Al"
>["tr_button_change_ip"]="IP Değiştir"
>["tr_dependencies"]="Eksik bağımlılıklar:"
>
>#Armenian
>["hy_auth"]="Մուտքագրեք ռուդ գաղտնաբառը"
>["hy_wrong_password"]="Սխալ գաղտնաբառ! Ելք:"
>["hy_torctl_started"]="torctl ծառայությունը հաջողությամբ աշխատվեց"
>["hy_torctl_start_failed"]="Չհաջողվեց torctl ծառայության սկիզբը"
>["hy_torctl_stopped"]="torctl ծառայությունը հաջողությամբ դադարվեց"
>["hy_torctl_stop_failed"]="Չհաջողվեց դադարեցնել torctl ծառայությունը:"
>["hy_tor_started"]="tor ծառայությունը հաջողությամբ աշխատվեց"
>["hy_tor_start_failed"]="Չհաջողվեց սկսել tor ծառայությունը"
>["hy_tor_stopped"]="tor ծառայությունը հաջողությամբ դադարվեց"
>["hy_tor_stop_failed"]="Չհաջողվեց դադարեցնել tor ծառայությունը"
>["hy_mac_changed"]="MAC հասցեն հաջողությամբ փոխվեց"
>["hy_mac_change_failed"]="Չհաջողվեց փոխել MAC հասցեները"
>["hy_mac_reverted"]="MAC հասցեն հաջողությամբ վերականգնվեց"
>["hy_mac_revert_failed"]="Չհաջողվեց վերականգնել MAC հասցեները"
>["hy_ip_changed"]="tor ցանցում IP հասցեն հաջողությամբ փոխվեց"
>["hy_ip_change_failed"]="Չհաջողվեց փոխել tor ցանցում IP հասցեն"
>["hy_title"]="tor/torctl կառավարում"
>["hy_service"]="ծառայություն"
>["hy_active"]="ակտիվ"
>["hy_inactive"]="ակտիվ չէ"
>["hy_addresses"]="հասցեներ"
>["hy_factory_defaults"]="գործարկային լռելյայնություն"
>["hy_fake"]="կեղծ"
>["hy_button_start"]="Սկսել"
>["hy_button_stop"]="Կանգնել"
>["hy_button_change"]="Փոխել"
>["hy_button_revert"]="Վերականգնել"
>["hy_button_change_ip"]="IP փոխել"
>["hy_dependencies"]="Բարդությունները բացակայում են:"
>
>#Kazakh
>["kk_auth"]="Root құпия сөзін енгізіңіз"
>["kk_wrong_password"]="Дұрыс құпия сөз! Шығу."
>["kk_torctl_started"]="torctl қызметі сәтті жүргізілді"
>["kk_torctl_start_failed"]="torctl қызметін бастау мүмкін болмады"
>["kk_torctl_stopped"]="torctl қызметі сәтті тоқтатылды"
>["kk_torctl_stop_failed"]="torctl қызметін тоқтату мүмкін болмады."
>["kk_tor_started"]="tor қызметі сәтті жүргізілді"
>["kk_tor_start_failed"]="tor қызметін бастау мүмкін болмады"
>["kk_tor_stopped"]="tor қызметі сәтті тоқтатылды"
>["kk_tor_stop_failed"]="tor қызметін тоқтату мүмкін болмады"
>["kk_mac_changed"]="MAC мекенжайы сәтті өзгертілді"
>["kk_mac_change_failed"]="MAC мекенжайларын өзгерту мүмкін болмады"
>["kk_mac_reverted"]="MAC мекенжайы сәтті кірістірілді"
>["kk_mac_revert_failed"]="MAC мекенжайларын кірістіру мүмкін болмады"
>["kk_ip_changed"]="tor желісіндегі IP мекенжайы сәтті өзгертілді"
>["kk_ip_change_failed"]="tor желісіндегі IP мекенжайын өзгерту мүмкін болмады"
>["kk_title"]="tor/torctl басқару"
>["kk_service"]="қызмет"
>["kk_active"]="жұмыс істейді"
>["kk_inactive"]="жұмыс істемейді"
>["kk_addresses"]="мекенжайдар"
>["kk_factory_defaults"]="завод дефолттары"
>["kk_fake"]="тәулік"
>["kk_button_start"]="Бастау"
>["kk_button_stop"]="Тоқтату"
>["kk_button_change"]="Өзгерту"
>["kk_button_revert"]="Қайтару"
>["kk_button_change_ip"]="IP өзгерту"
>["kk_dependencies"]="Тиісті қауіпсіздіктер:"
>)
>
>lang_app="en"
># Determine the language
>for key in "${!MESSAGES[@]}"; do
>    lang_key=$(echo "$key" | cut -d '_' -f1)
>    if [[ "$lang_key" == "$(echo $LANG | cut -d '_' -f1)" ]]; then
>        lang_app=$lang_key
>        break
>    fi
>done
>
># Function to check dependencies
>check_dependencies() {
>    local dependencies=("torctl" "tor" "yad" "macchanger" "faillock" "notify-send" "systemctl" "sudo")
>    local missing_dependencies=()
>
>    for dep in "${dependencies[@]}"; do
>        if ! command -v "$dep" > /dev/null 2>&1; then
>            missing_dependencies+=("$dep")
>        fi
>    done
>
>    if [ ${#missing_dependencies[@]} -ne 0 ]; then
>        echo "${MESSAGES[${lang_app}_dependencies]} ${missing_dependencies[*]}"  # Message for all languages
>        exit 1
>    fi
>}
>
># Check dependencies before executing the main script
>check_dependencies
>
># Clear failed login attempts
>faillock --user $USER --reset
>
># Ask for root password
>password=$(yad --entry --title="${MESSAGES[${lang_app}_title]}" \
>--window-icon="lock" --image "lock" \
>--width=300 --fixed \
>--text="${MESSAGES[${lang_app}_auth]}": --hide-text)
>
>if [ -z $password ]; then
>    exit 0
>fi
>
># Function to display messages
>notify_show() {
>    notify-send "$1" --icon=$2 --app-name="$3 " --expire-time=4000
>}
>
># Check password using sudo
>echo "$password" | sudo -S ls >/dev/null 2>&1
>if [ $? -ne 0 ]; then
>    notify_show "${MESSAGES[${lang_app}_wrong_password]}" "state-error" "Error"
>    exit 1
>fi
>
>ICON="/tmp/tor_icon.svg"
>
># Tor icon in SVG format
>tor_icon_SVG='<svg
>xmlns="http://www.w3.org/2000/svg"
>xmlns:xlink="http://www.w3.org/1999/xlink"
>width="48" height="48"><linearGradient id="b" x1="3.365" x2="36.074" y1="1046.
>22" y2="1007.718" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color=
>"#235ea2"/><stop offset="1" stop-color="#1992f1"/></linearGradient>
><linearGradient xlink:href="#a" id="c" x1="400.571" x2="400.794" y1="545.798"
>y2="517.627" gradientUnits="userSpaceOnUse"/><linearGradient id="a"><stop
>offset="0" stop-color="#69159f"/><stop offset="1" stop-color="#b92ff5"/>
></linearGradient><linearGradient id="d" x1="3.365" x2="36.074" y1="1046.22" y2=
>"1007.718" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#d3d3d3"
>/><stop offset="1" stop-color="#fcf9f9"/></linearGradient><linearGradient
>xlink:href="#a" id="g" x1="408.556" x2="415.144" y1="553.74" y2="517.596"
>gradientUnits="userSpaceOnUse"/><linearGradient id="h" x1="403.886" x2="403.41"
>y1="545.695" y2="502.445" gradientUnits="userSpaceOnUse"><stop offset="0"
>stop-color="#faf7f7"/><stop offset="1" stop-color="#fcf9f9"/></linearGradient>
><linearGradient id="e" x1="407.075" x2="408.095" y1="513.767" y2="500.696"
>gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#abcd03"/><stop
>offset="1" stop-color="#b3ff80"/></linearGradient><g fill="url(#b)"
>stroke-width="1.3" transform="translate(-577.541 -774.605)scale(1.5017)">
><circle cx="400.571" cy="531.798" r="14"/><circle cx="400.571" cy="531.798" r=
>"14" fill="url(#c)"/></g><path fill-opacity=".157" d="M30.033 3.87c-1.59.
>825-3.053 1.717-4.275 2.747l-.903-.902c-1.139 1.412-2.02 2.857-2.572
>4.297l-1.363-.567c.938 2.421 1.107 4.294.139 5.14-3.813 3.148-10.2 6.687-10.2
>12.013 0 1.807.35 3.66 1.102 5.361q.236.529.525 1.035l.045.078a11 11 0 0 0 1.24
>1.733l.022.023.092.1q.171.19.353.37l9.723 9.723.039.002A21.024 21.024 0 0 0
>45.023 24a21 21 0 0
>0-2.068-9.049l-9.89-9.89-.208-.1c-.247.063-.483.138-.728.203l-.863-.863a21
>21 0 0 0-1.233-.432"/><g fill="none" stroke="url(#d)" stroke-width=
>"1.3" transform="translate(-577.541 -774.605)scale(1.5017)"><circle cx=
>"400.571" cy="531.798" r="14"/><circle cx="400.571" cy="531.798" r="14"/></g>
><path fill="url(#e)" d="m409.54 503.227-1.396 3.857c1.978-2.724 5.118-4.774
>8.724-6.581-2.637 2.13-5.04 4.262-6.514 6.393 2.482-2.428 5.816-3.777
>9.576-4.667-5.001 3.102-8.97 6.43-11.995 9.775l-2.403-.728c.426-2.67
>1.876-5.405 4.008-8.049" transform="translate(-293.942 -385.902)scale(.77821)"
>/><path fill="#fffcdb" d="m20.83 9.417 3.57 1.481c0 .908-.074 3.677.494 4.494
>5.938 7.648 4.94 22.978-1.203 23.37-9.353 0-12.92-6.353-12.92-12.193 0-5.325
>6.384-8.865 10.197-12.012.968-.847.8-2.72-.138-5.14"/><path fill="url(#g)" d=
>"m409.071 509.82 1.654.844c-.156 1.088.077 3.499 1.166 4.12 4.821 2.995 9.37
>6.26 11.159 9.527 6.376 11.509-4.472 22.162-13.842 21.15 5.093-3.77
>6.571-11.508
>4.666-19.945-.778-3.305-1.983-6.3-4.122-9.682-.926-1.66-.603-3.72-.68-6.014"
>transform="translate(-293.942 -385.902)scale(.77821)"/><path fill-opacity=
>".157" d="M22.404 10.07v.051l-.003.007v28.578c.42.029.843.057 1.29.057
>6.142-.393 7.14-15.724
>1.202-23.371-.567-.817-.494-3.587-.494-4.495l-1.996-.826zM11.872
>31.96l.047.098-.047-.099m.502.996.068.116zm.603.952.086.119zm.706.897.112.123zm3.928
>2.817.202.086zm1.306.478.172.053zm1.47.363.093.018-.094-.018"/><path fill=
>"url(#h)" d="M404.483 508.021c1.206 3.11 1.422 5.517.178 6.606-4.9 4.044-13.105
>8.592-13.105 15.436 0 7.145 4.173 14.872 14.948 15.596V508.86z" transform=
>"translate(-293.942 -385.902)scale(.77821)"/>
></svg>'
>
># Save the image in SVG
>echo "$tor_icon_SVG" > $ICON
>
># Function to check the status of the torctl service
>check_torctl_status() {
>    status=$(echo "$password" | sudo -S torctl status)
>    if [[ $status == *"[+] torctl is started"* ]]; then
>        return 0  # torctl service is active
>    else
>        return 1  # torctl service is inactive
>    fi
>}
>
># Function to check the status of the tor service
>check_tor_status() {
>    status=$(echo "$password" | sudo -S systemctl is-active tor)
>    if [[ $status == "active" ]]; then
>        return 0  # tor service is active
>    else
>        return 1  # tor service is inactive
>    fi
>}
>
># Function to check if MAC addresses are factory defaults
>check_mac_equals() {
>    interface=$(ip -o link show | awk -F': ' '!/lo/{print $2; exit}')
>    current_mac=$(echo "$password" | sudo -S macchanger --show $interface | awk '/Current/{print $3}')
>    permanent_mac=$(echo "$password" | sudo -S macchanger --show $interface | awk '/Permanent/{print $3}')
>    if [[ $current_mac == $permanent_mac ]]; then
>        return 0  # MAC addresses are factory defaults
>    else
>        return 1  # MAC addresses are fake
>    fi
>}
>
># Function to start torctl
>start_torctl() {
>    echo "$password" | sudo -S torctl start
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_torctl_started]}" $ICON
>    else
>        notify_show "${MESSAGES[${lang_app}_torctl_start_failed]}" $ICON "Error"
>    fi
>}
>
># Function to stop torctl
>stop_torctl() {
>    echo "$password" | sudo -S torctl stop
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_torctl_stopped]}" $ICON
>    else
>        notify_show "${MESSAGES[${lang_app}_torctl_stop_failed]}" $ICON "Error"
>    fi
>}
>
># Function to start tor
>start_tor() {
>     echo "$password" | sudo -S systemctl start tor
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_tor_started]}" "tor"
>    else
>        notify_show "${MESSAGES[${lang_app}_tor_start_failed]}" "tor" "Error"
>    fi
>}
>
># Function to stop tor
>stop_tor() {
>     echo "$password" | sudo -S systemctl stop tor
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_tor_stopped]}" "tor"
>    else
>        notify_show "${MESSAGES[${lang_app}_tor_stop_failed]}" "tor" "Error"
>    fi
>}
>
># Function to change MAC addresses on all network interfaces
>change_mac() {
>    echo "$password" | sudo -S torctl chngmac
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_mac_changed]}" $ICON
>    else
>        notify_show "${MESSAGES[${lang_app}_mac_change_failed]}" $ICON "Error"
>    fi
>}
>
># Function to revert MAC addresses on all network interfaces
>revert_mac() {
>    echo "$password" | sudo -S torctl rvmac
>    if [ $? -eq 0 ]; then
>        notify_show "${MESSAGES[${lang_app}_mac_reverted]}" $ICON
>    else
>        notify_show "${MESSAGES[${lang_app}_mac_revert_failed]}" $ICON "Error"
>    fi
>}
>
># Function to change IP in tor network
>change_id() {
>    check_tor_status
>    if [ $? -eq 0 ]; then
>        echo "$password" | sudo -S systemctl stop tor
>        sleep 1
>        echo "$password" | sudo -S systemctl start tor
>            if [ $? -eq 0 ]; then
>                notify_show "${MESSAGES[${lang_app}_ip_changed]}" "tor"
>            else
>                notify_show "${MESSAGES[${lang_app}_tor_start_failed]}" "tor" "Error"
>            fi
>    else
>        notify_show "${MESSAGES[${lang_app}_ip_change_failed]}" "tor" "Error"
>    fi
>}
>
>do_exit () {
>    rm -f $ICON
>    exit 0
>}
>
># Main script window with buttons to call functions
>while true; do
>
>check_torctl_status
>if [ $? -eq 0 ]; then
>    status_torctl_label="<b>torctl</b> ${MESSAGES[${lang_app}_service]}: <span foreground='green'>${MESSAGES[${lang_app}_active]}</span>"
>    button_torctl_label="${MESSAGES[${lang_app}_button_stop]} <b>torctl</b>:2"
>else
>    status_torctl_label="<b>torctl</b> ${MESSAGES[${lang_app}_service]}: <span foreground='red'>${MESSAGES[${lang_app}_inactive]}</span>"
>    button_torctl_label="${MESSAGES[${lang_app}_button_start]} <b>torctl</b>:1"
>fi
>
>check_tor_status
>if [ $? -eq 0 ]; then
>    status_tor_label="<b>tor</b> ${MESSAGES[${lang_app}_service]}: <span foreground='green'>${MESSAGES[${lang_app}_active]}</span>"
>    button_tor_label="${MESSAGES[${lang_app}_button_stop]} <b>tor</b>:4"
>else
>    status_tor_label="<b>tor</b> ${MESSAGES[${lang_app}_service]}: <span foreground='red'>${MESSAGES[${lang_app}_inactive]}</span>"
>    button_tor_label="${MESSAGES[${lang_app}_button_start]} <b>tor</b>:3"
>fi
>
>check_mac_equals
>if [ $? -eq 0 ]; then
>    status_mac_label="<b>MAC</b> ${MESSAGES[${lang_app}_addresses]}: <span foreground='red'>${MESSAGES[${lang_app}_factory_defaults]}</span>"
>    button_mac_label="${MESSAGES[${lang_app}_button_change]} <b>MAC</b>:5"
>else
>    status_mac_label="<b>MAC</b> ${MESSAGES[${lang_app}_addresses]}: <span foreground='green'>${MESSAGES[${lang_app}_fake]}</span>"
>    button_mac_label="${MESSAGES[${lang_app}_button_revert]} <b>MAC</b>:6"
>fi
>
>    action=$(yad --fixed --title="${MESSAGES[${lang_app}_title]}" \
>        --window-icon=$ICON \
>        --image=$ICON \
>        --text="${status_torctl_label}\n${status_tor_label}\n${status_mac_label}" \
>        --button="$button_torctl_label" \
>        --button="$button_tor_label" \
>        --button="$button_mac_label" \
>        --button="${MESSAGES[${lang_app}_button_change_ip]}:7")
>
>    # Handling the return code
>    case $? in
>        1)
>            start_torctl
>            ;;
>        2)
>            stop_torctl
>            ;;
>        3)
>            start_tor
>            ;;
>        4)
>            stop_tor
>            ;;
>        5)
>            change_mac
>            ;;
>        6)
>            revert_mac
>            ;;
>        7)
>            change_id
>            ;;
>        252)
>            do_exit
>            ;;
>    esac
>done
>```

