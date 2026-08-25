# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools flag-o-matic

DESCRIPTION="Libraries/utilities to handle ELF objects (drop in replacement for libelf)"
HOMEPAGE="https://sourceware.org/elfutils/"
SRC_URI="https://sourceware.org/elfutils/ftp/0.196/elfutils-0.196.tar.bz2 -> elfutils-0.196.tar.bz2"
LICENSE="|| ( GPL-2+ LGPL-3+ ) utils? ( GPL-3+ )"
SLOT="0"
KEYWORDS="*"
IUSE="bzip2 debuginfod libarchive lzma nls static-libs +threads +utils valgrind zstd"
REQUIRED_USE="debuginfod? ( libarchive )
"
BDEPEND="sys-devel/flex
	sys-devel/m4
	nls? ( sys-devel/gettext )
	
"
RDEPEND="sys-libs/zlib[static-libs?]
	bzip2? ( app-arch/bzip2[static-libs?] )
	lzma? ( app-arch/xz-utils[static-libs?] )
	zstd? ( app-arch/zstd:=[static-libs?] )
	debuginfod? (
	  dev-db/sqlite:3=
	  dev-libs/json-c:=
	  net-libs/libmicrohttpd:=
	  net-misc/curl[static-libs?]
	)
	libarchive? ( app-arch/libarchive:= )
	
"
DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	
"
src_prepare() {
	default
	eautoreconf
	if ! use static-libs; then
		sed -i -e '/^lib_LIBRARIES/s:=.*:=:' -e '/^%.os/s:%.o$::' lib{asm,dw,elf}/Makefile.in || die
	fi
	# https://sourceware.org/PR23914
	sed -i 's:-Werror::' */Makefile.in || die
}
src_configure() {
	unset LEX YACC

	local myeconfargs=(
		$(use_enable nls)
		$(use_enable debuginfod)
		$(use_enable debuginfod libdebuginfod)
		$(use_enable valgrind valgrind-annotations)
		$(use_enable threads thread-safety)
		# Valgrind option is just for running tests under it; dodgy under sandbox
		# and indeed even w/ glibc with newer instructions.
		--disable-valgrind
		--program-prefix="eu-"
		--with-zlib
		$(use_with bzip2 bzlib)
		$(use_with libarchive)
		$(use_with lzma)
		$(use_with zstd)

	)
	# Valgrind option is just for running tests under it; dodgy under sandbox
	# and indeed even w/ glibc with newer instructions.
	#
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}
src_install() {
	default
	einstalldocs
	dodoc NOTES
	# These build quick, and are needed for most tests, so don't
	# disable their building when the USE flag is disabled.
	if ! use utils; then
		rm -rf "${ED}"/usr/bin || die
	fi
}


# vim: filetype=ebuild
