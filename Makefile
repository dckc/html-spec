# Makefile for HTML specification
# $Id$
#

# Things outside this distribution
ENV= SGML_PATH='./%N.%C:%N.dtd:%N.sgml'
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

DRAFT = HTML.txt
BIGDOC = html-spec-agg.sgml
BIGPRE = html-spec-pre.sgml

WIDTH=70
HTML2TXT = $(WWW) -n -na -p -w$(WIDTH)

HYPERTEXT = \
	HTML.html\
	StatusMeanings.html\
	AndMIME.html\
	Intro.html\
	Text.html\
	Tags.html\
	Elements/HEAD.html\
	Elements/BODY.html\
	Elements/A.html\
	Elements/ADDRESS.html\
	Elements/BASE.html\
	Elements/BLOCKQUOTE.html\
	Headings.html\
	Elements/IMG.html\
	Elements/ISINDEX.html\
	Elements/LINK.html\
	Lists.html\
	Elements/NEXTID.html\
	Elements/P.html\
	Elements/BR.html\
	Elements/HR.html\
	Elements/PRE.html\
	Elements/TITLE.html\
	Highlighting.html\
	NonStandard.html\
	LiteralHistory.html\
	Entities.html\
	ISOlat1.html\
	DTDHeading.html\
	HTML.dtd.html\
	Relationships.html\
	RegistrationAuthority.html\
	Acknowledgements.html\
	References.html\
	Authors.html

#@@	tolerated.html\

all: draft

draft: $(DRAFT)

$(DRAFT): $(HYPERTEXT)
	(for html in $(HYPERTEXT); do \
		$(HTML2TXT) $$html; \
	done;) >$@

snapshot:
	for html in $(HYPERTEXT); do \
		[ -f $$html ] || \
		  (echo $$html; \
		  $(WWW) -source $(HTML_SPEC_DIR)/$$html >$$html) ; \
	done

tarZ: $(PACKAGE).tar.Z

$(PACKAGE).tar.Z: $(DIST)
	tar cf $(PACKAGE).tar $(DIST)
	compress $(PACKAGE).tar

$(BIGDOC): $(BIGPRE)
	(cat $(BIGPRE); \
	for html in $(HYPERTEXT); do \
		b=`basename $$html .html`; \
		echo "<!ENTITY $$b SYSTEM '$$html' SUBDOC>" ; \
	done; \
	echo "]>" ; \
	for html in $(HYPERTEXT); do \
		b=`basename $$html .html`; \
		echo "&$$b;" ; \
	done;) >$@
	
validate: $(HYPERTEXT) $(BIGDOC)
	$(ENV) $(SGMLS) -s -e $(BIGDOC)

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
