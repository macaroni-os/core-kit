# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2+ )
DISTUTILS_OPTIONAL=1

inherit distutils-r1 libtool toolchain-funcs multilib-minimal

SRC_URI="http://ftp.astron.com/pub/file/file-5.40.tar.gz"
KEYWORDS="*"

DESCRIPTION="Identify a file's format by scanning binary data for patterns"
HOMEPAGE="https://www.darwinsys.com/file/"

LICENSE="BSD-2"
SLOT="0"
IUSE="bzip2 lzma python seccomp static-libs zlib"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	bzip2? ( app-arch/bzip2[${MULTILIB_USEDEP}] )
	lzma? ( app-arch/xz-utils[${MULTILIB_USEDEP}] )
	python? (
		${PYTHON_DEPS}
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )"
RDEPEND="${DEPEND}
	python? ( !dev-python/python-magic )
	seccomp? ( sys-libs/libseccomp[${MULTILIB_USEDEP}] )"
BDEPEND="sys-apps/grep"

src_prepare() {
	# Bug 728978
	if ! $(grep getcwd src/seccomp.c) ; then
		sed -i -e "/ALLOW_RULE(writev)/s@\$@\n\tALLOW_RULE(getcwd);\t// Used by Gentoo's portage sandbox@" \
			src/seccomp.c || die
	fi
	# Bug 784857
	if ! $(grep fstatat64 src/seccomp.c) ; then
		sed -i -e "/ALLOW_RULE(fstat64)/s@\$@\n#ifdef __NR_fstatat64\n\tALLOW_RULE(fstatat64);\n#endif@" \
			src/seccomp.c || die
	fi
	# ARM64 new emulated access() syscall
	if ! $(grep faccessat src/seccomp.c) ; then
		sed -i -e "/ALLOW_RULE(exit_group)/s@\$@\n#ifdef __NR_faccessat\n\tALLOW_RULE(faccessat);\n#endif@" \
			src/seccomp.c || die
	fi
	default
	elibtoolize

	# don't let python README kill main README #60043
	mv python/README.md python/README.python.md || die
	sed 's@README.md@README.python.md@' -i python/setup.py || die #662090
}

multilib_src_configure() {
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

build_src_configure() {
	local myeconfargs=(
		--disable-shared
		--disable-libseccomp
		--disable-bzlib
		--disable-xzlib
		--disable-zlib
	)
	tc-env_build econf "${myeconfargs[@]}"
}

need_build_file() {
	# when cross-compiling, we need to build up our own file
	# because people often don't keep matching host/target
	# file versions #362941
	tc-is-cross-compiler && ! has_version -b "~${CATEGORY}/${P}"
}

src_configure() {
	local ECONF_SOURCE="${S}"

	if need_build_file ; then
		mkdir -p "${WORKDIR}"/build || die
		cd "${WORKDIR}"/build || die
		build_src_configure
	fi

	multilib-minimal_src_configure
}

multilib_src_compile() {
	if multilib_is_native_abi ; then
		emake
	else
		cd src || die
		emake magic.h #586444
		emake libmagic.la
	fi
}

src_compile() {
	if need_build_file ; then
		emake -C "${WORKDIR}"/build/src magic.h #586444
		emake -C "${WORKDIR}"/build/src file
		local -x PATH="${WORKDIR}/build/src:${PATH}"
	fi
	multilib-minimal_src_compile

	if use python ; then
		cd python || die
		distutils-r1_src_compile
	fi
}

multilib_src_install() {
	if multilib_is_native_abi ; then
		default
	else
		emake -C src install-{nodist_includeHEADERS,libLTLIBRARIES} DESTDIR="${D}"
	fi
}

multilib_src_install_all() {
	dodoc ChangeLog MAINT README

	# Required for `file -C`
	insinto /usr/share/misc/magic
	doins -r magic/Magdir/*

	if use python ; then
		cd python || die
		distutils-r1_src_install
	fi
	find "${ED}" -type f -name "*.la" -delete || die
}