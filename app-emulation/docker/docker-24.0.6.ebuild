# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN=github.com/docker/docker
inherit bash-completion-r1 golang-base golang-vcs-snapshot linux-info systemd udev user

DESCRIPTION="The core functions you need to create Docker images and run Docker containers"
HOMEPAGE="https://www.docker.com/ https://github.com/moby/moby"
SRC_URI="https://github.com/moby/moby/tarball/a65e6533672c086ed1fe0f5120c7adecb4a2becf -> moby-24.0.6-a65e653.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="apparmor btrfs +container-init device-mapper overlay seccomp"

DEPEND="
	>=dev-db/sqlite-3.7.9:3
	apparmor? ( sys-libs/libapparmor )
	btrfs? ( >=sys-fs/btrfs-progs-3.16.1 )
	device-mapper? ( >=sys-fs/lvm2-2.02.89[thin] )
	seccomp? ( >=sys-libs/libseccomp-2.2.1 )
"

# https://github.com/moby/moby/blob/master/project/PACKAGERS.md#runtime-dependencies
# https://github.com/moby/moby/blob/master/project/PACKAGERS.md#optional-dependencies
# https://github.com/moby/moby/tree/master//hack/dockerfile/install
RDEPEND="
	${DEPEND}
	>=net-firewall/iptables-1.4
	sys-process/procps
	>=dev-vcs/git-1.7
	>=app-arch/xz-utils-4.9
	dev-libs/libltdl
	>=app-emulation/containerd-1.7.1[apparmor?,btrfs?,device-mapper?,seccomp?]
	!app-emulation/docker-proxy
	container-init? ( >=sys-process/tini-0.19.0[static] )
"

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#build-dependencies
BDEPEND="
	>=dev-lang/go-1.19.12
	dev-go/go-md2man
	virtual/pkgconfig
"
# tests require running dockerd as root and downloading containers
RESTRICT="installsources strip test"

S="${WORKDIR}/${P}/src/${EGO_PN}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv moby-moby* "${S}" || die
	fi
}

pkg_setup() {
	# this is based on "contrib/check-config.sh" from upstream's sources
	# required features.
	CONFIG_CHECK="
		~NAMESPACES ~NET_NS ~PID_NS ~IPC_NS ~UTS_NS
		~CGROUPS ~CGROUP_CPUACCT ~CGROUP_DEVICE ~CGROUP_FREEZER ~CGROUP_SCHED ~CPUSETS ~MEMCG
		~KEYS
		~VETH ~BRIDGE ~BRIDGE_NETFILTER
		~IP_NF_FILTER ~IP_NF_TARGET_MASQUERADE
		~NETFILTER_XT_MATCH_ADDRTYPE
		~NETFILTER_XT_MATCH_CONNTRACK
		~NETFILTER_XT_MATCH_IPVS
		~NETFILTER_XT_MARK
		~IP_NF_NAT ~NF_NAT
		~POSIX_MQUEUE
	"
	WARNING_POSIX_MQUEUE="CONFIG_POSIX_MQUEUE: is required for bind-mounting /dev/mqueue into containers"

	if kernel_is lt 4 8; then
		CONFIG_CHECK+="
			~DEVPTS_MULTIPLE_INSTANCES
		"
	fi

	if kernel_is le 5 1; then
		CONFIG_CHECK+="
			~NF_NAT_IPV4
		"
	fi

	if kernel_is le 5 2; then
		CONFIG_CHECK+="
			~NF_NAT_NEEDED
		"
	fi

	if kernel_is ge 4 15; then
		CONFIG_CHECK+="
			~CGROUP_BPF
		"
	fi

	# optional features
	CONFIG_CHECK+="
		~USER_NS
	"

	if use seccomp; then
		CONFIG_CHECK+="
			~SECCOMP ~SECCOMP_FILTER
		"
	fi

	CONFIG_CHECK+="
		~CGROUP_PIDS
	"

	if kernel_is lt 6 1; then
		CONFIG_CHECK+="
			~MEMCG_SWAP
			"
	fi

	if kernel_is le 5 8; then
		CONFIG_CHECK+="
			~MEMCG_SWAP_ENABLED
		"
	fi

	CONFIG_CHECK+="
		~!LEGACY_VSYSCALL_NATIVE
		"
	if kernel_is lt 5 19; then
		CONFIG_CHECK+="
			~LEGACY_VSYSCALL_EMULATE
			"
	fi
	CONFIG_CHECK+="
		~!LEGACY_VSYSCALL_NONE
		"
	WARNING_LEGACY_VSYSCALL_NONE="CONFIG_LEGACY_VSYSCALL_NONE enabled: Containers with <=glibc-2.13 will not work"

	if kernel_is le 4 5; then
		CONFIG_CHECK+="
			~MEMCG_KMEM
		"
	fi

	if kernel_is lt 5; then
		CONFIG_CHECK+="
			~IOSCHED_CFQ ~CFQ_GROUP_IOSCHED
		"
	fi

	CONFIG_CHECK+="
		~BLK_CGROUP ~BLK_DEV_THROTTLING
		~CGROUP_PERF
		~CGROUP_HUGETLB
		~NET_CLS_CGROUP ~CGROUP_NET_PRIO
		~CFS_BANDWIDTH ~FAIR_GROUP_SCHED
		~IP_NF_TARGET_REDIRECT
		~IP_VS
		~IP_VS_NFCT
		~IP_VS_PROTO_TCP
		~IP_VS_PROTO_UDP
		~IP_VS_RR
		"

	if use apparmor; then
		CONFIG_CHECK+="
			~SECURITY_APPARMOR
			"
	fi

	CONFIG_CHECK+="
		~EXT4_FS ~EXT4_FS_POSIX_ACL ~EXT4_FS_SECURITY
	"

	# network drivers
	CONFIG_CHECK+="
		~VXLAN ~BRIDGE_VLAN_FILTERING
		~CRYPTO ~CRYPTO_AEAD ~CRYPTO_GCM ~CRYPTO_SEQIV ~CRYPTO_GHASH
		~XFRM ~XFRM_USER ~XFRM_ALGO ~INET_ESP
	"
	if kernel_is le 5 3; then
		CONFIG_CHECK+="
			~INET_XFRM_MODE_TRANSPORT
		"
	fi

	CONFIG_CHECK+="
		~IPVLAN
		"
	CONFIG_CHECK+="
		~MACVLAN ~DUMMY
		"
	CONFIG_CHECK+="
		~NF_NAT_FTP ~NF_CONNTRACK_FTP ~NF_NAT_TFTP ~NF_CONNTRACK_TFTP
	"

	# storage drivers
	if use btrfs; then
		CONFIG_CHECK+="
			~BTRFS_FS
			~BTRFS_FS_POSIX_ACL
		"
	fi

	if use device-mapper; then
		CONFIG_CHECK+="
			~BLK_DEV_DM ~DM_THIN_PROVISIONING
		"
	fi

	CONFIG_CHECK+="
		~OVERLAY_FS
	"

	linux-info_pkg_setup
	enewgroup docker
}

