# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit pam toolchain-funcs

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="https://sites.google.com/site/fullycapable/"
SRC_URI="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-2.78.tar.gz -> libcap-2.78.tar.gz"
LICENSE="|| ( GPL-2 BSD ) pam? ( || ( LGPL-2+ BSD ) )"
SLOT="0"
KEYWORDS="*"
IUSE="pam +static-libs tools"
BDEPEND="sys-apps/diffutils tools? ( dev-lang/go )
"
RDEPEND="pam? ( sys-libs/pam )
	
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	
"
run_emake() {
	local args=(
		exec_prefix="${EPREFIX}"
		lib_prefix="${EPREFIX}/usr"
		lib="$(get_libdir)"
		prefix="${EPREFIX}/usr"
		PAM_CAP="$(usex pam yes no)"
		DYNAMIC=yes
		GOLANG="$(usex tools yes no)"
	)
	emake "${args[@]}" "$@"
}
src_compile() {
	local BUILD_CC
	tc-export_build_env BUILD_CC
	run_emake
}
src_install() {
	run_emake DESTDIR="${D}" install
	gen_usr_ldscript -a cap
	if ! use static-libs; then
	  rm "${ED}"/usr/$(get_libdir)/lib{cap,psx}.a || die
	fi
	# install pam plugins ourselves
	if [[ -d "${ED%/}"/usr/$(get_libdir)/security ]] ; then
	  rm -rf "${ED}"/usr/$(get_libdir)/security || die
	fi
	if use pam; then
	  dopammod pam_cap/pam_cap.so
	  dopamsecurity '' pam_cap/capability.conf
	fi
}


# vim: filetype=ebuild
