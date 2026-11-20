# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Updated config.sub and config.guess file from GNU"
HOMEPAGE="https://savannah.gnu.org/projects/config"
SRC_URI="https://distfiles.gentoo.org/pub/proj/base-system/gnuconfig/gnuconfig-20260517.tar.xz -> gnuconfig-20260517.tar.xz"
LICENSE="GPL-3+-with-autoconf-exception"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}"
src_compile() { :; }

src_install() {
	insinto /usr/share/${PN}
	doins config.{sub,guess} || die
	fperms +x /usr/share/${PN}/config.{sub,guess}
	dodoc ChangeLog
}


# vim: filetype=ebuild
