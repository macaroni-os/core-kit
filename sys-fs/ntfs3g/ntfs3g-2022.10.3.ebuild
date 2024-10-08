# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools toolchain-funcs

DESCRIPTION="Open source read-write NTFS driver that runs under FUSE"
HOMEPAGE="https://github.com/tuxera/ntfs-3g"
SRC_URI="https://github.com/tuxera/ntfs-3g/tarball/78414d93613532fd82f3a82aba5d4a1c32898781 -> ntfs-3g-2022.10.3-78414d9.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="acl debug +fuse +mount-ntfs ntfsdecrypt +ntfsprogs static-libs suid xattr"

RDEPEND="
	sys-apps/util-linux:0=
	ntfsdecrypt? (
		>=dev-libs/libgcrypt-1.2.2:0
		>=net-libs/gnutls-1.4.4
	)
"
DEPEND="${RDEPEND}
	sys-apps/attr
"
BDEPEND="
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-2022.5.17-configure-bashism.patch
)

src_unpack() {
	default
	mv ${WORKDIR}/tuxera-ntfs-3g-* ${S}
}

src_prepare() {
	default

	# Only needed for bashism patch
	eautoreconf
}

src_configure() {
	tc-ld-disable-gold

	local myconf=(
		# passing --exec-prefix is needed as the build system is trying to be clever
		# and install itself into / instead of /usr in order to be compatible with
		# separate-/usr setups (which we don't support without an initrd).
		--exec-prefix="${EPREFIX}"/usr

		--disable-ldconfig
		--enable-extras
		$(use_enable debug)
		$(use_enable fuse ntfs-3g)
		$(use_enable acl posix-acls)
		$(use_enable xattr xattr-mappings)
		$(use_enable ntfsdecrypt crypto)
		$(use_enable ntfsprogs)
		$(use_enable static-libs static)

		--with-uuid

		# disable hd library until we have the right library in the tree and
		# don't links to hwinfo one causing issues like bug #602360
		--without-hd

		# Needed for suid
		# https://bugs.gentoo.org/822024
		--with-fuse=internal
	)

	econf "${myconf[@]}"
}

src_install() {
	default
	if use fuse; then
		# Plugins directory
		keepdir "/usr/$(get_libdir)/ntfs-3g"
		if use suid; then
			fperms u+s /usr/bin/ntfs-3g
		fi
		if use mount-ntfs; then
			dosym mount.ntfs-3g /sbin/mount.ntfs
		fi
	fi
	find "${ED}" -name '*.la' -type f -delete || die
}