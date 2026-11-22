# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit eutils flag-o-matic gnuconfig libtool toolchain-funcs

DESCRIPTION="Core binutils libraries (libbfd, libopcodes, libiberty, libctf, libsframe)"
HOMEPAGE="https://sourceware.org/binutils/"
SRC_URI="https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz -> binutils-2.40.tar.xz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/0001-Re-enable-development.-Update-version-to-2.40.0.patch"
	"${FILESDIR}/0002-Gentoo-gold-ld-add-support-for-poisoned-system-direc.patch"
	"${FILESDIR}/0003-Gentoo-libiberty-install-PIC-version-of-libiberty.a.patch"
	"${FILESDIR}/0004-Gentoo-add-with-extra-soversion-suffix-option.patch"
	"${FILESDIR}/0006-Gentoo-Give-also-libctf-optionally-a-gentoo-specific.patch"
	"${FILESDIR}/0009-Updated-translations-for-the-gas-and-binutils-sub-di.patch"
	"${FILESDIR}/0010-libctf-update-regexp-to-allow-makeinfo-to-build-docu.patch"
	"${FILESDIR}/0011-Fix-version-number-snafu-in-some-configuration-files.patch"
	"${FILESDIR}/0012-toplevel-Makefile.def-add-install-strip-dependency-o.patch"
	"${FILESDIR}/0013-Updated-Swedish-translation-for-the-binutils-sub-dir.patch"
	"${FILESDIR}/0014-gprofng-PR29521-docs-man-pages-are-not-in-the-releas.patch"
	"${FILESDIR}/0015-gprofng-PR30043-libgprofng.so.-are-installed-to-a-wr.patch"
	"${FILESDIR}/0016-RISC-V-make-C-extension-JAL-available-again-for-32-b.patch"
	"${FILESDIR}/0017-Updated-Swedish-translation-for-the-binutils-sub-dir.patch"
	"${FILESDIR}/0018-bpf-fix-error-conversion-from-long-unsigned-int-to-u.patch"
	"${FILESDIR}/0019-Pass-JANSSON_LIBS-and-ZSTD_LIBS-to-ld-bootstrap-boot.patch"
	"${FILESDIR}/0020-Regen-config-files.patch"
	"${FILESDIR}/0021-configure-remove-dependencies-on-gmp-and-mpfr-when-g.patch"
	"${FILESDIR}/0022-gas-correct-symbol-name-comparison-in-.startof.-.siz.patch"
	"${FILESDIR}/0023-Updated-translations-for-the-bfd-and-gprof-directori.patch"
	"${FILESDIR}/0024-Updated-Serbian-translations-for-gold-gprof-and-opco.patch"
	"${FILESDIR}/0025-ppc32-and-LOAD-segment-with-RWX-permissions.patch"
	"${FILESDIR}/0026-PR30046-power-cmpi-leads-to-unknown-architecture.patch"
	"${FILESDIR}/0027-PR30155-ld-segfault-in-_bfd_nearby_section.patch"
	"${FILESDIR}/0028-PR30198-Assertion-and-segfault-when-linking-x86_64-e.patch"
	"${FILESDIR}/0029-Apply-a-similar-libiberty-fix-as-in-7d53105d-for-lib.patch"
	"${FILESDIR}/0030-PR30217-dynamic-relocations-using-local-dynamic-symb.patch"
	"${FILESDIR}/0031-coff_get_normalized_symtab-bfd_release.patch"
	"${FILESDIR}/0032-libctf-fix-assertion-failure-with-no-system-qsort_r.patch"
	"${FILESDIR}/0033-libctf-get-the-offsets-of-fields-of-unnamed-structs-.patch"
	"${FILESDIR}/0034-gas-arm-Fix-a-further-IT-predicated-vcvt-issue-in-th.patch"
	"${FILESDIR}/0035-gas-arm-Change-warning-message-to-not-reference-spec.patch"
	"${FILESDIR}/0036-lto-Don-t-add-indirect-symbols-for-versioned-aliases.patch"
	"${FILESDIR}/0037-Updated-Hungarian-translation-for-the-gprof-director.patch"
	"${FILESDIR}/0038-New-Georgian-translation-for-the-bfd-sub-directory.patch"
	"${FILESDIR}/0039-Fix-linker-performance-regression.patch"
	"${FILESDIR}/0040-section-select-Fix-performance-problem-PR30367.patch"
	"${FILESDIR}/0041-Fix-PR30079-abort-on-mingw.patch"
)
IUSE="cet default-gold doc +gold multitarget +nls +plugins static-libs"
REQUIRED_USE="default-gold? ( gold )"
BDEPEND="doc? ( sys-apps/texinfo )
	nls? ( sys-devel/gettext )
	sys-devel/flex
	virtual/yacc
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/binutils-2.40"
MY_BUILDDIR="${WORKDIR}/build"

