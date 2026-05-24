# QEMU + KVM + VFIO (проброс GPU) — инструкция

Инструкция рассчитана на проброс видеокарты (видеовыход + аудио) в Windows VM с использованием `vfio-pci` и `libvirt`.

## 1) Требования

### Железо
- CPU с аппаратной виртуализацией: `Intel VT-x`/`VT-d` или `AMD-V`/`AMD-Vi (IOMMU)`
- Минимум 4 физических ядра (рекомендуется 6+), минимум 8 потоков (рекомендуется 12+)
- RAM: хосту минимум 16 GB (лучше 32+), VM — минимум 8 GB (лучше 16+)
- GPU для хоста (или встроенная графика) и GPU для VM
- GPU (и их аудио-функции) должны быть в корректных IOMMU группах; в идеале — видеокарта и её аудио в одной IOMMU группе
- UEFI firmware (не Legacy BIOS)
- Пара PCIe-слотов (или иное решение, но важно иметь минимум два видеоустройства для хоста/VM)

### Важно
- Убедитесь, что вы понимаете, какие именно PCI устройства (VGA/Audio функции) будете пробрасывать.
- VFIO обычно требует осторожности: изменение GRUB/modprobe/initramfs влияет на загрузку системы.

## 2) Настройки BIOS/UEFI

### Intel (ключевые пункты)
1. `Intel Virtualization Technology (VT-x)` — `Enabled`
2. `Intel VT-d` — `Enabled`
3. `IOMMU / VT-d` — `Enabled`
4. `Above 4G Decoding` / `4G Above` — `Enabled` (желательно)
5. `CSM` — `Disabled` (если используете UEFI)
6. `Secure Boot` — `Disabled` (для OVMF без Secure Boot) или `Enabled` (если точно знаете, что делаете)

### AMD (ключевые пункты)
1. `SVM Mode` (AMD-V) — `Enabled`
2. `IOMMU` (AMD-Vi) — `Enabled`
3. `Above 4G Decoding` / `4G Above` — `Enabled` (желательно)
4. `CSM` — `Disabled`
5. `Secure Boot` — `Disabled` (или правильная настройка для Secure Boot OVMF)

### Проверка после загрузки Linux
Проверьте, что виртуализация и IOMMU реально включены.

```bash
# Проверить поддержку виртуализации
lscpu | grep -i virtualization

# Для Intel должно быть: VT-x
# Для AMD должно быть: AMD-V

# Флаги CPU
grep -E 'vmx|svm' /proc/cpuinfo

# Проверить IOMMU (после включения в BIOS и корректного GRUB)
dmesg | grep -i -e DMAR -e IOMMU -e AMD-Vi
```

Проверьте, что модули KVM загружены:

```bash
lsmod | grep -E '^kvm|kvm_'
```

## 3) Включить IOMMU в GRUB

### AMD
Отредактируйте `/etc/default/grub` и добавьте параметры в `GRUB_CMDLINE_LINUX_DEFAULT`:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_iommu=on iommu=pt"
```

Обновите конфигурацию GRUB и перезагрузитесь:
- Debian/Ubuntu: `sudo update-grub`
- Arch/Manjaro: обычно `sudo grub-mkconfig -o /boot/grub/grub.cfg` (или `sudo update-grub`, если команда доступна)

После перезагрузки проверьте:

```bash
dmesg | grep -i -e DMAR -e IOMMU -e AMD-Vi
```

### Intel
В `/etc/default/grub`:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on"
```

Обновите GRUB и перезагрузитесь.

## 4) Найти PCI ID видеокарты (VGA + Audio)

1. Посмотрите PCI устройства и их ID:

```bash
lspci -nnk
```

2. Быстро отфильтруйте по GPU:

```bash
lspci -nnk | grep -i nvidia
lspci -nnk | grep -i amd
```

Вам нужны **оба** адреса/функции:
- VGA (обычно `…:…:… .0`), видеовыход
- Audio (обычно `…:…:… .1`), звук HDMI/DP

Запишите:
- адрес в формате `BB:DD.F` (например `01:00.0` и `01:00.1`)
- vendor:device ID (например `10de:220a` и `10de:1aef`)

## 5) Проверить IOMMU groups

Проверьте, что видеокарта и аудио в **одной** IOMMU группе.

```bash
for g in /sys/kernel/iommu_groups/*; do
  echo "IOMMU Group ${g##*/}:"
  for d in $g/devices/*; do
    # Печатаем адрес функции и PCI IDs
    echo "  $(lspci -nns ${d##*/})"
  done
done
```

