# Project FreeBSD Wifibox

Wifibox deploys a Linux guest to drive a wireless networking card on
the FreeBSD host system with the help of PCI pass-through.  There have
been guides on the Internet to suggest the use of such techniques to
improve the wireless networking experience on FreeBSD, of which
Wifibox tries to implement as a single easy-to-use software package.

- [`bhyve`], a lightweight virtualization solution for FreeBSD, is
  utilized to run the embedded Linux system.  This helps to achieve
  low resource footprint.

- Configuration files could be shared with the host system.  For
  example, the guest may either use `wpa_supplicant(8)` or
  `hostapd(8)` and it is possible to import the host's
  `wpa_supplicant.conf(5)` and `hostapd.conf(5)` files without any
  changes.

- When configured by the guest, `wpa_supplicant(8)` or `hostapd(8)`
  control sockets could be exposed, which enables use of related
  utilities directly from the host, such as `wpa_cli(8)` or
  `wpa_gui(8)` from the [`net/wpa_supplicant_gui`] FreeBSD package, or
  `hostapd_cli(8)`.

- Everything is shipped in a single FreeBSD package that can be easily
  installed and removed.  It comes with an `rc(8)` system service that
  automatically launches the guest on boot and stops it on shutdown.

- A workaround is supplied for laptops to support suspend/resume.

For more information on the background and the high-level overview of
Wifibox, please read the [article] in the November/December 2024
edition of the FreeBSD Journal on Virtualization.

## Warning

*This is a work-in-progress experimental software project without any
guarantees or warranties.  It is shared in the hope that is going to
be useful and inspiring for others.  By its nature, it is a workaround
and shall be deprecated once the FreeBSD wireless drivers and
networking stack are updated to catch up with Linux.*

*Wifibox does not necessarily offer a drop-in replacement for the
wireless networking stack of FreeBSD.  This is entirely determined by
how the guest exposes network traffic for the host, which might happen
via Network Address Translation (NAT) or bridging, for example.  Be
sure to consult the documentation of the guest itself before use.*

## Prerequisites

Before the installation, please check if those items are present on
the target computer otherwise running the software might not be
possible:

- A CPU that is supported by [`bhyve`] PCI pass-through (I/O MMU) with
  ~256 MB physical memory or less depending on the guest, and some
  disk space available for the guest virtual disk image.

- A PCI wireless card that is known to be supported by the recent
  Linux versions, but it is not performing well enough under FreeBSD.
  Also, the Linux driver has to support [Message Signaled Interrupts]
  (MSI) because that is required for the PCI pass-through to work.
  USB wireless adapters are not supported.

- A supported FreeBSD/amd64 system: 13.5-RELEASE or 14.2-RELEASE.
  Later versions will also probably work, but your mileage may vary.

- [`grub2-bhyve`] or the corresponding `sysutils/grub2-bhyve` FreeBSD
  package, so the Linux guest could be booted via GRUB 2.

- [`socat`] or the respective `net/socat` FreeBSD package, through
  which control sockets for `wpa_supplicant(8)` and `hostapd(8)` could
  be published on the host.  The presence of `socat` is required only
  if this feature is activated, which depends on the guest
  configuration.

## Installation

Use the `net/wifibox` FreeBSD port which is available at the
[`freebsd-wifibox-port`] repository and automatically takes care of all
the following details, installs a guest image, and offers proper
removal of the installed files, hence it is a more convenient way to
manage the whole installation process.

### Manual Installation

Alternatively, a `Makefile` is present in this repository that can be
used to install all the files, as described below.  This workflow is
mostly recommended for development and testing.

```console
# make install \
    PREFIX=<prefix> \
    LOCALBASE=<prefix of the grub2-bhyve and socat packages> \
    GUEST_ROOT=<guest disk image location> \
    GUEST_MAN=<guest manual page location> \
    RECOVERY_METHOD=<method to use on suspend and resume> \
    DEVD_FIX=<add extra devd.conf(5) configuration to handle suspend>
```

By default, `PREFIX` is set to `/usr/local`.  In addition to that, it
is possible to set the `LOCALBASE` variable to tell if the prefix
under which the `grub-bhyve` and `socat` utilities were installed is
different.

The `GUEST_ROOT` variable should point to the directory that houses
the files related to the guest.  Note that these are not part of the
repository and should be installed individually.  For example, such
files could be installed from the [`freebsd-wifibox-alpine`]
repository.

- GRUB is going to be configured according to the contents of
  `grub.cfg`, and then the system is booted from the virtual disk
  image whose contents should be stored as `disk.img`.

- When needed, `device.map` could also be placed there to teach GRUB
  about the virtual disk image.

The `RECOVERY_METHOD` variable can be used to tell in which way
Wifibox should be revived on a suspend/resume pair of events.

- The default value is `restart_vmm`, which means that guest will be
  stopped, and the `vmm(4)` kernel module will be reloaded then the
  guest will be restarted on resume.
- Another option is `suspend_guest`, which will stop the only guest on
  suspend and then start it again on resume.
- Finally, there is `suspend_vmm`, which will stop both the guest and
  unload the `vmm(4)` kernel module on suspend and implement the
  reverse on resume.
- The recovery mechanism itself could be disabled by setting this
  value to be empty.

The `DEVD_FIX` variable controls the deployment of a fix for handling
the ACPI suspend event.  In older FreeBSD versions, suspend will not
automatically trigger a call for the `service wifibox suspend` command
so that has to be explicitly configured.  This has been added for
FreeBSD 14.0 hence it is not required any more from that version
onwards.  Set it to an empty value to disable this fix, otherwise the
default value is going to be determined based on the OS version where
the build is run.

