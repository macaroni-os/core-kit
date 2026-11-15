# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit unpacker toolchain-funcs flag-o-matic

DESCRIPTION="A POSIX standard archive tool"
HOMEPAGE="https://www.mirbsd.org/pax.htm"
SRC_URI="https://mbsd.evolvis.org/MirOS/dist/mir/cpio/paxmirabilis-20240817.cpio.gz -> paxmirabilis-20240817.cpio.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
BDEPEND="app-arch/cpio
"
S="${WORKDIR}/pax"
src_configure() {
	tc-export CC
	tc-getPROG SIZE size
}

# Upstream ships Build.sh, the supported way to build outside MirBSD;
# it probes the libc feature set (the 2016 hand-frozen CPPFLAGS no
# longer cover the 2024 sources) and also generates the man pages.
src_compile() {
	sh ./Build.sh || die
}

src_install() {
	dobin pax
	doman pax.1

	dosym pax /usr/bin/paxcpio
	newman cpio.1 paxcpio.1

	dosym pax /usr/bin/paxtar
	newman tar.1 paxtar.1
}


# vim: filetype=ebuild
