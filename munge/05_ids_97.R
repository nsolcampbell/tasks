library(foreign)

psn97 <- data.frame(read.spss("data/curf/ids_1997/IDS97PSN.SAV"))

psn_sub <- psn97[,
	c("HRSWKMCP", # hpw, main job
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
	  "WTPSN"     # weight (person)
	  )]
psn_sub$hours <- as.numeric(gsub("\\D", "", psn_sub$HRSWKACP))

save(ids_97=psn_sub, file='data/ids_97.rda')
