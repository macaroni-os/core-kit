# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QA_FLAGS_IGNORED="opt/rar/rar opt/rar/unrar"
QA_PRESTRIPPED="opt/rar/rar opt/rar/unrar"

DESCRIPTION="RAR compressor/uncompressor"
HOMEPAGE="https://rarlab.com/"
SRC_URI="https://www.rarlab.com/rar/rarlinux-x64-723.tar.gz -> rarlinux-x64-723.tar.gz"
LICENSE="RAR BSD BSD-2"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist"
RDEPEND="sys-libs/glibc
"
S="${WORKDIR}/rar"
src_compile() { :; }

src_prepare() {
	default
	rm -f license.txt || die
}

src_install() {
	exeinto /opt/rar
	doexe rar unrar || die

	dodir /opt/bin
	dosym ../rar/rar /opt/bin/rar || die
	dosym ../rar/unrar /opt/bin/unrar || die

	insinto /opt/rar
	doins default.sfx rarfiles.lst || die
	dodoc *.txt
}


# vim: filetype=ebuild
