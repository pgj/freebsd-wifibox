PREFIX?=/usr/local
LOCALBASE?=/usr/local
GUEST_ROOT?=$(LOCALBASE)/share/wifibox
RECOVERY_METHOD?=restart_vmm

BINDIR=$(DESTDIR)$(PREFIX)/sbin
ETCDIR=$(DESTDIR)$(PREFIX)/etc
RCDIR=$(ETCDIR)/rc.d
SHAREDIR=$(DESTDIR)$(PREFIX)/share
MANDIR=$(SHAREDIR)/man

MKDIR=/bin/mkdir
LN=/bin/ln
SED=/usr/bin/sed
CP=/bin/cp
CHMOD=/bin/chmod
GZIP=/usr/bin/gzip
GIT=$(LOCALBASE)/bin/git
SHELLCHECK=$(LOCALBASE)/bin/shellcheck
UNAME=/usr/bin/uname
IGOR=${LOCALBASE}/bin/igor
ASPELL=${LOCALBASE}/bin/aspell
MANDOC=/usr/bin/mandoc
ECHO=/bin/echo
TOUCH=/usr/bin/touch
RM=/bin/rm -f

.if !defined(VERSION)
VERSION!=	$(GIT) describe --tags --always
.endif

.if defined(GUEST_MAN)
_GUEST_MAN=	${GUEST_MAN}
.else
_GUEST_MAN=	../man8/wifibox.8.gz
.endif

.if !defined(DEVD_FIX)
_FREEBSD_VERSION!=	$(UNAME) -U

.if $(_FREEBSD_VERSION) > 1400089
DEVD_FIX=	#
.else
DEVD_FIX=	please
.endif

.endif

SUB_LIST=	PREFIX=$(PREFIX) \
		LOCALBASE=$(LOCALBASE) \
		VERSION=$(VERSION) \
		GUEST_ROOT=$(GUEST_ROOT)

.if ${RECOVERY_METHOD} == restart_vmm
SUB_LIST+=	SUSPEND_CMD=/usr/bin/true \
		RESUME_CMD='$${command} restart vmm'
.elif ${RECOVERY_METHOD} == suspend_guest
SUB_LIST+=	SUSPEND_CMD='$${command} stop guest' \
		RESUME_CMD='$${command} start guest'
.elif ${RECOVERY_METHOD} == suspend_vmm
SUB_LIST+=	SUSPEND_CMD='$${command} stop vmm' \
		RESUME_CMD='$${command} start vmm'
.else
SUB_LIST+=	SUSPEND_CMD=/usr/bin/true \
		RESUME_CMD=/usr/bin/true
.endif

_SUB_LIST_EXP= 	${SUB_LIST:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/}
_SCRIPT_SRC=	sbin/wifibox
_MAN_SRC=	man/wifibox.8

install:
	$(MKDIR) -p $(BINDIR)
	$(SED) ${_SUB_LIST_EXP} ${_SCRIPT_SRC} > $(BINDIR)/wifibox
	$(CHMOD) 555 $(BINDIR)/wifibox

	$(MKDIR) -p $(ETCDIR)/wifibox
	$(CP) -R etc/* $(ETCDIR)/wifibox/

.if defined(DEVD_FIX)
	$(MKDIR) -p $(ETCDIR)/devd
	$(SED) ${_SUB_LIST_EXP} devd/wifibox.conf.sample \
		> $(ETCDIR)/devd/wifibox.conf.sample
.endif

	$(MKDIR) -p $(RCDIR)
	$(SED) ${_SUB_LIST_EXP} rc.d/wifibox > $(RCDIR)/wifibox
	$(CHMOD) 555 $(RCDIR)/wifibox

	$(SED) ${_SUB_LIST_EXP} ${_MAN_SRC} \
		| $(GZIP) -c > $(MANDIR)/man8/wifibox.8.gz
	$(LN) -s ${_GUEST_MAN} $(MANDIR)/man5/wifibox-guest.5.gz

.MAIN: clean

clean: ;

shellcheck:
	@$(SHELLCHECK) -x ${_SCRIPT_SRC}

mancheck:
	@${ECHO} mandoc -T lint
	# Create a dummy manual page to suppress the `mandoc` warning
	@${TOUCH} wifibox-guest.5
	@$(SED) ${_SUB_LIST_EXP} ${_MAN_SRC} | ${MANDOC} -T lint
	@${RM} wifibox-guest.5
	@${ECHO} igor
	@$(SED) ${_SUB_LIST_EXP} ${_MAN_SRC} | ${IGOR}
