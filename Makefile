# Makefile for HTML specification
# $Id$
#

# Things outside this distribution
ENV= SGML_PATH='./%N.%C:%N.dtd:%N.sgml'
SGMLS = sgmls
PERL=perl

WWW = www
HTML_SPEC_DIR = http://info.cern.ch/hypertext/WWW/MarkUp
CANON_FILTER = test_html -c
DTDTOOL=www_dtd.pl

#
# "No user-serviceable parts inside"
#
ORIGINALS = Makefile $(HYPERTEXT)
RELEASE = 199404??
PACKAGE = html_spec-$(RELEASE)
DTD = html.dtd
DECL = html.decl

ELTINDEX = ElementIndex.html

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
	Acknowledgements.html\
	References.html\
	Authors.html \

#@@	tolerated.html\
#@@	HTML.dtd.html\
#	Relationships.html\
#	RegistrationAuthority.html\
#	DTDHeading.html\

all: validate canonicalize generate validate text

generate: $(ELTINDEX)

text: $(DRAFT)

HEADER =  HTML Specification    Connolly and Berners-Lee
FF = $(PERL) -e 'print "\f"'

$(DRAFT): $(HYPERTEXT) $(ELTINDEX) $(DTD) $(DECL)
	(for html in $(HYPERTEXT) $(ELTINDEX); do \
		$(HTML2TXT) $$html | pr -f -h '$(HEADER)'; \
		$(FF); \
	done; \
	pr -f -h '$(HEADER)' $(DTD); $(FF); \
	pr -f -h '$(HEADER)' $(DTD); $(FF); ) >$@

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
	touch $@

$(ELTINDEX): $(HYPERTEXT) $(DTD) $(DTDTOOL)
	$(PERL) $(DTDTOOL) -hypertext HTML $(HYPERTEXT) <$(DTD) >$@

canonicalize: $(HYPERTEXT)
	for h in $(HYPERTEXT); do \
		$(CANON_FILTER) <$$h >,xxx; \
		mv ,xxx $$h; \
	done
	touch $@

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
