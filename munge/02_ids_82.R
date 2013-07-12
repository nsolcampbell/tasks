library(foreign)
source('lib/curfmunge.R')

ids_82 <- data.frame(read.spss("data/curf/ids_82/IDS82.sav"))

subs <- curfmunge(ids_82,
					PPP0006="Sex",
					PPP0007="Age",
					PPP0014="AgeLeftSchool",
					PPP0026="HighestQual",
					PPP0027="QualField",
					PPP0034="HoursWorkedAllJobs",
					PPP0037="IndEmployer", 
					PPP0038="SectorEmployer", 
					PPP0039="CurrentOccup", 
					PPP0040="ManualOccup", 
					PPP0069="Occup8182",
					PPP0070="Industry8182", 
					PPP0096="IncomeWages", 
					PPP0119="IncomeWages8182"
)
subs$IncomeWages[subs$IncomeWages==9999] <- NA
subs$IncomeWages8182[subs$IncomeWages8182==99999] <- NA

old_educ <- list(c("Higher qualification"),
								 c("Bachelor degree/post.grad.diploma"),
								 c("Trade qualification", "Certificate/diploma"),
								 c("Adult education/hobby course", "Other","Still at school",
								 	"Secondary school course", "Never went to school", 
								 	"No qualifications since school"))
new_educ <- list("Postgraduate","Bachelor","Associate Degree","None")
subs$Educ <- recodeVar(as.character(subs$HighestQual), src=old_educ, tgt=new_educ)
subs$Educ <- factor(subs$Educ, ordered=TRUE, levels=new_educ)

# And a 3-level category (thanks ABS)
old_educ <- list(c("Higher qualification","Bachelor degree/post.grad.diploma"),
									 c("Trade qualification", "Certificate/diploma"),
									 c("Adult education/hobby course", "Other","Still at school",
										"Secondary school course", "Never went to school", 
										"No qualifications since school"))
new_educ <- list("Bachelor or Higher","Associate Degree","None")
subs$Educ3 <- recodeVar(as.character(subs$HighestQual), src=old_educ, tgt=new_educ)
subs$Educ3 <- factor(subs$Educ3, ordered=TRUE, levels=new_educ)

# remove individuals who earned less than $1,000 in last financial year
subs <- subs[subs$IncomeWages8182 >= 1000,]

# PLACEHOLDER
# TODO: read weights from nasty data file
subs$Weight <- rep(1, nrow(subs))

ids_82 <- subs
save(ids_82, file='data/ids_82.rda')
