# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_SETUPTOOLS="rdepend"

inherit bash-completion-r1 distutils-r1 toolchain-funcs

DESCRIPTION=""
HOMEPAGE="https://mesonbuild.com/"
SRC_URI="https://github.com/mesonbuild/meson/tarball/082917b40c8416bde925c64d22a2e60b2c059120 -> meson-1.7.2-082917b.tar.gz"
LICENSE="Apache-2.0"

KEYWORDS="*"

SLOT="0"

S="${WORKDIR}/mesonbuild-meson-082917b"

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}
	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson
}