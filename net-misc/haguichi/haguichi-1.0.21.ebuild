# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator

MY_MAJORV=$(get_version_component_range 1-2)
MY_CLRV="4.0"

DESCRIPTION="GTK2 graphical frontend for LogMeIn Hamachi"
HOMEPAGE="http://www.haguichi.net/"
SRC_URI="http://launchpad.net/${PN}/${MY_MAJORV}/${PV}/+download/${P}-clr${MY_CLRV}.tar.gz"
RESTRICT="mirror"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="net-misc/logmein-hamachi
	=dev-dotnet/gtk-sharp-2*
	=dev-dotnet/gconf-sharp-2*
	>=dev-dotnet/notify-sharp-0.4.0_pre20090305
	>=dev-dotnet/ndesk-dbus-glib-0.4.0"
RDEPEND="${DEPEND}"
