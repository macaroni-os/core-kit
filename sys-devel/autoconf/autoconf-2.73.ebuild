# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="https://www.gnu.org/software/autoconf/autoconf.html"
SRC_URI="https://gnuftp.mirror.garr.it/autoconf/autoconf-2.73.tar.xz -> autoconf-2.73.tar.xz"
LICENSE="GPL-3+"
SLOT="latest"
KEYWORDS="*"
IUSE="emacs"
BDEPEND="sys-apps/texinfo
	>=dev-lang/perl-5.10
	>=sys-devel/m4-1.4.16
	
"
RDEPEND="sys-apps/texinfo
	>=dev-lang/perl-5.10
	>=sys-devel/m4-1.4.16
	>=sys-devel/autoconf-wrapper-13
	sys-devel/gnuconfig
	
"
DEPEND="${RDEPEND}
	
"
PDEPEND="emacs? ( app-emacs/autoconf-mode )
"
src_prepare() {
	find -name Makefile.in -exec sed -i '/^pkgdatadir/s:$:-@VERSION@:' {} + || die
	default
}
src_configure() {
	export EMACS=no
	local myconf=(
		--program-suffix="-2.73"
	)
	econf "${myconf[@]}" || die
	# econf updates config.{sub,guess} which forces the manpages
	# to be regenerated which we don't want to do.
	touch man/*.1
}
src_install() {
	default
}


# vim: filetype=ebuild
