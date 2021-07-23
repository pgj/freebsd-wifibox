PREFIX?=/usr/local
LOCALBASE?=/usr/local
BINDIR=$(DESTDIR)$(PREFIX)/sbin
ETCDIR=$(DESTDIR)$(PREFIX)/etc
RCDIR=$(ETCDIR)/rc.d
SHAREDIR=$(DESTDIR)$(PREFIX)/share
MANDIR=$(DESTDIR)$(PREFIX)/man
RUNDIR=$(DESTDIR)/var/run/wifibox
LOGDIR=$(DESTDIR)/var/log/wifibox
IMGXZ?=disk.img.xz

SUB_LIST=	PREFIX=$(PREFIX) \
		LOCALBASE=$(LOCALBASE)
_SUB_LIST_EXP= 	${SUB_LIST:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/}

MKDIR=/bin/mkdir
SED=/usr/bin/sed
XZ=/usr/bin/xz
CP=/bin/cp
CHMOD=/bin/chmod
GZIP=/usr/bin/gzip

APPLIANCE_DIR=	$(RUNDIR)/appliance
APPLIANCE_DIRS=	$(APPLIANCE_DIR)/cache \
		$(APPLIANCE_DIR)/empty \
		$(APPLIANCE_DIR)/lib/apk \
		$(APPLIANCE_DIR)/lib/chrony \
		$(APPLIANCE_DIR)/lib/iptables \
		$(APPLIANCE_DIR)/lib/misc \
		$(APPLIANCE_DIR)/lib/udhcpd \
		$(APPLIANCE_DIR)/local \
		$(APPLIANCE_DIR)/log/chrony \
		$(APPLIANCE_DIR)/mail \
		$(APPLIANCE_DIR)/opt \
		$(APPLIANCE_DIR)/spool/cron \
		$(APPLIANCE_DIR)/tmp

install:
	$(MKDIR) -p $(BINDIR)
	$(SED) ${_SUB_LIST_EXP} sbin/wifibox > $(BINDIR)/wifibox
	$(CHMOD) 555 $(BINDIR)/wifibox

	$(MKDIR) -p $(SHAREDIR)/wifibox
	$(SED) ${_SUB_LIST_EXP} share/device.map > $(SHAREDIR)/wifibox/device.map
	$(CP) share/grub.cfg $(SHAREDIR)/wifibox
	$(XZ) -cd $(IMGXZ) > $(SHAREDIR)/wifibox/disk.img

	$(MKDIR) -p $(ETCDIR)/wifibox
	$(CP) etc/* $(ETCDIR)/wifibox/
	$(SED) ${_SUB_LIST_EXP} devd/wifibox.conf.sample > $(ETCDIR)/devd/wifibox.conf.sample

	$(MKDIR) -p $(RCDIR)
	$(SED) ${_SUB_LIST_EXP} rc.d/wifibox > $(RCDIR)/wifibox
	$(CHMOD) 555 $(RCDIR)/wifibox

	$(SED) ${_SUB_LIST_EXP} man/wifibox.8 | $(GZIP) -c > $(MANDIR)/man8/wifibox.8.gz

	$(MKDIR) -p $(LOGDIR)
	$(MKDIR) -p $(RUNDIR)
	$(MKDIR) -p $(APPLIANCE_DIRS)

.MAIN: clean

clean: ;
