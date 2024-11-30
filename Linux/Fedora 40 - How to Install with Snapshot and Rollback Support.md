2024-06-03
[Оригинальная статья](https://sysguides.com/install-fedora-with-snapshot-and-rollback-support)

Fedora Linux 40 has been released!

In this guide, I will show you how to install Fedora with snapshot and rollback support.

As a result, if you make a mistake while modifying the system configuration, installing packages, or updating, you won't have to worry about breaking the system. Simply restore the snapshot prior to the problematic change, and you'll be fine.

So let's get started.


```table-of-contents
title: Содержание
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
## 1. Partitions and Subvolumes Layout

For this guide, I will use a hard disk with a capacity of 128 GiB.

I'll create a 600 MiB EFI system partition and use the remaining disk space to create a partition for the Linux file system.

Fedora also creates a [SwapOnZRAM](https://fedoraproject.org/wiki/Changes/SwapOnZRAM) during boot, so no separate swap partition is required.

This is how the disk partition looks:

```
NAME         SIZE  FSTYPE  PARTTYPENAME      MOUNTPOINT
/dev/vda     128G                           
/dev/vda1    600M  vfat    EFI System        /boot/efi  
/dev/vda2  127.4G  btrfs   Linux filesystem  /
```

On the Linux partition (/dev/vda2), I'll create a btrfs file system. Then, on the btrfs file system, I'll create the following subvolumes to keep them out of root file system snapshots.

```
NAME             MOUNTPOINT                 TYPE  
[main]           /                          mainvolume  
home             /home                      subvolume  
opt              /opt                       subvolume  
cache            /var/cache                 subvolume  
crash            /var/crash                 subvolume  
AccountsService  /var/lib/AccountsService   subvolume  
gdm              /var/lib/gdm               subvolume  
images           /var/lib/libvirt/images    subvolume  
log              /var/log                   subvolume  
spool            /var/spool                 subvolume  
tmp              /var/tmp                   subvolume  
www              /var/www                   subvolume  
.mozilla         /home/$USER/.mozilla       subvolume  
.snapshots       /.snapshots                subvolume  
.snapshots       /home/.snapshots           subvolume
```

The directories for which subvolumes are created and the reasons for doing so are listed below. For more information, visit [this website](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html).

**/home**

Contains user data. It will be created to keep user data separate while also preventing data loss during system root rollbacks.

**/opt**

Contains applications installed by a third party. It will be created to prevent these applications from being uninstalled during rollbacks.

**/var/cache, /var/crash, /var/tmp**

Directories contain temporary files and caches. They're created to be excluded from snapshots. Fedora mounts /tmp with tmpfs at boot, so a separate subvolume is unnecessary.

**/var/lib/AccountsService, /var/lib/gdm**

Contains login user and Gnome display information. These directories must be writable at all times. When you try to boot a snapshot from the GRUB menu, you are booting into a read-only snapshot, which causes the system to hang just before the Gnome login screen appears.

In case you're using a desktop environment other than Gnome, it's necessary to replace the '/var/lib/gdm' with one that's specific to your desktop environment.

For KDE, it is '/var/lib/sddm'.

To find out about other desktop environments, refer to [this page](https://wiki.archlinux.org/title/Desktop_environment).

**/var/lib/libvirt/images**

The default location for libvirt-managed virtual machine images. It will be created so that virtual machine images are not replaced with older versions during a rollback.

**/var/log**

Contains log files. It will be created to prevent the loss of log data during rollbacks.

**/var/spool**

Contains data that is awaiting some kind of later processing, such as mail, mail queues, printing, printer spool, and so on. It will be created to prevent the loss of mail, printing, and spool data following a rollback.

**/var/www**

Web server directory. It will be created to keep hosted web server data separate and prevent data loss during system root rollbacks.

**/home/$USER/.mozilla**

By default, Fedora Workstation includes the Firefox web browser. If you take a snapshot of your home directory and later undo any changes, you don't want to lose any new bookmarks, passwords, and other user data.

So, I'll create a subvolume for the '.mozilla' directory. This keeps it separate from the home subvolume and prevents data loss during undo operations.

Depending on your usage, you may also want to consider creating subvolumes in your home directory for the following directories:

- **Chrome Browser**: /home/$USER/.config/google-chrome
- **GnuPG**: /home/$USER/.gnupg
- **SSH**: /home/$USER/.ssh
- **Thunderbird Mail**: /home/$USER/.thunderbird

**/.snapshots, /home/.snapshots**

Contains snapshots of the root (/) and home (/home) directories.

## 2. Install Fedora Workstation

Boot your system using the Fedora Workstation 40 installer in UEFI mode. On the welcome screen, select the **Install to Hard Drive** option. Next, select your **Language**, **Keyboard**, and configure **Time & Date**. Following that, from the **INSTALLATION SUMMARY** screen, select **Installation Destination**.

You should now be on the **INSTALLATION DESTINATION** screen. To proceed, pick the **Advanced Custom (Blivet-GUI)** radio button and then hit the **Done** button.

On the **BLIVET GUI PARTITIONING** screen, create the partitions, file systems, and btrfs subvolumes necessary to install the Fedora Workstation 40.

[![Install Fedora with Snapshot and Rollback Support - Blivet GUI](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Blivet_GUI.webp)](https://sysguides.com/wp-content/uploads/2024/04/01-install-fedora-40-with-snapshot-and-rollback-support-blivet.webp)

First, you need to create and mount the EFI partition. Select the **free space** and click the **+** sign to create a partition.

Set the partition Size to **600** MiB, the Filesystem to **EFI System Partition**, and the Mountpoint to **/boot/efi**.

[![Install Fedora with Snapshot and Rollback Support - EFI Partition](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_EFI_Partition.webp)](https://sysguides.com/wp-content/uploads/2024/04/02-install-fedora-40-with-snapshot-and-rollback-support-efi.webp)

Then, you need to create a btrfs volume where you can create all the subvolumes needed to install Fedora Workstation 40.

Select the free space again and click on the **+** sign to create a Btrfs volume. Set the Filesystem to **btrfs** and the Mountpoint to **/**. I used the entire remaining space. However, you can specify the size you want for the btrfs volume.

[![Install Fedora with Snapshot and Rollback Support - BTRFS Partition](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_BTRFS_Partition.webp)](https://sysguides.com/wp-content/uploads/2024/04/03-install-fedora-40-with-snapshot-and-rollback-support-root.webp)

Next, you must create a home subvolume. (1) Select the **Btrfs Volume** from the left panel, and (2) click on the **+** sign on the right panel.

[![Install Fedora with Snapshot and Rollback Support - Create Subvolume](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Create_Subvolume.webp)](https://sysguides.com/wp-content/uploads/2024/04/04-install-fedora-40-with-snapshot-and-rollback-support-create-subvolume.webp)

Create a home subvolume. Enter the Name as **home** and Mountpoint as **/home**. Click **OK** to finish.

[![Install Fedora with Snapshot and Rollback Support - Home Subvolume](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Home_Subvolume.webp)](https://sysguides.com/wp-content/uploads/2024/04/05-install-fedora-40-with-snapshot-and-rollback-support-home-subvolume.webp)

I will create the remaining subvolumes when the installation is finished. This is because the Anaconda installer does not allow you to create subvolumes with slashes (/) in their names, such as var/log.

For now, click **Done** to finish creating subvolumes.

On the **SUMMARY OF CHANGES** screen, double-check that everything is properly defined. To finalize the changes, click the **Accept Changes** button.

[![Install Fedora with Snapshot and Rollback Support - Summary](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Summary.webp)](https://sysguides.com/wp-content/uploads/2024/04/06-install-fedora-40-with-snapshot-and-rollback-support-summary.webp)

You will be returned to the **INSTALLATION SUMMARY** screen. Press the **Begin Installation** button to start the installation process. The installation process will start. Just sit back and relax.

[![Install Fedora with Snapshot and Rollback Support - Installation](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Installation.webp)](https://sysguides.com/wp-content/uploads/2024/04/07-install-fedora-40-with-snapshot-and-rollback-support-installation.webp)

When the installation is finished, click the **Finish Installation** button and restart the system.

The last phase of the installation process will start. Click the **Start Setup** button to complete the remaining customization steps, such as setting a new login, password, etc.

You will then be logged into the Fedora Workstation 40 with the all-new Gnome 46 desktop interface.

[![Install Fedora with Snapshot and Rollback Support - GNOME 46](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_GNOME_46.webp)](https://sysguides.com/wp-content/uploads/2024/04/08-install-fedora-40-with-snapshot-and-rollback-support-gnome-46.webp)

When booting your system, you may have noticed the following error message.

error: ../../grub-core/commands/loadenv.c:216:sparse file not allowed.

This is because you did not create a separate ext4 /boot partition and instead included it in the btrfs system root. GRUB preboot writes to /boot/grub2/grubenv if the boot was successful. This error occurs because of the GRUB btrfs.mod driver, unlike ext4, is read-only. To resolve this, open the Gnome terminal and execute the following command.

```bash
sudo grub2-editenv - unset menu_auto_hide
```

Set the btrfs volume label. I named the btrfs volume **FEDORA**, but you may name it whatever you want.

```bash
sudo btrfs filesystem label / FEDORA
```

```bash
sudo btrfs filesystem show /
```

```
Label: 'FEDORA'  uuid: 0fa2b51a-9876-4905-a36a-dbb2f40e7c12
	Total devices 1 FS bytes used 6.60GiB
	devid    1 size 127.41GiB used 10.02GiB path /dev/vda2
```

Your setup should look something like this.

```bash
lsblk -p /dev/vda
```

```
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
/dev/vda    252:0    0   128G  0 disk 
├─/dev/vda1 252:1    0   600M  0 part /boot/efi
└─/dev/vda2 252:2    0 127.4G  0 part /home
                                      /
```

And the subvolumes will look like this.

```bash
sudo btrfs subvolume list /
```

```
ID 256 gen 51 top level 5 path home
ID 257 gen 46 top level 5 path var/lib/machines
```

In Fedora Workstation, systemd automatically creates the /var/lib/machines subvolume for systemd-nspawn containers.

Enable the fastest mirrors to speed up package downloads. Copy the command from sudo to EOF, paste it into your terminal, and hit [Enter].

```bash
sudo bash -c 'cat >> /etc/dnf/dnf.conf' <<EOF
defaultyes=True
fastestmirror=True
max_parallel_downloads=10
EOF
```

Clear all previous caches and update the local DNF metadata cache.

```bash
sudo dnf clean all
sudo dnf makecache
```

Install the packages listed below.

```bash
sudo dnf install vim git inotify-tools make
```

Now, update your operating system.

```bash
sudo dnf update
```

And reboot your system.

```bash
sudo reboot
```

## 3. Create the Additional Subvolumes

I'll now proceed with creating the remaining subvolumes on the system root.

These subvolumes are created on the system root to avoid being included in the rollback process. Some of these directories store temporary files and caches. Some contain data that you do not want to lose if you roll back the system root. And some should be in read-write mode when booting into a read-only snapshot.

Create the directory '/var/lib/libvirt'. Only applicable to other Fedora Spins; not required for Fedora Workstation.

```bash
sudo mkdir -vp /var/lib/libvirt
```

Get the UUID of your btrfs system root.

```
ROOT_UUID="$(sudo grub2-probe --target=fs_uuid /)"

echo ${ROOT_UUID}
0fa2b51a-9876-4905-a36a-dbb2f40e7c12
```

Get the btrfs subvolume mount options from the /etc/fstab file.

```
OPTIONS="$(grep '/home' /etc/fstab \
    | awk '{print $4}' \
    | cut -d, -f2-)"

echo ${OPTIONS}
compress=zstd:1
```

Declare the remaining subvolumes you want to create in the 'SUBVOLUMES' bash array. Copy from 'SUBVOLUMES' to ')', paste into the terminal, and press [ENTER].

```
SUBVOLUMES=(
    "opt"
    "var/cache"
    "var/crash"
    "var/lib/AccountsService"
    "var/lib/gdm"
    "var/lib/libvirt/images"
    "var/log"
    "var/spool"
    "var/tmp"
    "var/www"
    "home/$USER/.mozilla"
)
```

If you are installing Fedora for KDE Desktop, replace 'var/lib/gdm' with 'var/lib/sddm'.

If you intend to install Google Chrome, you should also create a subvolume for it. Add the following to the SUBVOLMES array:

"home/$USER/.config/google-chrome"  

If you intend to install the Mozilla Thunderbird email client, add the following to the SUBVOLMES array:

"home/$USER/.thunderbird"

If you use the GnuPG encryption and signing tool, you must create a subvolume to avoid losing your keys.

"home/$USER/.gnupg"

Similarly, if you use the SSH remote login client, you must create a subvolume to prevent losing your keys.

"home/$USER/.ssh"

For this tutorial, however, I will only create the '.mozilla' subvolume in the user's home directory.

```
printf '%s\n' "${SUBVOLUMES[@]}"
opt
var/cache
var/crash
var/lib/AccountsService
var/lib/gdm
var/lib/libvirt/images
var/log
var/spool
var/tmp
var/www
home/madhu/.mozilla
```

Find the length of the longest element in the SUBVOLMES array.

```
MAX_LEN="$(printf '/%s\n' "${SUBVOLUMES[@]}" | wc -L)"

echo ${MAX_LEN}
24
```

Now, create subvolumes and also add them to the /etc/fstab file. Copy from 'for' to 'done', paste it in the terminal, and hit [ENTER].

```
for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}" ]] ; then
        sudo mv -v "/${dir}" "/${dir}-old"
        sudo btrfs subvolume create "/${dir}"
        sudo cp -ar "/${dir}-old/." "/${dir}/"
    else
        sudo btrfs subvolume create "/${dir}"
    fi
    sudo restorecon -RF "/${dir}"
    printf "%-41s %-${MAX_LEN}s %-5s %-s %-s\n" \
        "UUID=${ROOT_UUID}" \
        "/${dir}" \
        "btrfs" \
        "subvol=${dir},${OPTIONS}" \
        "0 0" | \
        sudo tee -a /etc/fstab
