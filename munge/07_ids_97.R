library(foreign)
library(doBy)

psn97 <- data.frame(read.spss("data/curf/ids_1997/IDS97PSN.SAV"))

sub <- psn97[,
	c("SEXP",
		"AGECP",
		"HRSWKMCP", # hpw, main job
	  "HRSWK2CP", # hpw, job 2
	  "HRSWKACP", # hpw main+2nd job
	  "LFSTBCP",  # LF status (both)
	  "DURUNEMP", # unemp duration
	  "OCCCP",    # occup. main job
	  "INDCP",    # ind. main job
	  "STOW",     # status in emp
	  "LKFTPTCP", # looked for work
	  "HQUALCP",  # highest qual >2dry
	  "STUDSTCP", # study status
	  "YRLSCHCP", # yr left schl (15-20)
	  "IWSUCP",   # curr wky j inc (both)
	  "IWSTPP",   # prev yr j inc (both)
		"IEARNCP",  # total current weekly earned income
		"IEARNPP",  # total pre fy earned income
	  "WTPSN"     # weight (person)
	  )]
sub$hours <- as.numeric(gsub("\\D", "", sub$HRSWKACP))

old_educ <- list(c("Higher degree", "Postgraduate diploma"), 
								 c("Bachelor degree"), 
								 c("Undergraduate diploma", "Associate diploma", 
								 	"Skilled vocational qualifications", "Basic vocational qualifications"),
								 c("Still at school","No qualifications"))
new_educ <- list("Postgraduate","Bachelor","Associate Degree","None")
sub$Educ <- recodeVar(as.character(sub$HQUALCP), src=old_educ, tgt=new_educ)
sub$Educ <- factor(sub$Educ, ordered=TRUE, levels=new_educ)

old_educ <- list(c("Higher degree", "Postgraduate diploma", "Bachelor degree"), 
								 c("Undergraduate diploma", "Associate diploma", 
								 	"Skilled vocational qualifications", "Basic vocational qualifications"),
								 c("Still at school","No qualifications"))
new_educ <- list("Bachelor or Higher","Associate Degree","None")
sub$Educ3 <- recodeVar(as.character(sub$HQUALCP), src=old_educ, tgt=new_educ)
sub$Educ3 <- factor(sub$Educ3, ordered=TRUE, levels=new_educ)

ids_97 <- sub
save(ids_97, file='data/ids_97.rda')
