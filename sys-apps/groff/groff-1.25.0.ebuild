# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit toolchain-funcs

DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="https://www.gnu.org/software/groff/groff.html"
SRC_URI="https://gnuftp.mirror.garr.it/groff/groff-1.25.0.tar.gz -> groff-1.25.0.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/groff-1.19.2-man-unicode-dashes.patch"
)
DOCS=(
	BUG-REPORT
	ChangeLog
	MORE.STUFF
	NEWS
	PROBLEMS
	PROJECTS
	README
	TODO
)
IUSE="examples uchardet X"
BDEPEND="dev-lang/perl
	sys-apps/texinfo
	
"
RDEPEND="uchardet? ( app-i18n/uchardet )
	X? (
	  x11-libs/libICE
	  x11-libs/libSM
	  x11-libs/libX11
	  x11-libs/libXaw
	  x11-libs/libXmu
	  x11-libs/libXt
	)
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	default

	# Honor the MacaroniOS docdir
	sed -i -e "s|^docdir =.*|docdir = \"/usr/share/doc/${PF}\"|g" \
		Makefile.in \
		|| die "failed to modify Makefile.in"

	# OS stamp rendered into man page headers
	cat <<-EOF >> tmac/mdoc.local || die
	.ds volume-operating-system MacaroniOS
	.ds operating-system MacaroniOS/${KERNEL}
	.ds default-operating-system MacaroniOS/${KERNEL}
	EOF

	# make sure we don't get a crappy `g' nameprefix on UNIX systems with real
	# troff (GROFF_G macro runs some test to see, its own troff doesn't satisfy)
	sed -i -e 's/^[ \t]\+g=g$/g=/' configure || die
}
src_configure() {
	local myeconfargs=(
		--with-appdefdir="/usr/share/X11/app-defaults"
		--without-compatibility-wrappers   # no Prefix support in the MacaroniOS trees; keep tree behavior
		$(use_with uchardet)
		$(use_with X x)
	)

	econf "${myeconfargs[@]}"
}
src_compile() {
	emake AR="$(tc-getAR)"
}
src_install() {
	default

	# The following links are required for man
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl

	if ! use examples ; then
		# The pdf files might not be generated if ghostscript is unavailable
		local pdf="${ED}/usr/share/doc/${PF}/examples/mom/mom-pdf.pdf"
		if [[ -e ${pdf} ]] ; then
			# Keep mom-pdf.pdf since it's more of a manual than an example
			mv "${pdf}" "${ED}/usr/share/doc/${PF}/pdf/" || die
		fi
		rm -rf "${ED}/usr/share/doc/${PF}/examples"
	fi
}


# vim: filetype=ebuild
