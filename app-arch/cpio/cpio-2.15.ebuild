# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="https://www.gnu.org/software/cpio/cpio.html"
SRC_URI="https://gnuftp.mirror.garr.it/cpio/cpio-2.15.tar.bz2 -> cpio-2.15.tar.bz2"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/cpio-2.12-non-gnu-compilers.patch"
)
IUSE="nls"
src_configure() {
	local myeconfargs=(
		$(use_enable nls)
		--bindir=/bin
		--with-rmt=/usr/sbin/rmt
	)
	econf "${myeconfargs[@]}"
}


# vim: filetype=ebuild
