# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit toolchain-funcs

DESCRIPTION="Parallel implementation of the XZ compression utility"
HOMEPAGE="https://jnovy.fedorapeople.org/pxz/"
SRC_URI="https://github.com/jnovy/pxz/archive/824de5dd22df3ba54bfe2cdd76029a62e53201fe.tar.gz -> pxz-5.0_pre20260317-824de5d.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
RDEPEND="app-arch/xz-utils
	sys-devel/gcc:*[openmp]
	
"
DEPEND="${RDEPEND}
"
# The distfile name carries the commit sha (review ask), so vcs-snapshot
# no longer renames the archive root: move it into ${S} explicitly.
post_src_unpack() {
	mv ${WORKDIR}/pxz-* "${S}"
}

src_prepare() {
	tc-check-openmp
	tc-export CC
	export BINDIR=/usr/bin
	export MANDIR=/usr/share/man
	default
}


# vim: filetype=ebuild
