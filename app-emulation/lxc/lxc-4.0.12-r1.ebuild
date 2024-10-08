# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 linux-info flag-o-matic optfeature pam readme.gentoo-r1

DESCRIPTION="A userspace interface for the Linux kernel containment features"
HOMEPAGE="https://linuxcontainers.org/ https://github.com/lxc/lxc"
SRC_URI="https://linuxcontainers.org/downloads/lxc/${P}.tar.gz"
SRC_URI="https://github.com/lxc/lxc/tarball/7e37cc96bb94175a8e351025d26cc35dc2d10543 -> lxc-4.0.12-7e37cc9.tar.gz"

KEYWORDS="*"

LICENSE="GPL-2 LGPL-2.1 LGPL-3"
SLOT="0"
IUSE="apparmor +caps doc io-uring man pam seccomp selinux +ssl +tools"
RDEPEND="
	app-misc/pax-utils
	sys-apps/util-linux
	sys-libs/libcap
	virtual/awk
	caps? ( sys-libs/libcap )
	apparmor? ( sys-libs/libapparmor )
	io-uring? ( >=sys-libs/liburing-2:= )
	pam? ( sys-libs/pam )
	seccomp? ( sys-libs/libseccomp )
	selinux? ( sys-libs/libselinux )
	ssl? ( dev-libs/openssl:0= )
	"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	apparmor? ( sys-apps/apparmor )"
BDEPEND="virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
	man? ( app-text/docbook-sgml-utils )
"

CONFIG_CHECK="~!NETPRIO_CGROUP
	~CGROUPS
	~CGROUP_CPUACCT
	~CGROUP_DEVICE
	~CGROUP_FREEZER

	~CGROUP_SCHED
	~CPUSETS
	~IPC_NS
	~MACVLAN

	~MEMCG
	~NAMESPACES
	~NET_NS
	~PID_NS

	~POSIX_MQUEUE
	~USER_NS
	~UTS_NS
	~VETH"

ERROR_CGROUP_FREEZER="CONFIG_CGROUP_FREEZER: needed to freeze containers"
ERROR_MACVLAN="CONFIG_MACVLAN: needed for internal (inter-container) networking"
ERROR_MEMCG="CONFIG_MEMCG: needed for memory resource control in containers"
ERROR_NET_NS="CONFIG_NET_NS: needed for unshared network"
ERROR_POSIX_MQUEUE="CONFIG_POSIX_MQUEUE: needed for lxc-execute command"
ERROR_UTS_NS="CONFIG_UTS_NS: needed to unshare hostnames and uname info"
ERROR_VETH="CONFIG_VETH: needed for internal (host-to-container) networking"

DOCS=( AUTHORS CONTRIBUTING MAINTAINERS NEWS README doc/FAQ.txt )

pkg_setup() {
	linux-info_pkg_setup
}

PATCHES=(
	"${FILESDIR}"/${PV}/${PN}-2.0.5-omit-sysconfig.patch # bug 558854
	"${FILESDIR}"/${PV}/${PN}-4.0.12-cgroups.patch #FL-10036
)

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/lxc-* "${S}"
}

src_prepare() {
	default

	export bashcompdir="/etc/bash_completion.d"
	eautoreconf
}

src_configure() {
	append-flags -fno-strict-aliasing

	local myeconfargs=(
		--bindir=/usr/bin
		--localstatedir=/var
		--sbindir=/usr/bin

		--with-config-path=/var/lib/lxc
		--with-distro=gentoo
		--with-rootfs-path=/var/lib/lxc/rootfs
		--with-runtime-path=/run

		--disable-coverity-build
		--disable-dlog
		--disable-fuzzers
		--disable-mutex-debugging
		--disable-no-undefined
		--disable-rpath
		--disable-sanitizers
		--disable-tests
		--disable-werror

		--enable-bash
		--enable-commands
		--enable-memfd-rexec
		--enable-thread-safety

		$(use_enable apparmor)
		$(use_enable caps capabilities)
		$(use_enable doc api-docs)
		$(use_enable doc examples)
		$(use_enable io-uring liburing)
		$(use_enable man doc)
		$(use_enable pam)
		$(use_enable seccomp)
		$(use_enable selinux)
		$(use_enable ssl openssl)
		$(use_enable tools)

		$(use_with pam pamdir $(getpam_mod_dir))
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# The main bash-completion file will collide with lxd, need to relocate and update symlinks.
	mkdir -p "${ED}"/$(get_bashcompdir) || die "Failed to create bashcompdir."
	mv "${ED}"/etc/bash_completion.d/lxc "${ED}"/$(get_bashcompdir)/lxc-start || die "Failed to relocate lxc bash-completion file."
	rm -r "${ED}"/etc/bash_completion.d || die "Failed to remove wrong bash_completion.d content."

	if use tools; then
		bashcomp_alias lxc-start lxc-{attach,autostart,cgroup,checkpoint,config,console,copy,create,destroy,device,execute,freeze,info,ls,monitor,snapshot,stop,top,unfreeze,unshare,update-config,usernsexec,wait}
	else
		bashcomp_alias lxc-start lxc-usernsexec
	fi

	keepdir /etc/lxc /var/lib/lxc/rootfs /var/log/lxc
	rmdir "${D}"/var/cache/lxc "${D}"/var/cache || die "rmdir failed"

	find "${D}" -name '*.la' -delete -o -name '*.a' -delete || die

	# Gentoo-specific additions!
	newinitd "${FILESDIR}/${PN}.initd" ${PN}

	DOC_CONTENTS="
		For openrc, there is an init script provided with the package.
		You should only need to symlink /etc/init.d/lxc to
		/etc/init.d/lxc.configname to start the container defined in
		/etc/lxc/configname.conf.

		Correspondingly, for systemd a service file lxc@.service is installed.
		Enable and start lxc@configname in order to start the container defined
		in /etc/lxc/configname.conf."
	DISABLE_AUTOFORMATTING=true
	readme.gentoo_create_doc
}

pkg_postinst() {
	elog
	elog "Run 'lxc-checkconfig' to see optional kernel features."
	elog

	optfeature "automatic template scripts" app-containers/lxc-templates
	optfeature "Debian-based distribution container image support" dev-util/debootstrap
	optfeature "snapshot & restore functionality" sys-process/criu
}