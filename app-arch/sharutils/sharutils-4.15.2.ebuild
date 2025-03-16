# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic autotools

DESCRIPTION="Tools to deal with shar archives"
HOMEPAGE="https://www.gnu.org/software/sharutils/"
SRC_URI="https://ftp.gnu.org/gnu/sharutils/sharutils-4.15.2.tar.xz -> sharutils-4.15.2.tar.xz"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/sharutils-4.15.2-CVE-2018-1000097.patch"
	"${FILESDIR}/sharutils-4.15.2-gcc-10.patch"
	"${FILESDIR}/sharutils-4.15.2-glibc228.patch"
)
IUSE="nls"
DEPEND="app-arch/xz-utils
	sys-apps/texinfo
	nls? ( sys-devel/gettext )
	
"
src_prepare() {
	default
	append-cflags $(test-flags-CC -Wno-error=format-security)
	append-cflags -std=gnu17
	eautoreconf
}

src_configure() {
	econf $(use_enable nls)
}


# vim: filetype=ebuild
