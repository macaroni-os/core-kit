# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"al.essio.dev/pkg/shellescape v1.5.1"
	"al.essio.dev/pkg/shellescape v1.5.1/go.mod"
	"github.com/!burnt!sushi/toml v1.4.0"
	"github.com/!burnt!sushi/toml v1.4.0/go.mod"
	"github.com/cpuguy83/go-md2man/v2 v2.0.3/go.mod"
	"github.com/creack/pty v1.1.9/go.mod"
	"github.com/evanphx/json-patch/v5 v5.6.0"
	"github.com/evanphx/json-patch/v5 v5.6.0/go.mod"
	"github.com/google/go-cmp v0.5.9"
	"github.com/google/go-cmp v0.5.9/go.mod"
	"github.com/google/shlex v0.0.0-20191202100458-e7afc7fbc510"
	"github.com/google/shlex v0.0.0-20191202100458-e7afc7fbc510/go.mod"
	"github.com/inconshreveable/mousetrap v1.1.0"
	"github.com/inconshreveable/mousetrap v1.1.0/go.mod"
	"github.com/jessevdk/go-flags v1.4.0/go.mod"
	"github.com/kr/pty v1.1.1/go.mod"
	"github.com/kr/text v0.1.0/go.mod"
	"github.com/kr/text v0.2.0"
	"github.com/kr/text v0.2.0/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"github.com/niemeyer/pretty v0.0.0-20200227124842-a10e7caefd8e"
	"github.com/niemeyer/pretty v0.0.0-20200227124842-a10e7caefd8e/go.mod"
	"github.com/pelletier/go-toml v1.9.5"
	"github.com/pelletier/go-toml v1.9.5/go.mod"
	"github.com/pkg/errors v0.8.1/go.mod"
	"github.com/pkg/errors v0.9.1"
	"github.com/pkg/errors v0.9.1/go.mod"
	"github.com/russross/blackfriday/v2 v2.1.0/go.mod"
	"github.com/spf13/cobra v1.8.0"
	"github.com/spf13/cobra v1.8.0/go.mod"
	"github.com/spf13/pflag v1.0.5"
	"github.com/spf13/pflag v1.0.5/go.mod"
	"golang.org/x/sys v0.6.0"
	"golang.org/x/sys v0.6.0/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/check.v1 v1.0.0-20200902074654-038fdea0a05b"
	"gopkg.in/check.v1 v1.0.0-20200902074654-038fdea0a05b/go.mod"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
	"sigs.k8s.io/yaml v1.4.0"
	"sigs.k8s.io/yaml v1.4.0/go.mod"
)

go-module_set_globals

SRC_URI="https://github.com/kubernetes-sigs/kind/tarball/200b3aac0b5ff698426715db9b4d13288bd470a3 -> kind-0.29.0-200b3aa.tar.gz
https://distfiles.macaronios.org/f6/f9/f9/f6f9f994e66ccbdd9eedbdf5568f27effc3cffcd7cf3919a1409ae254a0bb07484b661db35b54cf2fb3e27e0a0f5146924d40f48b220219dbdb4c281c2239fdf -> kind-0.29.0-funtoo-go-bundle-8bde5768ecf7f89c94f35066a56be015332fc27f270a621d444db1df901ddf3900af01dd08a0130014e06f84358a7eb2fc0594cf5e9bfde0a021e27495cec5bf.tar.gz"

DESCRIPTION="Tool for running local Kubernetes clusters using Docker container nodes"
HOMEPAGE="https://kind.sigs.k8s.io/ https://github.com/kubernetes-sigs/kind"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="hardened"

BDEPEND="dev-lang/go"
RDEPEND="app-emulation/docker"

post_src_unpack() {
	mv "${WORKDIR}"/kubernetes-sigs-kind-* "${S}" || die
}

src_compile() {
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
		emake -j1 GOFLAGS="" GOLDFLAGS="" LDFLAGS="" WHAT=cmd/${PN}
}

src_install() {
	dobin bin/${PN}
	dodoc README.md
}