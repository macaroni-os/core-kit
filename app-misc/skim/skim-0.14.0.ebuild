# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/68f1c408ce4fec142363ed2b031ad1e7a38ed8a7 -> skim-0.14.0-68f1c40.tar.gz
https://distfiles.macaronios.org/1f/66/7e/1f667ef4e019a26a88eb49896972f736aefe4372cb3f75b6995d2f04e4d82cafc973f992cc194018f40da8e181869a657b6fe282af9c14f502f4d9a0315c6a18 -> skim-0.14.0-funtoo-crates-bundle-12cd8e2bfb275164c35f44802d0336216349ac67199d3b1edfbc5128e2245f4fb5fb1663fb1e602254591c6d5ed945f01f1b9cd7325b5c685c3a3f19c4289366.tar.gz"

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