# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python2_{6,7} python3_{1,2,3} )

inherit distutils-r1

MY_PV="${PV/_beta/b}"
MY_P="${PN}2-${MY_PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Python bindings for GMP library"
HOMEPAGE="http://www.aleax.it/gmpy.html http://code.google.com/p/gmpy/ http://pypi.python.org/pypi/gmpy"
SRC_URI="http://${PN}.googlecode.com/files/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/gmp-5.0.0
	>=dev-libs/mpfr-3.1.0
	>=dev-libs/mpc-1.0.0"
DEPEND="${RDEPEND}
	app-arch/unzip"


# setup.py needs -Ddir to be set but complains about it when just using 'build'
python_configure_all() {
	mydistutilsargs=( build_ext -Ddir="${ROOT}/usr" )
}

src_prepare() {
	# setup.py presumptuously checks libs by looking for static libs
	sed -i "s/\\.a'/.so'/" setup.py
}

