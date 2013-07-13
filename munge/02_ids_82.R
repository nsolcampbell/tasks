library(foreign)
library(plyr)
library(doBy)
source('lib/curfmunge.R')

ids_82 <- data.frame(read.spss("data/curf/ids_82/IDS82.sav"))

subs <- curfmunge(ids_82,
					PPP0001="IDENT_PSN",
					PPP0003="FAMNO_PSN",
					PPP0004="IUNO_PSN",
					PPP0005="PERSON_NUMBER",
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

# convert identifiers to character, from levels
collist <- c("IDENT_PSN","FAMNO_PSN","IUNO_PSN","PERSON_NUMBER")
subs[,collist] <- as.character(subs[,collist])

# Some troll at the ABS dropped the person weight from the SAS/SPSS files.
# This CSV was created by the script get_weights.py in the munge directory
weights <- read.csv("munge/weights.csv", stringsAsFactors=F)

subs <- join(x=subs, y=weights, 
		 by=c("IDENT_PSN", "FAMNO_PSN", "IUNO_PSN", "PERSON_NUMBER"))

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

# remove individuals retirement age or above
subs <- subs[!(subs$Age %in% c("65 - 69", "70 - 74", "75 - 79", "80 - 84", "85 +")),]

# recode into experience groups
age_groups   <- list(c("15", "16", "17", "18", "19", "20 - 24", "25 - 29", "30 - 34", "35 - 39"),
						  			 c("40 - 44", "45 - 49", "50 - 54", "55 - 59", "60 - 64"))
pot_exp      <- list("0-24", "25-39")
subs$PotExp2 <- recodeVar(as.character(subs$Age), age_groups, pot_exp)

ids_82 <- subs
save(ids_82, file='data/ids_82.rda')
