latexfile = annotated_bibliography

figures =

referencefile = Polarization

TEX = pdflatex

VPATH = Figs

$(latexfile).pdf : $(figures) $(latexfile).tex $(latexfile).bbl
	while ($(TEX) $(latexfile) ; \
	grep -q "Rerun to get cross" $(latexfile).log ) do true ; \
	done

# keep .eps files in the same directory as the .fig files
# %.eps : %.fig
#	fig2dev -L eps $< > $(dir $< )$@

pdf : $(latexfile).pdf

$(latexfile).bbl : $(latexfile).tex $(referencefile).bib
	if [ -a ../../BibTeX/Polarization.bib ] ; \
	then \
	  rm Polarization.bib ; \
	  cp ../../BibTeX/Polarization.bib . ; \
	fi;
	pdflatex $(latexfile)
	bibtex $(latexfile)

$(latexfile).tar.gz : $(figures) $(latexfile).tex $(referencefile).bib
	tar -czvf $(latexfile).tar.gz $^

clean:
	rm -f $(latexfile).log $(latexfile).aux $(latexfile).bbl $(latexfile).blg $(latexfile).aux
