# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit libtool toolchain-funcs

DESCRIPTION="Identify a file's format by scanning binary data for patterns"
HOMEPAGE="https://www.darwinsys.com/file/"
SRC_URI="https://astron.com/pub/file/file-5.48.tar.gz -> file-5.48.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="bzip2 lzma python seccomp static-libs zlib"
BDEPEND="sys-apps/grep
"
RDEPEND="bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/xz-utils )
	zlib? ( >=sys-libs/zlib-1.2.8-r1 )
	seccomp? ( sys-libs/libseccomp )
	
"
DEPEND="bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/xz-utils )
	zlib? ( >=sys-libs/zlib-1.2.8-r1 )
	
"
PDEPEND="python? ( ~sys-apps/file-python-5.48 )
"
src_prepare() {
	# Allow getcwd in file's own seccomp filter so the portage
	# sandbox keeps working during the build.
	if ! $(grep getcwd src/seccomp.c) ; then
		sed -i -e "/ALLOW_RULE(writev)/s@\$@\n\tALLOW_RULE(getcwd);\t// Used by Gentoo's portage sandbox@" \
			src/seccomp.c || die
	fi
	default
	elibtoolize
}
src_configure() {
	local myeconfargs=(
		--enable-fsect-man5
		$(use_enable bzip2 bzlib)
		$(use_enable lzma xzlib)
		$(use_enable seccomp libseccomp)
		$(use_enable static-libs static)
		$(use_enable zlib)
	)
	econf "${myeconfargs[@]}"
}
src_install() {
	default
	dodoc ChangeLog MAINT

	# Required for `file -C`
	insinto /usr/share/misc/magic
	doins -r magic/Magdir/*
	find "${ED}" -type f -name "*.la" -delete || die
}


# vim: filetype=ebuild
