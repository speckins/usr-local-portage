# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# x11-misc/virtualgl

EAPI="2"

inherit multilib flag-o-matic

LJT_PV="1.1.1"

DESCRIPTION="Run OpenGL applications on remote display software with full 3D hardware acceleration"
HOMEPAGE="http://www.virtualgl.org/"
SRC_URI="mirror://sourceforge/${PN}/VirtualGL/${PV}/VirtualGL-${PV}.tar.gz
         mirror://sourceforge/libjpeg-turbo/${LJT_PV}/libjpeg-turbo-${LJT_PV}.tar.gz"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="LGPL-2.1 wxWinLL-3.1"
RESTRICT="mirror"

IUSE=""

RDEPEND="x11-libs/libXext
         x11-libs/libXv
         x11-libs/libxcb
         media-libs/mesa"
DEPEND="${RDEPEND}"

S="${WORKDIR}/vgl"
LJT="${WORKDIR}/libjpeg-turbo-${LJT_PV}"
QA_SONAME="usr/lib/libdlfaker.so
           usr/lib/libgefaker.so 
           usr/lib/librrfaker.so
           usr/lib32/libdlfaker.so
           usr/lib32/libgefaker.so
           usr/lib32/librrfaker.so"

src_prepare() {
	# Change /usr/doc -> /usr/share/doc
	# Rename glxinfo to vglxinfo (conflicts w/ x11-apps/mesa-progs)
	# Remove redundant targets which get run again in install
	sed -i \
		-e 's|^docdir=$(prefix)|docdir=$(prefix)/share|' \
		-e 's|$(prefix)/bin/glxinfo|$(prefix)/bin/vglxinfo|' \
		-e 's|^install:.*$|install:|' \
		Makefile
	# Strip -O3 flag
	# Add zlib (-lz) libraries
	# Remove ln which causes sandbox violation sometimes
	sed -i \
		-e 's| -O3||' \
		-e 's|-lcrypto|-lcrypto -lz|' \
		-e 's|\(^_DUMMY4\)|#\1|' \
		Makerules.linux

	mkdir "${LJT}/build"{,32} || die "mkdir failed"
}

src_configure() {
	local ECONF_SOURCE="${LJT}"

	einfo "Configuring libjpeg-turbo"
	cd "${LJT}/build"
	econf \
		--with-pic \
		--with-jpeg8 \
		--disable-dependency-tracking

	if has_multilib_profile; then
		multilib_toolchain_setup x86
		cd ../build32 && econf \
			--disable-dependency-tracking \
			--with-pic \
			--with-jpeg8
		multilib_toolchain_setup
	fi
}

src_compile() {
	einfo "Building libjpeg-turbo"
	cd "${LJT}/build"
	emake install DESTDIR="${WORKDIR}"
	if has_multilib_profile; then
		einfo "Building 32-bit libjpeg-turbo"
		cd ../build32
		emake
		emake install-libLTLIBRARIES DESTDIR="${WORKDIR}"
		ln -s "${WORKDIR}/usr/lib64" "${WORKDIR}/usr/lib"
	fi

	einfo "Building VirtualGL"
	append-flags -fpic
	cd "${S}"
	emake rr \
		JPEG_LDFLAGS="-L${WORKDIR}/usr/$(get_libdir) -Wl,-Bstatic -lturbojpeg -Wl,-Bdynamic"
	emake diags mesademos

	if has_multilib_profile; then
		emake rr \
			M32=yes \
			JPEG_LDFLAGS="-L${WORKDIR}/usr/$(ABI=x86 get_libdir) -Wl,-Bstatic -lturbojpeg -Wl,-Bdynamic"
		emake mesademos M32=yes
	fi
}

src_install() {
	emake install prefix="${D}/usr" || die "installation failed"
	dodir /etc/opt/VirtualGL
	fowners root:video /etc/opt/VirtualGL
	fperms 0750 /etc/opt/VirtualGL
	newinitd "${FILESDIR}/vgl.initd" vgl
	newconfd "${FILESDIR}/vgl.confd" vgl
	rm "${D}/usr/bin/vglserver_config" "${D}/usr/bin/vglgenkey"
}