Ожидаемый результат: `01:00.0` и `01:00.1` (или ваши адреса) находятся в одной группе.

## 6) Настроить VFIO (bind видеокарты в vfio-pci)

### 6.1 Создать конфиг модулей
Создайте файл `/etc/modprobe.d/vfio.conf`:

```bash
sudo nano /etc/modprobe.d/vfio.conf
```

Для NVIDIA (пример под RTX 3080):

```conf
options vfio-pci ids=10de:220a,10de:1aef
blacklist nouveau
```

Для AMD (пример):

```conf
options vfio-pci ids=1002:73ff,1002:ab28
```

Примечание: blacklist конкретного драйвера (например `amdgpu`) может понадобиться/не понадобиться — ориентируйтесь на ваши конфликты драйверов (`lspci -nnk`).

### 6.2 Обновить initramfs
- Debian/Ubuntu:
```bash
sudo update-initramfs -u
```
- Arch/Manjaro:
```bash
sudo mkinitcpio -P
```

### 6.3 Перезагрузка и проверка
Перезагрузитесь, затем проверьте, что `vfio-pci` захватил устройства:

```bash
lspci -nnk | grep -A2 "01:00"
# или фильтром по PCI адресу/ID
```

В выводе для нужных функций должно быть `Kernel driver in use: vfio-pci`.

## 7) Установить QEMU/KVM + libvirt + OVMF

### Arch/Manjaro (пример)
```bash
sudo pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer \
  edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo
```

Запустите и включите сервис:

```bash
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

Добавьте пользователя в группы:

```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

newgrp libvirt
```

### Debian/Ubuntu (пример)
```bash
sudo apt update
sudo apt install qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients \
  bridge-utils virt-manager ovmf virt-viewer
```

Далее:
```bash
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

## 8) Создать VM (UEFI + временный SPICE для установки Windows)

### 8.1 Создание VM
В `virt-manager`:
1. `Создать новую VM`
2. Выберите установочный ISO Windows
3. `Firmware: UEFI x86_64` (OVMF)
4. Выделите ресурсы:
   - RAM: минимум 8 GB (рекомендуется 16 GB)
   - CPU: минимум 4 ядра (рекомендуется 8+)
   - Disk: минимум 50 GB (рекомендуется 100 GB+)
5. Для этапа установки оставьте виртуальный дисплей **SPICE**

### 8.2 Установка Windows
- Установите Windows как обычно
- После установки установите `VirtIO` драйверы (см. ниже)

### 8.3 Установка VirtIO драйверов
Скачайте `virtio-win` ISO:

```bash
wget https://github.com/virtio-win/virtio-win-pkg-scripts/releases/download/v0.1.271/virtio-win-0.1.271.iso
```

В `virt-manager` подключите ISO к CD-ROM VM и установите в Windows драйверы для:
- Disk (часто `VirtIO SCSI`)
- Network (`VirtIO Network`)
- (по желанию) `VirtIO Balloon`

## 9) Проброс GPU в VM через libvirt XML

### 9.1 Подготовка
1. Остановите VM полностью:
```bash
virsh shutdown <vm-name>
```
2. Проверьте, что ваш GPU уже привязан к `vfio-pci`:
```bash
lspci -nnk | grep -A2 "01:00"
```

### 9.2 Правка XML
Откройте XML:

```bash
sudo virsh edit <vm-name>
```

В секцию `<devices>` добавьте два `hostdev`:
- один для VGA функции (например `01:00.0`)
- второй для Audio функции (например `01:00.1`)

Как преобразовать адрес `01:00.0` в XML:
- `domain` обычно `0x0000`
- `bus` = первая часть `01` -> `0x01`
- `slot` = вторая часть `00` -> `0x00`
- `function` = `.0` -> `0x0`

Пример (адаптируйте под свои адреса):

```xml
<!-- Видеокарта VGA -->
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x01" slot="0x00" function="0x0"/>
  </source>
</hostdev>

<!-- Аудио видеокарты -->
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x01" slot="0x00" function="0x1"/>
  </source>
</hostdev>
```

### 9.3 Отключить SPICE (минимизация конфликтов)
Удалите или закомментируйте секцию графики SPICE:

```xml
<!--
<graphics type="spice" autoport="yes">
  <listen type="address"/>
</graphics>
-->
```

После этого экран VM будет выводиться через проброшенную видеокарту (нужен второй монитор или Looking Glass).

### 9.4 Запуск и проверка
Запустите VM:

```bash
virsh start <vm-name>
```

