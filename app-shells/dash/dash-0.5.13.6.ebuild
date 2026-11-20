# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic toolchain-funcs

DESCRIPTION="Debian Almquist Shell"
HOMEPAGE="http://gondor.apana.org.au/~herbert/dash/"
SRC_URI="http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.13.6.tar.gz -> dash-0.5.13.6.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="libedit static"
BDEPEND="virtual/pkgconfig
"
RDEPEND="!static? ( libedit? ( dev-libs/libedit ) )
	
"
DEPEND="${RDEPEND}
	libedit? ( static? ( dev-libs/libedit[static-libs] ) )
	
"
src_prepare() {
	default

	# Use pkg-config for libedit linkage
	sed -i \
		-e "/LIBS/s:-ledit:\`$(tc-getPKG_CONFIG) --libs libedit $(usex static --static '')\`:" \
		configure || die
}

src_configure() {
	append-cppflags -DJOBS=$(usex libedit 1 0)
	use static && append-ldflags -static

	local myeconfargs=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"
		--bindir=/bin
		--enable-fnmatch
		$(use_with libedit)
	)
	econf "${myeconfargs[@]}"
}


# vim: filetype=ebuild
