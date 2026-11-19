# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
NCURSES_TARGETS=( ncurses ncursesw ncursest ncursestw )
inherit toolchain-funcs preserve-libs usr-ldscript

DESCRIPTION="console display library"
HOMEPAGE="https://www.gnu.org/software/ncurses/ https://invisible-island.net/ncurses/"
SRC_URI="https://invisible-mirror.net/archives/ncurses/current/ncurses-6.6-20261114.tgz -> ncurses-6.6-20261114.tgz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/ncurses-5.7-nongnu.patch"
	"${FILESDIR}/ncurses-6.0-rxvt-unicode-9.15.patch"
	"${FILESDIR}/ncurses-6.0-pkg-config.patch"
	"${FILESDIR}/ncurses-6.0-ticlib.patch"
	"${FILESDIR}/ncurses-6.2_p20210123-cppflags-cross.patch"
)
IUSE="ada +cxx debug gpm minimal profile static-libs tinfo trace unicode"
RDEPEND="${DEPEND}
	!<=sys-libs/ncurses-5.9-r4:5
	!<sys-libs/slang-2.3.2_pre23
	!<x11-terms/rxvt-unicode-9.06-r3
	!<x11-terms/st-0.6-r1
	
"
DEPEND="gpm? ( sys-libs/gpm )
	
"
post_src_unpack() {
	mv ${WORKDIR}/ncurses-* ${S} || die
}

src_configure() {
	unset TERMINFO
	tc-export_build_env BUILD_{CC,CPP}
	BUILD_CPPFLAGS+=" -D_GNU_SOURCE"
	local BUILD_DIR="${WORKDIR}/build"

	local t
	for t in "${NCURSES_TARGETS[@]}" ; do
		do_configure "${t}"
	done
}

do_configure() {
	local target=$1
	shift

	mkdir -p "${BUILD_DIR}/${target}" || die
	cd "${BUILD_DIR}/${target}" || die

	local conf=(
		# We need the basic terminfo files in /etc for
		# embedded/recovery.
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo"

		# Enable installation of .pc files.
		--enable-pc-files
		# This path is used to control where the .pc files are
		# installed.
		--with-pkg-config-libdir="/usr/$(get_libdir)/pkgconfig"

		# Now the rest of the various standard flags.
		--with-shared
		--without-hashed-db
		$(use_with ada)
		$(use_with cxx)
		$(use_with cxx cxx-binding)
		--with-cxx-shared
		$(use_with debug)
		$(use_with profile)
		# The configure script uses ldd to parse the linked output
		# which is flaky for cross-compiling/multilib/ldd
		# versions/etc...
		$(use_with gpm gpm libgpm.so.1)
		# Required for building on mingw-w64, and possibly other
		# windows platforms
		$(use_enable kernel_Winnt term-driver)
		--disable-termcap
		--enable-symlinks
		--with-rcs-ids
		--with-manpage-format=normal
		--enable-const
		--enable-colorfgbg
		--enable-hard-tabs
		--enable-echo
		$(use_enable !ada warnings)
		$(use_with debug assertions)
		$(use_enable !debug leaks)
		$(use_with debug expanded)
		$(use_with !debug macros)
		--with-progs
		$(use_with trace)
		$(use_with tinfo termlib)
		--disable-stripping
		--disable-pkg-ldflags
	)

	if [[ ${target} == ncurses*w ]] ; then
		conf+=( --enable-widec )
	else
		conf+=( --disable-widec )
	fi
	if [[ ${target} == ncursest* ]] ; then
		conf+=( --with-{pthread,reentrant} )
	else
		conf+=( --without-{pthread,reentrant} )
	fi
	# Make sure each variant goes in a unique location.
	if [[ ${target} == "ncurses" ]] ; then
		# "ncurses" variant goes into /usr/include
		conf+=( --enable-overwrite )
	else
		conf+=( --includedir="/usr/include/${target}" )
	fi
	ECONF_SOURCE="${S}" \
	econf "${conf[@]}" "$@"
}

src_compile() {
	local BUILD_DIR="${WORKDIR}/build"

	local t
	for t in "${NCURSES_TARGETS[@]}" ; do
		do_compile "${t}"
	done
}

do_compile() {
	local target=$1
	shift

	cd "${BUILD_DIR}/${target}" || die

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package in
	# parallel. This is not really a perf hit since the source
	# generation is quite small.
	emake -j1 sources
	# For some reason, sources depends on pc-files which depends on
	# compiled libraries which depends on sources which ...
	# Manually delete the pc-files file so the install step will
	# create the .pc files we want.
	rm -f misc/pc-files || die
	emake "$@"
}

src_install() {
	local BUILD_DIR="${WORKDIR}/build"

	local target
	for target in "${NCURSES_TARGETS[@]}" ; do
		emake -C "${BUILD_DIR}/${target}" DESTDIR="${D}" install
	done

	# Move main libraries into /.
	gen_usr_ldscript -a \
		"${NCURSES_TARGETS[@]}" \
		$(usex tinfo 'tinfow tinfo' '')

	if ! tc-is-static-only ; then
		# Provide a link for -lcurses.
		ln -sf libncurses$(get_libname) "${ED}"/usr/$(get_libdir)/libcurses$(get_libname) || die
	fi

	# don't delete '*.dll.a', needed for linking
	if ! use static-libs; then
		find "${ED}"/usr/ -name '*.a' ! -name '*.dll.a' -delete || die
	fi

	dosym $(sed 's@[^/]\+@..@g' <<< $(get_libdir))/share/terminfo \
		/usr/$(get_libdir)/terminfo

	# We need the basic terminfo files in /etc for embedded/recovery.
	einfo "Installing basic terminfo files in /etc..."
	local terms=(
		# Dumb/simple values that show up when using the in-kernel VT.
		ansi console dumb linux
		vt{52,100,102,200,220}
		# [u]rxvt users used to be pretty common.
		rxvt{,-unicode}{,-256color}
		# xterm users are common, as is terminals re-using/spoofing it.
		xterm xterm-{,256}color
		# screen is common (and reused by tmux).
		screen{,-256color}
		screen.xterm-256color
	)
	local x
	for x in "${terms[@]}"; do
		local termfile=$(find "${ED}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
		local basedir=$(basename "$(dirname "${termfile}")")

		if [[ -n ${termfile} ]] ; then
			dodir "/etc/terminfo/${basedir}"
			mv "${termfile}" "${ED}/etc/terminfo/${basedir}/" || die
			dosym "../../../../etc/terminfo/${basedir}/${x}" \
				"/usr/share/terminfo/${basedir}/${x}"
		fi
	done

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" | newenvd - 50ncurses

	use minimal && rm -r "${ED}"/usr/share/terminfo*
	# Because ncurses5-config --terminfo returns the directory we
	# keep it
	keepdir /usr/share/terminfo

	cd "${S}" || die
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/libncurses.so.5
	preserve_old_lib /$(get_libdir)/libncursesw.so.5
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/libncurses.so.5
	preserve_old_lib_notify /$(get_libdir)/libncursesw.so.5
}


# vim: filetype=ebuild
