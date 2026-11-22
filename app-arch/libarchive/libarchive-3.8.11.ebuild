# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit libtool

DESCRIPTION="Multi-format archive and compression library"
HOMEPAGE="https://www.libarchive.org/"
SRC_URI="https://github.com/libarchive/libarchive/releases/download/v3.8.11/libarchive-3.8.11.tar.gz -> libarchive-3.8.11.tar.gz"
LICENSE="BSD BSD-2 BSD-4 public-domain"
SLOT="0/13"
KEYWORDS="*"
IUSE="acl blake2 +bzip2 +e2fsprogs expat +iconv +ssl lz4 +lzma lzo nettle static-libs +threads xattr +zlib zstd"
RDEPEND="acl? ( virtual/acl )
	blake2? ( app-crypt/libb2 )
	bzip2? ( app-arch/bzip2 )
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	iconv? ( virtual/libiconv )
	xattr? ( sys-apps/attr )
	ssl? ( dev-libs/openssl:= )
	lz4? ( >=app-arch/lz4-0_p131:0= )
	lzma? ( app-arch/xz-utils )
	lzo? ( >=dev-libs/lzo-2 )
	nettle? ( dev-libs/nettle:0= )
	zlib? ( sys-libs/zlib )
	zstd? ( app-arch/zstd )
	
"
DEPEND="${RDEPEND}
	virtual/os-headers
	e2fsprogs? ( sys-fs/e2fsprogs )
	
"
src_configure() {
	export ac_cv_header_ext2fs_ext2_fs_h=$(usex e2fsprogs)

	local myconf=(
		$(use_enable acl)
		$(use_enable static-libs static)
		$(use_enable xattr)
		$(use_with blake2 libb2)
		$(use_with bzip2 bz2lib)
		$(use_with expat)
		$(use_with !expat xml2)
		$(use_with iconv)
		$(use_with lz4)
		$(use_with lzma)
		$(use_with lzo lzo2)
		$(use_with nettle)
		$(use_with zlib)
		$(use_with zstd)
		$(use_with ssl openssl)
		--enable-bsdcat=$(tc-is-static-only && echo static || echo shared)
		--enable-bsdcpio=$(tc-is-static-only && echo static || echo shared)
		--enable-bsdtar=$(tc-is-static-only && echo static || echo shared)

		# Windows-specific
		--without-cng
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	# Libs.private: should be used from libarchive.pc instead
	find "${ED}" -type f -name "*.la" -delete || die
}


# vim: filetype=ebuild
