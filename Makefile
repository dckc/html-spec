# Makefile for HTML specification
# $Id$
#

RELEASE = 19950531
PACKAGE = html-spec-$(RELEASE)

# Things outside this distribution
SGMLS = sgmls
# I use James Clark's groff...
NROFF = gnroff
TROFF = groff
MACROS = -mgs
#MACROS = -ms
TEXI2ROFF = texi2roff
TEXI2HTML = texi2html
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
SPEC=html-spec

SRCS = html.decl html.dtd html-1.dtd html-s.dtd html-1s.dtd\
	ISOlat1.sgml catalog \
	draft-status.sgm \
	snafu.decl html-spec.style \
	html-spec.sgm \
	intro.sgm html-sgml.sgm html-mime.sgm \
	elements.sgm head-elts.sgm doc-charset.sgm phrase.sgm hyperlink.sgm \
	blocks.sgm headings.sgm lists.sgm forms.sgm pubtext.sgm \
	references.sgm glossary.sgm acknowledgements.sgm \
	entity-sets.sgm iso-latin-1.sgm \
	obsolete.sgm proposed.sgm

ORIGINALS = Makefile $(SRCS) $(DTD) $(DTDAUX) $(DECL) \
	head.ms abstract.ms

HYPERTEXT = html-spec_toc.html \
	html-spec_foot.html \
	html-spec_1.html \
	html-spec_2.html \
	html-spec_3.html \
	html-spec_4.html \
	html-spec_5.html \
	html-spec_6.html \
	html-spec_7.html \
	html-spec_8.html \
	html-spec_9.html \
	html-spec_10.html \
	html-spec_11.html \
	html-spec_12.html



DIST = $(ORIGINALS)  \
	$(SPEC).txt $(SPEC).ps $(SPEC).texi $(HYPERTEXT)
DECL = html.decl
DTD = html.dtd
DTDAUX = html-1.dtd html-0.dtd
PLAINTEXT = html-spec.txt

all: hypertext hardcopy

hypertext: $(SPEC)_toc.html

$(SPEC)_toc.html: $(SPEC).texi
	$(TEXI2HTML) -doctype html2 -debug 8 -expandinfo -split_chapter -glossary Terms -bibliography References -verbose $(SPEC).texi

hardcopy: $(SPEC).ps $(SPEC).ps.gz

#$(SPEC).txt: $(SPEC).ms
#	$(NROFF) -Tascii $(MACROS) $(SPEC).ms >$@

$(SPEC).ps: $(SPEC).dvi
	dvips $(SPEC).dvi

$(SPEC).ps.gz: $(SPEC).ps
	gzip -c $(SPEC).ps >$(SPEC).ps.gz

$(SPEC).dvi: $(SPEC).texi
	texi2dvi $(SPEC).texi

#$(SPEC).dvi: $(SPEC).tex
#	latex $(SPEC).tex

$(SPEC).ms: $(SPEC).texi
	$(TEXI2ROFF) -ms $(SPEC).texi >$@

$(SPEC).texi: $(SRCS)
	$(GF) -s html-spec.style -f texinfo snafu.decl html-spec.sgm >$@

$(SPEC).tex: $(SRCS)
	$(GF) -s html-spec.style -f latex2e snafu.decl html-spec.sgm >$@


dist: $(PACKAGE).tar.gz

$(PACKAGE).tar.gz: $(DIST)
	tar cf $(PACKAGE).tar $(DIST)
	gzip $(PACKAGE).tar

#	cp $@ ../dist
#	rm $@
#	ln -s ../dist/$@


############ old stuff below here

ENV= SGML_PATH='./%N.%C:%N.dtd:%N.sgml'

#ORIGINALS = Makefile $(HYPERTEXT) $(DTD) $(DTDAUX) $(DECL) $(BIGPRE)
#DIST = README.html $(ORIGINALS) $(PLAINTEXT) $(INDEXES) $(BIGDOC)

INDEXES = \
	L0index.html \
	L0Pindex.html \
	L1index.html \
	L1Pindex.html \
	L2index.html \
	L2Pindex.html


BIGDOC = html-spec-agg.sgml
BIGPRE = html-spec-pre.sgml

WIDTH=70
HTML2TXT = $(WWW) -n -na -p -w$(WIDTH)

#HYPERTEXT = \
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



#all: validate canonicalize generate validate text

generate: $(INDEXES)

text: $(PLAINTEXT)

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
