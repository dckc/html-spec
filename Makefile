# Makefile for HTML specification
# $Id$
#

# Things outside this distribution
SGMLS = sgmls
NROFF = nroff
TROFF = troff
# I use the gnu stuff...
MACROS = -mgm
#MACROS = -ms
TEXI2ROFF = texi2roff
GF = gf

PERL=perl
PYTHON = python

WWW = www
HTML_SPEC_DIR = 'http://info.cern.ch/hypertext/WWW/MarkUp2'
CANON_FILTER = test_html -c
DTDTOOL=www_dtd.pl

#
# "No user-serviceable parts inside"
#
INTERNET_DRAFT=draft-ietf-html-spec-03

SRCS = html.decl html.dtd ISOlat1.sgml catalog \
	snafu.decl html-spec.sgm \
	conformance.sgm intro.sgm terms.sgm html-sgml.sgm html-mime.sgm \
	elements.sgm head-elts.sgm doc-charset.sgm phrase.sgm hyperlink.sgm \
	blocks.sgm headings.sgm lists.sgm forms.sgm pubtext.sgm

submit: $(INTERNET_DRAFT).txt $(INTERNET_DRAFT).ps

$(INTERNET_DRAFT).txt: $(INTERNET_DRAFT).mm
	$(NROFF) -Tascii $(MACROS) $(INTERNET_DRAFT).mm >$@

$(INTERNET_DRAFT).ps: $(INTERNET_DRAFT).mm
	$(TROFF) $(MACROS) -Tps $(INTERNET_DRAFT).mm >$@

$(INTERNET_DRAFT).mm: $(INTERNET_DRAFT).texi
	$(TEXI2ROFF) -mm $(INTERNET_DRAFT).texi >$@

$(INTERNET_DRAFT).texi: $(SRCS)
	$(GF) -f texinfo snafu.decl html-spec.sgm >$@


RELEASE = 19940613
PACKAGE = html-spec-$(RELEASE)
ENV= SGML_PATH='./%N.%C:%N.dtd:%N.sgml'

ORIGINALS = Makefile $(HYPERTEXT) $(DTD) $(DTDAUX) $(DECL) $(BIGPRE)
DIST = README.html $(ORIGINALS) $(PLAINTEXT) $(INDEXES) $(BIGDOC)
DTD = html.dtd
DTDAUX = html-1.dtd html-0.dtd
DECL = html.decl

INDEXES = \
	L0index.html \
	L0Pindex.html \
	L1index.html \
	L1Pindex.html \
	L2index.html \
	L2Pindex.html


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
     Elements/META.html \
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
   html.dtd

#   DeclHeading.html
#   DTDHeading.html
#     IETF/Draft-Disclaimer.html
#	Relationships.html
#	RegistrationAuthority.html



all: validate canonicalize generate validate text

generate: $(INDEXES)

text: $(PLAINTEXT)

HEADER =  HTML Specification    Connolly and Berners-Lee
FF = $(PERL) -e 'print "\f"'

$(PLAINTEXT): $(HYPERTEXT) $(INDEXES) $(DTD) $(DTDAUX) $(DECL)
	(for html in $(HYPERTEXT) $(INDEXES); do \
		$(HTML2TXT) $$html | pr -f -h '$(HEADER)'; \
		$(FF); \
	done; \
	pr -f -h '$(HEADER)' $(DECL); $(FF); \
	pr -f -h '$(HEADER)' html-0.dtd; $(FF); \
	pr -f -h '$(HEADER)' html-1.dtd; $(FF); \
	pr -f -h '$(HEADER)' html.dtd; $(FF); \
	) >$@

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
	touch $@

L0index.html: $(HYPERTEXT) html-0.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
			HTML $(HYPERTEXT) <html-0.dtd >$@

L0Pindex.html: $(HYPERTEXT) html-0s.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
		HTML $(HYPERTEXT) <html-0s.dtd >$@

L1index.html: $(HYPERTEXT) html-1.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
		HTML $(HYPERTEXT) <html-1.dtd >$@

L1Pindex.html: $(HYPERTEXT) html-1.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
		HTML $(HYPERTEXT) <html-1s.dtd >$@

L2index.html: $(HYPERTEXT) html.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
		HTML $(HYPERTEXT) <html.dtd >$@

L2Pindex.html: $(HYPERTEXT) html-s.dtd $(DTDTOOL)
	$(ENV) $(PERL) $(DTDTOOL) -nodiscussion -hypertext \
		HTML $(HYPERTEXT) <html-s.dtd >$@


canonicalize: $(HYPERTEXT)
	for h in $(HYPERTEXT); do \
		$(CANON_FILTER) <$$h >,xxx; \
		mv ,xxx $$h; \
	done
	touch $@

mif: HTML-1.mif

MIF_STYLESHEET = mif/template.mif
PYWWW = ../pywww
HTML2MIF = PYTHONPATH=$(PYWWW) $(PYTHON) $(PYWWW)/MIFReport.py
HTML2MIFN = PYTHONPATH=$(PYWWW) $(PYTHON) $(PYWWW)/MIFNodeSet.py

HTML-1.mif: $(HYPERTEXT)
	$(HTML2MIF) $(HYPERTEXT) >$@

#@@ need to redo this!
HTML-2.mif: $(ELTINDEX)
	$(HTML2MIF) -section $(ELTINDEX) >$@

HTML-Ref.N.doc: $(ELTINDEX)
	$(HTML2MIFN) -section L2Pindex.html >$@

HTML-0Ref.N.doc: $(ELTINDEX)
	$(HTML2MIFN) -section L0Pindex.html >$@


ChangeLog:
	folder +cm
	inc +cm -file $$HOME/cm/CVSROOT/commit.mbox
	pick +cm --module web/html-spec
	rmm notp
	packf -file ChangeLog
