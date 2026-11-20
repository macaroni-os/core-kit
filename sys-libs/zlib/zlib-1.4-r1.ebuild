# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
AUTOTOOLS_AUTO_DEPEND=no
inherit autotools toolchain-funcs

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="https://zlib.net/"
SRC_URI="https://github.com/madler/zlib/releases/download/v1.4/zlib-1.4.tar.gz -> zlib-1.4.tar.gz"
LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/zlib-1.4-minizip-drop-crypt-header.patch"
)
IUSE="minizip static-libs"
DEPEND="minizip? ( ${AUTOTOOLS_DEPEND} )
	
"
src_prepare() {
	default
	if use minizip ; then
		cd contrib/minizip || die
		eautoreconf
	fi
}

src_configure() {
	# not an autoconf script, so can't use econf
	local uname=$(/usr/share/gnuconfig/config.sub "${CHOST}" | cut -d- -f3)
	"${S}"/configure \
		--shared \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		${uname:+--uname=${uname}} \
		|| die

	if use minizip ; then
		local minizipdir="contrib/minizip"
		cd ${minizipdir} || die
		ECONF_SOURCE="${S}/${minizipdir}" \
		econf $(use_enable static-libs static)
	fi
}

src_compile() {
	emake
	use minizip && emake -C contrib/minizip
}

sed_macros() {
	sed -i -r 's:\<(O[FN])\>:_Z_\1:g' "$@" || die
}

src_install() {
	emake install DESTDIR="${D}" LDCONFIG=:
	gen_usr_ldscript -a z
	sed_macros "${ED}"/usr/include/*.h
	if use minizip ; then
		emake -C contrib/minizip install DESTDIR="${D}"
		sed_macros "${ED}"/usr/include/minizip/*.h
	fi
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/lib{z,minizip}.{a,la}
	dodoc FAQ README ChangeLog doc/*.txt
	use minizip && dodoc contrib/minizip/*.txt
}


# vim: filetype=ebuild
