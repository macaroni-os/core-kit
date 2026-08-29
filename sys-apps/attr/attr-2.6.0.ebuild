# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit libtool toolchain-funcs usr-ldscript

DESCRIPTION="Extended attributes tools"
HOMEPAGE="https://savannah.nongnu.org/projects/attr"
SRC_URI="http://download.savannah.nongnu.org/releases/attr/attr-2.6.0.tar.gz -> attr-2.6.0.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="debug nls static-libs"
DEPEND="nls? ( sys-devel/gettext )
	
"

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	unset PLATFORM
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG
	 tc-ld-disable-gold
	 local myeconfargs=(
	  --bindir="${EPREFIX}"/bin
	  --libexecdir="${EPREFIX}"/usr/$(get_libdir)
	  --enable-shared
	  $(use_enable static-libs static)
	  $(use_enable nls)
	  $(use_enable debug)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install
	 # we install attr into /bin, so we need the shared lib with it
	gen_usr_ldscript -a attr
	 # Add a wrapper until people upgrade.
	insinto /usr/include/attr
	newins "${FILESDIR}"/xattr-shim.h xattr.h
	 if ! use static-libs; then
	  find "${ED}" -name '*.la' -delete || die
	fi
	 einstalldocs
}


# vim: filetype=ebuild
