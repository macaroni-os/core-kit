# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

DESCRIPTION="Encrypted overlay filesystem written in Go"
HOMEPAGE="https://nuetzlich.net/gocryptfs https://github.com/rfjakob/gocryptfs/releases"

SRC_URI="https://github.com/rfjakob/gocryptfs/tarball/7d4fb1fd0667d1fed945a519de86919cb90f4edb -> gocryptfs-2.4.0-7d4fb1f.tar.gz
https://distfiles.macaronios.org/99/04/26/990426de0134b89de5f8a3f1c7ebf950c71fe19d4b7ea1d48f930d09fcd4b0e549c4153a7205a2024e455765f8261bb9a8610b5a065ebb68ca074fb5cd8d38a6 -> gocryptfs-2.4.0-funtoo-go-bundle-ec772957817fbb0ce5f170cf32cd78d77aade9b5eab92c16ddb66f301f1546c2a0e25e35f6506d58de0e254b7b440dd902eea217760614b4b285de9978a869e9.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"

SLOT="0"
KEYWORDS="*"
IUSE="debug +man pie +ssl"

BDEPEND="man? ( dev-go/go-md2man )"
RDEPEND="
	sys-fs/fuse
	ssl? ( dev-libs/openssl:0= )
"

S="${WORKDIR}/rfjakob-gocryptfs-7d4fb1f"

# We omit debug symbols which looks like pre-stripping to portage.
QA_PRESTRIPPED="
	/usr/bin/gocryptfs-atomicrename
	/usr/bin/gocryptfs-findholes
	/usr/bin/gocryptfs-statfs
	/usr/bin/gocryptfs-xray
	/usr/bin/gocryptfs
"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.GitVersion=v${PV}"
		-X "'main.GitVersionFuse=[vendored]'"
		-X "main.BuildDate=$(date -u '+%Y-%m-%d')"
	)

	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex !ssl 'without_openssl' 'none')"
	)

	go build "${mygoargs[@]}" || die

	# loop over all helper tools
	for dir in gocryptfs-xray contrib/statfs contrib/findholes contrib/atomicrename; do
		cd "${S}/${dir}" || die
		go build "${mygoargs[@]}" || die
	done

	cd "${S}"

	if use man; then
		go-md2man -in Documentation/MANPAGE.md -out gocryptfs.1 || die
		go-md2man -in Documentation/MANPAGE-STATFS.md -out gocryptfs-statfs.2 || die
		go-md2man -in Documentation/MANPAGE-XRAY.md -out gocryptfs-xray.1 || die
	fi
}

src_install() {
	dobin gocryptfs
	dobin gocryptfs-xray/gocryptfs-xray

	newbin contrib/statfs/statfs "${PN}-statfs"
	newbin contrib/findholes/findholes "${PN}-findholes"
	newbin contrib/atomicrename/atomicrename "${PN}-atomicrename"

	if use man; then
		doman gocryptfs.1
		doman gocryptfs-xray.1
		doman gocryptfs-statfs.2
	fi
}