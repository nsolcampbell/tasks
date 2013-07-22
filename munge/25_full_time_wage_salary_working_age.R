# Full-time, wage/salary earners of working age
load('data/curf/combined.rda')

combined <- subset(combined, CFullTime == 'Full-time')
combined <- subset(combined, PFYSource == 'Wages and Salaries')
combined <- subset(combined, Age4 %in% c("15-34","35-54","55-74"))

# remove < $100/week
combined <- subset(combined, CInc >= 100)

ftwswa <- combined
save(ftwswa, file='data/curf/ftwswa.rda')
