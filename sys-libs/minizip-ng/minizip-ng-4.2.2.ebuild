# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Fork of the popular zip manipulation library found in the zlib distribution."
HOMEPAGE="https://github.com/zlib-ng/minizip-ng"
SRC_URI="https://api.github.com/repos/zlib-ng/minizip-ng/tarball/4.2.2 -> minizip-ng-4.2.2-7b23871.tar.gz"
LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"
IUSE="compat openssl zstd"
RDEPEND="app-arch/bzip2
	app-arch/xz-utils
	sys-libs/zlib-ng
	virtual/libiconv
	compat? ( !sys-libs/zlib[minizip] )
	openssl? ( dev-libs/openssl:= )
	zstd? ( app-arch/zstd:= )
"
DEPEND="${RDEPEND}
"
post_src_unpack() {
	mv ${WORKDIR}/zlib-ng-minizip-ng-* ${S} || die
}

src_configure() {
	local mycmakeargs=(
		-DMZ_COMPAT=$(usex compat)


		-DMZ_FETCH_LIBS=OFF
		-DMZ_FORCE_FETCH_LIBS=OFF

		# Compression library options
		-DMZ_ZLIB=ON
		-DMZ_BZIP2=ON
		-DMZ_LZMA=ON
		# The PPMD codec (4.2.0+) git-clones ip7z/7zip during configure:
		# that clone_repo() call is not gated by MZ_FETCH_LIBS, so it
		# cannot be satisfied under network-sandbox, and the 4.0.x line
		# this package was built from has no PPMD support at all. Keep the
		# codec off until its sources ship as a tracked distfile.
		-DMZ_PPMD=OFF
		-DMZ_ZSTD=$(usex zstd)
		-DMZ_LIBCOMP=OFF

		# Encryption support options
		-DMZ_PKCRYPT=ON
		-DMZ_WZAES=ON
		-DMZ_OPENSSL=$(usex openssl)
		# MZ_LIBBSD -- Builds with libbsd crypto random
		# Turning this option on breaks compilation on Funtoo next
		-DMZ_LIBBSD=OFF
		-DMZ_SIGNING=ON

		# Character conversion options
		-DMZ_ICONV=ON
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use compat ; then
		ewarn "minizip-ng is experimental and replacing the system zlib[minizip] is dangerous"
		ewarn "Please be careful!"
	fi
}


# vim: filetype=ebuild
