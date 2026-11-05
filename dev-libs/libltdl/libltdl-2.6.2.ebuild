# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="https://www.gnu.org/software/libtool/"
SRC_URI="https://ftp.wayne.edu/gnu/libtool/libtool-2.6.2.tar.xz -> libtool-2.6.2.tar.xz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"
S="${WORKDIR}/libtool-${PV}/libltdl"
src_configure() {
	ECONF_SOURCE=${S}
	econf --enable-ltdl-install \
	  $(use_enable static-libs static)
}
src_install() {
	emake DESTDIR="${D}" install
}


# vim: filetype=ebuild
