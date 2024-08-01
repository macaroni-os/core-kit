# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/db9f194c12486343ae23b37781123ff0dbfaaf16 -> skim-0.10.4-db9f194.tar.gz
https://distfiles.macaronios.org/c6/99/38/c69938b3ca5f70c0aa2943136c20e80687d1d608804ef311bb1e6a7d5d735d6eee9a08408a7e266d5a93e281a47e6bea8a99dc51984b5f4f8ff00cd8a47c8401 -> skim-0.10.4-funtoo-crates-bundle-febeeb2544aa30e665d1115b72b3ee69005605d0f2c7ccbabbf83de37301dc95e9e7694e7e57d3779e5585f951707cf82d52d37c2056890813265f7976c22e27.tar.gz"

LICENSE="Apache-2.0 MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="*"
IUSE="tmux vim"

RDEPEND="
	tmux? ( app-misc/tmux )
	vim? ( || ( app-editors/vim app-editors/gvim ) )
"
BDEPEND="virtual/rust"

QA_FLAGS_IGNORED="usr/bin/sk"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/lotabout-skim-* ${S} || die
}

src_install() {
	# prevent cargo_src_install() blowing up on man installation
	mv man manpages || die

	cargo_src_install
	dodoc CHANGELOG.md README.md
	doman manpages/man1/*

	use tmux && dobin bin/sk-tmux

	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin
		doins plugin/skim.vim
	fi

	# install bash/zsh completion and keybindings
	# since provided completions override a lot of commands, install to /usr/share
	insinto /usr/share/${PN}
	doins shell/{*.bash,*.zsh}
}