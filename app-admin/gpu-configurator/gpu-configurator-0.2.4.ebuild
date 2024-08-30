# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Macaroni OS GPU Configurator"
HOMEPAGE="https://github.com/macaroni-os/gpu-configurator"
SRC_URI="https://github.com/macaroni-os/gpu-configurator/tarball/d68ef56e77c33c66227816cff4b5def2e0a4d0c3 -> gpu-configurator-0.2.4-d68ef56.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/go"
RDEPEND="
	sys-apps/kmod
	sys-apps/pciutils
"

post_src_unpack() {
	mv macaroni-os-${PN}-* ${S}
}

src_compile() {
	golang_ldflags=(
		"-X \"github.com/macaroni-os/gpu-configurator/pkg/converter.BuildTime=$(date -u '+%Y-%m-%d %I:%M:%S %Z')\""
		"-X github.com/macaroni-os/gpu-configurator/pkg/converter.BuildCommit=d68ef56e77c33c66227816cff4b5def2e0a4d0c3"
	)

	CGO_ENABLED=0 go build \
		-ldflags "${golang_ldflags[*]}" \
		-o ${PN} -v -x -mod=vendor . || die
}

src_install() {
	dobin "${PN}"
	dodoc README.md
}

# vim: filetype=ebuild