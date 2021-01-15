# Distributed under the terms of the GNU General Public License v2

EAPI="6"
ETYPE="sources"
KEYWORDS="~amd64 ~x86"

HOMEPAGE="http://kernel.kolivas.org/"

K_SECURITY_UNSUPPORTED="1"

CK_EXTRAVERSION="ck1"

inherit kernel-2
detect_version
detect_arch

RDEPEND="virtual/linux-sources"

DESCRIPTION="Linux 5.10.7, with Con Kolivas' MuQSS scheduler and patchset"

CK_URI="http://ck.kolivas.org/patches/5.0/5.10/5.10-ck1/patch-5.10-ck1.xz"

K_BRANCH_ID="5.10"

SRC_URI="${KERNEL_URI}
	${ARCH_URI}
	${CK_URI}
	"

UNIPATCH_LIST="
        ${DISTDIR}/patch-${K_BRANCH_ID}-${CK_EXTRAVERSION}.xz
	${FILESDIR}/${CK_EXTRAVERSION}-revert-version.patch
	"

UNIPATCH_STRICTORDER="yes"

pkg_postinst() {
	kernel-2_pkg_postinst
}

pkg_postrm() {
	kernel-2_pkg_postrm
}