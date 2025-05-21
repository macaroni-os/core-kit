# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/f2ffa801c7eb82a88ef79ddcf5f959e21b1ce9df -> skim-0.17.3-f2ffa80.tar.gz
https://distfiles.macaronios.org/43/d8/aa/43d8aab2154ee330f44340cc7436eb7f593dbf87cf92f4c65ec0761f010fbf86de2a8d74fef2703ecbaca4e6ad18e41470285ff60c36c59e827269384547c8c0 -> skim-0.17.3-funtoo-crates-bundle-1bb9ae54fc944323244c120183393198af6e9a77a4275b616219b7d2d9998f38a5b5aa70e16555686b1e518e8b7aea01a790773f264db407458d061da6063fb8.tar.gz"

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