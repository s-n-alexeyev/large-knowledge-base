### Что такое БИОС?

BIOS будет загружен при запуске компьютера для инициализации и проверки работы оборудования. Он используется POST или Power On Self Test, чтобы убедиться, что конфигурация оборудования действительна и работает правильно, затем выполняется поиск MBR (Master Boot Records), в котором хранится загрузочное устройство, и используется для запуска загрузчика, затем ядра, а затем Операционная система.

Все эти процессы загрузки в BIOS называются Legacy Boot, ниже приводится простое объяснение процесса загрузки в BIOS.

BIOS > MBR > Bootloader > Kernel > Operating System

BIOS считают старой и устаревшей прошивкой, хотя всегда найдутся люди, использующие ее. BIOS имеет ограниченную функциональность для современных компьютеров и современных ПК, он должен работать на 16-битном процессоре с объемом памяти всего 1 МБ для выполнения. Кроме того, он будет инициализировать несколько аппаратных средств одновременно, что замедляет процесс загрузки.

Заменой прошивки для BIOS является UEFI, который доступен на современных материнских платах.

### Что такое UEFI?

UEFI или Unified Extensible Firmware Interface считается заменой прошивки для BIOS. Он поставляется с большим количеством функций и функций, которые ограничены в BIOS, и доступен на современных материнских платах и современных ПК.

Несмотря на то, что он считается заменой BIOS, UEFI работает по-другому и имеет концепцию, противоположную BIOS. UEFI хранит всю информацию об инициализации и запуске в файле .efi, который хранится в разделе ESP (системный раздел EFI). и ESP также будет хранить программы загрузчика для операционной системы, установленной на компьютере.

В UEFI используется GPT для хранения всей информации о разделах, а не MBR. А ниже простое объяснение того, как операционная система загружается в UEFI.

UEFI **>** GPT/ESP **>** Kernel **>** Operating System

Ниже приведены некоторые примечательные функции UEFI, недоступные в традиционном BIOS:

- Быстрая загрузка
- Обработка более 2 ТБ или дисков (что очень важно для современных условий).
- Поддерживает более 4 разделов с таблицей разделов GUID.
- Поддержка безопасной загрузки
- Поддержка 64-разрядных устройств с современной прошивкой.
- Имеет простой графический интерфейс пользователя.
- и т. д.

### Прошивка на виртуализацию KVM

По умолчанию виртуализация KVM использует BIOS в качестве прошивки по умолчанию для гостевых виртуальных машин. Чтобы включить поддержку UEFI в KVM, необходимо установить пакет OVMF (прошивка открытой виртуальной машины) в хост-системе.  
  
Проект OVMF является частью микропрограммы Intel tianocore для виртуальной машины qemu.

## Предпосылки

В этом руководстве вы узнаете, как включить поддержку UEFI на виртуальной машине KVM. Вы будете устанавливать пакет OVMF на хост-компьютер и настраивать виртуальную машину с прошивкой UEFI.

Прежде чем начать, убедитесь, что у вас есть машина с установленной поверх нее виртуализацией KVM.

Ниже приведено руководство по установке виртуализации KVM в Arch Linux.

## Установка пакета OVMF

Сначала вы должны войти на хост-сервер KVM и установить пакеты. По умолчанию пакеты ovmf доступны в большинстве репозиториев дистрибутивов Linux, таких как Debian, Ubuntu, CentOS и т. д.

1. Установите ovmf в системах на основе Debian с помощью команды apt, как показано ниже.

```shell
sudo apt install ovmf
```

2. А для систем на основе RHEL, таких как CentOS/Fedora, вам необходимо установить пакет edk2-ovmf с помощью команды DNF/Yum, как показано ниже.

```shell
sudo dnf install edk2-ovmf  
```
  
or  
  
```shell
sudo yum install edk2-ovmf
```

3. Для систем на основе Arch Linux, таких как Manjaro, вы можете использовать приведенную ниже команду pacman.

```shell
sudo pacman -S edk2-ovmf
```

И поддержка UEFI для виртуализации KVM включена. Теперь давайте создадим новые виртуальные машины.

## Включить UEFI на виртуальной машине

Существует несколько способов создания виртуальной машины в виртуализации KVM. Вы можете использовать режим командной строки (используя команду `virt-install`) или графическое приложение, такое как `диспетчер виртуальных машин`.

### Создайте виртуальную машину с помощью virt-install

1. Чтобы создать виртуальную машину с прошивкой UEFI с помощью командной строки _virt-install_, добавьте параметр _--boot uefi_ в параметры команды.

Ниже приведен пример использования команды `virt-install` для создания новой виртуальной машины _Artix_ с прошивкой UEFI.

```shell
sudo virt-install --name=Artix \  
--os-type=Linux \  
--os-variant=archlinux \  
--vcpu=2 \  
--ram=1024 \  
--disk path=/var/lib/libvirt/images/Artix.img,size=15 \  
--graphics spice \  
--cdrom=/home/user/Desktop/artix-base-openrc-20210726-x86_64.iso \  
--network network=default \  
--boot uefi
```

Теперь вы загрузитесь на свою виртуальную машину.  
И если вы войдете в настройки UEFI, ниже вы получите несколько скриншотов.  
Ниже приведен скриншот интерактивной оболочки UEFI на виртуальной машине KVM.

![|600](/Media/Pictures/KVM_UEFI/image_1.png)

А ниже скриншот настроек OVMF на виртуальной машине UEFI KVM

![|600](/Media/Pictures/KVM_UEFI/image_2.png)

### Создайте виртуальную машину с помощью диспетчера виртуальных машин

Приложение диспетчера виртуальных машин предоставляет графический интерфейс для управления виртуализацией KVM.  
Если вы новичок в виртуализации KVM, рекомендуется использовать virt-manager (менеджер виртуальных машин) для настройки среды виртуализации.  
Чтобы создать виртуальную машину с поддержкой прошивки UEFI с помощью приложения _virt-manager_, необходимо настроить его во время создания самой виртуальной машины.

1. В последнем окне при создании виртуальной машины с помощью virt-manager вы увидите окно подтверждения, как показано ниже.

![|400](/Media/Pictures/KVM_UEFI/image_3.png)

Необходимо установить флажок _Настроить конфигурацию перед установкой_, а затем нажать кнопку _Готово_.

2. В новом окне откройте меню _Обзор_ и перейдите в раздел _Сведения о гипервизоре_.

В разделе «Прошивка» выберите _UEFI x86_64: ..._, затем нажмите кнопку _Применить_.

![|600](/Media/Pictures/KVM_UEFI/image_4.png)

Теперь нажмите кнопку _Начать установку_, чтобы начать установку виртуальной машины.

3. В процессе загрузки виртуальной машины вы увидите _загрузочную заставку TianoCore_, как показано ниже.

![|600](/Media/Pictures/KVM_UEFI/image_5.png)

4. После этого вы увидите свою операционную систему, как показано ниже.

![|600](/Media/Pictures/KVM_UEFI/image_6.png)

Теперь вы успешно создали виртуальную машину в виртуализации KVM, и теперь виртуальная машина использует прошивку UEFI вместо BIOS по умолчанию.

## Заключение

