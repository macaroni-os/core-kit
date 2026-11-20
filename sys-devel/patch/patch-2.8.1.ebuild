# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="https://www.gnu.org/software/patch/patch.html"
SRC_URI="https://gnuftp.mirror.garr.it/patch/patch-2.8.1.tar.xz -> patch-2.8.1.tar.xz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="static xattr"
RDEPEND="xattr? ( sys-apps/attr )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	use static && append-ldflags -static

	local myeconfargs=(
		$(use_enable xattr)
	)
	# Do not let $ED mess up the search for `ed`.
	ac_cv_path_ED=$(type -P ed) \
		econf "${myeconfargs[@]}"
}


# vim: filetype=ebuild
