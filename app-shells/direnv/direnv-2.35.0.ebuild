# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/!burnt!sushi/toml v1.4.0"
	"github.com/!burnt!sushi/toml v1.4.0/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"golang.org/x/mod v0.19.0"
	"golang.org/x/mod v0.19.0/go.mod"
	"golang.org/x/sys v0.6.0"
	"golang.org/x/sys v0.6.0/go.mod"
)

go-module_set_globals

DESCRIPTION="Direnv is an environment switcher for the shell"
HOMEPAGE="https://direnv.net"
SRC_URI="https://github.com/direnv/direnv/tarball/978008aa7c66e5beb3e3c4a7705c3d0ce4f99f1c -> direnv-2.35.0-978008a.tar.gz
https://distfiles.macaronios.org/8f/29/57/8f295700a39a6871faee35373a930665d58605e3c9988b44b1da394779ad8df893bbe2ad3c727b8896a9887c009e14398d25e911df81387f0dd9c7c33d15de6e -> direnv-2.35.0-funtoo-go-bundle-472c0a10be6464f6a7b2cf2038e0baafb077896cb6c32db15ac4c594776bfc838f976aa907e6f9a8e8f0b5f66ad955a4a42659b8f38ccff925511b01888a1658.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/go"

# depends on golangci-lint which we do not have an ebuild for
RESTRICT="test"

post_src_unpack() {
	mv "${WORKDIR}"/direnv-direnv-* "${S}" || die
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
	einstalldocs
}