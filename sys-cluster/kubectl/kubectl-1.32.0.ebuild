# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/7e247d1acd3bd293fd854a8e4a408e4af010af32 -> kubernetes-1.32.0-7e247d1.tar.gz
https://distfiles.macaronios.org/8a/1e/26/8a1e264a24a699e6f76ed312f9f6d293dc96229e5d22f6ef366b52a9e6834f0aa2a6f004864c648d089d5a1560687e0f685265981e43816f22d8650bc0c8da50 -> kubectl-1.32.0-funtoo-go-bundle-1e20fe74154df09d45b50d0723a6453a732c7d74c19a38d8d2e6f297990b4999b5759abc26f092f73ee70c4d7126c7505883c99693dc8fb039254582bdf1fd27.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="hardened"

DEPEND="!sys-cluster/kubernetes"
BDEPEND=">=dev-lang/go-1.21"

RESTRICT+=" test"

src_unpack() {
	default
	rm -rf ${S}
	mv ${WORKDIR}/kubernetes-kubernetes-* ${S} || die
}

src_compile() {
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
	FORCE_HOST_GO=yes \
		emake -j1 GOFLAGS="" GOLDFLAGS="" LDFLAGS="" WHAT=cmd/${PN}
}

src_install() {
	dobin _output/bin/${PN}
	_output/bin/${PN} completion bash > ${PN}.bash || die
	_output/bin/${PN} completion zsh > ${PN}.zsh || die
	newbashcomp ${PN}.bash ${PN}
	insinto /usr/share/zsh/site-functions
	newins ${PN}.zsh _${PN}
}