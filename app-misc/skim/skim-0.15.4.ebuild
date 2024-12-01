# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/17c261af1cc0e81ebfb5b8a85fc03ffedd9de440 -> skim-0.15.4-17c261a.tar.gz
https://distfiles.macaronios.org/98/22/74/9822745dd0b87e73e14a65a714a6ed63102fe2e6ec707b243d0cee3a920a0eac6c9109d5372b6f3c6f7569598a1037a300539d218167367dbeeda9c5842e6f4c -> skim-0.15.4-funtoo-crates-bundle-ddbfbd2c058b4c5d1bebcbf53ad1914373a7d7b7a05bd0307a3c34bb3b775477bdf06a9f1ab02429e248f92525de6868060105752c6285943248c6bf8b6fc49e.tar.gz"

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
	mv ${WORKDIR}/skim-rs-skim-* ${S} || die
}

src_install() {
	# prevent cargo_src_install() blowing up on man installation
	mv man manpages || die

	cargo_src_install --path skim
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