# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="Utilities and libraries for NUMA systems"
HOMEPAGE="https://github.com/numactl/numactl"
SRC_URI="https://github.com/numactl/numactl/releases/download/v2.0.19/numactl-2.0.19.tar.gz -> numactl-2.0.19.tar.gz"
# ARM lacks the __NR_migrate_pages syscall.
KEYWORDS="* -arm"

LICENSE="GPL-2"
SLOT="0"
IUSE="static-libs"

src_prepare() {
	# lto not supported yet
	# gcc-9 with -flto leads to link failures: #692254
	filter-flags -flto*
	sed -i -e '/^numademo_CFLAGS/s/-O3 //' ${S}/Makefile.am || die
	eautoreconf
	default
}

src_configure() {
	ECONF_SOURCE="${S}" econf $(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" install
	find "${ED}"/usr/ -type f -name libnuma.la -delete || die
	local DOCS=( README.md )
	einstalldocs
	# delete man pages provided by the man-pages package #238805
	rm -r "${ED}"/usr/share/man/man[25] || die
}