# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit toolchain-funcs flag-o-matic

DESCRIPTION="Timezone data (/usr/share/zoneinfo) and utilities (tzselect/zic/zdump)"
HOMEPAGE="https://www.iana.org/time-zones"
SRC_URI="
https://data.iana.org/time-zones/releases/tzdata2026f.tar.gz -> tzdata2026f.tar.gz
https://data.iana.org/time-zones/releases/tzcode2026f.tar.gz -> tzcode2026f.tar.gz"
LICENSE="BSD public-domain"
SLOT="0"
KEYWORDS="*"
IUSE="nls leaps-timezone"
RDEPEND="nls? ( virtual/libintl )
	!sys-libs/glibc[vanilla(+)]
	
"
DEPEND="nls? ( virtual/libintl )
"
S="${WORKDIR}"
src_prepare() {
	default

	# check_web contacts validator.w3.org
	sed -i -e 's/check_tables check_web/check_tables/g' \
		Makefile || die "Failed to disable check_web"

}

src_configure() {
	tc-export CC

	append-lfs-flags

	append-cppflags -DHAVE_GETTEXT=$(usex nls 1 0) -DTZ_DOMAIN='\"libc\"'
	LDLIBS=""
	if use nls ; then
		# See if an external libintl is available.
		local c="${T}/test"
		echo 'main(){}' > "${c}.c"
		if $(tc-getCC) ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} "${c}.c" -o "${c}" -lintl 2>/dev/null ; then
			LDLIBS+=" -lintl"
		fi
	fi
}

_emake() {
	emake \
		REDO=$(usex leaps-timezone posix_right posix_only) \
		TZDATA_TEXT= \
		ZICDIR='/usr/bin' \
		"$@"
}

src_compile() {
	_emake \
		AR="$(tc-getAR)" \
		cc="$(tc-getCC)" \
		RANLIB="$(tc-getRANLIB)" \
		CFLAGS="${CFLAGS} -std=gnu99 ${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		LDLIBS="${LDLIBS}"
}

src_install() {
	local zic=""
	_emake install ${zic} DESTDIR="${D}" LIBDIR="/nukeit"
	rm -rf "${D}/nukeit" "${ED}/etc" || die

	insinto /usr/share/zoneinfo
	doins "${S}"/leap-seconds.list

	# Delete man pages installed by man-pages package.
	rm "${ED}"/usr/share/man/man5/tzfile.5* "${ED}"/usr/share/man/man8/{tzselect,zdump,zic}.8 || die
	dodoc CONTRIBUTING README NEWS *.html
}

get_TIMEZONE() {
	local tz src="/etc/timezone"
	if [[ -e ${src} ]] ; then
		tz=$(sed -e 's:#.*::' -e 's:[[:space:]]*::g' -e '/^$/d' "${src}")
	else
		tz="FOOKABLOIE"
	fi
	[[ -z ${tz} ]] && return 1 || echo "${tz}"
}

pkg_preinst() {
	local tz=$(get_TIMEZONE)
	if [[ ${tz} == right/* || ${tz} == posix/* ]] ; then
		eerror "The right & posix subdirs are no longer installed as subdirs -- they have been"
		eerror "relocated to match upstream paths as sibling paths.  Further, posix/xxx is the"
		eerror "same as xxx, so you should simply drop the posix/ prefix.  You also should not"
		eerror "be using right/xxx for the system timezone as it breaks programs."
		die "Please fix your timezone setting"
	fi

	# Trim the symlink by hand to avoid portage's automatic protection checks.
	rm -f /usr/share/zoneinfo/posix

	if has_version "<=${CATEGORY}/${PN}-2015c" ; then
		elog "Support for accessing posix/ and right/ directly has been dropped to match"
		elog "upstream.  There is no need to set TZ=posix/xxx as it is the same as TZ=xxx."
		elog "For TZ=right/, you can use TZ=../zoneinfo-leaps/xxx instead.  See this post"
		elog "for details: https://mm.icann.org/pipermail/tz/2015-February/022024.html"
	fi
}

configure_tz_data() {
	# make sure the /etc/localtime file does not get stale
	local tz src="/etc/timezone" etc_lt="/etc/localtime"

	# If it's a symlink, assume the user knows what they're doing and
	# they're managing it themselves.
	if [[ -L "${etc_lt}" ]] ; then
		einfo "Assuming your ${etc_lt} symlink is what you want; skipping update."
		return 0
	fi

	if ! tz=$(get_TIMEZONE) ; then
		einfo "Assuming your empty ${etc_lt} file is what you want; skipping update."
		return 0
	fi
	if [[ "${tz}" == "FOOKABLOIE" ]] ; then
		elog "You do not have TIMEZONE set in ${src}."

		if [[ ! -e "${etc_lt}" ]] ; then
			cp -f /usr/share/zoneinfo/Factory "${etc_lt}"
			elog "Setting ${etc_lt} to Factory."
		else
			elog "Skipping auto-update of ${etc_lt}."
		fi
		return 0
	fi

	if [[ ! -e "/usr/share/zoneinfo/${tz}" ]] ; then
		elog "You have an invalid TIMEZONE setting in ${src}"
		elog "Your ${etc_lt} has been reset to Factory; enjoy!"
		tz="Factory"
	fi
	einfo "Updating ${etc_lt} with /usr/share/zoneinfo/${tz}"
	cp -f "/usr/share/zoneinfo/${tz}" "${etc_lt}"
}

pkg_config() {
	configure_tz_data
}

pkg_postinst() {
	configure_tz_data
}


# vim: filetype=ebuild
