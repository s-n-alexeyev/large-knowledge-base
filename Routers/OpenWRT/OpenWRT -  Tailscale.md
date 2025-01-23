# Tailscale[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#tailscale)

Tailscale создает виртуальную сеть между хостами. Он может использоваться как простой механизм для удаленного администрирования без пересылки портов или быть настроенным таким образом, чтобы узлы в вашей виртуальной сети могли проксировать трафик через подключенные устройства как временный VPN.

Вы можете узнать больше о том, как работает Tailscale [тут](https://tailscale.com/blog/how-tailscale-works/ "https://tailscale.com/blog/how-tailscale-works/").
### Установка[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#installation)

```bash
opkg update
opkg install tailscale
```

Обратите внимание, что в зависимости от вашей версии OpenWRT пакет может быть устаревшим и не содержать обновлений безопасности. Вы можете найти инструкции о том, как обновиться до последней версии пакета Tailscale на странице вашего административного консоли Tailscale.

### Подготовительная настройка[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#initial_setup)

После установки Tailscale выполните команду ниже и завершите регистрацию устройства, вставив предоставленную ссылку в веб-браузер и аутентифицируясь с помощью поддерживаемого метода.

```bash
tailscale up
```

После регистрации соединение устройства можно просмотреть с помощью команды "статус":

```bash
tailscale status
```

Дополнительная конфигурация может потребоваться для взаимодействия с другими машинами вашего Tailnet в зависимости от ваших стандартных правил пересылки. Ниже приведены инструкции, которые можно использовать для добавления нового неуправляемого интерфейса и зоны брандмауэра, чтобы вы могли классифицировать и применять правила пересылки к трафику Tailscale.

Создайте новый неуправляемый интерфейс через LuCI.: **Network** → **Interfaces** → **Add new interface**
- Name: **tailscale**  
- Protocol: **Unmanaged**  
- Device: **tailscale0**

Проверьте, что интерфейсу был назначен ваш адрес Tailscale:

```bash
ip address show tailscale0
```

If an address was not assigned (Tailscale versions before 1.58.2-1):

Create a new firewall zone via LuCI: **Network** → **Firewall** → **Zones** → **Add**

- Name: **tailscale**
    
- Input: **ACCEPT** (default)
    
- Output: **ACCEPT** (default)
    
- Forward: **ACCEPT**
    
- Masquerading: **on**
    
- MSS Clamping: **on**
    
- Covered networks: **tailscale**
    
- Allow forward to destination zones: Select your **LAN** (and/or other internal zones or WAN if you plan on using this device as an exit node)
    
- Allow forward from source zones: Select your **LAN** (and/or other internal zones or leave it blank if you do not want to route LAN traffic to other tailscale hosts)
    

Click **Save & Apply**

### OpenWrt ssh access[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#openwrt_ssh_access)

If ssh access to OpenWrt through tailscale is wanted, setup a port forward from the created tailscale interface and lan to the local OpenWrt IP, default 192.168.1.1 and port 22 on ingress and egress.

### iptables-nft issue[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#iptables-nft_issue)

OpenWrt 22.03 and later, use [nftables](https://openwrt.org/docs/guide-user/firewall/misc/nftables "docs:guide-user:firewall:misc:nftables") (superseding iptables) as a backend to [firewall4](https://openwrt.org/releases/22.03/notes-22.03.0#firewall4_based_on_nftables "releases:22.03:notes-22.03.0"). Tailscale alone is [unable to configure nftables automatically](https://github.com/tailscale/tailscale/issues/4086 "https://github.com/tailscale/tailscale/issues/4086") and this prevents the tailscale daemon from initializing properly and forwarding traffic. Additional packages must be installed (OpenWRT versions 22 or 23):

opkg install iptables-nft kmod-ipt-conntrack kmod-ipt-conntrack-extra kmod-ipt-conntrack-label kmod-nft-nat kmod-ipt-nat

# The kmod-ipt-conntrack packages came from https://github.com/openwrt/openwrt/issues/13859

Versions 22.x only:

Restart the daemon

service tailscale restart

Verify no Kernel errors occur:

tailscale status

Complete the setup as usual

### How to setup a Subnet Router/Exit Node[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#how_to_setup_a_subnet_routerexit_node)

In order to get tailscale to cooperate well with LuCI, you will need to create a new managed interface and firewall zone for tailscale.

- Add the interface and firewall zone as per the [Initial Setup](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#initial_setup "docs:guide-user:services:vpn:tailscale:start ↵") section

- Restart `tailscale` and add the routes you want to advertise to peers using the `--advertise-routes` option with a comma separated list of network addresses and CIDRs. The `--accept-routes` option will manage adding static routes for other subnet routes within your tailnet.

tailscale up --advertise-routes=10.0.0.0/24,10.0.1.0/24 --accept-routes

You can also also use `--advertise-exit-node` node here to offer both subnet routes and a WAN gateway to your tailscale network:

tailscale up --advertise-routes=10.0.0.0/24,10.0.1.0/24 --accept-routes --advertise-exit-node

If you're using OpenWrt == 22.03 you will also need to specify `--netfilter-mode=off`. For later versions you should not include it.

- Open the [Machines](https://login.tailscale.com/admin/machines "https://login.tailscale.com/admin/machines") page in the Tailscale admin interface. Once you've found the machine from the ellipsis icon menu, open the `Edit route settings..` panel, and approve exported routes and or enable the `Use as exit node` option.

![](https://openwrt.org/_media/media/docs/howto/screenshot_2023-03-12_at_5.09.51_am.png?w=200&tok=8be3cc) ![](https://openwrt.org/_media/media/docs/howto/screenshot_2023-04-05_at_2.54.48_pm.png?w=400&tok=433990)

- Devices on either subnet should be able to route traffic over the VPN. If you've configured this device to be an exit node, it should now be selectable from your tailscale apps as an `Exit Node`. You can test connectivity with tools like `ping` or `traceroute`.

### Force LAN traffic to route through Exit Node[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#force_lan_traffic_to_route_through_exit_node)

To use the device as a VPN gateway, configure Tailscale to use an exit node. This will route all LAN traffic to go through your exit node only.

If you're using OpenWrt == 22.03 you will also need to specify `--netfilter-mode=off`. For versions 23+ do _NOT_ include netfilter-mode.

tailscale up --exit-node=MY-EXIT-NODE --exit-node-allow-lan-access=true

- Add the interface and firewall zone as per the [Initial Setup](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#initial_setup "docs:guide-user:services:vpn:tailscale:start ↵") section

- Disable packet forwarding by default: **Network** → **Firewall** → **General Settings**

- Forward: **reject**
    

- Disable LAN-to-WAN forwarding: **Network** → **Firewall** → **Zones** → **lan** → **Edit**

- Allow forward to destination zones: Ensure that your **WAN** zone is **unselected**.
    

- Enable Tailscale NAT: **Network** → **Firewall** → **Zones** → **tailscale** → **Edit**

- Allow forward to destination zones: Unspecified (all unchecked)
    
- Ensure that Masquerading is checked (this allows LAN traffic to appear as the router's tailscale address (similar to how WAN works)
    

- Enable LAN-to-Tailscale forwarding **Network** → **Firewall** → **Zones** → **lan** → **Edit**

- Allow forward to destination zones: Ensure that your **Tailscale** zone is **selected**.
    

You can verify that all traffic is being forced over your remote Tailscale exit node by running traceroute. You should see your Tailscale exit node in the second or so hop chain. If your Tailscale connected OpenWRT router is sending all traffic to the exit node but not LAN clients:

- Double check that your LAN firewall zone does not include the WAN for destination forwarding.

- You may have unexpected iptables or nftables stale rules. Reboot your OpenWRT device so you get a clean boot and application of rules.

## Installation on storage constrained devices[](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#installation_on_storage_constrained_devices)

Tailscale cannot be installed on devices with 16MB or less of flash memory because the package and its dependencies consume too much space. Until the day that there is a separate “tailscale-lite” build, your best bet is to compile (or cross-compile) it yourself from upstream sources and use the [multicall binary](https://flameeyes.blog/2009/10/19/multicall-binaries/ "https://flameeyes.blog/2009/10/19/multicall-binaries/") build target. To reduce the filesize further, you can strip debugging symbols and run the resulting binary through a packer, like _[upx](https://github.com/upx/upx "https://github.com/upx/upx")_. As of `1.56.1`, this will result in ~98% reduction in size (from ~33MB to ~5.2MB).

Instead of running the optimized binaries directly, it is recommend that you repack the `tailscale.ipk`, and `tailscaled.ipk` packages with the smaller optimized binaries. This will let you benefit from OpenWrt conventions like init scripts, opkg installation receipts, etc, keeping your installation sane and consistent while still being able to use the smaller binaries.

If your device has only 16MB of flash or less, you will need to share the multicall binary between both of the `tailscale` and `tailscaled` packages. To do this, stub out the large `/usr/sbin/tailscale{d}` binaries contained within these packages, install them, manually copy the optimized binary to the device, and then replace the stubs with symlinks. More detailed instructions on how to do this are below.

The official Tailscale small binary build guide is here:

- [https://tailscale.com/kb/1207/small-tailscale/](https://tailscale.com/kb/1207/small-tailscale/ "https://tailscale.com/kb/1207/small-tailscale/")
    

Tips:

- [upx 3.96 produces broken mips binaries](https://github.com/upx/upx/issues/342 "https://github.com/upx/upx/issues/342"), use the latest version. Upx can handle all executable formats, so you don't need to run it under the target architecture.
    
- You can shave off an additional MB or so with `strip --strip-all`. This strips even more than when using `go build` ldflags. Look for the `binutils` package of your target architecture. For my MIPS target, on Linux that was `binutils-mips-linux-gnu`, on macOS the same MacPorts package is called `mips-elf-binutils`.
    
- You should reset your git checkout of Tailscale to a tagged stable release to ensure compatibility with the OpenWrt package you're repacking. This also makes troubleshooting easier on yourself in the future and is best practice.
    
- Be very careful when repacking your `.ipk` not to include leading paths. An absolute path in the root of the package will produce an unusable `.ipk`.
    
- Don't forget to symlink `/usr/sbin/talescale.combined` to `/usr/sbin/tailscale` and `/usr/sbin/tailscaled`.
    
- If installing on >= 22.03, don't forget to apply the work arounds listed earlier on this page.
    
- **On slow devices, upx packed executables may appear to hang at first when you run them but this is normal; higher startup time for lower storage costs. If having trouble try compressing without `--best`**
    
- It's a good idea to check that your `tailscale.combined` actually runs on your target architecture with a simple `./tailscaled --version` on the target device before going to the trouble of repacking.
    

Other useful links:

- [https://zyfdegh.github.io/post/202002-go-compile-for-mips/](https://zyfdegh.github.io/post/202002-go-compile-for-mips/ "https://zyfdegh.github.io/post/202002-go-compile-for-mips/")
    
- [https://serverfault.com/questions/163487/how-to-tell-if-a-linux-system-is-big-endian-or-little-endian/749469#749469](https://serverfault.com/questions/163487/how-to-tell-if-a-linux-system-is-big-endian-or-little-endian/749469#749469 "https://serverfault.com/questions/163487/how-to-tell-if-a-linux-system-is-big-endian-or-little-endian/749469#749469")
    

Shell history on macOS where I built tailscale from source for a big endian mips target:

sudo port install go mips-elf-binutils upx
git clone https://github.com/tailscale/tailscale.git
cd tailscale
git checkout tags/v1.56.1 -b v1.56.1
env GOOS=linux GOARCH=mips GOMIPS=softfloat go build -o tailscale.combined -tags ts_include_cli,ts_omit_aws,ts_omit_bird,ts_omit_tap,ts_omit_kube -trimpath -ldflags="-s -w" ./cmd/tailscaled
/opt/local/bin/mips-elf-strip --strip-all tailscale.combined
upx --lzma --best tailscale.combined # (v3.96 has deadlock bug)

The steps below were performed on Debian Linux. I repacked the OpenWrt `.ipk` for the `tailscale` and `tailscaled` packages and replaced the large binaries with small stub scripts that always return true. I did this so that the pre/post scripts will run successfully and the opkg database at `/usr/lib/opkg` will be consistent. The packages were installed manually and stub files deleted post installation. The multicall binary was then uploaded and symlinks created.

# convenience variables
export package=tailscaled_1.56.1-1_mips_24kc.ipk
export release=23.05.2
export arch=mips_24kc

# download .ipk
wget https://downloads.openwrt.org/releases/${release}/packages/${arch}/packages/${package}
mkdir ${package%%.ipk}
pushd ${package%%.ipk}
tar -xvf ../${package}

# data
mkdir data
pushd data
tar -xvf ../data.tar.gz
echo -e '#!/bin/sh\ntrue\n' > usr/sbin/${package%%_*}
tar --numeric-owner --group=0 --owner=0 -czf ../data.tar.gz *
popd
size=$(du -sb data | awk '{ print $1 }')
rm -rf data

# control
mkdir control
pushd control
tar -xvf ../control.tar.gz
sed -i "s/^Installed-Size.*/Installed-Size: ${size}/g" control
tar --numeric-owner --group=0 --owner=0 -czf ../control.tar.gz *
popd
rm -rf control

# repack .ipk
tar --numeric-owner --group=0 --owner=0 -cvzf ../${package} debian-binary data.tar.gz control.tar.gz
popd

You should now have a repacked package named `tailscaled_1.56.1-1_mips_24kc.ipk`. You will need to repeat this process for the `tailscale` package.

Set a new package variable:

export package=tailscale_1.56.1-1_mips_24kc.ipk

And repeat the repack process above to create the repacked `tailscale` package.

You should now have two repacked packages similar to `tailscale_1.56.1-1_mips_24kc.ipk` and `tailscaled_1.56.1-1_mips_24kc.ipk`. Copy these files to `/tmp` on your device. Since sftp-server is not included with dropbear/OpenWrt, if you're scp from a relatively recent version of OpenSSH you'll need to either use `scp -O` to use the legacy scp fallback mode, or do this _**from**_ the OpenWrt device.

# convenience variables
export version=1.56.1
export arch=mips_24kc

# copy files
scp remote:/tmp/tailscale.combined /tmp
scp remote:/tmp/tailscaled_${version}-1_${arch}.ipk /tmp
scp remote:/tmp/tailscale_${version}-1_${arch}.ipk /tmp

# install dependencies
opkg install kmod-tun

# install repacked packages
opkg install /tmp/tailscaled_${version}-1_${arch}.ipk
opkg install /tmp/tailscale_${version}-1_${arch}.ipk

# remove stubs and link multicall binary
rm /usr/sbin/tailscaled
rm /usr/sbin/tailscale
cd /usr/sbin
cp /tmp/tailscale.combined .
ln -s tailscale.combined tailscaled
ln -s tailscale.combined tailscale

# verify
tailscale --version
tailscaled --version

You're now ready to continue to [iptables-nft_issue](https://openwrt.org/docs/guide-user/services/vpn/tailscale/start#iptables-nft_issue "docs:guide-user:services:vpn:tailscale:start").