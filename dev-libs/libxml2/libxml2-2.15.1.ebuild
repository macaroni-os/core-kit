# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit python-r1 meson

DESCRIPTION="XML C parser and toolkit"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home"
SRC_URI="https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.1.tar.xz -> libxml2-2.15.1.tar.xz"
SLOT="2"
KEYWORDS="*"
IUSE="doc icu python readline static-libs lzma"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
BDEPEND="virtual/pkgconfig
	
"
RDEPEND="virtual/libiconv
	sys-libs/zlib:=
	icu? ( dev-libs/icu:= )
	lzma? ( app-arch/xz-utils:= )
	readline? ( sys-libs/readline:= )
	
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	
"
PDEPEND="python? ( dev-python/libxml2-python )
	
"
S="${WORKDIR}/libxml2-2.15.1"
src_prepare() {
	default
	sed -e "/^dir_doc/ s/meson.project_name()$/\'${PF}\'/" -i meson.build || die
}
src_configure() {
	local emesonargs=(
	  -Ddefault_library=$(usex static-libs both shared)
	  $(meson_feature icu)
	  $(meson_feature doc docs)
	  $(meson_feature readline)
	  $(meson_feature readline history)
	  -Dpython=disabled
	  -Dschematron=enabled
	  # There has been a clean break with a soname bump.
	  # It's time to deal with the breakage.
	  # bug #935452
	  -Dlegacy=disabled
	)
	meson_src_configure
}
src_install() {
	meson_src_install
}
pkg_postinst() {
	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [[ -n "${ROOT}" ]]; then
	  elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
	  # Need an XML catalog, so no-one writes to a non-existent one
	  CATALOG="${EROOT}/etc/xml/catalog"
	  if [[ ! -e "${CATALOG}" ]]; then
	    [[ -d "${EROOT}/etc/xml" ]] || mkdir -p "${EROOT}/etc/xml"
	    "${EPREFIX}"/usr/bin/xmlcatalog --create > "${CATALOG}"
	    einfo "Created XML catalog in ${CATALOG}"
	  fi
	fi
}


# vim: filetype=ebuild
