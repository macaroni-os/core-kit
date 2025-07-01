# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for C library"
SLOT="0"
KEYWORDS="*"
RDEPEND="elibc_glibc? ( sys-libs/glibc )
	elibc_musl? ( sys-libs/musl )
	elibc_uclibc? ( sys-libs/uclibc-ng )
	
"

# vim: filetype=ebuild
