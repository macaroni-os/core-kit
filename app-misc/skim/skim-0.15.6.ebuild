# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/422bd35a5781c55295ace334bcea1ceca2f26f14 -> skim-0.15.6-422bd35.tar.gz
https://distfiles.macaronios.org/7f/5f/ac/7f5facd277d3b2ab2854c22a65b77e031fad4a19ac385600c4994194bb32fd6938d17a0a2e9f20dea72e0bfc9662e12b74df0c33ec369e7f1ee3053877962964 -> skim-0.15.6-funtoo-crates-bundle-9162ebf67d23547064fe75b14779215c69785dea7ac8d95b60503992051372fdebd1b8f5719701c8fb6d338b098b4b9ebc493b64fb598d39bcae60afd6bf896f.tar.gz"

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