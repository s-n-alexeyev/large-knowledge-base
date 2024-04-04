

Starting version 2023.2, Kali Linux uses [PipeWire](https://pipewire.org/) to deal with audio, for both the XFCE desktop and the GNOME desktop. Before that, Kali Linux used another sound server named [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/). (Note: for those who use Kali’s KDE desktop: PulseAudio is still in charge)

The change should be seamless, as PipeWire provides a compatibility layer (a service named `pipewire-pulse`). Therefore legacy applications that were designed to work with PulseAudio should keep working as if nothing happened, blissfully unaware of the change.

If you encounter some audio issues after upgrading to Kali 2023.2: **please do NOT uninstall the package `pipewire-pulse`**, despite all the Internet pages telling you to do so! This used to be a fix in an older version of Kali Linux, and therefore this “fix” is now copy/pasted everywhere on the Internet. But now that we switched to PipeWire, uninstalling this package would be counter-productive, and would break your system even more. Please don’t.

[

## Upgrading to PipeWire

](https://www.kali.org/docs/troubleshooting/no-sound/#upgrading-to-pipewire)

For users who upgrade their Kali installation, all you need to do is upgrade your system as usual, with the pair of commands:

```sh
kali@kali:~$ sudo apt update
kali@kali:~$
kali@kali:~$ sudo apt full-upgrade -y
kali@kali:~$
```

This will automatically install PipeWire. It will be effective after a reboot. If for some reason the sound doesn’t work after that, try to reboot.

If sound still doesn’t work after that, let’s install the `pipewire-audio` metapackage with the following command:

```sh
kali@kali:~$ sudo apt install --mark-auto -y pipewire-audio
```

Then reboot again. If sound still doesn’t work, you might want to reach out on [Kali’s bugtracker](https://bugs.kali.org) so we can help troubleshoot the issue.

[

## Missing firmware for Intel SOF audio devices

](https://www.kali.org/docs/troubleshooting/no-sound/#missing-firmware-for-intel-sof-audio-devices)

This only applies if you run Kali baremetal. Some recent Intel sound cards require a firmware to work, and it could be that this firmware is not installed on your system. In doubt, you can install it, it won’t do any harm:

```sh
kali@kali:~$ sudo apt update
kali@kali:~$
kali@kali:~$ sudo apt install -y firmware-sof-signed
kali@kali:~$
```