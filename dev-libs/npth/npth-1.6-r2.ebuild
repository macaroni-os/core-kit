# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="New GNU Portable Threads Library"
HOMEPAGE="https://git.gnupg.org/cgi-bin/gitweb.cgi?p=npth.git"
SRC_URI="https://gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2 -> npth-1.6.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--disable-static \
		$(use_enable test tests)
}

src_install() {
	default

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}