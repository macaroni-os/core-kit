# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRC_URI="https://www.greenwoodsoftware.com/less/less-710.tar.gz -> less-710.tar.gz"
LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="pcre unicode"
RDEPEND=">=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2:0=
	pcre? ( dev-libs/libpcre2 )
	sys-apps/groff
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(usex unicode)
	export ac_cv_lib_ncurses_initscr=$(usex !unicode)
	local myeconfargs=(
		--with-regex=$(usex pcre pcre2 posix)
		--with-editor=/usr/libexec/editor
	)
	econf "${myeconfargs[@]}"
}
src_install() {
	default
	newbin "${FILESDIR}"/lesspipe-r1.sh lesspipe
	newenvd "${FILESDIR}"/less.envd 70less
}


# vim: filetype=ebuild
