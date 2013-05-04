# set latexfile to the name of the main file without the .tex
latexfile = annotated_bibliography
# put the names of figure files here.  include the .eps
figures =

# if no references, run "touch latexfile.bbl; touch referencefile.bib"
# or delete dependency in .dvi and tarball sections
referencefile = Polarization

TEX = pdflatex

# support subdirectories
VPATH = Figs

# reruns latex if needed.  to get rid of this capability, delete the
# three lines after the rule.  Delete .bbl dependency if not using
# BibTeX references.
# idea from http://ctan.unsw.edu.au/help/uk-tex-faq/Makefile
$(latexfile).pdf : $(figures) $(latexfile).tex $(latexfile).bbl
	while ($(TEX) $(latexfile) ; \
	grep -q "Rerun to get cross" $(latexfile).log ) do true ; \
	done

# keep .eps files in the same directory as the .fig files
%.eps : %.fig
	fig2dev -L eps $< > $(dir $< )$@

pdf : $(latexfile).pdf

$(latexfile).bbl : $(latexfile).tex $(referencefile).bib
	pdflatex $(latexfile)
	bibtex $(latexfile)

# make can't know all the sourcefiles.  some file may not have
# sourcefiles, e.g. eps's taken from other documents. 
$(latexfile).tar.gz : $(figures) $(latexfile).tex $(referencefile).bib
	tar -czvf $(latexfile).tar.gz $^

tarball: $(latexfile).tar.gz

clean:
	rm -f $(latexfile).log $(latexfile).aux $(latexfile).bbl $(latexfile).blg $(latexfile).aux
