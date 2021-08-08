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

- A FreeBSD/amd64 system with the `virtio-9p` backend available for
  [bhyve].  FreeBSD 13.0 and later has this out of the box, but it
  could be made work on FreeBSD 12 as well (see below).

- [grub2-bhyve](https://github.com/grehan-freebsd/grub2-bhyve) or the
  corresponding `sysutils/grub2-bhyve` FreeBSD package.

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
# make install PREFIX=<prefix> IMGXZ=<disk image location>
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

## Documentation

There is a manual page installed that can be used to learn about the
basic usage and configuration.

```console
# man wifibox
```

## Compatibility

It has been reported working successfully on the following
configurations:

- Intel Core i5-6300U, Intel Wireless 8260 (Lenovo Thinkpad X270):
  FreeBSD/amd64 12.2-RELEASE + [virtio-9p patch](https://reviews.freebsd.org/D10335),
  FreeBSD/amd64 13.0-RELEASE

Feel free to submit a pull request or write an email to have your
configuration added here!

[bhyve]: https://wiki.freebsd.org/bhyve
[Alpine Linux]: https://alpinelinux.org/
