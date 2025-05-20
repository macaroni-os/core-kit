# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="An eselect module to manage /etc/fonts/conf.d symlinks"
HOMEPAGE="https://www.gentoo.org"
SRC_URI="https://distfiles-flat.macaronios.org/distfiles/fontconfig.eselect-1.1.bz2 -> fontconfig.eselect-1.1.bz2"
LICENSE="GPL-2"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3
		 >=media-libs/fontconfig-2.4"

S=${WORKDIR}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${S}"/fontconfig.eselect-${PV} fontconfig.eselect
}