# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 go-module

go-module_set_globals

DESCRIPTION="Docker CLI plugin for extended build capabilities with BuildKit"
HOMEPAGE="https://github.com/docker/buildx"
SRC_URI="https://github.com/docker/buildx/tarball/9872040b6626fb7d87ef7296fd5b832e8cc2ad17 -> buildx-0.11.2-9872040.tar.gz
https://distfiles.macaronios.org/d6/b3/59/d6b359db7e34d9099f5a8c32e9c49c2f7e548181e94ffc59b0b6497e964af74dea371d0bb99b0220d19cc4c28b18550c4a864dc7c95bfe667ec109ba3c5538f7 -> docker-buildx-0.11.2-funtoo-go-bundle-b4b2ef08adf1fa13b5ca06a175cde88a306cfa61664d26fd9b8c77760ad9b26abf77fdf25f4e628c6ebc7c5fad874aca29d6a1dc55a8e0626fd6df9bcb4e05fd.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="*"

RDEPEND=">=app-emulation/docker-cli-23.0.0"

RESTRICT="test"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv docker-buildx* "${S}" || die
	fi
}

src_prepare() {
	default
	# do not strip
	sed -i -e 's/-s -w//' Makefile || die
}

src_compile() {
	local _buildx_r='github.com/docker/buildx'
	go build -o docker-buildx \
		-ldflags "-linkmode=external
		-X $_buildx_r/version.Version=0.11.2
		-X $_buildx_r/version.Revision=9872040b6626fb7d87ef7296fd5b832e8cc2ad17
		-X $_buildx_r/version.Package=$_buildx_r" \
		./cmd/buildx
}

src_test() {
	emake test
}

src_install() {
	exeinto /usr/libexec/docker/cli-plugins
	doexe docker-buildx
	dodoc README.md
}