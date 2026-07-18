# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit preserve-libs

DESCRIPTION="Portable, high level programming interface to various calling conventions"
HOMEPAGE="https://sourceware.org/libffi/ https://github.com/libffi/libffi/"
SRC_URI="https://github.com/libffi/libffi/releases/download/v3.7.1/libffi-3.7.1.tar.gz -> libffi-3.7.1.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="debug exec-static-trampoline pax_kernel static-libs"
src_configure() {
	ECONF_SOURCE="${S}" econf \
	  --prefix="${EPREFIX}"/usr/ \
	  --includedir="${EPREFIX}"/usr/$(get_libdir)/${PN}/include \
	  --disable-multi-os-directory \
	  $(use_enable static-libs static) \
	  $(use_enable exec-static-trampoline exec-static-tramp) \
	  $(use_enable pax_kernel pax_emutramp) \
	  $(use_enable debug)
}

src_install() {
	einstalldocs
	emake DESTDIR="${D}" install
	find "${ED}" -name "*.la" -delete || die
}
pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libffi.so.7
}
pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libffi.so.7
}


# vim: filetype=ebuild