src_compile() {
	export DOCKER_GITCOMMIT="a65e653"
	export GOPATH="${WORKDIR}/${P}"
	export VERSION="24.0.6-funtoo"

	# setup CFLAGS and LDFLAGS for separate build target
	# see https://github.com/tianon/docker-overlay/pull/10
	export CGO_CFLAGS="-I${ESYSROOT}/usr/include"
	export CGO_LDFLAGS="-L${ESYSROOT}/usr/$(get_libdir)"

	# let's set up some optional features :)
	export DOCKER_BUILDTAGS=''
	for gd in btrfs device-mapper overlay; do
		if ! use $gd; then
			DOCKER_BUILDTAGS+=" exclude_graphdriver_${gd//-/}"
		fi
	done

	for tag in apparmor seccomp; do
		if use $tag; then
			DOCKER_BUILDTAGS+=" $tag"
		fi
	done

	# build binaries
	./hack/make.sh dynbinary || die 'dynbinary failed'
}

src_install() {
	dosym containerd /usr/bin/docker-containerd
	dosym containerd-shim /usr/bin/docker-containerd-shim
	dosym runc /usr/bin/docker-runc
	use container-init && dosym tini /usr/bin/docker-init
	dobin bundles/dynbinary-daemon/dockerd
	dobin bundles/dynbinary-daemon/docker-proxy

	newinitd ${REPODIR}/app-emulation/docker/files/${PN}.initd ${PN}
	newconfd ${REPODIR}/app-emulation/docker/files/${PN}.confd ${PN}

	systemd_dounit contrib/init/systemd/docker.{service,socket}

	udev_dorules contrib/udev/*.rules

	dodoc AUTHORS CONTRIBUTING.md NOTICE README.md
	dodoc -r docs/*

	# note: intentionally not using "doins" so that we preserve +x bits
	dodir /usr/share/${PN}/contrib
	cp -R contrib/* "${ED}/usr/share/${PN}/contrib"
}

pkg_postinst() {
	udev_reload

	elog
	elog "To use Docker, the Docker daemon must be running as root. To automatically"
	elog "start the Docker daemon at boot:"
	if systemd_is_booted || has_version sys-apps/systemd; then
		elog "  systemctl enable docker.service"
	else
		elog "  rc-update add docker default"
	fi
	elog
	elog "To use Docker as a non-root user, add yourself to the 'docker' group:"
	elog '  usermod -aG docker <youruser>'
	elog

	if use device-mapper; then
		elog " Devicemapper storage driver has been deprecated"
		elog " It will be removed in a future release"
		elog
	fi

	if use overlay; then
		elog " Overlay storage driver/USEflag has been deprecated"
		elog " in favor of overlay2 (enabled unconditionally)"
		elog
	fi

	if has_version sys-fs/zfs; then
		elog " ZFS storage driver is available"
		elog " Check https://docs.docker.com/storage/storagedriver/zfs-driver for more info"
		elog
	fi
}

pkg_postrm() {
	udev_reload
}