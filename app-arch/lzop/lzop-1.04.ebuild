# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Utility for fast (even real-time) compression/decompression"
HOMEPAGE="http://www.lzop.org/"
SRC_URI="http://www.lzop.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=dev-libs/lzo-2"
DEPEND="${RDEPEND}"

src_test() {
	einfo "compressing config.status to test"
	src/lzop config.status || die 'compression failed'
	ls -la config.status{,.lzo}
	src/lzop -t config.status.lzo || die 'lzo test failed'
	src/lzop -dc config.status.lzo | diff config.status - || die 'decompression generated differences from original'
}

src_install() {
	# do not install COPYING or redundant conversions of manpage
	emake DESTDIR="${D}" install \
		dist_doc_DATA="AUTHORS NEWS README THANKS"
}
