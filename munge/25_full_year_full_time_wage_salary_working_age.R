# Full-year, full-time, wage/salary earners of working age
load('data/curf/combined.rda')

#combined <- subset(combined, Year %in% c("1982","1995","2008","2010"))
# combined <- subset(combined, FullYear == 'Full Year')
combined <- subset(combined, CFullTime == 'Full-time')
combined <- subset(combined, PFYSource == 'Wages and Salaries')
combined <- subset(combined, Age4 %in% c("15-34","35-54","55-74"))

fyftws <- combined
save(fyftws, file='data/curf/fyftws.rda')