После загрузки Windows откройте `Диспетчер устройств`:
- видеокарта должна определиться как нормальная GPU

## 10) Установить драйверы видеокарты в Windows

Скачайте последние драйверы:
- NVIDIA: https://www.nvidia.com/Download/index.aspx
- AMD: https://www.amd.com/en/support

Установите драйвер (Custom installation при желании без лишних компонентов) и перезагрузите VM.

Проверка:
- `Диспетчер устройств` -> `Видеоадаптеры`
- `dxdiag` -> вкладка `Экран`

## 11) Быстрый чеклист (если что-то не работает)

1. В BIOS включены VT-x/VT-d или SVM + IOMMU
2. В GRUB включены параметры IOMMU
3. В `lspci -nnk` для пробрасываемых функций `Kernel driver in use: vfio-pci`
4. VGA и Audio в одной IOMMU группе
5. В XML пробросили **обе** функции (`.0` и `.1`)
6. SPICE отключён/не конфликтует (если нужен вывод через GPU)
7. Видеовыход монитора подключен к выходам правильной видеокарты (VM GPU)

Логи/консоль:
```bash
virsh console <vm-name>
journalctl -u libvirtd -e
```

## 12) Опционально: Looking Glass (вывод на хост без второго монитора)

### Идея
Looking Glass показывает кадры VM на хосте через shared memory (обычно нужен `memfd`, а не hugepages).

### 12.1 Установка клиента на хост
- Debian/Ubuntu:
```bash
sudo apt install looking-glass-client
```
- Arch/Manjaro:
```bash
sudo pacman -S looking-glass
# или AUR/AppImage — по вашему методу
```

### 12.2 Добавить shmem в XML VM
В `virsh edit <vm-name>` добавьте `shmem` (пример):

```xml
<shmem name="looking-glass">
  <model type="ivshmem-plain"/>
  <size unit="M">128</size>
</shmem>
```

Адрес PCI для `shmem` можно не указывать (если libvirt/текущий XML у вас сам назначает), либо подберите под вашу схему — зависит от существующей топологии устройства в XML.

### 12.3 Память VM: memfd вместо hugepages
В `memoryBacking` используйте `memfd` (пример):

```xml
<memoryBacking>
  <source type="memfd"/>
  <access mode="shared"/>
</memoryBacking>
```

### 12.4 Host компонент в Windows + запуск клиента на хосте
- Скачайте Looking Glass Host для Windows и установите в VM
- Запустите на хосте:
```bash
looking-glass-client -F -S -m KEY_RIGHTALT
```

## 13) Опционально: CPU pinning (улучшение стабильности frametime)

Смысл: закрепить vCPU VM за конкретными pCPU хоста через `<cputune>`.

В XML (примерная заготовка, адаптируйте под свою топологию):

```xml
<cputune>
  <vcpupin vcpu="0" cpuset="0"/>
  <vcpupin vcpu="1" cpuset="16"/>
  <!-- ... -->
  <emulatorpin cpuset="8-15,24-31"/>
</cputune>
```

Под свою систему подбирайте cpuset диапазоны через `lscpu` и `numactl --hardware`.

## 14) Опционально: Bridge сеть (VM в вашей LAN)

Если VM нужна в той же подсети, где и хост, настройте bridge.

Пример (создание `br0` через NetworkManager):
```bash
nmcli connection add type bridge con-name br0 ifname br0 ipv4.method auto
nmcli connection add type bridge-slave con-name bridge-slave-enp14s0 \
  ifname enp14s0 master br0
nmcli connection up br0
```

В libvirt создайте сеть, использующую bridge (пример XML в `/tmp/bridge-lan.xml`):
```bash
cat > /tmp/bridge-lan.xml <<EOF
<network>
  <name>bridge-lan</name>
  <uuid>$(uuidgen)</uuid>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

sudo virsh net-define /tmp/bridge-lan.xml
sudo virsh net-autostart bridge-lan
sudo virsh net-start bridge-lan
```

В XML VM замените интерфейс на bridge (пример):
```xml
<interface type="network">
  <mac address="52:54:00:4d:e0:64"/>
  <source network="bridge-lan"/>
  <model type="virtio"/>
</interface>
```

## 15) Опционально: Бэкапы VM перед пробросом GPU

Сделайте snapshot:

```bash
virsh snapshot-create-as <vm-name> --name "before-gpu-passthrough" --description "Перед пробросом видеокарты"
```

Список:
```bash
virsh snapshot-list <vm-name>
```

Откат:
```bash
virsh snapshot-revert <vm-name> --snapshotname "before-gpu-passthrough"
```