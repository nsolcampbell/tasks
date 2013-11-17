bibliographyfile = annotated_bibliography
paperfile = paper
slidesfile = slides

figures =

referencefile = Polarization

TEX = pdflatex

VPATH = Figs

all: paper bib slides

wc: 
	echo `cat abstract.tex chapter*tex appendix*tex | detex | wc -w` words.

paper: $(paperfile).pdf

bib: $(bibliographyfile).pdf

slides: $(slidesfile).pdf

$(bibliographyfile).pdf : $(bibliographyfile).tex $(bibliographyfile).bbl
	while ($(TEX) $(bibliographyfile) ; \
	grep -Eq "Please rerun LaTeX|Rerun to get cross-references" $(bibliographyfile).log ) do true ; \
	done

$(paperfile).pdf : $(figures) $(paperfile).tex $(paperfile).bbl $(bibliographyfile).bbl
	while ($(TEX) $(paperfile) ; \
	grep -Eq "Please rerun LaTeX|Rerun to get cross-references" $(paperfile).log ) do true ; \
	done

$(slidesfile).pdf : $(figures) $(slidesfile).tex $(slidesfile).bbl $(bibliographyfile).bbl
	while ($(TEX) $(slidesfile) ; \
	grep -Eq "Please rerun LaTeX|Rerun to get cross-references" $(slidesfile).log ) do true ; \
	done

$(paperfile).bbl:
	pdflatex $(paperfile)
	biber $(paperfile)

$(slidesfile).bbl:
	pdflatex $(slidesfile)
	biber $(slidesfile)

# keep .eps files in the same directory as the .fig files
# %.eps : %.fig
#	fig2dev -L eps $< > $(dir $< )$@

pdf : $(paperfile).pdf

# Because we're insane, we're using bibtex for the bibliography
# and biblatex for the paper itself. Just easier.
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
	rm -f $(bibliographyfile).log $(bibliographyfile).aux $(bibliographyfile).bbl \
	      $(bibliographyfile).blg $(bibliographyfile).aux
	rm -f $(paperfile).log $(paperfile).aux $(paperfile).bcf $(paperfile).blg \
	      $(paperfile).aux $(paperfile).run.xml $(paperfile).toc $(paperfile).lot \
	      $(paperfile).out $(paperfile).bbl
	rm -f chapter_*.aux chapter_*.blg title.aux appendix_*.aux abstract.aux
	rm -f $(slidesfile).log $(slidesfile).aux $(slidesfile).bcf $(slidesfile).blg \
	      $(slidesfile).aux $(slidesfile).run.xml $(slidesfile).toc $(slidesfile).lot \
	      $(slidesfile).out $(slidesfile).bbl $(slidesfile).nav $(slidesfile).snm \
	      $(slidesfile).vrb $(slidesfile).lot 

clean: mostlyclean
	rm -f $(bibliographyfile).pdf $(paperfile).pdf $(slidesfile).pdf
