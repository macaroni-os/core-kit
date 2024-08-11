# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit bash-completion-r1 python-single-r1

# Whenever you bump a GKPKG, check if you have to move
# or add new patches!
VERSION_BCACHE_TOOLS="1.0.8_p20141204"
VERSION_BOOST="1.79.0"
VERSION_BTRFS_PROGS="6.3.2"
VERSION_BUSYBOX="1.36.1"
VERSION_COREUTILS="9.4"
VERSION_CRYPTSETUP="2.6.1"
VERSION_DMRAID="1.0.0.rc16-3"
VERSION_DROPBEAR="2022.83"
VERSION_EUDEV="3.2.10"
VERSION_EXPAT="2.5.0"
VERSION_E2FSPROGS="1.46.4"
VERSION_FUSE="2.9.9"
VERSION_GPG="1.4.23"
VERSION_HWIDS="20210613"
VERSION_ISCSI="2.1.8"
VERSION_JSON_C="0.13.1"
VERSION_KMOD="30"
VERSION_LIBAIO="0.3.113"
VERSION_LIBGCRYPT="1.9.4"
VERSION_LIBGPGERROR="1.43"
VERSION_LIBXCRYPT="4.4.36"
VERSION_LVM="2.02.188"
VERSION_LZO="2.10"
VERSION_MDADM="4.1"
VERSION_POPT="1.19"
VERSION_STRACE="6.4"
VERSION_THIN_PROVISIONING_TOOLS="0.9.0"
VERSION_UNIONFS_FUSE="2.0"
VERSION_USERSPACE_RCU="0.14.0"
VERSION_UTIL_LINUX="2.38.1"
VERSION_XFSPROGS="6.3.0"
VERSION_XZ="5.4.3"
#VERSION_ZLIB="1.2.13"
VERSION_ZLIB="1.3.1"
VERSION_ZSTD="1.5.5"
VERSION_KEYUTILS="1.6.3"

