# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools libtool

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="https://www.pcre.org/"
SRC_URI="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.49/pcre2-10.49.tar.bz2 -> pcre2-10.49.tar.bz2"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="bzip2 +jit libedit pcre16 +pcre32 +readline +recursion-limit static-libs unicode zlib"
REQUIRED_USE="?? ( libedit readline )"
BDEPEND="virtual/pkgconfig
"
RDEPEND="bzip2? ( app-arch/bzip2 )
	zlib? ( sys-libs/zlib )
	libedit? ( dev-libs/libedit )
	readline? ( sys-libs/readline:0= )
	
"
DEPEND="${RDEPEND}
	>=sys-apps/findutils-4.4.0
	
"
S="${WORKDIR}/pcre2-10.49"
src_prepare() {
	default
	elibtoolize
}

src_configure() {
	local myeconfargs=(
		--enable-pcre2-8
		--enable-shared
		--htmldir=/usr/share/doc/${PF}/html
		--with-match-limit-depth=$(usex recursion-limit 8192 MATCH_LIMIT)
		$(use_enable bzip2 pcre2grep-libbz2)
		$(use_enable libedit pcre2test-libedit)
		$(use_enable readline pcre2test-libreadline)
		$(use_enable zlib pcre2grep-libz)
		$(use_enable jit)
		$(use_enable jit pcre2grep-jit)
		$(use_enable pcre16 pcre2-16)
		$(use_enable pcre32 pcre2-32)
		$(use_enable static-libs static)
		$(use_enable unicode)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_compile() {
	emake V=1
}

src_install() {
	emake DESTDIR="${D}" install
	find "${ED}" -name "*.la" -delete || die
}


# vim: filetype=ebuild
