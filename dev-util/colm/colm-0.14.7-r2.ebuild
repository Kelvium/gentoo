# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="COmputer Language Manipulation"
HOMEPAGE="https://www.colm.net/open-source/colm/"
SRC_URI="https://www.colm.net/files/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

BDEPEND="
	doc? (
		|| ( app-text/asciidoc dev-ruby/asciidoctor )
		dev-python/pygments
	)
"
# libfsm moved from ragel -> colm, bug #766108
RDEPEND="!<dev-util/ragel-7.0.3"

PATCHES=(
	"${FILESDIR}"/${PN}-0.14.7-drop-julia-check.patch
	"${FILESDIR}"/${PN}-0.14.7-disable-static-lib.patch
	"${FILESDIR}"/${PN}-0.14.7-solaris.patch
)

src_prepare() {
	default

	# bug #733426
	sed -i -e 's/(\[ASCIIDOC\], \[asciidoc\], \[asciidoc\]/S([ASCIIDOC], [asciidoc asciidoctor]/' configure.ac || die

	# bug #766069
	sed -i -e "s|gcc|$(tc-getCC) ${CFLAGS}|" src/main.cc || die
	sed -i -e "s|gcc|$(tc-getCC)|" test/colm.d/gentests.sh || die
	sed -i -e "s|g++|$(tc-getCXX)|" test/colm.d/gentests.sh || die

	# fix linkage on Darwin from colm itself during build
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/libcolm\.so/libcolm.dylib/' src/main.cc || die
	fi

	eautoreconf
}

src_configure() {
	econf $(use_enable doc manual)
}

src_test() {
	# Build tests
	default

	# Run them
	cd test || die
	./runtests || die
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
