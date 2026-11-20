# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit eutils toolchain-funcs

DESCRIPTION="Package maintenance system for Debian"
HOMEPAGE="https://packages.qa.debian.org/dpkg"
SRC_URI="http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_1.21.23.tar.xz -> dpkg_1.21.23.tar.xz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
DOCS=(
	ChangeLog
	THANKS
	TODO
)
IUSE="+bzip2 +lzma nls selinux static-libs unicode +update-alternatives +zstd +zlib"
RDEPEND="dev-lang/perl:=
	app-crypt/libmd
	bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/xz-utils )
	nls? ( virtual/libintl )
	selinux? ( sys-libs/libselinux )
	zstd? ( app-arch/zstd )
	zlib? ( >=sys-libs/zlib-1.1.4 )
	
"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig
	nls? (
	  app-text/po4a
	  >=sys-devel/gettext-0.18.2
	)
	
"
src_prepare() {
	use nls && strip-linguas -i po

	default
}

src_configure() {
	tc-export CC
	econf \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		$(use_enable unicode) \
		$(use_enable update-alternatives) \
		$(use_with bzip2 libbz2) \
		$(use_with lzma liblzma) \
		$(use_with selinux libselinux) \
		$(use_with zstd libzstd) \
		$(use_with zlib libz) \
		--disable-compiler-warnings \
		--disable-compiler-optimizations \
		--disable-linker-optimizations \
		--disable-dselect \
		--disable-silent-rules \
		--disable-start-stop-daemon \
		--localstatedir=/var
}

src_compile() {
	emake AR=$(tc-getAR)
}

src_install() {
	default

	keepdir \
		/usr/$(get_libdir)/db/methods/{mnt,floppy,disk} \
		/var/lib/dpkg/{alternatives,info,parts,updates}

	find "${D}" -name '*.la' -type f -delete || die
}


# vim: filetype=ebuild
