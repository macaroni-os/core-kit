# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/ae2960b0af8dac5340594e7d37ef91487fd2b0e8 -> skim-0.18.0-ae2960b.tar.gz
https://distfiles.macaronios.org/f4/0d/56/f40d5642db2044627c07d9a17d6e14d7c16e37a61b43a75b33faefbe4438a87e7fbffba8ac3021b6027b521c1d06b61f9a64fb672eb72edb0165a756dae6bc31 -> skim-0.18.0-funtoo-crates-bundle-e988a615861a3d65e5c084062edd0829298ae1bb434979e12f23d08eb25e4ac412574406096516969a264c3e5049836a61183c4e6835bf3bda751ae543eaf73e.tar.gz"

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