# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit eutils flag-o-matic gnuconfig libtool toolchain-funcs

DESCRIPTION="Tools necessary to build programs"
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
RDEPEND="!<sys-libs/binutils-libs-2.46.1-r1
	!<sys-devel/binutils-2.46.1-r1
	sys-libs/zlib
	
"
DEPEND="${RDEPEND}
"
PDEPEND="=sys-libs/binutils-libs-2.46.1-r1
"
S="${WORKDIR}/binutils-2.46.1"
MY_BUILDDIR="${WORKDIR}/build"

src_prepare() {
	# The Gentoo patchset is vendored under files/ and applied via
	# PATCHES; no external patch tarball is fetched on bumps.
	default

	# 9999-Gentoo-We-make-a-release.patch as a plain sed (review ask).
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

	# Binutils installs tools in /usr/bin, and a subset of these (the
	# build-related ones) in /usr/${CHOST}/bin. There are duplications,
	# and hard-links are used.

	# To simplify installation, ensure all the tools installed to
	# /usr/bin are moved to /usr/${CHOST}/bin, because some only
	# appear in /usr/bin:
	cd "${D}"/usr/bin || die
	for x in *; do
		if ! [ -e "${D}"/usr/${CHOST}/bin/${x} ]; then
			mv "${x}" "${D}"/usr/${CHOST}/bin || die
		fi
	done

	# Set up /usr/${CHOST}/bin/ld to use a symlink rather than a
	# hardlink to point to the correct version of ld:
	rm -f "${D}"/usr/${CHOST}/bin/ld
	if use default-gold; then
		ln -s ld.gold "${D}"/usr/${CHOST}/bin/ld || die
	else
		ln -s ld.bfd "${D}"/usr/${CHOST}/bin/ld || die
	fi

	# Now set up /usr/bin to contain symlinks to the actual tools
	# which are in /usr/${CHOST}/bin. We will also create a
	# ${CHOST}-(name-of-bin) symlink in /usr/bin:
	rm -f "${D}"/usr/bin/* || die
	cd "${D}"/usr/${CHOST}/bin || die
	for x in *; do
		ln -s ../${CHOST}/bin/${x} "${D}"/usr/bin/${x} || die
		ln -s ../${CHOST}/bin/${x} "${D}"/usr/bin/${CHOST}-${x} || die
	done

	use static-libs || find "${ED}" -name '*.la' -delete

	# Headers and libraries are owned by sys-libs/binutils-libs.
	rm -rf "${ED}"/usr/include || die
	rm -f "${ED}"/usr/lib*/lib{bfd,opcodes,iberty,ctf,sframe}* 2>/dev/null || true

	cd "${S}"
	dodoc README
	docinto bfd
	dodoc bfd/ChangeLog* bfd/README bfd/PORTING bfd/TODO
	docinto binutils
	dodoc binutils/ChangeLog binutils/NEWS binutils/README
	docinto gas
	dodoc gas/ChangeLog* gas/CONTRIBUTORS gas/NEWS gas/README*
	docinto gprof
	dodoc gprof/ChangeLog* gprof/TEST gprof/TODO gprof/bbconv.pl
	docinto ld
	dodoc ld/ChangeLog* ld/README ld/NEWS ld/TODO
	docinto libiberty
	dodoc libiberty/ChangeLog* libiberty/README
	docinto opcodes
	dodoc opcodes/ChangeLog*

	# Some things land in /usr/lib and others in /usr/lib64, which
	# makes Portage complain and abort. Combine them:
	if [ -d "${D}"/usr/lib ] && [ -d "${D}"/usr/lib64 ]; then
		mv "${D}"/usr/lib/* "${D}"/usr/lib64
		rm -rf "${D}"/usr/lib
	fi
}

pkg_preinst() {
	# Remove the existing tools symlinks and the ldscripts symlink so
	# that they can be replaced with a real directory: this runs right
	# before Portage copies things to the filesystem root.
	for x in addr2line ar as c++filt dwp elfedit gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip; do
		rm -f ${ROOT}/usr/bin/${x}
		rm -f ${ROOT}/usr/${CHOST}/bin/${x}
	done
	ldscripts_link=${ROOT}/usr/${CHOST}/lib/ldscripts
	if [ -L ${ldscripts_link} ]; then
		rm -f ${ldscripts_link}
	else
		echo ${ldscripts_link} is NOT a symlink
	fi
}


# vim: filetype=ebuild
