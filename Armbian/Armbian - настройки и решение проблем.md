#  Первоначальная настройка
На флешке находим файл /boot/armbian_first_run.txt.template и переименовываем его в /boot/armbian_first_run.txt  

>В файле прописываешь точку доступа и пароль.

```ini
#-----------------------------------------------------------------  
# Armbian first run configuration  
# Set optional end user configuration  
#       - Rename this file from /boot/armbian_first_run.txt.template to /boot/armbian_first_run.txt  
#       - Settings below will be applied only on 1st run of Armbian  
#-----------------------------------------------------------------  
  
#-----------------------------------------------------------------  
# General:  
# 1 = delete this file, after first run setup is completed.  
  
FR_general_delete_this_file_after_completion=1  
  
#-----------------------------------------------------------------  
#Networking:  
# Change default network settings  
# Set to 1 to apply any network related settings below  
  
FR_net_change_defaults=0  
  
# Enable WiFi or Ethernet.  
#       NB: If both are enabled, WiFi will take priority and Ethernet will be disabled.  
  
FR_net_ethernet_enabled=1  
FR_net_wifi_enabled=1  
  
#Enter your WiFi creds  
#       SECURITY WARN: Your wifi keys will be stored in plaintext, no encryption.  
  
FR_net_wifi_ssid='Ace'  
FR_net_wifi_key='PvBsPvBy'  
  
#       Country code to enable power ratings and channels for your country. eg: GB US DE | https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2  
  
FR_net_wifi_countrycode='KZ'  
  
#If you want to use a static ip, set it here  
  
FR_net_use_static=0  
FR_net_static_ip='192.168.0.100'  
FR_net_static_mask='255.255.255.0'  
FR_net_static_gateway='192.168.0.1'  
FR_net_static_dns='8.8.8.8 8.8.4.4' #2 entries max, seperated by a space.  
#-----------------------------------------------------------------
```

Чтобы включить беспроводной интерфейс на вашем устройстве с использованием командной строки в Linux, выполните следующие действия:
1. Проверьте доступные интерфейсы

Используйте команду ip link для отображения всех сетевых интерфейсов и их состояния.

```
ip link
```

Вывод будет содержать список интерфейсов. Например:

1: lo: <LOOPBACK,UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
2: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000

Здесь wlan0 — это имя беспроводного интерфейса.
2. Включите интерфейс

Чтобы включить интерфейс (например, wlan0), выполните команду:

```
sudo ip link set wlan0 up
```

3. Проверьте состояние

Снова выполните ip link, чтобы убедиться, что интерфейс включён. Его состояние должно быть state UP.
4. Подключитесь к Wi-Fi сети

Если вы хотите подключиться к Wi-Fi сети, используйте один из следующих инструментов:
Через nmcli (если используется NetworkManager):

```
# Список доступных сетей
nmcli device wifi list
nmcli device wifi connect "Ace" password "PvBsPvBy" ifname wlan0
```

Через iw и wpa_supplicant:

    Найдите сеть:

```
sudo iw dev wlan0 scan | grep SSID
```

Подключитесь:

```
wpa_passphrase "SSID" "пароль" | sudo tee /etc/wpa_supplicant.conf
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
sudo dhclient wlan0
```


---

# HACS 2.0
https://my.home-assistant.io/redirect/supervisor_addon/?repository_url=https%3A%2F%2Fgithub.com%2Fhacs%2Faddons&addon=cb646a50_get

# RK3318 bluetooth
```bash
ln -s  /usr/lib/firmware/brcm/BCM43342.hcd /usr/lib/firmware/brcm/BCM.hcd
```

---
