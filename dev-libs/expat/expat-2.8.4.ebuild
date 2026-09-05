# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools

DESCRIPTION=":herb: Fast streaming XML parser written in C99 with >90% test coverage; moved from SourceForge to GitHub"
HOMEPAGE="https://libexpat.github.io/"
SRC_URI="https://github.com/libexpat/libexpat/releases/download/R_2_8_4/expat-2.8.4.tar.xz -> expat-2.8.4.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
DOCS=(
	README.md
)
IUSE="examples static-libs unicode"
BDEPEND="unicode? (
	  sys-devel/automake
	  sys-devel/autoconf
	  sys-devel/libtool
	)
	app-portage/elt-patches
	
"
src_prepare() {
	default
	# fix interpreter to be a recent/good shell
	sed -i -e "1s:/bin/sh:${BASH}:" conftools/get-version.sh || die
	if use unicode; then
		cp -R "${S}" "${S}"w || die
		pushd "${S}"w >/dev/null
		find -name Makefile.am \
			-exec sed \
			-e 's,libexpat\.la,libexpatw.la,' \
			-e 's,libexpat_la,libexpatw_la,' \
			-i {} + || die
		eautoreconf
		popd >/dev/null
	fi
}
src_configure() {
	local myconf="$(use_enable static-libs static) --without-docbook"
	mkdir -p "${BUILD_DIR}"w || die
	if use unicode; then
		pushd "${BUILD_DIR}"w >/dev/null
		CPPFLAGS="${CPPFLAGS} -DXML_UNICODE" ECONF_SOURCE="${S}"w econf ${myconf}
		popd >/dev/null
	fi
	ECONF_SOURCE="${S}" econf ${myconf}
}
src_compile() {
	emake
	if use unicode; then
		pushd "${BUILD_DIR}"w >/dev/null
		emake -C lib
		popd >/dev/null
	fi
}
src_install() {
	emake install DESTDIR="${D}"
	if use unicode; then
		pushd "${BUILD_DIR}"w >/dev/null
		emake -C lib install DESTDIR="${D}"
		popd >/dev/null

		pushd "${ED}"/usr/$(get_libdir)/pkgconfig >/dev/null
		cp expat.pc expatw.pc
		sed -i -e '/^Libs/s:-lexpat:&w:' expatw.pc || die
		popd >/dev/null
	fi
	einstalldocs
	doman doc/xmlwf.1
	# Note: Use of HTML_DOCS would add unwanted "doc" subfolder
	docinto html
	dodoc doc/*.{css,html}
	if use examples; then
		docinto examples
		dodoc examples/*.c
		docompress -x usr/share/doc/${PF}/examples
	fi
	find "${D}" -name '*.la' -type f -delete || die
}


# vim: filetype=ebuild
