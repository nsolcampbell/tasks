library(foreign)
library(doBy)

inc_h_94 <- data.frame(read.spss('data/curf/inc_h_94_98/IDS94PSN.SAV'))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

keepcols <- c("SEXP", 
							"AGECP", 
							"LFSTFCP", # Labor force status, main job
							"LFST2CP", # Labor force status, second job
							"HRSWKMCP",# Usual HPW, main job
							"HRSWK2CP",# Usual HPW, second job
							"HRSWKACP",# Usual HPW, both jobs
							"LFSTBCP", # LF status, both jobs
							"OCCCP",   # Occupation, main job
							"INDCP",   # Industry, main job
							"HQUALCP", # Highest post-secondary education
							"STUDSTCP",# Study status
							"YRLSCHCP",# Year left school
							"MTHSCHCP",# Month left school
							"IWSUCP",  # Total current weekly employee income from wages and salaries from main and second jobs
							"IOBTCP",  # Current weekly income from own unincorporated business
							"IOBTCPF", # Current weekly income from own unincorporated business flag
							"IEARNCP", # Total current weekly earned income
							"IWSTPP",  # Total previous financial year income from wages and salaries
							"IEARNPP", # Total previous financial year earned income
							"PSRCCP",  # Principal source of current weekly income
							"WTPSN"    # Person weight
)
repcols <- paste("REPWT",1:30,sep="")

# exclude non-income earners (excl retirees, those living on benefits/passive income)
inc_earners <- inc_h_94$PSRCCP %in% c("Wages and salaries", 
																			"Own unincorporated business income")

# include only full-time workers
ft <- inc_h_94$LFSTBCP == "Employed full-time"

keeprows = ft & inc_earners

sub <- inc_h_94[keeprows,c(keepcols,repcols)]

# eliminate < 1,000 per year earners as noise
sub <- sub[sub$IEARNPP >= 1000,]

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

sub$SEXP <- recodeVar(as.character(sub$SEXP), 
										  src=list("Males","Females"), tgt=list("Male","Female"))

# TODO: derive potential experience series

sub$ScaledWeight <- sub$WTPSN / as.numeric(sum(sub$WTPSN))

# come up with education weights
for (ed in levels(sub$Educ)) {
	this_level <- which(sub$Educ == ed)
	sub[this_level,"EducWeight"] <- sub[this_level,"WTPSN"] / sum(sub[this_level,"WTPSN"])
}

inc_h_94 <- sub
save(inc_h_94, file='data/inc_h_94.rda')
