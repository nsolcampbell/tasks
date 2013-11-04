DOC_DIR = doc
EXPLORE_DIR = explore

all: docs analysis

docs:
	$(MAKE) -C $(DOC_DIR) all

thesis:
	$(MAKE) -C $(DOC_DIR) thesis

analysis:

explore:
	$(MAKE) -C $(EXPLORE_DIR) html

clean:
	$(MAKE) -C $(DOC_DIR) clean

mungedata:
	for f in `ls munge/*R`; do R -q -f $$f; done

quantreg:
	R -q -f munge/40_combine_anzsco_onet.R && R -q -f munge/50_weight_onet_anzsco.R && R -q -f analysis/quant_reg_i.R && R -q -f analysis/quant_reg_ii.R && cat analysis/quant_reg_*.txt

	# top and tail the latex tables,
	# remove some junk
	egrep -v '\\(begin|end)\{document\}|usepackage|documentclass|rotating' analysis/quant_reg_i.tex | sed -e 's/df = //g' > doc/quant_reg_i.tex
	egrep -v '\\(begin|end)\{document\}|usepackage|documentclass|rotating' analysis/quant_reg_ii.tex | sed -e 's/df = //g' > doc/quant_reg_ii.tex

share:
	R -q -f analysis/wage_share.R
	egrep -v '\\(begin|end)\{document\}|usepackage|documentclass|rotating' analysis/share_table.tex | sed -e 's/df = //g' > doc/share_table.tex

