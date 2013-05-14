bibliographyfile = annotated_bibliography
thesisfile = thesis

figures =

referencefile = Polarization

TEX = pdflatex

VPATH = Figs

all: thesis bibliography

wc: 
	echo `cat chapter*tex | detex | wc -w` words.

thesis: $(thesisfile).pdf

bibliography: $(bibliographyfile).pdf

$(bibliographyfile).pdf : $(bibliographyfile).tex $(bibliographyfile).bbl
	while ($(TEX) $(bibliographyfile) ; \
	grep -q "Rerun to get cross" $(bibliographyfile).log ) do true ; \
	done

$(thesisfile).pdf : $(figures) $(thesisfile).tex
	while ($(TEX) $(thesisfile) ; \
	grep -q "Rerun to get cross" $(thesisfile).log ) do true ; \
	done

# keep .eps files in the same directory as the .fig files
# %.eps : %.fig
#	fig2dev -L eps $< > $(dir $< )$@

pdf : $(thesisfile).pdf

# because we're insane, we're using bibtex for the bibliography
$(bibliographyfile).bbl : $(bibliographyfile).tex $(referencefile).bib
	if [ -a ../../BibTeX/Polarization.bib ] ; \
	then \
	  rm Polarization.bib ; \
	  sed -E '1d;2d;3d;s/^[ 	]+$$/\\par/' ../../BibTeX/Polarization.bib > Polarization.bib ; \
	fi;
	pdflatex $(bibliographyfile)
	bibtex $(bibliographyfile)

$(bibliographyfile).tar.gz : $(figures) $(bibliographyfile).tex $(referencefile).bib
	tar -czvf $(bibliographyfile).tar.gz $^

mostlyclean:
	rm -f $(bibliographyfile).log $(bibliographyfile).aux $(bibliographyfile).bbl $(bibliographyfile).blg $(bibliographyfile).aux
	rm -f $(thesisfile).log $(thesisfile).aux $(thesisfile).bcf $(thesisfile).blg $(thesisfile).aux $(thesisfile).run.xml $(thesisfile).toc $(thesisfile).lot
	rm -f chapter_*.aux chapter_*.blg title.aux appendix_*.aux abstract.aux

clean: mostlyclean
	rm -f $(bibliographyfile).pdf $(thesisfile).pdf

