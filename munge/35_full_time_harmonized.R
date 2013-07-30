# Full-time, wage/salary earners of working age
load('data/curf/harmonized.rda')

harmonized <- subset(harmonized, CFullTime == 'Full-time')
harmonized <- subset(harmonized, PFYSource == 'Wages and Salaries')
harmonized <- subset(harmonized, Age4 %in% c("15-34","35-54","55-74"))

# remove < $100/week
harmonized <- subset(harmonized, CInc >= 100)

harmonized.ft <- harmonized
save(harmonized.ft, file='data/curf/harmonized.ft.rda')
