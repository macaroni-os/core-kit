# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils libtool flag-o-matic gnuconfig multilib toolchain-funcs

DESCRIPTION="Tools necessary to build programs"
HOMEPAGE="https://sourceware.org/binutils/"
LICENSE="GPL-3+"
IUSE="cet default-gold doc +gold multitarget +nls +plugins static-libs test vanilla"
REQUIRED_USE="default-gold? ( gold )"

SRC_URI="https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz -> binutils-2.40.tar.xz https://dev.gentoo.org/~dilfridge/distfiles/binutils-2.40-patches-5.tar.xz -> binutils-2.40-patches-5.tar.xz"
SLOT=$(ver_cut 1-2)

S="${WORKDIR}/binutils-2.40"

KEYWORDS="*"
RDEPEND="
!sys-devel/binutils-config
!<sys-libs/binutils-libs-2.40_p5-r1
!<sys-devel/binutils-2.40_p5-r1
sys-libs/zlib"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( sys-apps/texinfo )
	test? (
		dev-util/dejagnu
		sys-devel/bc
	)
	nls? ( sys-devel/gettext )
	sys-devel/flex
	virtual/yacc
"
PDEPEND="=sys-libs/binutils-libs-2.40_p5-r1"

RESTRICT="!test? ( test )"

MY_BUILDDIR=${WORKDIR}/build

src_unpack() {
	unpack binutils-2.40.tar.xz
	cd "${WORKDIR}" || die
	unpack binutils-2.40-patches-5.tar.xz
	mkdir -p "${MY_BUILDDIR}" || die
}

src_prepare() {
	if ! use vanilla; then
		einfo "Applying binutils patchset binutils-2.40-patches-5.tar.xz"
		eapply "${WORKDIR}/patch"
		einfo "Done."
	fi
	# Apply things from PATCHES and user dirs
	default
	# Run misc portage update scripts
	gnuconfig_update
	elibtoolize --portage --no-uclibc
}

src_configure() {
	strip-linguas -u */po

	# Keep things sane
	strip-flags

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

	# For bi-arch systems, enable a 64bit bfd.  This matches
	# the bi-arch logic in toolchain.eclass. #446946
	# We used to do it for everyone, but it's slow on 32bit arches. #438522
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
		--with-bugurl="https://bugs.funtoo.org/"
		--with-pkgversion="Funtoo 2.40_p5 patchset: https://dev.gentoo.org/~dilfridge/distfiles/binutils-2.40-patches-5.tar.xz"
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

src_test() {
	cd "${MY_BUILDDIR}"
	# bug 637066
	filter-flags -Wall -Wreturn-type
	emake -k check
}

src_install() {
	cd "${MY_BUILDDIR}"
	emake DESTDIR="${D}" install

	# Binutils installs tools in /usr/bin, and a a subset of these (the build-related ones) in /usr/$CHOST/bin.
	# There are duplications, and hard-links are used.

	# To simplify installation, ensure all the tools installed to /usr/bin are moved to /usr/$CHOST/bin, because
	# some only appear in /usr/bin:

	cd ${D}/usr/bin || die
	for x in *; do
		if ! [ -e ${D}/usr/$CHOST/bin/${x} ]; then
			mv ${x} ${D}/usr/$CHOST/bin || die
		fi
	done

	# Set up /usr/$CHOST/bin/ld to use a symlink rather than a hardlink to point to the correct version of ld:

	rm -f ${D}/usr/$CHOST/bin/ld
	if use default-gold; then
	  ln -s ld.gold ${D}/usr/$CHOST/bin/ld || die
	else
	  ln -s ld.bfd ${D}/usr/$CHOST/bin/ld || die
	fi

	# Now set up /usr/bin to contain symlinks to the actual tools which are in /usr/$CHOST/bin. We will also
	# create a $CHOST-(name-of-bin) symlink in /usr/bin:

	rm -f ${D}/usr/bin/* || die
	cd ${D}/usr/$CHOST/bin || die
	for x in *; do
		ln -s ../$CHOST/bin/$x ${D}/usr/bin/$x || die
		ln -s ../$CHOST/bin/$x ${D}/usr/bin/$CHOST-$x || die
	done

	use static-libs || find "${ED}" -name '*.la' -delete

	# Provide libiberty.h directly.
	dosym libiberty/libiberty.h /usr/include/libiberty.h

#	doins "${libiberty_headers[@]/#/${S}/include/}"

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

  # This works around an issue where some things are installed in /usr/lib and others in /usr/lib64, which will
  # cause Portage to complain and abort. This just combines them:

	if [ -d ${D}/usr/lib ] && [ -d ${D}/usr/lib64 ]; then
	mv ${D}/usr/lib/* ${D}/usr/lib64
		rm -rf ${D}/usr/lib
	fi
}

pkg_preinst() {

  # This section includes hacks to remove things that may conflict with the merge. We remove existing tools symlinks
  # as well as remove the ldscripts symlink so it can be replaced with a real directory. This is done in pkg_preinst()
  # as it is right before Portage tries to copy things to the filesystem root -- so gets things out of the way just
  # in time...

	for x in addr2line ar as c++filt dwp elfedit gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip; do
		rm -f ${ROOT}/usr/bin/$x
		rm -f ${ROOT}/usr/${CHOST}/bin/$x
	done
	ldscripts_link=${ROOT}/usr/${CHOST}/lib/ldscripts
	if [ -L $ldscripts_link ]; then
		rm -f $ldscripts_link
	else
		echo $ldscripts_link is NOT a symlink
	fi
}