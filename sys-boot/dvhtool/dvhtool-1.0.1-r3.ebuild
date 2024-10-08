# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools toolchain-funcs

DESCRIPTION="Tool to copy kernel(s) into the volume header on SGI MIPS-based workstations"
HOMEPAGE="http://packages.debian.org/unstable/utils/dvhtool"
SRC_URI="http://deb.debian.org/debian/pool/main/d/dvhtool/dvhtool_1.0.1.orig.tar.gz -> dvhtool_1.0.1.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND=""
RDEPEND=""

S="${S}.orig"

PATCHES=(
	# several applicable hunks from a debian patch
	"${FILESDIR}"/${P}-debian.diff

	# Newer minor patches from Debian
	"${FILESDIR}"/${P}-debian-warn_type_guess.diff
	"${FILESDIR}"/${P}-debian-xopen_source.diff

	# Allow dvhtool to recognize Linux RAID and Linux LVM partitions
	"${FILESDIR}"/${P}-add-raid-lvm-parttypes.patch

)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	CC=$(tc-getCC) LD=$(tc-getLD) \
		econf
}

src_compile() {
	CC=$(tc-getCC) LD=$(tc-getLD) \
		emake
}