# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="zlib replacement with optimizations for 'next generation' systems."
HOMEPAGE="https://github.com/zlib-ng/zlib-ng"
SRC_URI="https://api.github.com/repos/zlib-ng/zlib-ng/tarball/2.3.3 -> zlib-ng-2.3.3-1273109.tar.gz"
LICENSE="ZLIB"
SLOT="0"
KEYWORDS="*"
IUSE="compat
cpu_flags_x86_avx2
cpu_flags_x86_sse2
cpu_flags_x86_ssse3
cpu_flags_x86_sse4a
cpu_flags_x86_pclmul
cpu_flags_arm_crc32
cpu_flags_arm_neon
cpu_flags_ppc_vsx2
"
RDEPEND="compat? ( !sys-libs/zlib )
"

post_src_unpack() {
	mv zlib-ng-zlib-ng-* ${S}
}


src_configure() {
	local mycmakeargs=(
	  -DZLIB_COMPAT="$(usex compat)"
	  # zlib-ng 2.2 removed the WITH_UNALIGNED switch (zbuild.h now
	  # follows __ARM_FEATURE_UNALIGNED); the test suite is not part
	  # of the package build.
	  -DBUILD_TESTING=OFF
	)
	 # The intrinsics options are all defined conditionally, so we need
	# to enable them on/off per-arch here for now.
	if use amd64 || use x86 ; then
	  mycmakeargs+=(
	    -DWITH_AVX2=$(usex cpu_flags_x86_avx2)
	    -DWITH_SSE2=$(usex cpu_flags_x86_sse2)
	    -DWITH_SSSE3=$(usex cpu_flags_x86_ssse3)
	    -DWITH_SSE42=$(usex cpu_flags_x86_sse4a)
	    -DWITH_PCLMULQDQ=$(usex cpu_flags_x86_pclmul)
	  )
	fi
	 if use arm || use arm64 ; then
	  mycmakeargs+=(
	    -DWITH_ARMV8=$(usex cpu_flags_arm_crc32)
	    -DWITH_NEON=$(usex cpu_flags_arm_neon)
	  )
	fi
	 if use ppc || use ppc64 ; then
	  # The POWER8 support is VSX which was introduced
	  # VSX2 was introduced with POWER8, so use that as a proxy for it
	  mycmakeargs+=(
	    -DWITH_POWER8=$(usex cpu_flags_ppc_vsx2)
	  )
	fi
	 # TODO: There's no s390x USE_EXPAND yet
	 cmake_src_configure
}

src_install() {
	cmake_src_install
	 if use compat ; then
	  ewarn "zlib-ng is experimental and replacing the system zlib is dangerous"
	  ewarn "Please be careful!"
	  ewarn
	  ewarn "The following link explains the guarantees (and what is NOT guaranteed):"
	  ewarn "https://github.com/zlib-ng/zlib-ng/blob/2.0.x/PORTING.md"
	fi
}



# vim: filetype=ebuild
