# Project FreeBSD Wifibox

Wifibox deploys a Linux guest to drive a wireless networking card on
the FreeBSD host system with the help of PCI pass-through.  There have
been guides on the Internet to suggest the use of such techniques to
improve the wireless networking experience on FreeBSD, of which
Wifibox tries to implement as a single easy-to-use software package.

- [`bhyve`], a lightweight virtualization solution for FreeBSD, is
  utilized to run the embedded Linux system.  This helps to achieve
  low resource footprint.

- Configuration files are shared with the host system.  For example,
  the guest may either use `wpa_supplicant(8)` or `hostapd(8)` and it
  is possible to import the host's `wpa_supplicant.conf(5)` and
  `hostapd.conf(5)` files without any changes.

- When configured by the guest, `wpa_supplicant(8)` or `hostapd(8)`
  control sockets could be exposed, which enables use of related
  utilities directly from the host, such as `wpa_cli(8)` or
  `wpa_gui(8)` from the [`net/wpa_supplicant_gui`] FreeBSD package, or
  `hostapd_cli(8)`.

- Everything is shipped in a single FreeBSD package that can be easily
  installed and removed.  It comes with an `rc(8)` system service that
  automatically launches the guest on boot and stops it on shutdown.

- A workaround is supplied for laptops to support suspend/resume.

## Warning

*This is a work-in-progress experimental software project without any
guarantees or warranties.  It is shared in the hope that is going to
be useful and inspiring for others.  By its nature, it is a workaround
and shall be deprecated once the FreeBSD wireless drivers and
networking stack are updated to catch up with Linux.*

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

- A supported FreeBSD/amd64 system: 12.4-RELEASE or 13.2-RELEASE.
  Later versions will also probably work, but your mileage may vary.

- The [`bhyve+`] port which installs unofficial patches for `bhyve` to
  fill gaps present in the base system.  For FreeBSD 12, this is
  mandatory, but it may come handy on newer systems as well.

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
    BHYVE=<bhyve binary location> \
    BHYVECTL=<bhyvectl binary location> \
    VMM_KO=<vmm kernel module location> \
    RECOVERY_METHOD=<method to use on suspend and resume>
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

The `BHYVE`, `BHYVECTL`, and `VMM_KO` variables give the location of
the `bhyve`, `bhyvectl` binaries, and the `vmm.ko` kernel module
respectively.  By default, these are the ones in the base system
(i.e. `/usr/sbin/bhyve`) but they might be insufficient on older
systems, due to lack of support for VirtFS/9P file system passthrough
or missing fixes.  If [`bhyve+`] is installed, this is the way to hook
it up.

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
| AMD Ryzen 5 5600G | Intel Wi-Fi 6 AX-200 | ASUS ROG STRIX B550-I GAMING | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5700U | Realtek RTL8852AE | HP 255 G8 | 13.2-RELEASE |
| AMD Ryzen 5 5600G | AMD RZ608 Wi-Fi 6E (MediaTek MT7921K) | ASUS ROG STRIX B550-I GAMING | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5700X | Intel Wi-Fi 6 AX-200 | GigaByte X570S | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5700X | AMD RZ608 Wi-Fi 6E (MediaTek MT7921K) | GigaByte X570S | 13-STABLE, 14-CURRENT |
| AMD Ryzen 7 5825U | Realtek RTL8852BE | HP Laptop 15s-eq3636nz | 13.2-RC3 |
| Intel Core i5-3210M | Broadcom BCM4331 | Apple MacBook Pro A1278 | 13.2-RELEASE |
| Intel Core i5-5300U | Intel Wireless 7265 | Lenovo Thinkpad T450 | 13.1-RELEASE |
| Intel Core i5-6300U | Intel Dual Band Wireless AC 8260 | Lenovo Thinkpad X270 | 12.4-RELEASE, 13.2-RELEASE, 14.0-BETA3, 15-CURRENT (snapshot `20230907-03a7c36ddbc0-265205`) |
| Intel Core i5-10210U | Intel Dual Band Wireless AC 9500 | System 76 Lemur Pro 'LEMP9' | 13.0-RELEASE |
| Intel Core i7-4600M | Intel Centrino Advanced-N 6235 | Dell Latitude E6440 | 13.0-RELEASE |
| Intel Core i7-8565U | Qualcomm Atheros QCA6174 | Dell XPS 9380 | 13-STABLE |
| Intel Core i7-8650U | Intel(R) Dual Band Wireless AC 8265 | Lenovo Thinkpad T480 | 13.1-RELEASE |

Feel free to submit a pull request or write an email to have your
configuration added here!

[`bhyve`]: https://wiki.freebsd.org/bhyve
[Message Signaled Interrupts]: https://www.kernel.org/doc/Documentation/PCI/MSI-HOWTO.txt
[`bhyve+`]: https://github.com/pgj/freebsd-bhyve-plus-port/
[`freebsd-wifibox-port`]: https://github.com/pgj/freebsd-wifibox-port
[`freebsd-wifibox-alpine`]: https://github.com/pgj/freebsd-wifibox-alpine
[`net/wpa_supplicant_gui`]: https://cgit.freebsd.org/ports/tree/net/wpa_supplicant_gui
[`grub2-bhyve`]: https://github.com/grehan-freebsd/grub2-bhyve
[`socat`]: http://www.dest-unreach.org/socat/
