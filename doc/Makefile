bibliographyfile = annotated_bibliography
thesisfile = thesis

figures =

referencefile = Polarization

TEX = pdflatex

VPATH = Figs

all: thesis bib

wc: 
	echo `cat chapter*tex | detex | wc -w` words.

thesis: $(thesisfile).pdf

bib: $(bibliographyfile).pdf

$(bibliographyfile).pdf : $(bibliographyfile).tex $(bibliographyfile).bbl
	while ($(TEX) $(bibliographyfile) ; \
	grep -Eq "Please rerun LaTeX|Rerun to get cross-references" $(bibliographyfile).log ) do true ; \
	done

$(thesisfile).pdf : $(figures) $(thesisfile).tex $(thesisfile).bbl $(bibliographyfile).bbl
	while ($(TEX) $(thesisfile) ; \
	grep -Eq "Please rerun LaTeX|Rerun to get cross-references" $(thesisfile).log ) do true ; \
	done

$(thesisfile).bbl:
	pdflatex $(thesisfile)
	biber $(thesisfile)

# keep .eps files in the same directory as the .fig files
# %.eps : %.fig
#	fig2dev -L eps $< > $(dir $< )$@

pdf : $(thesisfile).pdf

# Because we're insane, we're using bibtex for the bibliography
# and biblatex for the thesis itself. Just easier.
# We're also exporting directly from the reference manager.
# This is hard-coded for my environment, so let it use the bib
# file in SCM.
$(bibliographyfile).bbl : $(bibliographyfile).tex $(referencefile).bib
	if [ -a ../../BibTeX/Polarization.bib ] ; \
	then \
	  rm -f Polarization.bib ; \
	  sed -E '1d;2d;3d;s/^[ 	]*$$/\\par/' ../../BibTeX/Polarization.bib > Polarization.bib ; \
	fi;
	pdflatex $(bibliographyfile)
	bibtex $(bibliographyfile)

# no deps: so always try to copy bib file, if available.
$(referencefile).bib :
	if [ -a ../../BibTeX/$(referencefile).bib ] ; \
	then \
	  rm -f $(referencefile).bib ; \
	  sed -E '1d;2d;3d;s/^[         ]*$$/\\par/' ../../BibTeX/$(referencefile).bib > $(referencefile).bib ; \
	fi;

$(bibliographyfile).tar.gz : $(figures) $(bibliographyfile).tex $(referencefile).bib
	tar -czvf $(bibliographyfile).tar.gz $^

mostlyclean:
	rm -f $(bibliographyfile).log $(bibliographyfile).aux $(bibliographyfile).bbl $(bibliographyfile).blg $(bibliographyfile).aux
	rm -f $(thesisfile).log $(thesisfile).aux $(thesisfile).bcf $(thesisfile).blg $(thesisfile).aux $(thesisfile).run.xml \
		$(thesisfile).toc $(thesisfile).lot $(thesisfile).out $(thesisfile).bbl
	rm -f chapter_*.aux chapter_*.blg title.aux appendix_*.aux abstract.aux

clean: mostlyclean
	rm -f $(bibliographyfile).pdf $(thesisfile).pdf

