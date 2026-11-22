# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="https://www.gnu.org/software/sed/"
SRC_URI="https://gnuftp.mirror.garr.it/sed/sed-4.10.tar.xz -> sed-4.10.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl nls static"
BDEPEND="app-arch/xz-utils
	nls? ( sys-devel/gettext )
	
"
RDEPEND="!static? (
	  acl? ( virtual/acl )
	  nls? ( virtual/libintl )
	)
	
"
DEPEND="${RDEPEND}
	static? (
	  acl? ( virtual/acl[static-libs(+)] )
	  nls? ( virtual/libintl[static-libs(+)] )
	)
	
"
src_configure() {
	use static && append-ldflags -static

	local myconf=(
		# essential binary: install into /bin like the tree's --exec-prefix
		--bindir=/bin
		$(use_enable acl)
		$(use_enable nls)
	)
	econf "${myconf[@]}"
}


# vim: filetype=ebuild
