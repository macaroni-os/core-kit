# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Funtoo's networking scripts."
HOMEPAGE="http://www.funtoo.org/Networking"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

SRC_URI="https://github.com/funtoo/corenetwork/tarball/87aff581398eba1f63bc38a3ea1dfac61eb34191 -> corenetwork-1.8.0-87aff58.tar.gz"

RDEPEND="sys-apps/openrc !<=sys-apps/openrc-0.12.4-r4"

S="${WORKDIR}/funtoo-corenetwork-87aff58"

#src_unpack() {
#	unpack $A
#	local old="${WORKDIR}/${GITHUB_USER}-corenetwork-*"
#	mv $old "${WORKDIR}/corenetwork-${PV}" || die
#}

src_install() {
	exeinto /etc/init.d || die
	doexe init.d/{netif.tmpl,net.lo} || die
	cp -a netif.d ${D}/etc || die
	chown -R root:root ${D}/etc/netif.d || die
	chmod 0755 ${D}/etc/netif.d || die
	chmod -R 0644 ${D}/etc/netif.d/* || die
}
# vim: syn=ebuild noet: