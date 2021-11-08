# Project FreeBSD Wifibox

Wifibox deploys a Linux guest to drive a wireless networking card on
the FreeBSD host system with the help of PCI pass-through.  There have
been guides on the Internet to suggest the use of such techniques to
improve the wireless networking experience on FreeBSD, of which
Wifibox tries to implement as a single easy-to-use software package.

- [bhyve], a lightweight virtualization solution for FreeBSD, is
  utilized to run [Alpine Linux], a security-oriented, lightweight
  Linux distribution based on musl libc and busybox.  This helps to
  achieve low resource footprint.

- Configuration files are shared with the host system.  The guest
  uses `wpa_supplicant(8)` so it is possible to import the host's
  `wpa_supplicant.conf(5)` file without any changes.

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

- A PCI wireless card that is known to be supported by the recent
  Linux versions, but it is not performing well enough under FreeBSD.

- A CPU that is supported by [bhyve] PCI pass-through (I/O MMU) with
  ~256 MB physical memory and ~700 MB disk space available.

- A supported FreeBSD/amd64 system: 11.4-RELEASE, 12.2-RELEASE, or
  13.0-RELEASE.  14-CURRENT might work.

- The [bhyve+] port which installs unofficial patches for `bhyve` to
  fill gaps present in the base system.  For FreeBSD 11 and 12, this
  is mandatory, but it may come handy on newer systems as well.

- [grub2-bhyve](https://github.com/grehan-freebsd/grub2-bhyve) or the
  corresponding `sysutils/grub2-bhyve` FreeBSD package, so the Linux
  guest could be booted via GRUB 2.

## Installation

Use the `net/wifibox` FreeBSD port which is available at the
[freebsd-wifibox-port](https://github.com/pgj/freebsd-wifibox-port)
repository and automatically takes care of all the following details
and offers proper removal of the installed files, hence it is a more
convenient way to manage the whole installation process.

### Manual Installation

Alternatively, a `Makefile` is present in this repository that can be
used to install all the files, as described below.  This workflow is
mostly recommended for development and testing.

```console
# make install \
    PREFIX=<prefix> \
    LOCALBASE=<prefix of the grub2-bhyve package> \
    IMGXZ=<disk image location> \
    BHYVE=<bhyve binary location> \
    BHYVECTL=<bhyvectl binary location> \
    VMM_KO=<vmm kernel module location>
```

By default, `PREFIX` is set to `/usr/local`.  In addition to that, it
is possible to set the `LOCALBASE` variable to tell if the prefix
under which the `grub-bhyve` utility was installed is different.

The `IMGXZ` variable should point to the virtual machine image to use,
which is `disk.img.xz` by default.  Note that this file is not part of
the repository because it is usually a large binary file.  That is why
it is released separately from the
[freebsd-wifibox-image](https://github.com/pgj/freebsd-wifibox-image)
repository, under the
[Releases](https://github.com/pgj/freebsd-wifibox-image/releases) tab.
Grab one of those files (ideally, the latest), and either place it in
working directory as `disk.img.xz` or set the value of `IMGXZ` to the
location of the downloaded file on the file system.

The `BHYVE`, `BHYVECTL`, and `VMM_KO` variables give the location of
the `bhyve`, `bhyvectl` binaries, and the `vmm.ko` kernel module
respectively.  By default, these are the ones in the base system
(i.e. `/usr/sbin/bhyve`) but they might be insufficient on older
systems, due to lack of support for VirtFS/9p file system passthrough
or missing fixes.  If [bhyve+] is installed, this is the way to hook
it up.

## Documentation

There is a manual page installed that can be used to learn about the
basic usage and configuration.

```console
# man wifibox
```

## Compatibility

It has been reported working successfully on the following
configurations:

- Intel Core i5-6300U, Intel Dual Band Wireless AC 8260 (Lenovo
  Thinkpad X270): 11.4-RELEASE, 12.2-RELEASE, 13.0-RELEASE, 14-CURRENT
  (snapshot `20210819-eba8e643b19-248803`).

- Intel Core i7-4600M, Intel Centrino Advanced-N 6235 (Dell Latitude
  E6440): 13.0-RELEASE.
  
- Intel Core i5-10210U, Intel Dual Band Wireless AC 9560 (System 76 
  Lemur Pro 'LEMP9'): 13.0-RELEASE

Feel free to submit a pull request or write an email to have your
configuration added here!

[bhyve]: https://wiki.freebsd.org/bhyve
[bhyve+]: https://github.com/pgj/freebsd-bhyve-plus-port/
[Alpine Linux]: https://alpinelinux.org/
