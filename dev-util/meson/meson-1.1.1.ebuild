# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_SETUPTOOLS="rdepend"

inherit bash-completion-r1 distutils-r1 toolchain-funcs

SRC_URI="https://github.com/mesonbuild/meson/tarball/0266440992769d39266e600a310871fbbb276fdd -> meson-1.1.1-0266440.tar.gz"
KEYWORDS="*"

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"

LICENSE="Apache-2.0"
SLOT="0"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/mesonbuild-* "${S}"
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}
	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson
}