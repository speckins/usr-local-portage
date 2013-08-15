# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Qt4 graphical frontend for LogMeIn Hamachi"
HOMEPAGE="http://code.google.com/p/quamachi/"
SRC_URI="http://${PN}.googlecode.com/files/${P^}.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="net-misc/logmein-hamachi
	dev-python/PyQt4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN^}/Build"

src_prepare() {
	# remove uninstall target, which is run before install, since it causes a sandbox violation
	# change make to $(MAKE) to resolve QA parallel build issue
	sed -i \
		-e '/^\s\+make uninstall$/d' \
		-e 's/^\(\s\+\)make/\1$(MAKE)/g' \
		Makefile || die "sed failed"
}

src_install() {
	emake DESTDIR="${D}" Install.AllUsers || die

	rm -rf "${D}/usr/share/${PN^}/Build/"
}