done
```

Once you've finished creating subvolumes based on your needs, change the ownership of the directories in the user's home to your user name.

```bash
sudo chown -cR $USER:$USER /home/$USER/
```

If you have created subvolumes '.gnupg' and '.ssh', you must change their permissions.

```bash
sudo chmod -vR 0700 /home/$USER/{.gnupg,.ssh}
```

Examine your /etc/fstab file. This is what it should look like. The UUID and username will be unique to your system.

```bash
cat /etc/fstab
...
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /                        btrfs defaults        0 0
UUID=85A7-4DC2                            /boot/efi                vfat  umask=0077,shortname=winnt 0 2
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /home                    btrfs subvol=home,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /opt                     btrfs subvol=opt,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/cache               btrfs subvol=var/cache,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/crash               btrfs subvol=var/crash,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/lib/AccountsService btrfs subvol=var/lib/AccountsService,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/lib/gdm             btrfs subvol=var/lib/gdm,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/lib/libvirt/images  btrfs subvol=var/lib/libvirt/images,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/log                 btrfs subvol=var/log,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/spool               btrfs subvol=var/spool,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/tmp                 btrfs subvol=var/tmp,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /var/www                 btrfs subvol=var/www,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /home/madhu/.mozilla     btrfs subvol=home/madhu/.mozilla,compress=zstd:1 0 0
```

Reload /etc/fstab to mount all the subvolumes.

```bash
sudo systemctl daemon-reload

