# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Macaroni OS Build Package/Repository tool"
HOMEPAGE="https://github.com/geaaru/luet"
SRC_URI="https://github.com/geaaru/luet/tarball/c9c8eae0f1611a0a7a2cc24c45488550bb9a7382 -> luet-0.40.2-c9c8eae.tar.gz"

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
		"-X github.com/geaaru/luet/pkg/config.BuildCommit=c9c8eae0f1611a0a7a2cc24c45488550bb9a7382"
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