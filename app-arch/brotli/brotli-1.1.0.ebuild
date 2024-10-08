# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"
SRC_URI="https://github.com/google/brotli/tarball/ed738e842d2fbdf2d6459e39267a633c4a9b2f5d -> brotli-1.1.0-ed738e8.tar.gz"
SLOT="0/$(ver_cut 1)"

PDEPEND="python? ( ~dev-python/brotlipy-${PV} )"
DEPEND=""

IUSE="python test"

LICENSE="MIT python? ( Apache-2.0 )"

KEYWORDS="*"
S="${WORKDIR}"/google-brotli-ed738e8

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	( cd ${S} && python3 setup.py sdist ) || die
}

src_install() {
	cmake_src_install
	insinto /usr/share/${PN}/bindings
	newins ${S}/dist/brotli-${PV}.tar.gz brotli-python-${PV}.tar.gz
}