# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="GNU macro processor"
HOMEPAGE="https://www.gnu.org/software/m4/m4.html"
SRC_URI="https://gnuftp.mirror.garr.it/m4/m4-1.4.21.tar.xz -> m4-1.4.21.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="examples nls"
BDEPEND="app-arch/xz-utils
	nls? ( sys-devel/gettext )
	
"
RDEPEND="virtual/libiconv
	nls? (
	  sys-devel/gettext
	  virtual/libintl
	)
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local -a myeconfargs=(
		--enable-changeword

		--with-packager="MacaroniOS"
		--with-packager-version="1.4.21"
		--with-packager-bug-reports="https://github.com/macaroni-os/mark-issues/issues"

		$(usex nls '' '--disable-nls')

		# Disable automagic dependency over libsigsegv
		ac_cv_libsigsegv=no
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	if use examples ; then
		dodoc -r examples
		rm -f "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
}


# vim: filetype=ebuild
