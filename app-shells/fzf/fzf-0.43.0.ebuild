# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 go-module

DESCRIPTION="A general-purpose command-line fuzzy finder, written in GoLang"
HOMEPAGE="https://github.com/junegunn/fzf"

EGO_SUM=(
	"github.com/gdamore/encoding v1.0.0"
	"github.com/gdamore/encoding v1.0.0/go.mod"
	"github.com/gdamore/tcell/v2 v2.5.4"
	"github.com/gdamore/tcell/v2 v2.5.4/go.mod"
	"github.com/lucasb-eyer/go-colorful v1.2.0"
	"github.com/lucasb-eyer/go-colorful v1.2.0/go.mod"
	"github.com/mattn/go-isatty v0.0.17"
	"github.com/mattn/go-isatty v0.0.17/go.mod"
	"github.com/mattn/go-runewidth v0.0.14"
	"github.com/mattn/go-runewidth v0.0.14/go.mod"
	"github.com/mattn/go-shellwords v1.0.12"
	"github.com/mattn/go-shellwords v1.0.12/go.mod"
	"github.com/rivo/uniseg v0.2.0/go.mod"
	"github.com/rivo/uniseg v0.4.4"
	"github.com/rivo/uniseg v0.4.4/go.mod"
	"github.com/saracen/walker v0.1.3"
	"github.com/saracen/walker v0.1.3/go.mod"
	"github.com/yuin/goldmark v1.4.13/go.mod"
	"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
	"golang.org/x/crypto v0.0.0-20210921155107-089bfa567519/go.mod"
	"golang.org/x/mod v0.6.0-dev.0.20220419223038-86c51ed26bb4/go.mod"
	"golang.org/x/net v0.0.0-20190620200207-3b0461eec859/go.mod"
	"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110/go.mod"
	"golang.org/x/net v0.0.0-20220722155237-a158d28d115b/go.mod"
	"golang.org/x/sync v0.0.0-20190423024810-112230192c58/go.mod"
	"golang.org/x/sync v0.0.0-20220601150217-0de741cfad7f/go.mod"
	"golang.org/x/sync v0.0.0-20220722155255-886fb9371eb4"
	"golang.org/x/sync v0.0.0-20220722155255-886fb9371eb4/go.mod"
	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
	"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod"
	"golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1/go.mod"
	"golang.org/x/sys v0.0.0-20220520151302-bc2c85ada10a/go.mod"
	"golang.org/x/sys v0.0.0-20220722155257-8c9f86f7a55f/go.mod"
	"golang.org/x/sys v0.0.0-20220811171246-fbc7d0a398ab/go.mod"
	"golang.org/x/sys v0.13.0"
	"golang.org/x/sys v0.13.0/go.mod"
	"golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod"
	"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211/go.mod"
	"golang.org/x/term v0.13.0"
	"golang.org/x/term v0.13.0/go.mod"
	"golang.org/x/text v0.3.0/go.mod"
	"golang.org/x/text v0.3.3/go.mod"
	"golang.org/x/text v0.3.7/go.mod"
	"golang.org/x/text v0.5.0"
	"golang.org/x/text v0.5.0/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	"golang.org/x/tools v0.0.0-20191119224855-298f0cb1881e/go.mod"
	"golang.org/x/tools v0.1.12/go.mod"
	"golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7/go.mod"
)

go-module_set_globals

SRC_URI="https://github.com/junegunn/fzf/tarball/d5959d240f19b698aa728c11535abd2a66ab5248 -> fzf-0.43.0-d5959d2.tar.gz
https://direct.funtoo.org/17/79/3c/17793ca8d06a1e8e2f7f398f2376b9e2dc2685d5d6fe0ee7ff60d1046c3175602c939b88788841776e39af966b839b11319db7c273ec40c49c6abd494e9fc5a1 -> fzf-0.43.0-funtoo-go-bundle-25ef8f527545fc4dac9629087034ba1648e0a0436be44ffa0ac765020cb205e1b5353a9b6e97c6fb3e7e9e3ab4bcbdd4c65a05b63a7df6e433bf9c2e37aca4c9.tar.gz"

LICENSE="MIT BSD-with-disclosure"
SLOT="0"
KEYWORDS="*"

post_src_unpack() {
	mv ${WORKDIR}/junegunn* ${S} || die
}

src_compile() {
	emake PREFIX=${EPREFIX}/usr FZF_VERSION=${PV} FZF_REVISION=tarball bin/${PN}
}

src_install() {
	dobin bin/${PN}
	doman man/man1/${PN}.1

	dobin bin/${PN}-tmux
	doman man/man1/${PN}-tmux.1

	insinto /usr/share/vim/vimfiles/plugin
	doins plugin/${PN}.vim

	insinto /usr/share/nvim/runtime/plugin
	doins plugin/${PN}.vim

	newbashcomp shell/completion.bash ${PN} || die

	insinto /usr/share/zsh/site-functions
	newins shell/completion.zsh _${PN}

	insinto /usr/share/fzf
	doins shell/key-bindings.bash
	doins shell/key-bindings.fish
	doins shell/key-bindings.zsh
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		elog "To add fzf support to your shell, make sure to use the right file"
		elog "from /usr/share/fzf."
		elog
		elog "For bash, add the following line to ~/.bashrc:"
		elog
		elog "	# source /usr/share/fzf/key-bindings.bash"
		elog
		elog "Or create a symlink:"
		elog
		elog "	# ln -s /usr/share/fzf/key-bindings.bash /etc/bash/bashrc.d/fzf.bash"
		elog
		elog "Plugins for Vim and Neovim are installed to respective directories"
		elog "and will work out of the box."
		elog
		elog "For fzf support in tmux see fzf-tmux(1)."
	fi
}