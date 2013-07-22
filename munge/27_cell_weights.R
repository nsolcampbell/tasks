library(plyr)
load('data/curf/ftwswa.rda')

# normalize weights by education/sex/year and sex/year

ftwswa$SexYearEducAWeight <- NA
ftwswa$SexYearEducBWeight <- NA
ftwswa$SexYearWeight <- NA
for (s in levels(ftwswa$Sex)) {
    sex <- ftwswa$Sex == s
    for (y in levels(ftwswa$Year)) {
        year <- ftwswa$Year == y
        # sy_subs gives indexes for (sex,year) cell
        sy_subs <- which(sex & year)
        ftwswa$SexYearWeight[sy_subs] <- 
            ftwswa$Weight[sy_subs] / sum(ftwswa$Weight[sy_subs])
        for (e in levels(ftwswa$EducA)) {
            educ <- ftwswa$EducA == e
            # sye_subs gives indexes for (year,sex,educ) cell
            sye_subs <- which(sex & year & educ)
            ftwswa$SexYearEducAWeight[sye_subs] <- 
                ftwswa$Weight[sye_subs] / sum(ftwswa$Weight[sye_subs])
        }
        for (e in levels(ftwswa$EducB)) {
            educ <- ftwswa$EducB == e
            # sye_subs gives indexes for (year,sex,educ) cell
            sye_subs <- which(sex & year & educ)
            ftwswa$SexYearEducBWeight[sye_subs] <- 
                ftwswa$Weight[sye_subs] / sum(ftwswa$Weight[sye_subs])
        }
    }
}

ftwswaw <- ftwswa

save(ftwswaw, file='data/curf/ftwswaw.rda')
