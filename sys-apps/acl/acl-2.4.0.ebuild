# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit libtool toolchain-funcs usr-ldscript ltprune

DESCRIPTION="access control list utilities, libraries and headers"
HOMEPAGE="https://savannah.nongnu.org/projects/acl"
SRC_URI="http://download.savannah.nongnu.org/releases/acl/acl-2.4.0.tar.gz -> acl-2.4.0.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="nls static-libs"
DEPEND="nls? ( sys-devel/gettext )
	
"

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	local myeconfargs=(
	  --bindir="${EPREFIX}"/bin
	  --libexecdir="${EPREFIX}"/usr/$(get_libdir)
	  $(use_enable static-libs static)
	  $(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	 gen_usr_ldscript -a acl
	 use static-libs || prune_libtool_files --all
}


# vim: filetype=ebuild
