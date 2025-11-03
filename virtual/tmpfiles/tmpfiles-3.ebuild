# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual to select between different tmpfiles.d handlers"
SLOT="0"
KEYWORDS="*"
IUSE="systemd"
RDEPEND="!systemd? ( sys-apps/systemd-tmpfiles )
	systemd? ( sys-apps/systemd )
	
"

# vim: filetype=ebuild
