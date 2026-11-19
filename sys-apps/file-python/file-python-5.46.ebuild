# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Python bindings for the libmagic library"
HOMEPAGE="https://www.darwinsys.com/file/"
SRC_URI="https://astron.com/pub/file/file-5.46.tar.gz -> file-5.46.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	~sys-apps/file-5.46
	
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	
"
S="${WORKDIR}/file-5.46/python"

# vim: filetype=ebuild
