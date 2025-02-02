# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="com.thoughtworks.qdox:qdox:1.12.1"

inherit java-pkg-2

DESCRIPTION="Parser for extracting class/interface/method definitions"
HOMEPAGE="https://github.com/codehaus/qdox"
SRC_URI="https://github.com/codehaus/qdox/archive/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1.12"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~ppc-macos ~x64-macos"

S="${WORKDIR}/${PN}-${PN}-${PV}"

CDEPEND="dev-java/ant-core:0"

DEPEND=">=virtual/jdk-1.8:*
	dev-java/byaccj:0
	>=dev-java/jflex-1.6.1:0
	dev-java/jmock:1.0
	test? ( dev-java/junit:0 )
	${CDEPEND}"

RDEPEND=">=virtual/jre-1.8:*
	${CDEPEND}"

PATCHES=(
	"${FILESDIR}/jflex-1.6.1.patch"
)

src_prepare() {
	default

	if ! use test ; then
		rm src/java/com/thoughtworks/qdox/tools/QDoxTester.java
		rm -rf src/java/com/thoughtworks/qdox/junit
		rm -rf src/test
	fi
}

src_compile() {
	jflex src/grammar/lexer.flex --skel src/grammar/skeleton.inner -d src/java/com/thoughtworks/qdox/parser/impl/ || die
	byaccj -v -Jnorun -Jnoconstruct -Jclass=Parser -Jsemantic=Value -Jpackage=com.thoughtworks.qdox.parser.impl src/grammar/parser.y || die
	mv Parser.java src/java/com/thoughtworks/qdox/parser/impl/ || die

	# create jar
	mkdir -p build/classes || die

	local cp="$(java-pkg_getjars --build-only ant-core,jmock-1.0)"

	if use test ; then
		cp="${cp}:$(java-pkg_getjars --build-only junit)"
	fi

	ejavac -sourcepath . -d build/classes -classpath "${cp}" \
		$(find . -name "*.java") || die "Cannot compile sources"

	mkdir dist || die
	cd build/classes || die
	jar -cvf "${S}"/dist/${PN}.jar com || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd "${S}"
		mkdir javadoc || die
		javadoc -d javadoc -sourcepath src/java -subpackages com -classpath "${cp}"
	fi
}

src_test() {
	java -cp "${S}"/dist/${PN}.jar:$(java-pkg_getjars --build-only ant-core,junit,jmock-1.0) \
		com.thoughtworks.qdox.tools.QDoxTester src || die "Tests failed!"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use source && java-pkg_dosrc src/java/com
	use doc && java-pkg_dojavadoc javadoc
}
