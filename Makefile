# Makefile for HTML specification
# $Id$
#

# Things outside this distribution
SGMLS = sgmls
WWW = www
HTML_SPEC_DIR = http://info.cern.ch/hypertext/WWW/MarkUp

#
# "No user-serviceable parts inside"
#
ORIGINALS = Makefile $(HYPERTEXT)
RELEASE = 199404??
PACKAGE = html_spec-$(RELEASE)
DTD = HTML.dtd
DECL = HTML.sgml

DRAFT = draft-iiir-html-02.txt

HTML2TXT = $(WWW) -n -na -p

HYPERTEXT = HTML.html \
	StatusMeanings.html \
	AndMIME.html \
	Intro.html \
	Text.html \
	Tags.html \
	Entities.html \
	DTDHeading.html \
	Relationships.html \
	RegistrationAuthority.html \
	Acknowledgements.html \
	References.html \
	Authors.html

all: draft

draft: $(DRAFT)

$(DRAFT): $(HYPERTEXT)
	(for html in $(HYPERTEXT); do \
		$(HTML2TXT) $$html; \
	done;) >$@

snapshot:
	for html in $(HYPERTEXT); do \
		$(WWW) -source $(HTML_SPEC_DIR)/$$html >$$html ; \
	done

tarZ: $(PACKAGE).tar.Z

$(PACKAGE).tar.Z: $(DIST)
	tar cf $(PACKAGE).tar $(DIST)
	compress $(PACKAGE).tar

validate: $(HYPERTEXT)
	(for sgml in $(HYPERTEXT); do \
	   echo $$sgml; \
	   (sgmls -s $(DECL) before $$sgml after || exit 0); \
	 done;) >$@ 2>&1
	rm before after

# Obsolete
IDTK = ../../installed
ARCH = sun4
BOOK = /doc/idtk/html/HTML.book
FMBATCH =  /fonts/Frame3.1X/bin/fmbatch
PROG = ../sgml_test
#HYPERTEXT = HTML.html Intro.html Text.html References.html HTML.dtd.html

hypertext:
	PATH=$${PATH}:$(IDTK)/bin:$(IDTK)/bin/$(ARCH) convert_book \
		debug=1 \
		idtk=$(IDTK) \
		fmt=html \
		filters= \
		extension=html \
		fmbatchcmd="$(FMBATCH)" \
		$(BOOK)

libtest: $(HYPERTEXT) $(PROG)
	for html in $(HYPERTEXT); do \
	   echo $$html; \
	   $(PROG) HTML HTML <$$html >1; \
	   $(PROG) HTML HTML <1 >2; \
	   diff -c 1 2 || true; \
	 done;
	rm 1 2
