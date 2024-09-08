# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Macaroni OS Build Package/Repository tool"
HOMEPAGE="https://github.com/geaaru/luet"
SRC_URI="https://github.com/geaaru/luet/tarball/2c2a917ec9029a69bb485eb5b3f0bab05e5dd59f -> luet-0.41.0-2c2a917.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/go"

post_src_unpack() {
	mv geaaru-luet-* ${S}
}

src_compile() {
	anise_ldflags=(
		"-X \"github.com/geaaru/luet/pkg/config.BuildTime=$(date -u '+%Y-%m-%d %I:%M:%S %Z')\""
		"-X github.com/geaaru/luet/pkg/config.BuildCommit=2c2a917ec9029a69bb485eb5b3f0bab05e5dd59f"
		"-X github.com/geaaru/luet/pkg/config.BuildGoVersion=$(go env GOVERSION)"
	)

	CGO_ENABLED=0 go build \
		-ldflags "${anise_ldflags[*]}" \
		-o luet-build/${PN} -v -x -mod=vendor ./luet-build/ || die
}

src_install() {
	dobin luet-build/${PN}
	dosym /usr/bin/${PN} /usr/bin/luet-build
	dodoc README.md
}

# vim: filetype=ebuild