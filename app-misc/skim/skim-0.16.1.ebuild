# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/81799d1f6546210b26b5ebf06d1fd41c21a8f8c1 -> skim-0.16.1-81799d1.tar.gz
https://distfiles.macaronios.org/d6/99/f9/d699f99ae0469e6f0a2a82866fe44ececff3dc25ca1118b3add98ab4c93c9c98ceaaf30d2d6cbb336c6729aa8029024db7553a14bd981ff1874f5d5d6bb3ca59 -> skim-0.16.1-funtoo-crates-bundle-7d4c0051afada407048f13c448e2215ff53010dcacdcd91d1a8f6e7dc43ef1e155cd16ecf651a95cea8cf60395474abbc66cddc112b5299c5a5d3ef688314ef5.tar.gz"

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