# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal usr-ldscript

DESCRIPTION="A cross-platform library to access USB devices "
HOMEPAGE="https://libusb.info/ https://github.com/libusb/libusb"
SRC_URI="https://github.com/libusb/libusb/tarball/d52e355daa09f17ce64819122cb067b8a2ee0d4b -> libusb-1.0.27-d52e355.tar.gz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="1"

IUSE="debug doc examples static-libs test udev"
RESTRICT="!test? ( test )"
REQUIRED_USE="static-libs? ( !udev )"

RDEPEND="udev? ( >=virtual/libudev-208:=[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	!udev? ( virtual/os-headers )"
BDEPEND="doc? ( app-doc/doxygen )"

post_src_unpack() {
	if [ ! -d "${S}" ] ; then
		mv libusb-libusb-* "${S}" || die
	fi
}

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable udev)
		$(use_enable debug debug-log)
		$(use_enable test tests-build)
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake

	if multilib_is_native_abi; then
		use doc && emake -C doc
	fi
}

multilib_src_test() {
	emake check

	# noinst_PROGRAMS from tests/Makefile.am
	if [[ -e /dev/bus/usb ]]; then
		tests/stress || die
	else
		# bug #824266
		ewarn "/dev/bus/usb does not exist, skipping stress test"
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install

	if multilib_is_native_abi; then
		gen_usr_ldscript -a usb-1.0

		use doc && dodoc -r doc/api-1.0
	fi
}

multilib_src_install_all() {
	find "${ED}" -type f -name "*.la" -delete || die

	dodoc AUTHORS ChangeLog NEWS PORTING README TODO

	if use examples; then
		docinto examples
		dodoc examples/*.{c,h}
	fi
}