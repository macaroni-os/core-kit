# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="A high-speed compression/decompression library by Google"
HOMEPAGE="https://github.com/google/snappy"
SRC_URI="https://api.github.com/repos/google/snappy/tarball/refs/tags/1.3.1 -> snappy-1.3.1-9c28114.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
DOCS=(
	format_description.txt
	framing_format.txt
	NEWS
	README.md
)

post_src_unpack() {
	mv google-snappy-* ${S}
}


src_configure() {
	local mycmakeargs=(
	  -DBUILD_SHARED_LIBS=ON
	  # The test and benchmark frameworks live in the
	  # third_party/ git submodules, which are missing from
	  # the release source tarballs.
	  -DSNAPPY_BUILD_TESTS=OFF
	  -DSNAPPY_BUILD_BENCHMARKS=OFF
	  # Optional compression libs only used by tests and
	  # benchmarks, kept off as the tree ebuild did.
	  -DHAVE_LIBZ=NO
	  -DHAVE_LIBLZO2=NO
	  -DHAVE_LIBLZ4=NO
	)
	cmake_src_configure
}



# vim: filetype=ebuild
