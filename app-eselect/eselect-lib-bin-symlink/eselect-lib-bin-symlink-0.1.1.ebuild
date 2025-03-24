# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools-utils

DESCRIPTION="An eselect library to manage executable symlinks"
HOMEPAGE="https://github.com/projg2/eselect-lib-bin-symlink/"
SRC_URI="https://github.com/projg2/eselect-lib-bin-symlink/tarball/08b219126c59351c2b347a55d37290f488f6d4a4 -> eselect-lib-bin-symlink-0.1.1-08b2191.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}/projg2-eselect-lib-bin-symlink-08b2191"

RDEPEND="app-admin/eselect"

src_prepare() {
	eautoreconf
}