SRC_URI="https://github.com/gentoo/genkernel/tarball/d6a77d90fd511b04b12bd7ae40d710d3d144c077 -> genkernel-4.3.10-d6a77d9.tar.gz
https://github.com/g2p/bcache-tools/archive/399021549984ad27bf4a13ae85e458833fe003d7.tar.gz -> bcache-tools-1.0.8_p20141204.tar.gz
https://boostorg.jfrog.io/artifactory/main/release/1.79.0/source/boost_1_79_0.tar.bz2 -> boost_1_79_0.tar.bz2
https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v6.3.2.tar.xz -> btrfs-progs-v6.3.2.tar.xz
https://www.busybox.net/downloads/busybox-1.36.1.tar.bz2 -> busybox-1.36.1.tar.bz2
https://ftpmirror.gnu.org/coreutils/coreutils-9.4.tar.xz -> coreutils-9.4.tar.xz
https://www.kernel.org/pub/linux/utils/cryptsetup/v2.6/cryptsetup-2.6.1.tar.xz -> cryptsetup-2.6.1.tar.xz
https://deb.debian.org/debian/pool/main/d/dmraid/dmraid_1.0.0.rc16.orig.tar.gz -> dmraid-1.0.0.rc16-3.tar.gz
https://matt.ucc.asn.au/dropbear/releases/dropbear-2022.83.tar.bz2 -> dropbear-2022.83.tar.bz2
https://dev.gentoo.org/~blueness/eudev/eudev-3.2.10.tar.gz -> eudev-3.2.10.tar.gz
https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.xz -> expat-2.5.0.tar.xz
https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.4/e2fsprogs-1.46.4.tar.xz -> e2fsprogs-1.46.4.tar.xz
https://github.com/libfuse/libfuse/releases/download/fuse-2.9.9/fuse-2.9.9.tar.gz -> fuse-2.9.9.tar.gz
https://gnupg.org/ftp/gcrypt/gnupg/gnupg-1.4.23.tar.bz2 -> gnupg-1.4.23.tar.bz2
https://github.com/gentoo/hwids/archive/hwids-20210613.tar.gz -> hwids-20210613.tar.gz
https://github.com/open-iscsi/open-iscsi/archive/2.1.8.tar.gz -> open-iscsi-2.1.8.tar.gz
https://s3.amazonaws.com/json-c_releases/releases/json-c-0.13.1.tar.gz -> json-c-0.13.1.tar.gz
https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-30.tar.xz -> kmod-30.tar.xz
https://releases.pagure.org/libaio/libaio-0.3.113.tar.gz -> libaio-0.3.113.tar.gz
https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.9.4.tar.bz2 -> libgcrypt-1.9.4.tar.bz2
https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.43.tar.bz2 -> libgpg-error-1.43.tar.bz2
https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz -> libxcrypt-4.4.36.tar.xz
https://mirrors.kernel.org/sourceware/lvm2/LVM2.2.02.188.tgz -> LVM2.2.02.188.tgz
https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz -> lzo-2.10.tar.gz
https://www.kernel.org/pub/linux/utils/raid/mdadm/mdadm-4.1.tar.xz -> mdadm-4.1.tar.xz
https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz -> popt-1.19.tar.gz
https://github.com/strace/strace/releases/download/v6.4/strace-6.4.tar.xz -> strace-6.4.tar.xz
https://github.com/jthornber/thin-provisioning-tools/archive/v0.9.0.tar.gz -> thin-provisioning-tools-0.9.0.tar.gz
https://github.com/rpodgorny/unionfs-fuse/archive/v2.0.tar.gz -> unionfs-fuse-2.0.tar.gz
https://lttng.org/files/urcu/userspace-rcu-0.14.0.tar.bz2 -> userspace-rcu-0.14.0.tar.bz2
https://www.kernel.org/pub/linux/utils/util-linux/v2.38/util-linux-2.38.1.tar.xz -> util-linux-2.38.1.tar.xz
https://www.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/xfsprogs-6.3.0.tar.xz -> xfsprogs-6.3.0.tar.xz
https://tukaani.org/xz/xz-5.4.3.tar.gz -> xz-5.4.3.tar.gz
https://zlib.net/zlib-1.3.1.tar.gz -> zlib-1.3.1.tar.gz
https://github.com/facebook/zstd/archive/v1.5.5.tar.gz -> zstd-1.5.5.tar.gz
https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/keyutils-1.6.3.tar.gz -> keyutils-1.6.3.tar.gz"
KEYWORDS="*"

DESCRIPTION="Gentoo's kernel and initrd generator"
HOMEPAGE="https://wiki.gentoo.org/wiki/Genkernel https://gitweb.gentoo.org/proj/genkernel.git/"

LICENSE="GPL-2"
SLOT="0"
RESTRICT=""
IUSE="ibm +firmware"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Note:
# We need sys-devel/* deps like autoconf or automake at _runtime_
# because genkernel will usually build things like LVM2, cryptsetup,
# mdadm... during initramfs generation which will require these
# things.
DEPEND=""
RDEPEND="${PYTHON_DEPS}
	app-arch/cpio
	>=app-misc/pax-utils-1.2.2
	app-portage/elt-patches
	app-portage/portage-utils
	dev-util/gperf
	sys-apps/sandbox
	sys-devel/autoconf
	sys-devel/autoconf-archive
	sys-devel/automake
	sys-devel/bc
	virtual/yacc
	sys-devel/flex
	sys-devel/libtool
	virtual/pkgconfig
	elibc_glibc? ( sys-libs/glibc[static-libs(+)] )
	firmware? ( sys-kernel/linux-firmware )"
BDEPEND="app-text/asciidoc"
PATCHES=(
	"${FILESDIR}"/"${PN}-4.3.10-fix-modinfo-error.patch"
)

S="${WORKDIR}"/gentoo-genkernel-d6a77d9

src_unpack() {
	local gk_src_file
	for gk_src_file in ${A} ; do
		if [[ ${gk_src_file} == genkernel-* ]] ; then
			unpack "${gk_src_file}"
		fi
	done
}

