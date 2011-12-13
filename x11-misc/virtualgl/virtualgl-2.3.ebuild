# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# x11-misc/virtualgl

EAPI="2"

inherit cmake-utils

MY_PN="VirtualGL"
MY_P="${MY_PN}-${PV}"
# LJT_PV="1.1.1"
LJT_PV="1.1.90"
LJT="${WORKDIR}/libjpeg-turbo-${LJT_PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Run OpenGL applications on remote display software with full 3D hardware acceleration"
HOMEPAGE="http://www.virtualgl.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}/${PV}/${MY_P}.tar.gz
         mirror://sourceforge/libjpeg-turbo/1.1.90%20%281.2beta1%29/libjpeg-turbo-${LJT_PV}.tar.gz"
# Upstream likes to use ugly characters in their betas:
# http://sourceforge.net/projects/libjpeg-turbo/files/1.1.90%20(1.2beta1)/libjpeg-turbo-1.1.90.tar.gz
# mirror://sourceforge/libjpeg-turbo/${LJT_PV}/libjpeg-turbo-${LJT_PV}.tar.gz

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="LGPL-2.1 wxWinLL-3.1"
RESTRICT="mirror"

IUSE=""

RDEPEND="x11-libs/libXext
         x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	mkdir "${LJT}/build" || die "mkdir failed"
}

src_configure() {
	local ECONF_SOURCE="${LJT}"

	# The in-tree libjpeg-turbo won't work (fails w/ fPIC error)
	einfo "Configuring libjpeg-turbo"
	cd "${LJT}/build"
	econf \
		--with-pic \
		--with-jpeg8 \
		--disable-dependency-tracking
	# cmake requires that we build libjpeg-turbo before configuring VirtualGL
	einfo "Building libjpeg-turbo"
	emake install DESTDIR="${WORKDIR}"

	einfo "Configuring VirtualGL"
	mycmakeargs=(
		-DVGL_DOCDIR=/usr/share/doc
		-DTJPEG_INCLUDE_DIR="${WORKDIR}"/usr/include
		-DTJPEG_LIBRARY="${WORKDIR}"/usr/$(get_libdir)/libturbojpeg.a
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dodir /etc/opt/VirtualGL
	fowners root:video /etc/opt/VirtualGL
	fperms 0750 /etc/opt/VirtualGL
	newinitd "${FILESDIR}/vgl.initd" vgl
	newconfd "${FILESDIR}/vgl.confd" vgl
	# Rename glxinfo to vglxinfo to avoid conflict with x11-apps/mesa-progs
	mv "${D}"/usr/bin/{,v}glxinfo
	rm "${D}/usr/bin/vglserver_config" "${D}/usr/bin/vglgenkey"
}
