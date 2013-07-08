library(foreign)

ids_82 <- data.frame(read.spss("data/curf/ids_82/IDS82.sav"))

# PPP0006  "SEX"
# PPP0007  "AGE OF INDIVIDUAL"
# PPP0014  "AGE LEFT SCHOOL"
# PPP0026  "HIGHEST QUALIFICATIONS"
# PPP0027  "QUALIFICATION FIELD"
# PPP0034  "HOURS WORKED IN ALL JOBS"
# PPP0037  "INDUSTRY/SERVICE OF EMPLOYER"
# PPP0038  "SECTOR OF INDUSTRY/SERVICE OF EMPLOYER"
# PPP0039  "CURRENT OCCUPATION"
# PPP0040  "MANUAL/NON MANUAL OCCUPATION"
# PPP0069  "OCCUPATION 1981/82"
# PPP0070  "INDUSTRY 1981/82"
# PPP0096  "CURRENT INCOME FROM WAGES & SALARIES"
# PPP0119  "1981/82 INCOME FROM WAGES & SALARIES"
ids_82$PPP0096[ids_82$PPP0096==9999] <- NA
ids_82$PPP0119[ids_82$PPP0119==99999] <- NA

fieldlist <- c("PPP0006","PPP0007","PPP0014","PPP0026","PPP0027","PPP0034",
							 "PPP0037","PPP0038","PPP0039","PPP0040","PPP0069","PPP0070",
							 "PPP0096","PPP0119")
fieldnames <- c("Sex","Age","AgeLeftSchool","HighestQual","QualField","HoursWorkedAllJobs",
						  	"IndEmployer", "SectorEmployer", "CurrentOccup", "ManualOccup", "Occup8182",
					 	    "Industry8182", "IncomeWages", "IncomeWages8182")
if (length(fieldlist) != length(fieldnames)) { stop() }
subs_82 <- ids_82[,fieldlist]
names(subs_82) <- fieldnames

save(ids_82=psn_sub, file='data/ids_82.rda')
