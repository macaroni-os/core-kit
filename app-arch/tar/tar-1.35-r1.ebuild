# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="https://www.gnu.org/software/tar/"
SRC_URI="https://gnuftp.mirror.garr.it/tar/tar-1.35.tar.xz -> tar-1.35.tar.xz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/tar-1.35-acl-2.4.0.patch"
)
IUSE="acl minimal nls selinux userland_GNU xattr"
BDEPEND="nls? ( sys-devel/gettext )
	
"
RDEPEND="acl? ( virtual/acl )
	selinux? ( sys-libs/libselinux )
	
"
DEPEND="${RDEPEND}
	sys-apps/attr
	
"
src_prepare() {
	default

	if ! use userland_GNU ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi
}
src_configure() {
	export gl_cv_warn_c__fanalyzer=no

	local myeconfargs=(
		--bindir=/bin
		--enable-backup-scripts
		--libexecdir=/usr/sbin
		$(usex userland_GNU "" "--program-prefix=g")
		$(use_with acl posix-acls)
		$(use_enable nls)
		$(use_with selinux)
		$(use_with xattr xattrs)
	)
	FORCE_UNSAFE_CONFIGURE=1 econf "${myeconfargs[@]}"
}
src_install() {
	default

	local p=$(usex userland_GNU "" "g")
	if [[ -z ${p} ]] ; then
		exeinto /etc
		doexe "${FILESDIR}"/rmt
	fi

	# autoconf looks for gtar before tar (in configure scripts), hence
	# in Prefix it is important that it is there, otherwise, a gtar from
	# the host system (FreeBSD, Solaris, Darwin) will be found instead
	# of the Prefix provided (GNU) tar
	if use prefix ; then
		dosym tar /bin/gtar
	fi

	mv "${ED}"/usr/sbin/${p}backup{,-tar} || die
	mv "${ED}"/usr/sbin/${p}restore{,-tar} || die

	if use minimal ; then
		find "${ED}"/etc "${ED}"/*bin/ "${ED}"/usr/*bin/ \
			-type f -a '!' '(' -name tar -o -name ${p}tar ')' \
			-delete || die
	fi
}


# vim: filetype=ebuild
