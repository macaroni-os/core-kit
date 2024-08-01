# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/c6d6ca4afd0a1358e77da966931fc2e50213a2cd -> procs-0.14.6-c6d6ca4.tar.gz
https://distfiles.macaronios.org/c5/84/da/c584dabba822585f7ffb0c19667d99df99393236f089ae8bc991ae06e38e528e7805ff0b3a53ddef58f3074848b15afd1fa7726950cc06ac533b8e2af09a0f6a -> procs-0.14.6-funtoo-crates-bundle-025ce06dfb896ee482744477f1ed3445e32f3b2829a89c85561dec6964881b7a2e63798e6261fb0f0c3158270654effac6bbebb5d0a763783e89833669e70723.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 MIT ZLIB"
SLOT="0"
KEYWORDS="*"

BDEPEND="virtual/rust"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/dalance-procs-* ${S} || die
}

src_install() {
	# Avoid calling doman from eclass. It fails.
	rm -rf ${S}/man
	cargo_src_install
	dodoc README.md
}