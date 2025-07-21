# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
inherit autotools flag-o-matic python-r1

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="https://people.redhat.com/sgrubb/libcap-ng/"
SRC_URI="https://people.redhat.com/sgrubb/libcap-ng/libcap-ng-0.8.5.tar.gz -> libcap-ng-0.8.5.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="python static-libs"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	python? ( dev-lang/swig )
	
"
RDEPEND="python? ( ${PYTHON_DEPS} )
	
"
src_prepare() {
	# Apply patch from upstream
	sed -i -e '/^PYTHON = $(PYTHON)/d' bindings/python3/Makefile.am || die
	default
	eautoreconf
}
src_configure() {
	use sparc && replace-flags -O? -O0
	local ECONF_SOURCE="${S}"
	local myconf=(
	  $(use_enable static-libs static)
	  --with-capability_header="${ESYSROOT}"/usr/include/linux/capability.h
	)
	local pythonconf=( --without-python3 )
	if use python ; then
	  setup_python_flags_configure() {
	    pythonconf=( --with-python3 )
	    run_in_build_dir econf "${pythonconf[@]}" "${myconf[@]}"
	  }
	  python_foreach_impl setup_python_flags_configure
	else
	  local BUILD_DIR=${WORKDIR}/build
	  run_in_build_dir econf "${pythonconf[@]}" "${myconf[@]}"
	fi
}
src_compile() {
	if use python; then
	  python_foreach_impl run_in_build_dir emake
	else
	  local BUILD_DIR=${WORKDIR}/build
	  emake -C "${BUILD_DIR}"
	fi
}
src_install() {
	if use python; then
	  python_foreach_impl run_in_build_dir emake DESTDIR="${D}" install
	else
	  local BUILD_DIR=${WORKDIR}/build
	  emake -C "${BUILD_DIR}" DESTDIR="${D}" install
	fi
	find "${ED}" -name '*.la' -delete || die
}


# vim: filetype=ebuild
