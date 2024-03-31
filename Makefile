#**************************************************************************
#** Copyright (c) 2023 THOR Software                                     **
#**                                                                      **
#** Written by Thomas Richter (THOR Software) for Accusoft               **
#** All Rights Reserved                                                  **
#**************************************************************************
#
#	$Id: Makefile,v 1.17 2012/05/02 12:51:15 thor Exp $
#
###############################################################################
#                 							      #
# Makefile for the RKRM dos documentation in TeX                              #
#									      #
###############################################################################
#
#	some deklarations, external commands i.e.
#
VIEWER		=	xdvi
GHOSTVIEW	=	gv
DVIPS		=	dvips
FIG2DEV		=	fig2dev
EPSTOPDF	=	epstopdf
TEX		=	latex
PDFLATEX	=	pdflatex
MAKEINDEX	=	makeindex
PRINT		=	lpr
PROPTIONS	=
DVIPSPRINTOPS	=
DVIPSPDFOPTS	=	-P pdf
PSTOPDF		=	ps2pdf
PSTOPDFOPTIONS	=	-dCompatibilityLevel=1.2
ACROREAD	=	xpdf
PS2TXT		=	pstotext
#
#
#
#

#
#	The main file
#
MAIN		=	dos
#
#	.fig figures
#
FIGURES		=

PSFIGURES	=	$(patsubst %.fig,%.pst,$(FIGURES))

TEXFIGURES	=	$(patsubst %.fig,%.txi,$(FIGURES))

ROTFIGURES	=	$(patsubst %.fig,%.ftg,$(FIGURES))

PSINCLUDE	=	

TEXSOURCES	=	$(MAIN).tex

#
#	Main make rules
#

view	:	$(MAIN).pdf
	@ $(ACROREAD) $(MAIN).pdf &

gv	:	$(MAIN).ps
	@ $(GHOSTVIEW) $(MAIN).ps &

print	:	$(MAIN).ps
	@ $(PRINT) $(PROPTIONS) $(MAIN).ps	

pdf	:	$(MAIN).pdf
	@ $(ACROREAD) $(MAIN).pdf

clean	:
	@ rm -f *.ps *.dvi *.ftg *.txi *.pst *.pspdf *.log *.ind *.idx *.toc *.aux *~ *.bak *.pdf *.lot *.lof core

#
#
#	default dependencies
#
%.dvi	:	%.tex
.PRECIOUS:	%.idx %.ind
#
%.dvi	:	%.tex %.ind
	@ $(TEX) $*.tex
	@ grep -c '^LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right' $*.log > /dev/null 2>&1 && $(TEX) $*.tex || :
	@ $(MAKEINDEX) -c $*

%.pdf	:	%.tex %.ind	front-page.pdf back-page.pdf
	@ $(PDFLATEX) $*.tex
	@ grep -c '^LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right' $*.log > /dev/null 2>&1 && $(TEX) $*.tex || :
	@ $(MAKEINDEX) -c $*
	@ mv dos.pdf tmp.pdf && pdfunite front-page.pdf tmp.pdf back-page.pdf dos.pdf
	@ pdftops $*.pdf
	@ $(PSTOPDF) -dPDFSETTINGS=/prepress $*.ps

%.ind	:	%.idx
	@ $(MAKEINDEX) -c $*

%.idx	:	%.tex
	@ $(TEX) $*.tex
	@ grep -c '^LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right' $*.log > /dev/null 2>&1 && $(TEX) $*.tex || :

%.ps	:	%.dvi
	@ $(DVIPS) $(DVIPSPRINTOPTS) $*

%.pspdf	:	%.dvi
	@ $(DVIPS) $(DVIPSPDFOPTS) $*

%.pdf	:	%.pspdf
	@ $(PSTOPDF) $(PSTOPDFOPTIONS) $*.ps $*.pdf

%.ftg	:	%.fig
	@ sed 's/Landscape/Portrait/' <$*.fig >$*.ftg

%.txi	:	%.ftg
	@ $(FIG2DEV) -L pstex_t -m 0.3 >$*.txi <$*.ftg -p $*.pst

%.pst	:	%.ftg
	@ $(FIG2DEV) -L pstex -m 0.3 >$*.pst <$*.ftg

%.txt	:	%.ps
	@ $(PS2TXT) <$*.ps >$*.txt
#
#
# Detailed dependencies
#
#

$(MAIN).dvi	: $(TEXSOURCES) $(TEXFIGURES) $(FIGURES) $(ROTFIGURES) $(PSFIGURES)
$(MAIN).ps	: $(MAIN).dvi $(PSINCLUDE) $(PSFIGURES)
$(MAIN).pdf	: $(TEXSOURCES) $(TEXFIGURES) $(FIGURES) $(ROTFIGURES) $(PSFIGURES)