sudo mount -va
```

```
/                        : ignored
/boot/efi                : already mounted
/home                    : already mounted
/opt                     : successfully mounted
/var/cache               : successfully mounted
/var/crash               : successfully mounted
/var/lib/AccountsService : successfully mounted
/var/lib/gdm             : successfully mounted
/var/lib/libvirt/images  : successfully mounted
/var/log                 : successfully mounted
/var/spool               : successfully mounted
/var/tmp                 : successfully mounted
/var/www                 : successfully mounted
/home/madhu/.mozilla     : successfully mounted
```

Check your subvolumes.

```bash
sudo btrfs subvolume list /
```

```
ID 256 gen 95 top level 5 path home
ID 257 gen 84 top level 5 path var/lib/machines
ID 258 gen 88 top level 5 path opt
ID 259 gen 94 top level 5 path var/cache
ID 260 gen 89 top level 5 path var/crash
ID 261 gen 89 top level 5 path var/lib/AccountsService
ID 262 gen 90 top level 5 path var/lib/gdm
ID 263 gen 91 top level 5 path var/lib/libvirt/images
ID 264 gen 94 top level 5 path var/log
ID 265 gen 92 top level 5 path var/spool
ID 266 gen 92 top level 5 path var/tmp
ID 267 gen 93 top level 5 path var/www
ID 268 gen 94 top level 256 path home/madhu/.mozilla
```

Your setup should now look somewhat like this.

```bash
lsblk -p /dev/vda
```

```
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
/dev/vda    252:0    0   128G  0 disk 
├─/dev/vda1 252:1    0   600M  0 part /boot/efi
└─/dev/vda2 252:2    0 127.4G  0 part /home/madhu/.mozilla
                                      /var/www
                                      /var/tmp
                                      /var/spool
                                      /var/log
                                      /var/lib/libvirt/images
                                      /var/lib/gdm
                                      /var/lib/AccountsService
                                      /var/crash
                                      /var/cache
                                      /opt
                                      /home
                                      /
```

Now that everything appears to be in order, you can delete the old directories. Copy from 'for' to 'done', paste it into the terminal, and hit [Enter].

```
for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}-old" ]] ; then
        sudo rm -rvf "/${dir}-old"
    fi
done
```

## 4. Install and Configure Snapper

Install the snapper and python3-dnf-plugin-snapper packages. The python3-dnf-plugin-snapper package allows you to create pre and post snapshots every time you install a package on the system with the `dnf` package manager.

```bash
sudo dnf install snapper python3-dnf-plugin-snapper
```

Create new snapper configurations named root and home for the btrfs volume at / and /home, respectively.

```bash
sudo snapper -c root create-config /
sudo snapper -c home create-config /home
```

The snapper configuration files will be saved in the /etc/snapper/configs/ directory.

Verify the snapper configuration files have been created.

```
sudo snapper list-configs
Config | Subvolume
-------+----------
home   | /home    
root   | /
```

Allow regular user to use `snapper` without requiring root privileges. Add your user name to the snapper's root and home configurations to set the ACL on the /.snapshots and /home/.snapshots directories.

```bash
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_ACL=yes
sudo snapper -c home set-config ALLOW_USERS=$USER SYNC_ACL=yes
```

Add the newly created snapshot subvolumes to the /etc/fstab file.

```bash
sudo vim /etc/fstab
```

```
...
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /home/madhu/.mozilla     btrfs subvol=home/madhu/.mozilla,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /.snapshots              btrfs subvol=.snapshots,compress=zstd:1 0 0
UUID=0fa2b51a-9876-4905-a36a-dbb2f40e7c12 /home/.snapshots         btrfs subvol=home/.snapshots,compress=zstd:1 0 0
```

Reload the /etc/fstab file.

```bash
sudo systemctl daemon-reload
sudo mount -va
```

Your subvolumes will look like this:

```
sudo btrfs subvolume list /
...
ID 268 gen 109 top level 256 path home/madhu/.mozilla
ID 269 gen 135 top level 5 path .snapshots
ID 270 gen 135 top level 256 path home/.snapshots
```

Disable the indexing of the .snapshots directories by updatedb. It is enabled by default, which can cause significant slowdown and excessive memory usage if you have a large number of snapshots.

```bash
echo 'PRUNENAMES = ".snapshots"' | sudo tee -a /etc/updatedb.conf
```

Enable snapshot booting by appending the SUSE_BTRFS_SNAPSHOT_BOOTING="true" option to the /etc/default/grub file.

```bash
echo 'SUSE_BTRFS_SNAPSHOT_BOOTING="true"' | sudo tee -a /etc/default/grub
```

You must also make changes to the /boot/efi/EFI/fedora/grub.cfg file now that snapshot booting is enabled.

```bash
sudo sed -i '1i set btrfs_relative_path="yes"' /boot/efi/EFI/fedora/grub.cfg
```

Finally, update the grub.cfg file.

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Later, I'll enable snapper timeline snapshots. For now, the snapper configuration is complete.

List the snapshots for / volume. For the root, you may use `snapper -c root ls` or simply `snapper ls`. Both provide the same output.

```bash
snapper ls
```

```
 # | Type   | Pre # | Date | User | Cleanup | Description | Userdata
