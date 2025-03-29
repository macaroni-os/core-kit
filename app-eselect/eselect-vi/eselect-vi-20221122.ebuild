# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Manages the /usr/bin/vi symlink"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Vim"
SRC_URI="https://gitweb.gentoo.org/proj/eselect-vi.git/snapshot/eselect-vi-20221122.tar.gz -> eselect-vi-20221122.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.6"

src_install() {
	insinto /usr/share/eselect/modules
	doins vi.eselect || die
}