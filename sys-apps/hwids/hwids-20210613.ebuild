# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit udev python-any-r1

DESCRIPTION="Hardware (PCI, USB, OUI, IAB) IDs databases"
HOMEPAGE="https://github.com/gentoo/hwids"
KEYWORDS="*"
SRC_URI="https://api.github.com/repos/gentoo/hwids/tarball/refs/tags/hwids-20210613 -> hwids-20210613.tar.gz"

LICENSE="|| ( GPL-2 BSD ) public-domain"
SLOT="0"
IUSE="+net +pci +udev +usb"

RDEPEND="
	udev? ( virtual/udev )
	!<sys-apps/pciutils-3.1.9-r2
	!<sys-apps/usbutils-005-r1
"

S="$WORKDIR/gentoo-${P}"

pkg_setup() {
	:
}

src_unpack() {
	unpack ${A}
	mv "$WORKDIR"/gentoo-hwids* "$S" || die
}

src_prepare() {
	default
	sed -i -e '/udevadm hwdb/d' Makefile || die
}

_emake() {
	emake \
		NET=$(usex net) \
		PCI=$(usex pci) \
		UDEV=$(usex udev) \
		USB=$(usex usb) \
		"$@"
}

src_install() {
	_emake install \
		DOCDIR="${EPREFIX}/usr/share/doc/${PF}" \
		MISCDIR="${EPREFIX}/usr/share/misc" \
		HWDBDIR="${EPREFIX}$(get_udevdir)/hwdb.d" \
		DESTDIR="${D}"
}

pkg_postinst() {
	if use udev; then
		udevadm hwdb --update --root="${ROOT}"
	fi
}