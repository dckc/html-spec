# Makefile for HTML specification
# $Id$
#

# Things outside this distribution
ENV= SGML_PATH='./%N.%C:%N.dtd:%N.sgml'
SGMLS = sgmls
PERL=perl
PYTHON = python

WWW = www
HTML_SPEC_DIR = http://info.cern.ch/hypertext/WWW/MarkUp2
CANON_FILTER = test_html -c
DTDTOOL=www_dtd.pl

#
# "No user-serviceable parts inside"
#
RELEASE = 19940603
PACKAGE = html-spec-$(RELEASE)

ORIGINALS = Makefile $(HYPERTEXT) $(DTD) $(DECL) $(BIGPRE)
DIST = README.html $(ORIGINALS) $(PLAINTEXT) $(ELTINDEX) $(BIGDOC)
DTD = html.dtd
DECL = html.decl
ELTINDEX = ElementIndex.html

PLAINTEXT = HTML.txt
BIGDOC = html-spec-agg.sgml
BIGPRE = html-spec-pre.sgml

WIDTH=70
HTML2TXT = $(WWW) -n -na -p -w$(WIDTH)

HYPERTEXT = \
   HTML.html \
     StatusMeanings.html \
   AndMIME.html \
   Intro.html \
   Text.html \
   Tags.html \
     Elements/HEAD.html \
     Elements/TITLE.html \
     Elements/ISINDEX.html \
     Elements/LINK.html \
     Elements/BASE.html \
     Elements/NEXTID.html \
	\
     Elements/BODY.html \
     Elements/A.html \
       URN.html \
       Elements/LinkTitle.html \
       Elements/LinkMethods.html \
	\
     Headings.html \
     Elements/P.html \
     Elements/BR.html \
     Highlighting.html \
     Elements/IMG.html \
     Elements/HR.html \
     Elements/ADDRESS.html \
     Elements/BLOCKQUOTE.html \
     Lists.html \
     Elements/PRE.html \
	\
     Forms.html \
       Elements/FORM.html \
       Elements/INPUT.html \
       Elements/TEXTAREA.html \
       Elements/SELECT.html \
       Elements/OPTION.html \
	\
     NonStandard.html \
       LiteralHistory.html \
   Entities.html \
     ISOlat1.html \
   Security.html \
   Acknowledgements.html \
   References.html \
   Authors.html

TEXT = \
   html.decl \
   html.dtd \

#   DeclHeading.html \
#   DTDHeading.html \
#     IETF/Draft-Disclaimer.html \
#	Relationships.html\
#	RegistrationAuthority.html\



all: validate canonicalize generate validate text

generate: $(ELTINDEX)

text: $(PLAINTEXT)

HEADER =  HTML Specification    Connolly and Berners-Lee
FF = $(PERL) -e 'print "\f"'

$(PLAINTEXT): $(HYPERTEXT) $(ELTINDEX) $(DTD) $(DECL)
	(for html in $(HYPERTEXT) $(ELTINDEX); do \
		$(HTML2TXT) $$html | pr -f -h '$(HEADER)'; \
		$(FF); \
	done; \
	pr -f -h '$(HEADER)' $(DTD); $(FF); \
	pr -f -h '$(HEADER)' $(DTD); $(FF); ) >$@

missing:
	for html in $(HYPERTEXT); do \
		[ -f $$html ] || \
		  (echo $$html; \
		  $(WWW) -source $(HTML_SPEC_DIR)/$$html >$$html) ; \
	done

snapshot:
	for html in $(HYPERTEXT); do \
		  (echo $$html; \
		  $(WWW) -source $(HTML_SPEC_DIR)/$$html >$$html) ; \
	done


README.html: index.html
	ln -s index.html README.html

dist: $(PACKAGE).tar.gz

$(PACKAGE).tar.gz: $(DIST)
	tar cf $(PACKAGE).tar $(DIST)
	gzip $(PACKAGE).tar
	cp $@ ../dist
	rm $@
	ln -s ../dist/$@

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
	$(ENV) $(SGMLS) -s -e $(DECL) $(ELTINDEX)
	touch $@

$(ELTINDEX): $(HYPERTEXT) $(DTD) $(DTDTOOL)
	$(PERL) $(DTDTOOL) -hypertext HTML $(HYPERTEXT) <$(DTD) >$@

canonicalize: $(HYPERTEXT)
	for h in $(HYPERTEXT); do \
		$(CANON_FILTER) <$$h >,xxx; \
		mv ,xxx $$h; \
	done
	touch $@

mif: HTML-1.mif HTML-2.mif

MIF_STYLESHEET = mif/template.mif
PYWWW = ../pywww
HTML2MIF = PYTHONPATH=$(PYWWW) $(PYTHON) $(PYWWW)/MIFReport.py

HTML-1.mif: $(HYPERTEXT)
	$(HTML2MIF) $(HYPERTEXT) >$@

HTML-2.mif: $(ELTINDEX)
	$(HTML2MIF) -section $(ELTINDEX) >$@