src_prepare() {
	default

	# Update software.sh
	sed -i \
		-e "s:VERSION_BCACHE_TOOLS:${VERSION_BCACHE_TOOLS}:"\
		-e "s:VERSION_BOOST:${VERSION_BOOST}:"\
		-e "s:VERSION_BTRFS_PROGS:${VERSION_BTRFS_PROGS}:"\
		-e "s:VERSION_BUSYBOX:${VERSION_BUSYBOX}:"\
		-e "s:VERSION_COREUTILS:${VERSION_COREUTILS}:"\
		-e "s:VERSION_CRYPTSETUP:${VERSION_CRYPTSETUP}:"\
		-e "s:VERSION_DMRAID:${VERSION_DMRAID}:"\
		-e "s:VERSION_DROPBEAR:${VERSION_DROPBEAR}:"\
		-e "s:VERSION_EUDEV:${VERSION_EUDEV}:"\
		-e "s:VERSION_EXPAT:${VERSION_EXPAT}:"\
		-e "s:VERSION_E2FSPROGS:${VERSION_E2FSPROGS}:"\
		-e "s:VERSION_FUSE:${VERSION_FUSE}:"\
		-e "s:VERSION_GPG:${VERSION_GPG}:"\
		-e "s:VERSION_HWIDS:${VERSION_HWIDS}:"\
		-e "s:VERSION_ISCSI:${VERSION_ISCSI}:"\
		-e "s:VERSION_JSON_C:${VERSION_JSON_C}:"\
		-e "s:VERSION_KMOD:${VERSION_KMOD}:"\
		-e "s:VERSION_LIBAIO:${VERSION_LIBAIO}:"\
		-e "s:VERSION_LIBGCRYPT:${VERSION_LIBGCRYPT}:"\
		-e "s:VERSION_LIBGPGERROR:${VERSION_LIBGPGERROR}:"\
		-e "s:VERSION_LIBXCRYPT:${VERSION_LIBXCRYPT}:"\
		-e "s:VERSION_LVM:${VERSION_LVM}:"\
		-e "s:VERSION_LZO:${VERSION_LZO}:"\
		-e "s:VERSION_MDADM:${VERSION_MDADM}:"\
		-e "s:VERSION_MULTIPATH_TOOLS:${VERSION_MULTIPATH_TOOLS}:"\
		-e "s:VERSION_POPT:${VERSION_POPT}:"\
		-e "s:VERSION_STRACE:${VERSION_STRACE}:"\
		-e "s:VERSION_THIN_PROVISIONING_TOOLS:${VERSION_THIN_PROVISIONING_TOOLS}:"\
		-e "s:VERSION_UNIONFS_FUSE:${VERSION_UNIONFS_FUSE}:"\
		-e "s:VERSION_USERSPACE_RCU:${VERSION_USERSPACE_RCU}:"\
		-e "s:VERSION_UTIL_LINUX:${VERSION_UTIL_LINUX}:"\
		-e "s:VERSION_XFSPROGS:${VERSION_XFSPROGS}:"\
		-e "s:VERSION_XZ:${VERSION_XZ}:"\
		-e "s:VERSION_ZLIB:${VERSION_ZLIB}:"\
		-e "s:VERSION_ZSTD:${VERSION_ZSTD}:"\
		"${S}"/defaults/software.sh \
		|| die "Could not adjust versions"
}

src_compile() {
	default
}

