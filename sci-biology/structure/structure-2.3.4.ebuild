# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils

DESCRIPTION="A free software package for using multi-locus genotype data to investigate population structure"
HOMEPAGE="http://pritch.bsd.uchicago.edu/structure.html"
SRC_URI="http://pritch.bsd.uchicago.edu/structure_software/release_versions/v${PV}/structure_kernel_source.tar.gz -> ${P}.tar.gz
	doc? ( http://pritch.bsd.uchicago.edu/structure_software/release_versions/v${PV}/structure_doc.pdf )"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE=""
RESTRICT="mirror"

IUSE="doc"
RDEPEND=""
DEPEND=""


S="${WORKDIR}/structure_kernel_src"

src_unpack() {
	# Ignore PDF file in archive list
	unpack ${P}.tar.gz
}

src_prepare() {
	# Fix Makefile to respect C* variables
	sed -i '/^\(OPT\|CFLAGS\|CC\)/d' Makefile
}

src_install() {

	# There's no install target, but only one executable, so...
	dobin structure

	# Install default parameter files under /usr/share/
	insinto /usr/share/${P}
	doins mainparams extraparams

	# Install docs
	use doc && dodoc "${DISTDIR}/structure_doc.pdf"

	einfo "Structure expects files mainparams and extraparams to be in the cwd at runtime."
	einfo "Defaults of these files are located under /usr/share/${P} and are a"
	einfo "good place to start."
}

