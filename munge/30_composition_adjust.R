# Composition-adjust sample on {gender} x {age} x {education} cells
# Adjustment is on totals of weights within each cell
# Entire survey is being scaled, not just the bits we want

load('data/curf/combined.rda')

combined$Age4 <- factor(combined$Age4, ordered=T, 
                        levels=c("15-34", "35-54", "55-74"))
dat <- combined

strat_year <- 2012

referencecells <- xtabs(Weight ~ EducB + Sex + Age4, 
                   data=subset(dat, Year == strat_year))

cellfactors <- xtabs(Weight ~ EducB + Sex + Age4 + Year, 
                   data = dat)
for (i in 1:length(levels(dat$Year)))
    cellfactors[,,,i] <- referencecells / cellfactors[,,,i]
harmonized <- adply(dat, 1, 
                    .fun = function(r) r$Weight * cellfactors[r$EducB, r$Sex, r$Age4, r$Year],
                    .parallel = T)
harmonized$Weight <- harmonized$V1

save(harmonized, file='data/curf/harmonized.rda')
