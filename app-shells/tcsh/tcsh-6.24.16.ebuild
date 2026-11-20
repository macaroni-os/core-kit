# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic autotools

DESCRIPTION="Enhanced version of the Berkeley C shell (csh)"
HOMEPAGE="https://www.tcsh.org/"
SRC_URI="https://astron.com/pub/tcsh/tcsh-6.24.16.tar.gz -> tcsh-6.24.16.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/tcsh-6.24.01-ftbfs-gcc-10.patch"
	"${FILESDIR}/tcsh-6.24.01-no-dot-in-default-path.patch"
	"${FILESDIR}/tcsh-6.21.00-use-ncurses.patch"
)
DOCS=(
	FAQ
	Fixes
	Ported
	README.md
	WishList
	Y2K
)
IUSE="nls"
RESTRICT="test"
RDEPEND=">=sys-libs/ncurses-5.1:0=
	sys-libs/libxcrypt
	virtual/libiconv
	
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	
"
src_prepare() {
	default

	eautoreconf

	# unify ECHO behaviour
	echo "#undef ECHO_STYLE" >> config_f.h
	echo "#define ECHO_STYLE BOTH_ECHO" >> config_f.h
}

src_configure() {
	# tcsh compiles in the locations of the system startup files
	# and the directories appended to its default PATH.
	append-cppflags \
		-D_PATH_DOTCSHRC="'\"/etc/csh.cshrc\"'" \
		-D_PATH_DOTLOGIN="'\"/etc/csh.login\"'" \
		-D_PATH_DOTLOGOUT="'\"/etc/csh.logout\"'" \
		-D_PATH_USRBIN="'\"/usr/bin\"'" \
		-D_PATH_BIN="'\"/bin\"'"

	# musl's utmp is non-functional
	if use elibc_musl ; then
		export ac_cv_header_utmp_h=no
		export ac_cv_header_utmpx_h=no
	fi

	local myeconfargs=(
		# keep the binary in /bin as the other shells in the kit do
		--bindir=/bin
		--prefix=/usr
		--datarootdir=/usr/share
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install install.man

	einstalldocs

	insinto /etc
	doins "${FILESDIR}"/csh.cshrc "${FILESDIR}"/csh.login

	# add csh -> tcsh symlink
	dosym tcsh /bin/csh
}


# vim: filetype=ebuild