## Documentation

There is a manual page installed that can be used to learn about the
basic usage and configuration.

```console
# man wifibox
```

## Compatibility

It has been reported working successfully on the following
configurations:

| CPU | Wireless NIC | Model | FreeBSD |
| :-- | :----------- | :---- | :------ |
| AMD A6-9225 | Realtek RTL8821CE | Lenovo IdeaPad 330-15AST | 13.1-RELEASE, 14-CURRENT |
| AMD Ryzen 3 5300U | Realtek RTL8852CE | HP HP Laptop 15s-eq2xxx | 14.1-RELEASE |
| AMD Ryzen 5 5600G | Intel Wi-Fi 6 AX-200 | ASUS ROG STRIX B550-I GAMING | 13-STABLE, 14-CURRENT |
| AMD Ryzen 5 5600G | AMD RZ608 Wi-Fi 6E (MediaTek MT7921K) | ASUS ROG STRIX B550-I GAMING | 13-STABLE, 14-CURRENT |
| AMD Ryzen 5 PRO 8540U | AMD RZ616 Wi-Fi 6E 802.11ax (MediaTek MT7922) | HP EliteBook 845 G11 (8R632AV) | GhostBSD 24.10.1 |
| AMD Ryzen 7 5700U | Realtek RTL8852AE | HP 255 G8 | 13.2-RELEASE |
| AMD Ryzen 7 5700X | Intel Wi-Fi 6 AX-200 | GigaByte X570S | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5700X | AMD RZ608 Wi-Fi 6E (MediaTek MT7921K) | GigaByte X570S | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5825U | Realtek RTL8852BE | HP Laptop 15s-eq3636nz | 13.2-RC3 |
| AMD Ryzen 9 9950X | Intel Wi-Fi 6E AX210 | Minisforum MS-A1-N0CPUR | 14.2-RELEASE |
| Intel Core i5-3210M | Broadcom BCM4331 | Apple MacBook Pro A1278 | 13.2-RELEASE |
| Intel Core i5-5300U | Intel Wireless 7265 | Lenovo ThinkPad T450 | 13.1-RELEASE |
| Intel Core i5-6300U | Intel Dual Band Wireless AC 8260 | Lenovo ThinkPad X270 | 13.5-RELEASE, 14.2-RELEASE, 15-CURRENT (snapshot `20250321-5d02f17e8253-276037`) |
| Intel Core i5-10210U | Intel Dual Band Wireless AC 9500 | System 76 Lemur Pro 'LEMP9' | 13.0-RELEASE |
| Intel Core i5-8250U | Realtek RTL8822BE | Lenovo YOGA 730 | 13.2-RELEASE |
| Intel Core i7-4600M | Intel Centrino Advanced-N 6235 | Dell Latitude E6440 | 13.0-RELEASE |
| Intel Core i7-4870HQ | Broadcom BCM43602 | Apple MacBook Pro 11.4 | 13.3-RELEASE |
| Intel Core i7-6600U | Intel(R) Dual Band Wireless AC 8260 | Lenovo ThinkPad T470 | 14.1-RELEASE |
| Intel Core i7-7500U | Intel(R) Dual Band Wireless AC 8265 | Lenovo ThinkPad X1 Carbon Gen5 | 13.2-RELEASE |
| Intel Core i7-7700K | Intel(R) Dual Band Wireless AC 3168 | Desktop HP 820 NL | 13.2-RELEASE |
| Intel Core i7-7820HQ | Intel(R) Wi-Fi 6E AX210/AX1675 | Dell Precision 7720 | 13.3-RELEASE, 14.1-RELEASE  |
| Intel Core i7-8565U | Qualcomm Atheros QCA6174 | Dell XPS 9380 | 13-STABLE |
| Intel Core i7-8650U | Intel(R) Dual Band Wireless AC 8265 | Lenovo ThinkPad T480 | 13.1-RELEASE |
| Intel Core i7-8665U | Intel(R) Dual Band Wireless AC 9560 | Lenovo ThinkPad X1 Carbon | GhostBSD 24.01.1 |
| Intel Core i7-10850H | Intel(R) Wi-Fi 6 AX201 | Dell Precision 7550 | 14.2-STABLE |
| Intel Core i7-1185G7 | Intel(R) Wi-Fi 6 AX201 | Lenovo ThinkPad X1 Carbon Gen9 | 14.2-RELEASE |

Feel free to submit a pull request or write an email to have your
configuration added here!

[`bhyve`]: https://wiki.freebsd.org/bhyve
[Message Signaled Interrupts]: https://www.kernel.org/doc/Documentation/PCI/MSI-HOWTO.txt
[`freebsd-wifibox-port`]: https://github.com/pgj/freebsd-wifibox-port
[`freebsd-wifibox-alpine`]: https://github.com/pgj/freebsd-wifibox-alpine
[`net/wpa_supplicant_gui`]: https://cgit.freebsd.org/ports/tree/net/wpa_supplicant_gui
[`grub2-bhyve`]: https://github.com/grehan-freebsd/grub2-bhyve
[`socat`]: http://www.dest-unreach.org/socat/
[article]: https://github.com/pgj/freebsd-wifibox/releases/download/freebsd-journal-2024-06/freebsd-journal-wifibox.pdf
