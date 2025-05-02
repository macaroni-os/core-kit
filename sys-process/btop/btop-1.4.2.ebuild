# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs xdg-utils

DESCRIPTION="A monitor of resources"
HOMEPAGE="https://github.com/aristocratos/btop"
SRC_URI="https://github.com/aristocratos/btop/tarball/19aec3e43d98fb815531c487a18f352c596c1d6f -> btop-1.4.2-19aec3e.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/aristocratos-btop-19aec3e"

src_prepare() {
	default

	# btop installs README.md to /usr/share/btop by default
	sed -i '/^.*cp -p README.md.*$/d' Makefile || die
}

src_compile() {
	# Disable btop optimization flags, since we have our flags in CXXFLAGS
	emake VERBOSE=true OPTFLAGS="" CXX="$(tc-getCXX)"
}

src_install() {
	emake \
		PREFIX="${EPREFIX}/usr" \
		DESTDIR="${D}" \
		install

	dodoc README.md CHANGELOG.md
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}