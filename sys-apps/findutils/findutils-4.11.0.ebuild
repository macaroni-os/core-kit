# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic

DESCRIPTION="GNU utilities for finding files"
HOMEPAGE="https://www.gnu.org/software/findutils/"
SRC_URI="https://gnuftp.mirror.garr.it/findutils/findutils-4.11.0.tar.xz -> findutils-4.11.0.tar.xz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="nls selinux static"
BDEPEND="app-arch/xz-utils
	nls? ( sys-devel/gettext )
	
"
RDEPEND="selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )
	
"
DEPEND="${RDEPEND}
"
pkg_setup() {
	# enable long file name support for getcwd()
	export gl_cv_func_getcwd_path_max=yes
}
src_prepare() {
	# Don't build or install locate because it conflicts with mlocate,
	# which is a secure version of locate.
	sed \
		-e '/^SUBDIRS/s@locate@@' \
		-e '/^built_programs/s@ frcode locate updatedb@@' \
		-i Makefile.in || die

	default
}
src_configure() {
	if use static; then
		append-flags -pthread
		append-ldflags -static
	fi

	program_prefix=$(usex userland_GNU '' g)
	local myeconfargs=(
		--with-packager="MacaroniOS"
		--with-packager-version="4.11.0"
		--with-packager-bug-reports="https://github.com/macaroni-os/mark-issues/issues"
		--program-prefix=${program_prefix}
		$(use_enable nls)
		$(use_with selinux)
		--libexecdir='$(libdir)'/find
	)
	econf "${myeconfargs[@]}"
}
src_compile() {
	# We don't build locate, but the docs want a file in there.
	emake -C locate dblocation.texi
	default
}


# vim: filetype=ebuild
