# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
ahash-0.7.6
aho-corasick-0.7.18
ansi_term-0.12.1
anyhow-1.0.58
async-broadcast-0.4.0
async-channel-1.6.1
async-executor-1.4.1
async-io-1.7.0
async-lock-2.5.0
async-recursion-0.3.2
async-task-4.2.0
async-trait-0.1.56
atty-0.2.14
autocfg-1.1.0
base64-0.13.0
bitflags-1.3.2
block-0.1.6
block-buffer-0.7.3
block-buffer-0.9.0
block-buffer-0.10.2
block-padding-0.1.5
byte-tools-0.3.1
byteorder-1.4.3
bytes-1.1.0
bytesize-1.1.0
cache-padded-1.2.0
cc-1.0.73
cfg-if-0.1.10
cfg-if-1.0.0
chrono-0.4.19
clap-3.2.6
clap_complete-3.2.2
clap_derive-3.2.6
clap_lex-0.2.3
combine-4.6.4
concurrent-queue-1.2.2
const_format-0.2.25
const_format_proc_macros-0.2.22
core-foundation-0.7.0
core-foundation-sys-0.7.0
cpufeatures-0.2.2
crossbeam-channel-0.5.5
crossbeam-deque-0.8.1
crossbeam-epoch-0.9.9
crossbeam-utils-0.8.10
crypto-common-0.1.3
deelevate-0.2.0
derivative-2.2.0
difflib-0.4.0
digest-0.8.1
digest-0.9.0
digest-0.10.3
dirs-2.0.2
dirs-4.0.0
dirs-next-2.0.0
dirs-sys-0.3.7
dirs-sys-next-0.1.2
dlv-list-0.3.0
downcast-0.11.0
dunce-1.0.2
dyn-clone-1.0.6
easy-parallel-3.2.0
either-1.6.1
enumflags2-0.7.5
enumflags2_derive-0.7.4
errno-0.2.8
errno-dragonfly-0.1.2
event-listener-2.5.2
fake-simd-0.1.2
fastrand-1.7.0
filedescriptor-0.8.2
float-cmp-0.9.0
fnv-1.0.7
form_urlencoded-1.0.1
fragile-1.2.1
futures-core-0.3.21
futures-io-0.3.21
futures-lite-1.12.0
futures-sink-0.3.21
futures-task-0.3.21
futures-util-0.3.21
generic-array-0.12.4
generic-array-0.14.5
gethostname-0.2.3
getrandom-0.1.16
getrandom-0.2.7
git2-0.14.4
guess_host_triple-0.1.3
hashbrown-0.12.1
heck-0.3.3
heck-0.4.0
hermit-abi-0.1.19
hex-0.4.3
home-0.5.3
idna-0.2.3
indexmap-1.9.1
instant-0.1.12
is_debug-1.0.1
itertools-0.10.3
itoa-1.0.2
jobserver-0.1.24
lazy_static-1.4.0
lazycell-1.3.0
libc-0.2.126
libgit2-sys-0.13.4+1.4.2
libz-sys-1.1.8
linked-hash-map-0.5.6
local_ipaddress-0.1.3
lock_api-0.4.7
log-0.4.17
mac-notification-sys-0.5.2
mach-0.3.2
malloc_buf-0.0.6
maplit-1.0.2
matches-0.1.9
memchr-2.5.0
memmem-0.1.1
memoffset-0.6.5
minimal-lexical-0.2.1
mockall-0.11.1
mockall_derive-0.11.1
nix-0.23.1
nix-0.24.1
nom-5.1.2
nom-7.1.1
normalize-line-endings-0.3.0
notify-rust-4.5.8
num-derive-0.3.3
num-integer-0.1.45
num-traits-0.2.15
num_cpus-1.13.1
num_threads-0.1.6
objc-0.2.7
objc-foundation-0.1.1
objc_id-0.1.1
once_cell-1.12.0
opaque-debug-0.2.3
opaque-debug-0.3.0
open-3.0.1
ordered-float-2.10.0
ordered-multimap-0.4.3
ordered-stream-0.0.1
os_info-3.4.0
os_str_bytes-6.1.0
parking-2.0.0
parking_lot-0.11.2
parking_lot_core-0.8.5
path-slash-0.1.4
pathdiff-0.2.1
pathsearch-0.2.0
percent-encoding-2.1.0
pest-2.1.3
pest_derive-2.1.0
pest_generator-2.1.3
pest_meta-2.1.3
phf-0.8.0
phf_codegen-0.8.0
phf_generator-0.8.0
phf_shared-0.8.0
pin-project-lite-0.2.9
pin-utils-0.1.0
pkg-config-0.3.25
polling-2.2.0
ppv-lite86-0.2.16
predicates-2.1.1
predicates-core-1.0.3
predicates-tree-1.0.5
proc-macro-crate-1.1.3
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro2-1.0.40
process_control-3.5.1
quick-xml-0.23.0
quote-1.0.20
rand-0.7.3
rand-0.8.5
rand_chacha-0.2.2
rand_chacha-0.3.1
rand_core-0.5.1
rand_core-0.6.3
rand_hc-0.2.0
rand_pcg-0.2.1
rayon-1.5.3
rayon-core-1.9.3
redox_syscall-0.2.13
redox_users-0.4.3
regex-1.5.6
regex-syntax-0.6.26
remove_dir_all-0.5.3
rust-ini-0.18.0
ryu-1.0.10
schemars-0.8.10
schemars_derive-0.8.10
scopeguard-1.1.0
semver-0.11.0
semver-1.0.10
semver-parser-0.10.2
serde-1.0.137
serde_derive-1.0.137
serde_derive_internals-0.26.0
serde_json-1.0.81
serde_repr-0.1.8
sha-1-0.8.2
sha-1-0.10.0
sha1-0.6.1
sha1_smol-1.0.0
sha2-0.9.9
shadow-rs-0.11.0
shared_library-0.1.9
shell-words-1.1.0
signal-hook-0.1.17
signal-hook-0.3.14
signal-hook-registry-1.4.0
siphasher-0.3.10
slab-0.4.6
smallvec-1.8.1
socket2-0.4.4
starship-battery-0.7.9
static_assertions-1.1.0
strsim-0.10.0
strum-0.22.0
strum_macros-0.22.0
syn-1.0.98
systemstat-0.1.11
tempfile-3.3.0
termcolor-1.1.3
terminal_size-0.1.17
terminfo-0.7.3
termios-0.3.3
termtree-0.2.4
termwiz-0.15.0
textwrap-0.15.0
thiserror-1.0.31
thiserror-impl-1.0.31
time-0.1.44
time-0.3.11
tinyvec-1.6.0
tinyvec_macros-0.1.0
toml-0.5.9
toml_edit-0.14.4
tracing-0.1.35
tracing-attributes-0.1.21
tracing-core-0.1.28
typenum-1.15.0
ucd-trie-0.1.3
uds_windows-1.0.2
unicase-2.6.0
unicode-bidi-0.3.8
unicode-ident-1.0.1
unicode-normalization-0.1.20
unicode-segmentation-1.9.0
unicode-width-0.1.9
unicode-xid-0.2.3
uom-0.30.0
url-2.2.2
urlencoding-2.1.0
utf8parse-0.2.0
vcpkg-0.2.15
version_check-0.9.4
versions-4.1.0
vtparse-0.6.1
waker-fn-1.1.0
wasi-0.9.0+wasi-snapshot-preview1
wasi-0.10.0+wasi-snapshot-preview1
wasi-0.11.0+wasi-snapshot-preview1
wepoll-ffi-0.1.2
which-4.2.5
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.5
winapi-x86_64-pc-windows-gnu-0.4.0
windows-0.24.0
windows-0.38.0
windows-sys-0.36.1
windows_aarch64_msvc-0.36.1
windows_aarch64_msvc-0.38.0
windows_i686_gnu-0.24.0
windows_i686_gnu-0.36.1
windows_i686_gnu-0.38.0
windows_i686_msvc-0.24.0
windows_i686_msvc-0.36.1
windows_i686_msvc-0.38.0
windows_x86_64_gnu-0.24.0
windows_x86_64_gnu-0.36.1
windows_x86_64_gnu-0.38.0
windows_x86_64_msvc-0.24.0
windows_x86_64_msvc-0.36.1
windows_x86_64_msvc-0.38.0
winres-0.1.12
winrt-notification-0.5.1
xml-rs-0.8.4
yaml-rust-0.4.5
zbus-2.3.2
zbus_macros-2.3.2
zbus_names-2.1.0
zvariant-3.4.1
zvariant_derive-3.4.1
"

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://api.github.com/repos/starship/starship/tarball/v1.9.1 -> starship-v1.9.1.tar.gz
	$(cargo_crate_uris ${CRATES})"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE="libressl"

DEPEND="
	libressl? ( dev-libs/libressl:0= )
	!libressl? ( dev-libs/openssl:0= )
	sys-libs/zlib:=
"
RDEPEND="${DEPEND}"

DOCS="docs/README.md"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/starship-starship-* ${S} || die
}

src_install() {
	dobin target/release/${PN}
	default
}


pkg_postinst() {
        echo
        elog "Thanks for installing starship."
        elog "For better experience, it's suggested to install some Powerline font."
        elog "You can get some from https://github.com/powerline/fonts"
        echo
}