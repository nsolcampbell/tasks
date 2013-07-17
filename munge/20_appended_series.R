load('data/curf/1982.rda')
load('data/curf/1986.rda')
load('data/curf/1995.rda')
load('data/curf/1996.rda')
load('data/curf/1997.rda')
load('data/curf/1998.rda')
load('data/curf/2001.rda')
load('data/curf/2008.rda')

source("lib/curfmunge.R")

combined <- rbind(subset_1982, subset_1986,
              subset_1995, subset_1996, subset_1997, subset_1998,
              subset_2001, subset_2008)
year_list <- sort(unique(combined$Year))
combined$Year <- factor(combined$Year, ordered=TRUE, levels=as.character(year_list))

# get rid of <1000 prev yr earners
combined <- combined[which(combined$PFYInc >= 1000),]

##' Return mean of 2nd and 3rd fiscal quarters of given (calendar) year
centered_cpi <- function(cpi_series, years) {
	sapply(years, FUN=function(y) mean(window(cpi_series, start=c(y,4), end=c(y+1,1))))
}

# This is from ABS cat. 640101, series A2325846C
# Australian quarterly CPI. We'll take the midpoint of the collection period, the
# mean of the CPI for quarters 4 and 1, as the income deflator.
CPI <- read.csv("~/Documents/School/polarization/data/6401.0/640101.csv", dec=",",skip=9,
                stringsAsFactors=FALSE)
cpi <- ts(as.numeric(CPI$A2325846C), start=c(1948,3), frequency=4)
cpi_now <- tail(cpi,1)
centered_factors <- cpi_now / centered_cpi(cpi, year_list)
combined$PFYRInc <- NA
combined$CRInc <- NA
for (i in seq_along(year_list)) {
    # need this because R handles factors horribly
    subsample <- as.character(combined$Year) == as.character(year_list[i])
    pfyinc_subsample <- subsample & !is.na(combined$PFYInc)
    cinc_subsample <- subsample & !is.na(combined$CInc)

    combined[which(pfyinc_subsample),"PFYRInc"] <- 
        combined[which(pfyinc_subsample),"PFYInc"] * centered_factors[i]
    combined[which(cinc_subsample),"CRInc"] <- 
        combined[which(cinc_subsample),"CInc"] * centered_factors[i]
}

# this stuff should be shunted over to the relevant figure code
# # come up with education weights
# for (ed in levels(sub$Educ)) {
# 	this_level <- which(sub$Educ == ed)
# 	sub[this_level,"EducWeight"] <- sub[this_level,"WTPSN"] / sum(sub[this_level,"WTPSN"])
# }

save(combined, file='data/curf/combined.rda')
