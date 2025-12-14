# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic toolchain-funcs

DESCRIPTION="Prints out location of specified executables that are in your path"
HOMEPAGE="https://carlowood.github.io/which/"
SRC_URI="https://gnuftp.mirror.garr.it/which/which-2.23.tar.gz -> which-2.23.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

src_configure() {
	append-lfs-flags
	tc-export AR
	default
}


# vim: filetype=ebuild
