# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 toolchain-funcs

DESCRIPTION="Python binding for LeechCore Physical Memory Acquisition Library"
HOMEPAGE="https://github.com/ufrisk/LeechCore"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-3"
SLOT="0"

# leechcorepyc ships with a bundled version of the LeechCore library. So we
# dont't depend on the library here. But we must be aware this module doesn't
# use the system library.
DEPEND="virtual/libusb:="
RDEPEND="${DEPEND}
	${PYTHON_DEPS}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-2.10.2-respect-CC.patch
)

src_configure() {
	tc-export CC

	distutils-r1_src_configure
}