---+--------+-------+------+------+---------+-------------+---------
0  | single |       |      | root |         | current     |
```

List the snapshots for /home subvolume.

```bash
snapper -c home ls
```

```
 # | Type   | Pre # | Date | User | Cleanup | Description | Userdata
---+--------+-------+------+------+---------+-------------+---------
0  | single |       |      | root |         | current     |
```

At this stage, you do not have any snapshots, we will create some later.

## 5. Install and Configure Grub-Btrfs

The [grub-btrfs](https://github.com/Antynea/grub-btrfs) package adds 'Fedora Linux snapshots' to the GRUB menu and allows you to test a snapshot in read-only mode before rolling back to it in read-write mode.

Clone the grub-btrfs repository.

```bash
git clone https://github.com/Antynea/grub-btrfs
```

The setup is pre-configured to work with Arch and Gentoo out of the box. You must make a few changes to the grub-btrfs config file to make it work with Fedora.

Change the directory to 'grub-btrfs', copy from 'sed' to 'config', paste it into the terminal, and press [ENTER].

```bash
cd grub-btrfs

sed -i \
-e '/#GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS/a \
GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="systemd.volatile=state"' \
-e '/#GRUB_BTRFS_GRUB_DIRNAME/a \
GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"' \
-e '/#GRUB_BTRFS_MKCONFIG=/a \
GRUB_BTRFS_MKCONFIG=/usr/sbin/grub2-mkconfig' \
-e '/#GRUB_BTRFS_SCRIPT_CHECK=/a \
GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check' \
config
```

Then install it.

```bash
sudo make install
```

Update grub.cfg and enable the grub-btrfsd.service.

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo systemctl enable --now grub-btrfsd.service
```

You will receive the 'No snapshots found' error since you have not yet created any snapshots, but don't worry, it will function properly after you do.

Your grub-btrfs installation is now complete. You may now delete the cloned grub-btrfs repository.

```bash
cd ..
rm -rvf grub-btrfs
```

## 6. Create a System Root Snapshot and Set It as the Default

Now that everything in Fedora has been installed and configured, it is time to take a subvolume snapshot of the main volume and set the subvolume as the default ‘/‘ file system. By manually creating a subvolume snapshot of the main volume and making it the default, you can easily rollback without having to specify the snapshot number and the 'ambit' during the rollback when using the snapper tool.

Create a directory named '1' in the /.snapshots directory.

```bash
sudo mkdir -v /.snapshots/1
```

Create an XML file called info.xml in the /.snapshots/1/ directory. Copy the following command from sudo to EOF, paste it into your terminal, and hit the `<Enter>` button.

```bash
sudo bash -c "cat > /.snapshots/1/info.xml" <<EOF
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>$(date -u +"%F %T")</date>
  <description>first root subvolume</description>
</snapshot>
EOF
```

Verify that the date is set properly and is in the Coordinated Universal Time (UTC) format.

```bash
cat /.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>2024-04-26 14:48:07</date>
  <description>first root subvolume</description>
</snapshot>
```

Now, create a read-write subvolume snapshot of the system root in the /.snapshots/1/ directory.

```bash
sudo btrfs subvolume snapshot / /.snapshots/1/snapshot
```

Get the subvolid of the /.snapshots/1/snapshot subvolume.

```bash
SNAP_1_ID="$(sudo btrfs inspect-internal rootid /.snapshots/1/snapshot)"

echo ${SNAP_1_ID}
271
```

Using this subvolume ID, set the /.snapshots/1/snapshot subvolume as the default subvolume for the root (/) filesystem.

```bash
sudo btrfs subvolume set-default ${SNAP_1_ID} /
```

Confirm that the /.snapshots/1/snapshot subvolume has been set as the default for the / filesystem.

```bash
sudo btrfs subvolume get-default /
```

```
ID 271 gen 170 top level 269 path .snapshots/1/snapshot
```

Finally, reboot your system.

```bash
sudo reboot
```

After rebooting, check the snapshots in snapper.

```bash
snapper ls
```

```
 # | Type   | Pre # | Date                            | User | Cleanup | Description          | Userdata
---+--------+-------+---------------------------------+------+---------+----------------------+---------
0  | single |       |                                 | root |         | current              |         
1* | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root |         | first root subvolume |
```

As you can see, the /.snapshots/1/snapshot subvolume is also visible as snapshot #1 in snapper. The asterisk (*) indicates that this snapshot is the default and is currently active.

The installation of Fedora 40 with snapshot and rollback support is now complete. You can now begin taking snapshots.

## 7. Snapper Tests

I'll run some tests here to make sure everything is in working order and that there are no problems.

### Test 1: Undo the Changes Made by the DNF Installer

In this test, I will use the `dnf` package manager to install a small package named `ps_mem`. I'll check the system after it is installed to see what changes were made. I'll then attempt to undo the changes and see if I can get the system back to its pre-installation state.

Install the ps_mem package. It displays the core memory used per program (not per process).

```bash
sudo dnf install ps_mem
```

Run the `ps_mem` program to see if it was installed successfully.

```bash
sudo ps_mem
```

```
 Private  +   Shared  =  RAM used	Program

148.0 KiB +  16.5 KiB = 164.5 KiB	fusermount3
200.0 KiB +  11.5 KiB = 211.5 KiB	inotifywait
256.0 KiB +  16.5 KiB = 272.5 KiB	mcelog
...
190.1 MiB +   1.7 MiB = 191.8 MiB	packagekitd
220.9 MiB +  22.1 MiB = 243.1 MiB	gnome-shell
258.9 MiB +   5.6 MiB = 264.5 MiB	gnome-software
---------------------------------
                          1.3 GiB
=================================
```

Check the snapper for snapshots.

```bash
snapper ls
```