src_prepare() {
	default

	sed -i -e 's:^development=true$:development=false:' bfd/development.sh || die
	# Run misc portage update scripts
	gnuconfig_update
	elibtoolize --portage --no-uclibc
}

src_configure() {
	strip-linguas -u */po

	# Keep things sane
	strip-flags

	mkdir -p "${MY_BUILDDIR}" || die
	cd "${MY_BUILDDIR}"
	local myconf=()

	if use plugins ; then
		myconf+=( --enable-plugins )
	fi
	# enable gold (installed as ld.gold) and ld's plugin architecture
	if use gold ; then
		myconf+=( --enable-gold )
		if use default-gold; then
			myconf+=( --enable-gold=default )
		fi
	fi

	if use nls ; then
		myconf+=( --without-included-gettext )
	else
		myconf+=( --disable-nls )
	fi

	# For bi-arch systems, enable a 64bit bfd. This matches the
	# bi-arch logic in toolchain.eclass.
	case $(tc-arch) in
		ppc|sparc|x86) myconf+=( --enable-64-bit-bfd ) ;;
	esac

	use multitarget && myconf+=( --enable-targets=all --enable-64-bit-bfd )

	# mips can't do hash-style=gnu ...
	if [[ $(tc-arch) != mips ]] ; then
		myconf+=( --enable-default-hash-style=gnu )
	fi

	myconf+=(
		--prefix=/usr
		--host=${CHOST}
		--target=${CHOST}
		$(use_enable cet)
		--enable-obsolete
		--enable-secureplt
		--enable-shared
		$(use_enable static-libs static)
		--enable-threads
		--enable-relro
		--enable-install-libiberty
		--enable-textrel-check=warning
		--disable-werror
		--enable-new-dtags
		--with-bugurl="https://github.com/macaroni-os/mark-issues/issues"
		--with-pkgversion="MacaroniOS 2.40_p5"
		--with-system-zlib
		--without-zlib
		# Strip out broken static link flags.
		# https://gcc.gnu.org/PR56750
		--without-stage1-ldflags
		--without-debuginfod
		${EXTRA_ECONF}
	)

	echo ./configure "${myconf[@]}"
	"${S}"/configure "${myconf[@]}" || die

	# Prevent makeinfo from running if doc is unset.
	if ! use doc ; then
		sed -i \
			-e '/^MAKEINFO/s:=.*:= true:' \
			Makefile || die
	fi
}

src_compile() {
	cd "${MY_BUILDDIR}"
	emake all

	# only build info pages if the user wants them
	if use doc ; then
		emake info
	fi

	# we nuke the manpages when we're left with junk
	# (like when we bootstrap, no perl -> no manpages)
	find . -name '*.1' -a -size 0 -delete
}


src_install() {
	cd "${MY_BUILDDIR}"
	emake DESTDIR="${D}" install

	# Keep only the library payload (headers + lib*): tools, docs and
	# ldscripts belong to sys-devel/binutils, which removes these files
	# from its own install (maintainer confirmation on #621).
	mkdir -p "${T}/keep/lib"
	cp -a "${D}/usr/include" "${T}/keep/include" 2>/dev/null || true
	local d n
	for d in "${D}"/usr/lib* ; do
		[ -d "$d" ] || continue
		n=$(basename "$d")
		mkdir -p "${T}/keep/lib/$n"
		cp -a "$d"/lib* "${T}/keep/lib/$n"/ 2>/dev/null || true
	done
	rm -rf "${D}/usr"
	mkdir -p "${D}/usr"
	[ -d "${T}/keep/include" ] && cp -a "${T}/keep/include" "${D}/usr/include"
	for d in "${T}"/keep/lib/* ; do
		n=$(basename "$d")
		mkdir -p "${D}/usr/$n"
		cp -a "$d"/* "${D}/usr/$n"/ 2>/dev/null || true
	done

	# Some things land in /usr/lib and others in /usr/lib64, which
	# makes Portage complain and abort. Combine them:
	if [ -d "${D}"/usr/lib ] && [ -d "${D}"/usr/lib64 ]; then
		mv "${D}"/usr/lib/* "${D}"/usr/lib64
		rm -rf "${D}"/usr/lib
	fi
	rm -rf "${ED}"/usr/include || die

	use static-libs || find "${ED}" -name '*.la' -delete
}


# vim: filetype=ebuild
