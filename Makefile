PREFIX?=/usr/local
LOCALBASE?=/usr/local
GUEST_ROOT?=$(LOCALBASE)/share/wifibox
RECOVERY_METHOD?=restart_vmm

BINDIR=$(DESTDIR)$(PREFIX)/sbin
ETCDIR=$(DESTDIR)$(PREFIX)/etc
RCDIR=$(ETCDIR)/rc.d
SHAREDIR=$(DESTDIR)$(PREFIX)/share
MANDIR=$(DESTDIR)$(PREFIX)/man

MKDIR=/bin/mkdir
LN=/bin/ln
SED=/usr/bin/sed
CP=/bin/cp
CHMOD=/bin/chmod
GZIP=/usr/bin/gzip
GIT=$(LOCALBASE)/bin/git

.if !defined(VERSION)
VERSION!=	$(GIT) describe --tags --always
.endif

.if !defined(BHYVE)
BHYVE=		/usr/sbin/bhyve
.endif

.if !defined(BHYVECTL)
BHYVECTL=	/usr/sbin/bhyvectl
.endif

.if !defined(VMM_KO)
VMM_KO=		vmm.ko
.endif

.if defined(GUEST_MAN)
_GUEST_MAN=	${GUEST_MAN}
.else
_GUEST_MAN=	../man8/wifibox.8.gz
.endif

SUB_LIST=	PREFIX=$(PREFIX) \
		LOCALBASE=$(LOCALBASE) \
		VERSION=$(VERSION) \
		BHYVE=$(BHYVE) \
		BHYVECTL=$(BHYVECTL) \
		VMM_KO=$(VMM_KO) \
		GUEST_ROOT=$(GUEST_ROOT)

.if ${RECOVERY_METHOD} == restart_vmm
SUB_LIST+=	SUSPEND_CMD=/usr/bin/true \
		RESUME_CMD='$${command} restart vmm'
.elif ${RECOVERY_METHOD} == suspend_guest
SUB_LIST+=	SUSPEND_CMD='$${command} stop guest' \
		RESUME_CMD='$${command} start guest'
.else
SUB_LIST+=	SUSPEND_CMD=/usr/bin/true \
		RESUME_CMD=/usr/bin/true
.endif

_SUB_LIST_EXP= 	${SUB_LIST:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/}

install:
	$(MKDIR) -p $(BINDIR)
	$(SED) ${_SUB_LIST_EXP} sbin/wifibox > $(BINDIR)/wifibox
	$(CHMOD) 555 $(BINDIR)/wifibox

	$(MKDIR) -p $(ETCDIR)/wifibox
	$(CP) -R etc/* $(ETCDIR)/wifibox/
	$(MKDIR) -p $(ETCDIR)/devd
	$(SED) ${_SUB_LIST_EXP} devd/wifibox.conf.sample \
		> $(ETCDIR)/devd/wifibox.conf.sample

	$(MKDIR) -p $(RCDIR)
	$(SED) ${_SUB_LIST_EXP} rc.d/wifibox > $(RCDIR)/wifibox
	$(CHMOD) 555 $(RCDIR)/wifibox

	$(SED) ${_SUB_LIST_EXP} man/wifibox.8 \
		| $(GZIP) -c > $(MANDIR)/man8/wifibox.8.gz
	$(LN) -s ${_GUEST_MAN} $(MANDIR)/man5/wifibox-guest.5.gz

.MAIN: clean

clean: ;
