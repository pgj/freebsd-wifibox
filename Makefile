PREFIX?=/usr/local
LOCALBASE?=/usr/local
BINDIR=$(DESTDIR)$(PREFIX)/sbin
ETCDIR=$(DESTDIR)$(PREFIX)/etc
RCDIR=$(ETCDIR)/rc.d
SHAREDIR=$(DESTDIR)$(PREFIX)/share
RUNDIR=$(DESTDIR)/var/run/wifibox
LOGDIR=$(DESTDIR)/var/log/wifibox
IMGXZ?=disk.img.xz

MKDIR=/bin/mkdir
SED=/usr/bin/sed
XZ=/usr/bin/xz
CP=/bin/cp
CHMOD=/bin/chmod

install:
	$(MKDIR) -p $(BINDIR)
	$(SED) -e 's!%%PREFIX%%!$(PREFIX)!g' -e 's!%%LOCALBASE%%!$(LOCALBASE)!g' wifibox > $(BINDIR)/wifibox
	$(CHMOD) 555 $(BINDIR)/wifibox

	$(MKDIR) -p $(SHAREDIR)/wifibox
	$(SED) -e 's!%%PREFIX%%!$(PREFIX)!g' -e 's!%%LOCALBASE%%!$(LOCALBASE)!g' share/device.map > $(SHAREDIR)/wifibox/device.map
	$(CP) share/grub.cfg $(SHAREDIR)/wifibox
	$(XZ) -cd $(IMGXZ) > $(SHAREDIR)/wifibox/disk.img

	$(MKDIR) -p $(ETCDIR)/wifibox
	$(CP) etc/* $(ETCDIR)/wifibox/

	$(MKDIR) -p $(RCDIR)
	$(SED) -e 's!%%PREFIX%%!$(PREFIX)!g' -e 's!%%LOCALBASE%%!$(LOCALBASE)!g' rc.d/wifibox > $(RCDIR)/wifibox
	$(CHMOD) 555 $(RCDIR)/wifibox

	$(MKDIR) -p $(LOGDIR)
	$(MKDIR) -p $(RUNDIR)
	$(MKDIR) -p $(RUNDIR)/appliance

.MAIN: clean

clean: ;
