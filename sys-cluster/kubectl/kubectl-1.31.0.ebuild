# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/e73bd2e33f000c5a2886771e712d6c90796a4873 -> kubernetes-1.31.0-e73bd2e.tar.gz
https://distfiles.macaronios.org/49/27/37/492737db1fc16111e0953df5ee6a52a8ef5980da9e058841540ba23be1b31038a8af60ff983cba42695546962722043613ae0b2994cc0b9bdaa15fdf8ba3156e -> kubectl-1.31.0-funtoo-go-bundle-ac558c5ab09681140cc7252ff2c97c2d39994738b6782ce52f0678b2bae459a5ba2bc6a2d4c6d46ae59529c266226b3d05c445dd7c76e559307816ba907d1287.tar.gz"

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