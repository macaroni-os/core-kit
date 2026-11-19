# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic toolchain-funcs

DESCRIPTION="unzipper for pkzip-compressed files"
HOMEPAGE="https://www.info-zip.org/"
SRC_URI="
https://ftp.debian.org/debian/pool/main/u/unzip/unzip_6.0-32.debian.tar.xz -> unzip_6.0-32.debian.tar.xz
https://downloads.sourceforge.net/infozip/unzip60.tar.gz -> unzip60.tar.gz"
LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/unzip-6.0-no-exec-stack.patch"
	"${FILESDIR}/unzip-6.0-format-security.patch"
	"${FILESDIR}/unzip-6.0-fix-false-overlap-detection-on-32bit-systems.patch"
)
IUSE="bzip2 natspec unicode"
RDEPEND="bzip2? ( app-arch/bzip2 )
	natspec? ( dev-libs/libnatspec )
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/unzip60"
src_prepare() {
	# debian/patches/series is Debian's canonical application order and
	# is the only correct one from revision 31 on, where the patch file
	# names lost their numeric prefix (globbing them applies patches out
	# of order and fails on process.c/extract.c). All four hunks of the
	# local patch set still apply on top (verified with
	# patch -p1 --dry-run on both revisions).
	local deb="${WORKDIR}/debian/patches" p
	while read -r p; do
		[[ -n "${p}" ]] || continue
		[[ "${p}" == *this-is-debian-unzip.patch ]] && continue
		eapply "${deb}/${p}"
	done < "${deb}/series"

	default

	# natspec support is a patch rather than an upstream option: it
	# includes natspec.h and links libnatspec unconditionally, so it
	# must stay behind the USE flag.
	use natspec && eapply "${FILESDIR}"/unzip-6.0-natspec.patch

	sed -i -r \
		-e '/^CFLAGS/d' \
		-e '/CFLAGS/s:-O[0-9]?:$(CFLAGS) $(CPPFLAGS):' \
		-e '/^STRIP/s:=.*:=true:' \
		-e "s:\<CC *= *\"?g?cc2?\"?\>:CC=\"$(tc-getCC)\":" \
		-e "s:\<LD *= *\"?(g?cc2?|ld)\"?\>:LD=\"$(tc-getCC)\":" \
		-e "s:\<AS *= *\"?(g?cc2?|as)\"?\>:AS=\"$(tc-getCC)\":" \
		-e 's:LF2 = -s:LF2 = :' \
		-e 's:LF = :LF = $(LDFLAGS) :' \
		-e 's:SL = :SL = $(LDFLAGS) :' \
		-e 's:FL = :FL = $(LDFLAGS) :' \
		-e "/^#L_BZ2/s:^$(use bzip2 && echo .)::" \
		-e 's:$(AS) :$(AS) $(ASFLAGS) :g' \
		unix/Makefile \
		|| die "sed unix/Makefile failed"

	# Delete bundled code to make sure we don't use it.
	rm -r bzip2 || die
}

src_configure() {
	# Mark builds a single native ABI (no multilib), so the tree's
	# get_abi_CFLAGS-based ASFLAGS plumbing and the non-Linux TARGETs
	# are dropped with it.
	case ${CHOST} in
		i?86*-*linux*) TARGET="linux_asm" ;;
		*linux*)       TARGET="linux_noasm" ;;
		*) die "Unsupported CHOST ${CHOST}: only Linux targets are supported" ;;
	esac

	append-cppflags -DNO_LCHMOD -DLARGE_FILE_SUPPORT
	use bzip2 && append-cppflags -DUSE_BZIP2
	use unicode && append-cppflags -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DUSE_ICONV_MAPPING
}

src_compile() {
	emake -f unix/Makefile ${TARGET}
}

src_install() {
	dobin unzip funzip unzipsfx unix/zipgrep
	dosym unzip /usr/bin/zipinfo
	doman man/*.1
	dodoc BUGS History* README ToDo WHERE
}


# vim: filetype=ebuild
