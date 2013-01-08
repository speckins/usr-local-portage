# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# there's a flag to build levmar (Levenberg-Marquardt nonlinear least squares
# algorithms; http://www.ics.forth.gr/~lourakis/levmar/index.htm) into teem, but
# levmar is not in the portage tree; an overlay is available, however.

EAPI="2"

inherit cmake-utils

DESCRIPTION="Coordinated group of libraries for representing, processing, and visualizing scientific raster data."
HOMEPAGE="http://teem.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${P}-src.tar.gz"
KEYWORDS="x86 amd64"
SLOT="0"
LICENSE="LGPL-2.1"
RESTRICT="mirror"

IUSE="zlib png threads bzip2 fftw static-libs experimental"

RDEPEND="png? ( media-libs/libpng )
         zlib? ( sys-libs/zlib )
	     bzip2? ( app-arch/bzip2 )
	     fftw? ( sci-libs/fftw )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}-src"

src_configure() {

	mycmakeargs=(
		$(cmake-utils_use png TEEM_PNG)
		$(cmake-utils_use threads TEEM_PTHREAD)
		$(cmake-utils_use zlib TEEM_ZLIB)
		$(cmake-utils_use fftw TEEM_FFTW3)
		$(cmake-utils_use bzip2 TEEM_BZIP2)
		$(cmake-utils_use_build !static-libs SHARED_LIBS)
		$(cmake-utils_use_build experimental EXPERIMENTAL_APPS)
		$(cmake-utils_use_build experimental EXPERIMENTAL_LIBS)
	)

	cmake-utils_src_configure
}