```
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata
---+--------+-------+---------------------------------+------+---------+-----------------------------+---------
0  | single |       |                                 | root |         | current                     |         
1* | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root |         | first root subvolume        |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |         
3  | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root | number  | /usr/bin/dnf install ps_mem |
```

As you can see, the ps_mem package has pre (#2) and post (#3) snapshots.

Let's take a look at the changes it made to the system between snapshots #2 and #3.

```bash
snapper status 2..3
```

```
+..... /usr/bin/ps_mem
c..... /usr/lib/sysimage/rpm/rpmdb.sqlite-shm
c..... /usr/lib/sysimage/rpm/rpmdb.sqlite-wal
+..... /usr/share/doc/ps_mem
+..... /usr/share/doc/ps_mem/LICENSE
+..... /usr/share/man/man1/ps_mem.1.gz
c..... /var/lib/dnf/history.sqlite-shm
c..... /var/lib/dnf/history.sqlite-wal
-..... /var/lib/dnf/rpmdb_lock.pid
```

Now I'll undo the changes.

```bash
sudo snapper undochange 2..3
```

```
create:1 modify:4 delete:4
```

Check again to ensure that the ps_mem package was successfully uninstalled.

```bash
sudo ps_mem
sudo: ps_mem: command not found
```

Cool! The undo was successful. But, because I want to keep the package ps_mem, I'll undo the changes again. This time between snapshots #3 and #2.

```bash
sudo snapper undochange 3..2
```

```
create:4 modify:4 delete:1
```

Now run ps_mem again to see if it exists.

```bash
sudo ps_mem
```

```
 Private  +   Shared  =  RAM used	Program

148.0 KiB +  16.5 KiB = 164.5 KiB	fusermount3
200.0 KiB +  11.5 KiB = 211.5 KiB	inotifywait
256.0 KiB +  16.5 KiB = 272.5 KiB	mcelog
...
190.1 MiB +   1.7 MiB = 191.8 MiB	packagekitd
220.9 MiB +  22.1 MiB = 243.1 MiB	gnome-shell
258.9 MiB +   5.6 MiB = 264.5 MiB	gnome-software
---------------------------------
                          1.3 GiB
=================================
```

Test 1 was successful.

### Test 2: Undo Any Changes Made to Individual Files

Assume you're configuring something and editing a configuration file. Then you realize you messed up the configuration file. You want to see what changes you made to the original file and possibly wish you could undo the changes.

You can use snapper to undo not only all changes between two snapshots, but also a single file.

In this test, I will simply delete the last line of the /etc/hosts file. Then I'll compare it to the same file in snapshot #3 to see what changed and if I can undo all of the changes and restore it to its original state.

This is how the original /etc/hosts file looks.

```bash
cat /etc/hosts
```

```
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# See hosts(5) for proper format and other examples:
# 192.168.1.10 foo.example.org foo
# 192.168.1.13 bar.example.org bar
```

Now I'll remove the last line.

```bash
sudo sed -i '$d' /etc/hosts

cat /etc/hosts
```

```
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# See hosts(5) for proper format and other examples:
# 192.168.1.10 foo.example.org foo
```

Now that I have removed the last line, using the snapper tool, compare the /etc/hosts file with the one in snapshot #3.

```bash
snapper diff 3..0 /etc/hosts
```

```
--- /.snapshots/3/snapshot/etc/hosts	2023-11-29 05:34:49.000000000 -0500
+++ /etc/hosts	2024-04-26 11:29:39.238565474 -0400
@@ -4,4 +4,3 @@
 ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
 # See hosts(5) for proper format and other examples:
 # 192.168.1.10 foo.example.org foo
-# 192.168.1.13 bar.example.org bar
```

The number 0 in the command 3..0 represents the current snapshot, while the number 3 represents snapshot #3.

As you can see in the last line, the /etc/hosts file in the current snapshot is missing that line compared to the one in snapshot #3. If you want to learn how to read the output, take a look at the man pages `man diff` and `man snapper`.

To replace the /etc/hosts file with the one in snapshot #3, use the following command.

```bash
sudo snapper undochange 3..0 /etc/hosts
```

```
create:0 modify:1 delete:0
```

Check to see if the /etc/hosts file has indeed been rolled back.

```
cat /etc/hosts
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# See hosts(5) for proper format and other examples:
# 192.168.1.10 foo.example.org foo
# 192.168.1.13 bar.example.org bar
```

Test 2 was successful.

### Test 3: Create Manual Pre-Post Snapshots and Undo the Changes

In this test, I will begin by creating manual 'pre' snapshots of the / and /home directories. Then I'll install a small package called Color Picker (gcolor3) from GitHub by compiling it from the source file. When I'm finished, regardless of whether the compiling was successful or not, I'll create 'post' snapshots for the previously created 'pre' snapshots. I'll then look at the changes it made to the system between the pre-post snapshots and, finally, undo everything.

Create a manual 'pre' snapshot for both the / and /home directories.

```bash
snapper -c root create -t pre -c number -d 'Pre Color Picker'
snapper -c home create -t pre -c number -d 'Pre Color Picker'
```

List the snapshots.

```bash
snapper ls
```

```
 # | Type   | Pre # | Date                            | User  | Cleanup | Description                 | Userdata
---+--------+-------+---------------------------------+-------+---------+-----------------------------+---------
0  | single |       |                                 | root  |         | current                     |         
1* | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root  |         | first root subvolume        |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root  | number  | /usr/bin/dnf install ps_mem |         
3  | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root  | number  | /usr/bin/dnf install ps_mem |         
4  | pre    |       | Fri 26 Apr 2024 11:56:10 AM EDT | madhu | number  | Pre Color Picker            |         

snapper -c home ls
 # | Type   | Pre # | Date                            | User  | Cleanup | Description      | Userdata
---+--------+-------+---------------------------------+-------+---------+------------------+---------
0  | single |       |                                 | root  |         | current          |         
1  | pre    |       | Fri 26 Apr 2024 11:56:18 AM EDT | madhu | number  | Pre Color Picker |
```

Install the pre-requisite packages before compiling the source file.

```bash
sudo dnf install meson gcc-c++ libhandy-devel libportal-devel \
    libportal-gtk3-devel
```

Compile the source.

```bash
git clone https://github.com/Hjdskes/gcolor3.git
cd gcolor3
meson setup build
ninja-build -C build
sudo ninja-build -C build install
```

Make sure the Color Picker package has been installed properly. Enter `gcolor3` into the terminal and hit [ENTER]. The Color Picker app must be open and appear as shown.

![Install Fedora with Snapshot and Rollback Support - Gcolor 3](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Gcolor_3.webp)

Now that you have successfully installed the Color Picker application, close the application and create 'post' snapshots for the / and /home directories.

```
snapper -c root create -t post --pre-number 4 -c number -d 'Post Color Picker'
snapper -c home create -t post --pre-number 1 -c number -d 'Post Color Picker'
```

List the snapshots.

```
snapper -c root ls
 # | Type   | Pre # | Date                            | User  | Cleanup | Description                                                                            | Userdata
---+--------+-------+---------------------------------+-------+---------+----------------------------------------------------------------------------------------+---------
0  | single |       |                                 | root  |         | current                                                                                |         
1* | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root  |         | first root subvolume                                                                   |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root  | number  | /usr/bin/dnf install ps_mem                                                            |         
3  | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root  | number  | /usr/bin/dnf install ps_mem                                                            |         
4  | pre    |       | Fri 26 Apr 2024 11:56:10 AM EDT | madhu | number  | Pre Color Picker                                                                       |         
5  | pre    |       | Fri 26 Apr 2024 11:59:24 AM EDT | root  | number  | /usr/bin/dnf install meson gcc-c++ libhandy-devel libportal-devel libportal-gtk3-devel |         
6  | post   |     5 | Fri 26 Apr 2024 11:59:54 AM EDT | root  | number  | /usr/bin/dnf install meson gcc-c++ libhandy-devel libportal-devel libportal-gtk3-devel |         
7  | post   |     4 | Fri 26 Apr 2024 12:02:24 PM EDT | madhu | number  | Post Color Picker                                                                      |         

snapper -c home ls
 # | Type   | Pre # | Date                            | User  | Cleanup | Description       | Userdata
---+--------+-------+---------------------------------+-------+---------+-------------------+---------
0  | single |       |                                 | root  |         | current           |         
1  | pre    |       | Fri 26 Apr 2024 11:56:18 AM EDT | madhu | number  | Pre Color Picker  |         
2  | post   |     1 | Fri 26 Apr 2024 12:02:34 PM EDT | madhu | number  | Post Color Picker |
```

Review the changes made to the system between the pre and post snapshots.

```
snapper -c root status 4..7
c..... /boot/grub2/grub-btrfs.cfg
c..... /etc/cups/subscriptions.conf
c..... /etc/cups/subscriptions.conf.O
...
c..... /var/lib/dnf/history.sqlite-shm
c..... /var/lib/dnf/history.sqlite-wal
c..... /var/lib/PackageKit/transactions.db

snapper -c home status 1..2
c..... /home/madhu/.cache/gnome-software/appstream/components.xmlb
+..... /home/madhu/.config/gcolor3
+..... /home/madhu/.config/gcolor3/config.ini
...
+..... /home/madhu/.local/share/gvfs-metadata/root-267c9227.log
-..... /home/madhu/.local/share/gvfs-metadata/root-c6c739f9.log
c..... /home/madhu/.local/share/ibus-typing-booster/debug.log
```

This is the total number of files added, removed, or modified.

```
snapper -c root status 4..7 | wc -l
12771

snapper -c home status 1..2 | wc -l
278
```

I'll now undo the changes in the / and /home directories.

```
sudo snapper -c root undochange 4..7
create:0 modify:13 delete:12758

sudo snapper -c home undochange 1..2
create:1 modify:3 delete:274
```

The Color Picker package will be completely removed from the system.

Log out and then log back in.

```
gnome-session-quit
```

Check again to see if the Color Picker has been completely removed.

```
gcolor3
bash: gcolor3: command not found...
```

Since you removed the Color Picker package, there is no reason to keep its pre-post snapshots if you do not intend to use it again. So you can delete those snapshots.

```
snapper -c root delete 4-7
snapper -c home delete 1-2
```

Test 3 was successful.

### Test 4: Rollback to a Previous Snapshot from the GRUB Menu

In this rollback test, I will delete the most critical files and directories on which the Linux operating system relies. These include Linux kernel and initramfs files in the /boot directory, the /etc directory, which contains all configuration files, and the /usr directory, which contains all drivers, kernel modules, and library files.

Once I delete these files and directories, I will be unable to issue any commands because the Linux OS is pretty much dead, and the system will undoubtedly fail the next time it boots. So I'll hard boot the system and see if I can save the day by rolling back to a working snapshot.

So, before I delete them, here's how they appear.

```
sudo du -sch /boot /etc /usr
307M	/boot
34M	/etc
6.1G	/usr
6.4G	total
```

Now delete the files and directories.

```
sudo rm -rvf /boot/{vmlinuz,initramfs}* /etc /usr
```

Boom!!! All critical files have been removed. Your Linux system is no longer operational.

Reboot the system.

Your system should now fail to boot and display something like this.

![Install Fedora with Snapshot and Rollback Support - Grub Error](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Grub_Error.webp)

Return to the GRUB menu, and this time boot from snapshot #3.

![Install Fedora with Snapshot and Rollback Support - Grub Snapshots Menu](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Grub_Snapshots_Menu.webp)

![Install Fedora with Snapshot and Rollback Support - Select Snapshot No 3](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Select_Snapshot_No_3.webp)

![Install Fedora with Snapshot and Rollback Support - Select Latest Kernel](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Select_Latest_Kernel.webp)

Once you've finished booting, open the terminal.

Check the '/' file system. Because you booted into the snapshot, the file system '/' will be read-only.

```
sudo btrfs property get -ts /
ro=true
```

Now that everything appears to be operating properly, it is time to roll back this snapshot in read-write mode.

```
snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata
---+--------+-------+---------------------------------+------+---------+-----------------------------+---------
0  | single |       |                                 | root |         | current                     |         
1+ | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root |         | first root subvolume        |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |         
3- | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root | number  | /usr/bin/dnf install ps_mem |
```

As you can see from the output, snapshot #1 has a '+' symbol, indicating that it is the default subvolume, whereas snapshot #3 has a '-' symbol, indicating that it is the currently booted subvolume.

```
sudo snapper rollback
Ambit is classic.
Creating read-only snapshot of default subvolume. (Snapshot 4.)
Creating read-write snapshot of current subvolume. (Snapshot 5.)
Setting default subvolume to snapshot 5.
```

Now, reboot your system.

```
sudo reboot
```

This time, from the GRUB menu, boot normally. Also, notice that the Snapshots menu is missing. This is because of the rollback. We will fix it once we have booted into the operating system.

![Install Fedora with Snapshot and Rollback Support - Grub Rollback](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Grub_Rollback.webp)

The first thing you should do after a rollback is to update the grub.cfg file so that the GRUB menu snapshots are always in sync.

So, open the terminal and update the grub.cfg file.

```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Adding boot menu entry for UEFI Firmware Settings ...
Detecting snapshots ...
Found snapshot: 2024-04-26 12:26:34 | .snapshots/5/snapshot | single | writable copy of #3         |
Found snapshot: 2024-04-26 11:18:16 | .snapshots/3/snapshot | post   | /usr/bin/dnf install ps_mem |
Found snapshot: 2024-04-26 11:18:14 | .snapshots/2/snapshot | pre    | /usr/bin/dnf install ps_mem |
Found 3 snapshot(s)
Unmount /tmp/grub-btrfs.pOHbKZXUyh .. Success
done
```

The GRUB Snapshot menu has now been recreated.

Now, check the system once again.

```
sudo du -sch /boot /etc /usr
307M	/boot
34M	/etc
6.1G	/usr
6.4G	total

sudo btrfs property get -ts /
ro=false

snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata     
---+--------+-------+---------------------------------+------+---------+-----------------------------+--------------
0  | single |       |                                 | root |         | current                     |              
1  | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root | number  | first root subvolume        |              
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |              
3  | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root | number  | /usr/bin/dnf install ps_mem |              
4  | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root | number  | rollback backup of #1       | important=yes
5* | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root |         | writable copy of #3         |

sudo btrfs subvolume get-default /
ID 275 gen 338 top level 269 path .snapshots/5/snapshot
```

You successfully restored the system with the latest working snapshot in read and write mode.

Test 4 was successful.

## 8. Make a Snapshot the New System Root

Now that you've tested the snapper undo and rollback features and are hopefully satisfied with the results, you might want to set one of the snapshots as the new default system root and resume normal operating system use.

But first, let me show you how to determine how much space each snapshot takes up on your disk.

```
sudo btrfs filesystem du -s --human-readable /.snapshots/*/snapshot
     Total   Exclusive  Set shared  Filename
   1.87GiB       0.00B     1.87GiB  /.snapshots/1/snapshot
   6.18GiB    32.00KiB     6.12GiB  /.snapshots/2/snapshot
   6.18GiB    52.00KiB     6.12GiB  /.snapshots/3/snapshot
   1.87GiB       0.00B     1.87GiB  /.snapshots/4/snapshot
   6.18GiB   284.00KiB     6.12GiB  /.snapshots/5/snapshot
```

As you can see from the output above, snapshot #1 has an exclusive size of 0 bytes. This is because, as you may recall, I deleted all of the files recursively. Snapshot #4 is also 0 bytes in size because it is a read-only duplicate of snapshot #1.

To find out how the 'Total' and 'Set shared' values are calculated, see the man page `man btrfs-filesystem`.

Now, let's return to making a snapshot the new system root.

```
snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata     
---+--------+-------+---------------------------------+------+---------+-----------------------------+--------------
0  | single |       |                                 | root |         | current                     |              
1  | single |       | Fri 26 Apr 2024 10:48:07 AM EDT | root | number  | first root subvolume        |              
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |              
3  | post   |     2 | Fri 26 Apr 2024 11:18:16 AM EDT | root | number  | /usr/bin/dnf install ps_mem |              
4  | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root | number  | rollback backup of #1       | important=yes
5* | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root |         | writable copy of #3         |
```

The output indicates that snapshot #5 is the default subvolume, and since it is operational, you can simply delete the remaining snapshots and move on.

However, I will use snapshot #2 as the default because it is a 'pre' snapshot that was created just before ps_mem was installed and is clean.

So, first, delete all of the snapshots except #2. You cannot delete snapshot #5 because it is the active one.

```
snapper delete 1
snapper delete 3-4

snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata
---+--------+-------+---------------------------------+------+---------+-----------------------------+---------
0  | single |       |                                 | root |         | current                     |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |         
5* | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root |         | writable copy of #3         |
```

Create a directory named '1' in the /.snapshots directory.

```
sudo mkdir -v /.snapshots/1
```

Copy the info.xml file from /.snapshots/2/ to /.snapshots/1/.

```
sudo cp -v /.snapshots/2/info.xml /.snapshots/1/
```

Edit the /.snapshots/1/info.xml file and change the content from this...

```
sudo cat /.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
  <type>pre</type>
  <num>2</num>
  <date>2024-04-26 15:18:14</date>
  <description>/usr/bin/dnf install ps_mem</description>
  <cleanup>number</cleanup>
</snapshot>
```

...to this. Changes are in amber.

```
sudo cat /.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>2024-04-26 15:18:14</date>
  <description>new root subvolume</description>
</snapshot>
```

Create a read-write subvolume snapshot of snapshot #2 in the /.snapshots/1/ directory.

```
sudo btrfs subvolume snapshot /.snapshots/2/snapshot /.snapshots/1/snapshot
```

Get the subvolid of the /.snapshots/1/snapshot subvolume.

```
sudo btrfs inspect-internal rootid /.snapshots/1/snapshot
276
```

Using subvolid 276, set the /.snapshots/1/snapshot subvolume as the default subvolume for the root (/) filesystem.

```
sudo btrfs subvolume set-default 276 /
```

Then reboot.

```
sudo reboot
```

After rebooting, confirm that the /.snapshots/1/snapshot subvolume is indeed the default for the / filesystem.

```
sudo btrfs subvolume get-default /
ID 276 gen 365 top level 269 path .snapshots/1/snapshot
```

And is writable.

```
sudo btrfs property get -ts /
ro=false
```

Take a look at the snapper now.

```
snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description                 | Userdata
---+--------+-------+---------------------------------+------+---------+-----------------------------+---------
0  | single |       |                                 | root |         | current                     |         
1* | single |       | Fri 26 Apr 2024 11:18:14 AM EDT | root |         | new root subvolume          |         
2  | pre    |       | Fri 26 Apr 2024 11:18:14 AM EDT | root | number  | /usr/bin/dnf install ps_mem |         
5  | single |       | Fri 26 Apr 2024 12:26:34 PM EDT | root |         | writable copy of #3         |
```

As you can see, snapshot #1 is the default. You can now delete the remaining snapshots.

```
snapper delete 2-5

snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup | Description        | Userdata
---+--------+-------+---------------------------------+------+---------+--------------------+---------
0  | single |       |                                 | root |         | current            |         
1* | single |       | Fri 26 Apr 2024 11:18:14 AM EDT | root |         | new root subvolume |         

sudo btrfs filesystem du -s --human-readable /.snapshots/*/snapshot
     Total   Exclusive  Set shared  Filename
   6.18GiB   268.00KiB     6.12GiB  /.snapshots/1/snapshot
```

Update grub.cfg file.

```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

You're done.

## 9. Enable Automatic Timeline Snapshots

Now that you've finished everything, you can enable automatic timeline snapshots. When the timeline is enabled, a snapshot is created once every hour. Once per day, the timeline cleanup algorithm cleans up the snapshots.

Automatic Timeline Snapshots are enabled by default in both root and home configurations. Enable it only for the system root and disable it for the home. See the Arch Wiki page on '[Automatic timeline snapshots](https://wiki.archlinux.org/title/snapper#Automatic_timeline_snapshots)' for more information.

```
sudo snapper -c home set-config TIMELINE_CREATE=no
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

That's all. Every hour from now on, a 'single' snapshot will be created and cleaned up every other day.

```
snapper ls
 # | Type   | Pre # | Date                            | User | Cleanup  | Description        | Userdata
---+--------+-------+---------------------------------+------+----------+--------------------+---------
0  | single |       |                                 | root |          | current            |         
1* | single |       | Fri 26 Apr 2024 11:18:14 AM EDT | root |          | new root subvolume |         
2  | single |       | Fri 26 Apr 2024 03:00:04 PM EDT | root | timeline | timeline           |         
3  | single |       | Fri 26 Apr 2024 04:00:04 PM EDT | root | timeline | timeline           |
```

To stop timeline snapshots, disable the snapper timers.

```
sudo systemctl disable --now snapper-timeline.timer
sudo systemctl disable --now snapper-cleanup.timer
```

The installation of Fedora 40 with snapshot and rollback support is now complete.

## 10. Issues and Possible Solutions

**Problem 1:** Sometimes, after updating Fedora and rebooting, you may encounter a boot error like this:

error: ../../grub-core/script/lexer.c:352:syntax error.
error: ../../grub-core/script/lexer.c:352:Incorrect command.

**Issue:** This usually occurs when a kernel update has just been released and all of the kernel's supporting files have not yet been propagated to a repository mirror near you.

This is caused by the kernel parameter '{extra_cmdline}'. The '{extra_cmdline}' parameter is added to the kernel when you add the 'SUSE_BTRFS_SNAPSHOT_BOOTING=true' key to the /etc/default/grub file.

**Solution**: From the GRUB menu, select the kernel version you want to boot, and then press 'e' to modify the command.

Go to the line that starts with the word 'linux', and move the parameter '{extra_cmdline}' to the end of the line. The parameter '{extra_cmdline}' should always be at the end of the line.

From this:

![Install Fedora with Snapshot and Rollback Support - Issue 1](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Issue_1.webp)

To this:

![Install Fedora with Snapshot and Rollback Support - Solution 1](/Media/Pictures/Fedora_40_btrfs_snapper/Install_Fedora_with_Snapshot_and_Rollback_Support_-_Solution_1.webp)

Then, on your keyboard, press Ctrl+x. You will be successfully booted into the operating system. Next, launch the terminal and execute the following command.

```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Reboot the computer to ensure the problem has been resolved.

**Problem 2**: When you try to boot from a snapshot from the GRUB menu, you sometimes get an error like this:

error: ../../grub-core/commands/efi/tpm.c:150:unknown TPM error

**Issue:** The problem appears to be that GRUB does not support TPM 2.0 very well when enabled in UEFI System Settings.

**Solution:** I looked into it, and it appears that [this solution](https://discussion.fedoraproject.org/t/tpm-error-on-booting/76724/9) works perfectly. All credit goes to Eric Renfro.

Create a script named 02_tpm in the /etc/grub.d/ directory with the following contents.

```
# vim /etc/grub.d/02_tpm
#!/usr/bin/sh -e
echo "rmmod tpm"
```

Set the execute permission on a file.

```
# chmod +x /etc/grub.d/02_tpm
```

Update the grub.cfg file.

```
# grub2-mkconfig -o /boot/grub2/grub.cfg
```

This issue should now be resolved.

## 11. Upgrade Fedora 39 to Fedora 40

If you've already followed an earlier version of this tutorial and installed Fedora 39 and want to upgrade to Fedora 40, this section is for you.

Update the local DNF metadata cache.

```
sudo dnf makecache
```

Update your Fedora 39 release. This is important. **Do not skip this step**.

```
sudo dnf upgrade --refresh
```

After the updates have been installed, reboot your computer.

```
sudo reboot
```

After rebooting, open the terminal and run the following command to upgrade your Fedora 39 operating system to the most recent Fedora 40 version.

```
sudo dnf system-upgrade download --releasever=40
```

Once the upgrades have been downloaded, trigger the upgrade process. This will immediately reboot your computer, with no countdown or confirmation. So, before issuing the following command, close all other programs and save your work.

```
sudo dnf system-upgrade reboot
```

Once the upgrade process completes, your system will reboot again into the updated release version of Fedora 40.

If you want to learn more about the upgrade process, check out this [link](https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/).

## 12. Watch on YouTube

Tags: [BtrFS](https://sysguides.com/tag/btrfs) [Fedora](https://sysguides.com/tag/fedora) [Rollback](https://sysguides.com/tag/rollback) [Snapshot](https://sysguides.com/tag/snapshot)

---

←[Previous: How to Install Fedora 37 with LUKS Full Disk Encryption (FDE)](https://sysguides.com/install-fedora-37-with-luks-full-disk-encryption)

[Next: How to Install Fedora 38/39 with Full Disk Encryption, Snapshot and Rollback Support](https://sysguides.com/install-fedora-with-fde-snapshot-rollback-support)→

Subscribe

![guest](/Media/Pictures/Fedora_40_btrfs_snapper/guest.jpg)

109 Comments

Newest

## Search the Website

Search

---

## Latest Posts

- [How to Properly Dual-boot Windows 11 and Ubuntu](https://sysguides.com/dual-boot-windows-11-and-ubuntu)
- [How to Install Fedora 40 with LUKS Full Disk Encryption, Snapshot, and Rollback Support](https://sysguides.com/install-fedora-with-luks-fde-snapshot-rollback-support)
- [How to Create and Manage Internal Snapshots in KVM](https://sysguides.com/create-and-manage-internal-snapshots-in-kvm)
- [Share Files Between the KVM Host and Windows Guest Using Virtiofs](https://sysguides.com/share-files-between-the-kvm-host-and-windows-guest-using-virtiofs)
- [How to Properly Install a Windows 11 Virtual Machine on KVM](https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm)

---

## Popular Categories

- [Distro](https://sysguides.com/category/distro) (13)
- [Security](https://sysguides.com/category/security) (8)
- [Storage](https://sysguides.com/category/storage) (15)
- [Virtualization](https://sysguides.com/category/virtualization) (8)
- [WebDev](https://sysguides.com/category/webdev) (1)
- [Windows](https://sysguides.com/category/windows) (3)

---

## Like this Blog?

Readers like YOU help me keep this blog alive. If you like my work and want to