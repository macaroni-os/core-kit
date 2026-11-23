# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit eutils flag-o-matic gnuconfig libtool toolchain-funcs

DESCRIPTION="Core binutils libraries (libbfd, libopcodes, libiberty, libctf, libsframe)"
HOMEPAGE="https://sourceware.org/binutils/"
SRC_URI="https://ftp.gnu.org/gnu/binutils/binutils-2.46.1.tar.xz -> binutils-2.46.1.tar.xz"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="cet default-gold doc +gold multitarget +nls +plugins static-libs"
REQUIRED_USE="default-gold? ( gold )"
BDEPEND="doc? ( sys-apps/texinfo )
	nls? ( sys-devel/gettext )
	sys-devel/flex
	virtual/yacc
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/binutils-2.46.1"
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
		--with-pkgversion="MacaroniOS 2.46.1"
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
