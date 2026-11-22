# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
LIBTOOLIZE="true"
WANT_LIBTOOL="none"
inherit autotools epunt-cxx

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="https://www.gnu.org/software/libtool/"
SRC_URI="https://ftp.wayne.edu/gnu/libtool/libtool-2.6.2.tar.xz -> libtool-2.6.2.tar.xz"
LICENSE="GPL-2"
SLOT="2"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/libtool-2.6.2-pthread_bootstrapped.patch"
	"${FILESDIR}/libtool-2.6.2-ppc64le.patch"
)
IUSE="vanilla"
RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	dev-libs/libltdl:0
	!<sys-apps/sandbox-2.10-r4
	
"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	
"
src_prepare() {
	if use vanilla ; then
		eapply_user
		return 0
	fi

	default

	pushd libltdl >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	popd >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	epunt_cxx

	# Make sure timestamps don't trigger a rebuild of man pages.
	touch doc/*.1
	export HELP2MAN=false
}
src_configure() {
	export CONFIG_SHELL="$(type -P bash)"
	export ac_cv_path_SED="$(basename "$(type -P sed)")"
	ECONF_SOURCE=${S} econf --disable-ltdl-install
}
src_install() {
	default

	local x
	while read -d $'\0' -r x ; do
		ln -sf /usr/share/gnuconfig/${x##*/} "${x}" || die
	done < <(find "${ED}" '(' -name config.guess -o -name config.sub ')' -print0)
}


# vim: filetype=ebuild
