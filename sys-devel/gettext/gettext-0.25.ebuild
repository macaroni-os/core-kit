# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit libtool java-pkg-opt-2

DESCRIPTION="GNU locale utilities"
HOMEPAGE="https://www.gnu.org/software/gettext/"
SRC_URI="https://ftp.gnu.org/pub/gnu/gettext/gettext-0.25.tar.xz -> gettext-0.25.tar.xz"
LICENSE="GPL-3+ cxx? ( LGPL-2.1+ )"
SLOT="0"
KEYWORDS="*"
IUSE="acl -cvs +cxx doc emacs git java ncurses nls openmp static-libs xattr"
BDEPEND="git? (  dev-vcs/git )
	
"
RDEPEND="${DEPEND}
	git? (  dev-vcs/git )
	java? ( virtual/jdk )
	
"
DEPEND="virtual/libiconv
	virtual/libintl
	dev-libs/libxml2
	dev-libs/expat
	acl? ( virtual/acl )
	ncurses? ( sys-libs/ncurses )
	java? ( virtual/jdk )
	
"
PDEPEND="emacs? ( app-emacs/po-mode )
	
"
pkg_setup() {
	java-pkg-opt-2_pkg_setup
}
src_prepare() {
	java-pkg-opt-2_src_prepare
	default
	elibtoolize
}
src_configure() {
	local myconf=(
	  # switches common to runtime and top-level
	  --cache-file=${S}/config.cache
	  # Emacs support is now in a separate package
	  --without-emacs
	  --without-lispdir
	  # glib depends on us so avoid circular deps
	  --with-included-glib
	  # libcroco depends on glib which ... ^^^
	  --with-included-libcroco
	  # this will _disable_ libunistring (since it is not bundled),
	  --with-included-libunistring
	  # Never build libintl since it's in dev-libs/libintl now.
	  --without-included-gettext
	  # Never build bundled copy of libxml2.
	  --without-included-libxml
	  --disable-csharp
	  --without-cvs
	  $(use_enable acl)
	  $(use_enable cxx c++)
	  $(use_enable cxx libasprintf)
	  $(use_with git)
	  $(use_enable java)
	  $(use_enable ncurses curses)
	  $(use_enable nls)
	  $(use_enable openmp)
	  $(use_enable static-libs static)
	  $(use_enable xattr attr)
	)
	local ECONF_SOURCE="${S}"
	econf "${myconf[@]}"
}
src_install() {
	emake DESTDIR="${D}" install
	dosym msgfmt /usr/bin/gmsgfmt # bug #43435
	dobin gettext-tools/misc/gettextize
	# 909041 never install libintl which upstream insists on building
	rm -f "${ED}"/usr/$(get_libdir)/libintl.* "${ED}"/usr/include/libintl.h
	find "${ED}" -type f -name "*.la" -delete || die
	if use java ; then
	  java-pkg_dojar "${ED}"/usr/share/${PN}/*.jar
	  rm "${ED}"/usr/share/${PN}/*.jar || die
	  rm "${ED}"/usr/share/${PN}/*.class || die
	  if use doc ; then
	    java-pkg_dojavadoc "${ED}"/usr/share/doc/${PF}/html/javadoc2
	  fi
	fi
	dodoc AUTHORS ChangeLog NEWS README THANKS
	if use doc ; then
	  docinto html
	  dodoc "${ED}"/usr/share/doc/${PF}/*.html
	else
	  rm -rf "${ED}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	rm "${ED}"/usr/share/doc/${PF}/*.html || die
}
pkg_preinst() {
	java-pkg-opt-2_pkg_preinst
}


# vim: filetype=ebuild
