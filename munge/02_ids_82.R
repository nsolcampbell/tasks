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

save(ids_82=subs, file='data/ids_82.rda')
