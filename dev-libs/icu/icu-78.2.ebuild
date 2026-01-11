# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit autotools flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="The home of the ICU project source code."
HOMEPAGE="https://icu.unicode.org/"
SRC_URI="https://github.com/unicode-org/icu/releases/download/release-78.2/icu4c-78.2-sources.tgz -> icu4c-sources.tgz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="debug doc examples static-libs"
BDEPEND="${PYTHON_DEPS}
	sys-devel/autoconf-archive
	virtual/pkgconfig
	doc? ( app-text/doxygen[dot] )
	
"
S="${WORKDIR}/icu/source"
src_prepare() {
	default
	# Disable renaming as it is stupid thing to do
	sed -i \
	  -e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" \
	  common/unicode/uconfig.h || die
	# Fix linking of icudata
	sed -i \
	  -e "s:LDFLAGSICUDT=-nodefaultlibs -nostdlib:LDFLAGSICUDT=:" \
	  config/mh-linux || die
	# Append doxygen configuration to configure
	sed -i \
	  -e 's:icudefs.mk:icudefs.mk Doxyfile:' \
	  configure.ac || die
	eautoreconf
}
src_configure() {
	append-cxxflags -std=c++17
	local myeconfargs=(
	  --disable-renaming
	  --disable-samples
	  --disable-layoutex
	  $(use_enable debug)
	  $(use_enable static-libs static)
	  $(use_enable examples samples)
	)
	# icu tries to use clang by default
	tc-export CC CXX
	# make sure we configure with the same shell as we run icu-config
	# with, or ECHO_N, ECHO_T and ECHO_C will be wrongly defined
	export CONFIG_SHELL="${EPREFIX}/bin/sh"
	# probably have no /bin/sh in prefix-chain
	[[ -x ${CONFIG_SHELL} ]] || CONFIG_SHELL="${BASH}"
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}


# vim: filetype=ebuild
