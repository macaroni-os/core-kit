# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="https://www.gnu.org/software/make/make.html"
SRC_URI="https://gnuftp.mirror.garr.it/make/make-4.4.1.tar.gz -> make-4.4.1.tar.gz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="guile nls static"
# Commons depends
CDEPEND="guile? ( >=dev-scheme/guile-1.8:= )
	
"
RDEPEND="${CDEPEND}
	nls? ( virtual/libintl )
	
"
DEPEND="${CDEPEND}
	nls? ( sys-devel/gettext )
	
"
src_configure() {
	use static && append-ldflags -static
	local myeconfargs=(
		--program-prefix=g
		$(use_with guile)
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}
src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS NEWS README*
	if [[ ${USERLAND} == "GNU" ]] ; then
		# we install everywhere as 'gmake' but on GNU systems,
		# symlink 'make' to 'gmake'
		dosym gmake /usr/bin/make
		dosym gmake.1 /usr/share/man/man1/make.1
	fi
}


# vim: filetype=ebuild
