# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="Brotli compression format"
HOMEPAGE="https://github.com/google/brotli"
SRC_URI="https://api.github.com/repos/google/brotli/tarball/v1.2.0 -> brotli-1.2.0-028fb5a.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="python"
PDEPEND="python? ( dev-python/brotlipy )
	
"

post_src_unpack() {
	mv google-brotli-* ${S}
}


src_configure() {
	local mycmakeargs=(
	  -DBUILD_TESTING=false
	)
	cmake_src_configure
}



# vim: filetype=ebuild
