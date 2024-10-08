# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic linux-info pam

MY_PN=${PN/-utils//}
DESCRIPTION="eCryptfs userspace utilities"
HOMEPAGE="https://www.ecryptfs.org/"
SRC_URI="https://bazaar.launchpad.net/~ecryptfs/ecryptfs/trunk/tarball/894 -> ${P}.tgz"
S="${WORKDIR}/~${MY_PN}/${MY_PN}/trunk/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc gpg gtk nls openssl pam pkcs11 suid tpm"

BDEPEND="
	>=dev-util/intltool-0.41.0
	sys-devel/gettext
	virtual/pkgconfig
"
RDEPEND="
	>=dev-libs/libgcrypt-1.2.0:0=
	dev-libs/nss
	>=sys-apps/keyutils-1.5.11-r1:=
	sys-process/lsof
	gpg? ( app-crypt/gpgme:= )
	gtk? ( x11-libs/gtk+:2 )
	openssl? ( >=dev-libs/openssl-0.9.7:= )
	pam? ( sys-libs/pam )
	pkcs11? (
		>=dev-libs/openssl-0.9.7:=
		>=dev-libs/pkcs11-helper-1.04
	)
	tpm? ( app-crypt/trousers )"
DEPEND="
	${RDEPEND}
	dev-libs/glib:2
"

PATCHES=(
	"${FILESDIR}/${PN}-111-musl-fix.patch"
)

pkg_setup() {
	CONFIG_CHECK="~ECRYPT_FS"
	linux-info_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-cppflags -D_FILE_OFFSET_BITS=64

	econf \
		--enable-nss \
		--with-pamdir=$(getpam_mod_dir) \
		--disable-pywrap \
		$(use_enable doc docs) \
		$(use_enable gpg) \
		$(use_enable gtk gui) \
		$(use_enable nls) \
		$(use_enable openssl) \
		$(use_enable pam) \
		$(use_enable pkcs11 pkcs11-helper) \
		$(use_enable tpm tspi)
}

src_install() {
	emake DESTDIR="${D}" install

	use suid && fperms u+s /sbin/mount.ecryptfs_private

	find "${ED}" -name '*.la' -exec rm -f '{}' + || die
}

pkg_postinst() {
	if use suid; then
		ewarn
		ewarn "You have chosen to install ${PN} with the binary setuid root. This"
		ewarn "means that if there are any undetected vulnerabilities in the binary,"
		ewarn "then local users may be able to gain root access on your machine."
		ewarn
	fi
}
