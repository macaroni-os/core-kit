# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit autotools toolchain-funcs libtool flag-o-matic python-r1 multiprocessing

DESCRIPTION="Python bindings for the util-linux libmount library"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/util-linux/"
SRC_URI="https://api.github.com/repos/util-linux/util-linux/tarball/refs/tags/v2.42.4 -> util-linux-python-2.42.4-d76cbf8.tar.gz"
LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="*"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"
BDEPEND="virtual/pkgconfig
"
RDEPEND="${PYTHON_DEPS}
	~sys-apps/util-linux-2.42.4
	
"
DEPEND="${RDEPEND}
	virtual/os-headers
	
"

post_src_unpack() {
	mv util-linux-util-linux-* ${S}
}


src_prepare() {
	default
	./autogen.sh || die
	eautoreconf
}

python_configure() {
	local myeconfargs=(
	  --disable-all-programs
	  --disable-bash-completion
	  --without-systemdsystemunitdir
	  --with-python
	  --enable-libblkid
	  --enable-libmount
	  --enable-pylibmount
	)
	mkdir "${BUILD_DIR}" || die
	pushd "${BUILD_DIR}" >/dev/null || die
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
	popd >/dev/null || die
}

python_compile() {
	pushd "${BUILD_DIR}" >/dev/null || die
	emake
	popd >/dev/null || die
}

python_install() {
	pushd "${BUILD_DIR}" >/dev/null || die
	emake DESTDIR="${D}" \
	  install-pylibmountexecLTLIBRARIES \
	  install-pylibmountexecPYTHON
	python_optimize
	popd >/dev/null || die
}

src_configure() {
	python_foreach_impl python_configure
}

src_compile() {
	python_foreach_impl python_compile
}

src_install() {
	python_foreach_impl python_install
	# The automake python install target pulls in the libmount and
	# libblkid install targets; those libraries belong to util-linux.
	find "${ED}"/usr/$(get_libdir) -maxdepth 1 \( -name 'libblkid.*' -o -name 'libmount.*' \) -delete || die
	find "${ED}" -name "*.la" -delete || die
}



# vim: filetype=ebuild
