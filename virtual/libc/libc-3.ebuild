# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

DESCRIPTION="Virtual for C library"
SLOT="0"
KEYWORDS="*"
RDEPEND="elibc_glibc? (
	  >=sys-libs/glibc-2.41
	  sys-apps/locale-gen
	)
	elibc_musl? ( sys-libs/musl )
	elibc_uclibc? ( sys-libs/uclibc-ng )
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild
