# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic toolchain-funcs

DESCRIPTION="Standard GNU utilities (chmod, cp, dd, ls, sort, tr, head, wc, who,...)"
HOMEPAGE="https://www.gnu.org/software/coreutils/"
SRC_URI="https://gnuftp.mirror.garr.it/coreutils/coreutils-9.10.tar.xz -> coreutils-9.10.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl caps gmp hostname kill multicall nls +openssl +split-usr static xattr"
BDEPEND="app-arch/xz-utils
	dev-lang/perl
	
"
RDEPEND="!static? (
	  acl? (
	      sys-apps/acl
	  )
	  caps? (
	      sys-libs/libcap
	  )
	  gmp? (
	      dev-libs/gmp:=
	  )
	  xattr? (
	      sys-apps/attr
	  )
	  openssl? (
	      dev-libs/openssl:=
	  )
	)
	nls? ( virtual/libintl )
	hostname? ( !sys-apps/net-tools[hostname] )
	kill? (
	  !sys-apps/util-linux[kill]
	  !sys-process/procps[kill]
	)
	!<sys-apps/shadow-4.17.3
	
"
DEPEND="!static? (
	  acl? (
	      sys-apps/acl
	  )
	  caps? (
	      sys-libs/libcap
	  )
	  gmp? (
	      dev-libs/gmp:=
	  )
	  xattr? (
	      sys-apps/attr
	  )
	  openssl? (
	      dev-libs/openssl:=
	  )
	)
	static? (
	  acl? (
	      sys-apps/acl[static-libs]
	  )
	  caps? (
	      sys-libs/libcap[static-libs]
	  )
	  gmp? (
	      dev-libs/gmp:=[static-libs]
	  )
	  xattr? (
	      sys-apps/attr[static-libs]
	  )
	  openssl? (
	      dev-libs/openssl:=[static-libs]
	  )
	)
	
"
src_prepare() {
	default
	set -- man/*.x
	touch ${@/%x/1} || die
	# Avoid perl dep for compiled in dircolors default (bug #348642)
	if ! has_version dev-lang/perl ; then
	  touch src/dircolors.h || die
	  touch ${@/%x/1} || die
	fi
}
src_configure() {
	local myconf=(
	  --with-packager="MacaroniOS"
	  --with-packager-version="9.10"
	  --with-packager-bug-reports="https://github.com/macaroni-os/mark-issues"
	  # kill/uptime - procps
	  # su          - shadow
	  # hostname    - net-tools
	  --enable-install-program="arch,$(usev hostname),$(usev kill)"
	  --enable-no-install-program="$(usev !hostname),$(usev !kill),su,uptime"
	  --enable-largefile
	  $(usex caps '' --disable-libcap)
	  $(use_enable nls)
	  $(use_enable acl)
	  $(use_enable multicall single-binary)
	  $(use_enable xattr)
	  $(use_with gmp libgmp)
	  $(use_with openssl)
	)
	 if use gmp ; then
	  myconf+=( --with-libgmp-prefix="${ESYSROOT}"/usr )
	fi
	 export gl_cv_func_mknod_works=yes
	 if use static ; then
	  append-ldflags -static
	  # bug #321821
	  sed -i '/elf_sys=yes/s:yes:no:' configure || die
	fi
	 export ac_cv_{header_selinux_{context,flash,selinux}_h,search_setfilecon}=no
	econf "${myconf[@]}"
}
src_install() {
	default
	insinto /etc
	newins src/dircolors.hin DIR_COLORS
	if use split-usr ; then
	  cd "${ED}"/usr/bin || die
	  dodir /bin
	  # Move critical binaries into /bin (required by FHS)
	  local fhs="cat chgrp chmod chown cp date dd df echo false ln ls
	             mkdir mknod mv pwd rm rmdir stty sync true uname"
	  mv ${fhs} ../../bin/ || die "Could not move FHS bins!"
	  if use hostname ; then
	    mv hostname ../../bin/ || die
	  fi
	  if use kill ; then
	    mv kill ../../bin/ || die
	  fi
	  # Move critical binaries into /bin (common scripts)
	  # (Why are these required for booting?)
	  local com="basename chroot cut dir dirname du env expr head mkfifo
	             mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
	  mv ${com} ../../bin/ || die "Could not move common bins!"
	   # Create a symlink for uname in /usr/bin/ since autotools require it.
	  # (Other than uname, we need to figure out why we are
	  # creating symlinks for these in /usr/bin instead of leaving
	  # the files there in the first place...)
	  local x
	  for x in ${com} uname ; do
	    dosym ../../bin/${x} /usr/bin/${x}
	  done
	fi
}


# vim: filetype=ebuild