src_install() {
	insinto /etc
	doins "${S}"/genkernel.conf

	# in later versions, this file moves to build/
	doman genkernel.8
	dodoc AUTHORS README TODO
	dobin genkernel
	rm -f genkernel genkernel.8 AUTHORS ChangeLog README TODO genkernel.conf

	if use ibm ; then
		cp "${S}"/arch/ppc64/kernel-2.6{-pSeries,} || die
	else
		cp "${S}"/arch/ppc64/kernel-2.6{.g5,} || die
	fi

	insinto /usr/share/genkernel
	doins -r "${S}"/*

	fperms +x /usr/share/genkernel/gen_worker.sh
	fperms +x /usr/share/genkernel/path_expander.py

	python_fix_shebang "${ED}"/usr/share/genkernel/path_expander.py

	newbashcomp "${FILESDIR}"/genkernel-4.bash "${PN}"
	insinto /etc
	doins "${FILESDIR}"/initramfs.mounts

	pushd "${DISTDIR}" &>/dev/null || die
	insinto /usr/share/genkernel/distfiles
	doins ${A/${P}.tar.xz/}
	popd &>/dev/null || die
	
	# Bug: extract gz and recompress as bz2
	# Necessary because debian mirror serves gz, but genkernel expects bz2
	# Won't be necessary when FDO SSL works again
	pushd "${D}/usr/share/genkernel/distfiles" &>/dev/null || die
	zcat dmraid-${VERSION_DMRAID}.tar.gz | \
		bzip2 - -c > dmraid-${VERSION_DMRAID}.tar.bz2 && \
		rm dmraid-${VERSION_DMRAID}.tar.gz
	popd &>/dev/null || die
}

pkg_postinst() {
	# Wiki is out of date
	#echo
	#elog 'Documentation is available in the genkernel manual page'
	#elog 'as well as the following URL:'
	#echo
	#elog 'https://wiki.gentoo.org/wiki/Genkernel'
	#echo

	local replacing_version
	for replacing_version in ${REPLACING_VERSIONS} ; do
		if ver_test "${replacing_version}" -lt 4 ; then
			# This is an upgrade which requires user review

			ewarn ""
			ewarn "Genkernel v4.x is a new major release which touches"
			ewarn "nearly everything. Be careful, read updated manpage"
			ewarn "and pay special attention to program output regarding"
			ewarn "changed kernel command-line parameters!"

			# Show this elog only once
			break
		fi
	done

	if [[ $(find /boot -name 'kernel-genkernel-*' 2>/dev/null | wc -l) -gt 0 ]] ; then
		ewarn ''
		ewarn 'Default kernel filename was changed from "kernel-genkernel-<ARCH>-<KV>"'
		ewarn 'to "vmlinuz-<KV>". Please be aware that due to lexical ordering the'
		ewarn '*default* boot entry in your boot manager could still point to last kernel'
		ewarn 'built with genkernel before that name change, resulting in booting old'
		ewarn 'kernel when not paying attention on boot.'
	fi

	# Show special warning for users depending on remote unlock capabilities
	local gk_config="${EROOT}/etc/genkernel.conf"
	if [[ -f "${gk_config}" ]] ; then
		if grep -q -E "^SSH=[\"\']?yes" "${gk_config}" 2>/dev/null ; then
			if ! grep -q dosshd /proc/cmdline 2>/dev/null ; then
				ewarn ""
				ewarn "IMPORTANT: SSH is currently enabled in your genkernel config"
				ewarn "file (${gk_config}). However, 'dosshd' is missing from current"
				ewarn "kernel command-line. You MUST add 'dosshd' to keep sshd enabled"
				ewarn "in genkernel v4+ initramfs!"
			fi
		fi

		if grep -q -E "^CMD_CALLBACK=.*emerge.*@module-rebuild" "${gk_config}" 2>/dev/null ; then
			elog ""
			elog "Please remove 'emerge @module-rebuild' from genkernel config"
			elog "file (${gk_config}) and make use of new MODULEREBUILD option"
			elog "instead."
		fi
	fi

	local n_root_args=$(grep -o -- '\<root=' /proc/cmdline 2>/dev/null | wc -l)
	if [[ ${n_root_args} -gt 1 ]] ; then
		ewarn "WARNING: Multiple root arguments (root=) on kernel command-line detected!"
		ewarn "If you are appending non-persistent device names to kernel command-line,"
		ewarn "next reboot could fail in case running system and initramfs do not agree"
		ewarn "on detected root device name!"
	fi

	if [[ -d /run ]] ; then
		local permission_run_expected="drwxr-xr-x"
		local permission_run=$(stat -c "%A" /run)
		if [[ "${permission_run}" != "${permission_run_expected}" ]] ; then
			ewarn "Found the following problematic permissions:"
			ewarn ""
			ewarn "    ${permission_run} /run"
			ewarn ""
			ewarn "Expected:"
			ewarn ""
			ewarn "    ${permission_run_expected} /run"
			ewarn ""
			ewarn "This is known to be causing problems for any UDEV-enabled service."
		fi
	fi
}

# vim: noet ts=4 syn=ebuild