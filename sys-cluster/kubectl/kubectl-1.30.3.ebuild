# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/c5c736886799b46ed27c349a0c16f2b303473925 -> kubernetes-1.30.3-c5c7368.tar.gz
https://distfiles.macaronios.org/f9/ec/ac/f9ecac65bc5ad11761b7da6aaa107544f8101efba8f70439d0032f2737b76d6327eb7476bbb70db5e74f7c38dda30bf947652c9fa4ee8f7acf77780f900d5de1 -> kubectl-1.30.3-funtoo-go-bundle-e4097fe99bb07c17ceb0fcacff18323e9b75e0230d66ba95226eef08e89a91daa2a13cf2f1861b66d16c53b1aa6078a0ccf4b81ccaf013e689ca541826d3a361.tar.gz"

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