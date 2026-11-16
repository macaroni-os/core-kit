# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Extremely Fast Compression algorithm"
HOMEPAGE="https://github.com/lz4/lz4"
SRC_URI="https://api.github.com/repos/lz4/lz4/tarball/refs/tags/v1.11.1 -> lz4-1.11.1-aa4647f.tar.gz"
LICENSE="BSD-2 GPL-2"
SLOT="0/1"
KEYWORDS="*"
IUSE="static-libs"

post_src_unpack() {
	mv lz4-lz4-* ${S}
}


CMAKE_USE_DIR="${S}/build/cmake"

src_configure() {
	local mycmakeargs=(
	  -DBUILD_STATIC_LIBS=$(usex static-libs)
	)
	cmake_src_configure
}



# vim: filetype=ebuild
