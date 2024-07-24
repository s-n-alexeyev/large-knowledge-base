>вход на SSH
```bash
ssh -oHostKeyAlgorithms=+ssh-rsa root@192.168.1.1
```

>обновление
```bash
opkg update && opkg list-upgradable| awk '{print $1}'| tr '\n' ' '| xargs -r opkg upgrade
```

>обновление ключей (если нужно)
```bash
opkg install openwrt-keyring --force-overwrite
```