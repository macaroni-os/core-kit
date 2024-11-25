# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/skim-rs/skim"
SRC_URI="https://github.com/skim-rs/skim/tarball/ad909c379fef1e4818fba85d852d533e4e441dac -> skim-0.13.0-ad909c3.tar.gz
https://distfiles.macaronios.org/f3/27/a6/f327a64042989ab7d806708b9d1825ce8b291a4282b9072045d5fc3117eaf70769381c34cb02eced9fa33159798450efe140e70d2871e48a8492da0d301f654f -> skim-0.13.0-funtoo-crates-bundle-631a7b148db0af9b8784affbcf9a57fe77de9a20ac7a0892b714870be53531bdc67852bbb96ac7613b881129a2a6fb43f90c9311def5b56976f3613e96d25883.tar.gz"

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