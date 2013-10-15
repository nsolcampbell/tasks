library(doBy)

load('data/curf/1982.rda')
load('data/curf/1986.rda')
load('data/curf/1995.rda')
load('data/curf/1996.rda')
load('data/curf/1997.rda')
load('data/curf/1998.rda')
load('data/curf/2001.rda')
load('data/curf/2003.rda')
load('data/curf/2006.rda')
load('data/curf/2008.rda')
load('data/curf/2010.rda')
load('data/curf/2012.rda')

source("lib/curfmunge.R")

combined <- rbind(subset_1982, subset_1986,
              subset_1995, subset_1996, subset_1997, subset_1998,
              subset_2001, subset_2003, subset_2006, subset_2008, 
	      subset_2010, subset_2012)
year_list <- sort(unique(combined$Year))
combined$Year <- factor(combined$Year, ordered=TRUE, levels=as.character(year_list))

# recode industry (this function does all the years > 1990)
combined$CIndA <- recode_IndA(combined$CIndA)
# recode occupation to broad group
combined$COccupA <- recode_occupA(combined$COccupA)

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
centered_factors <- cpi_now / centered_cpi(cpi, year_list - 1) # NB -1 for PREVIOUS year
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

combined$Age4 <- factor(combined$Age4, levels=age_levels, ordered=T)

combined$EducA <- factor(combined$EducA, levels=EducA_levels, ordered=T)
combined$EducB <- factor(combined$EducB, levels=EducB_levels, ordered=T)
combined$Year  <- factor(combined$Year,  levels=year_list,    ordered=T)
combined$Sex   <- factor(combined$Sex,   levels=c("Male","Female"), ordered=F)

combined$Asco <- NA
has_asco_ii <- with(combined, Year >= 1997 & Year <= 2006)
combined$AscoII[has_asco_ii] <- recodeVar(as.character(combined$COccupB[has_asco_ii]),
                            list(c("Advanced clerical and service workers", "Advanced Clerical and Service Workers"), 
                                 c("Associate professionals", "Associate Professionals"), 
                                 c("Elementary clerical, sales and service workers", "Elementary Clerical, Sales and Service Workers"), 
                                 "Inadequately described",
                                 c("Intermediate clerical, sales and service workers", "Intermediate Clerical, Sales and Service Workers"), 
                                 c("Intermediate production and transport workers", "Intermediate Production and Transport Workers"), 
                                 c("Labourers and related workers", "Labourers and Related Workers"), 
                                 c("Managers and Administrators", "Managers and administrators"),
                                 "Not applicable", 
                                 "Professionals", 
                                 c("Tradespersons and related workers", "Tradespersons and Related Workers")
                            ),
                             list("Advanced clerical and service workers", 
                                  "Associate professionals",
                                  "Elementary clerical, sales and service workers",
                                  "Inadequately described",
                                  "Intermediate clerical, sales and service workers",
                                  "Intermediate production and transport workers", 
                                  "Labourers and related workers",
                                  "Managers and Administrators", 
                                  "Not applicable", 
                                  "Professionals", 
                                  "Tradespersons and related workers")
                             )

has_asco_i <- with(combined, Year >= 1986 & Year <= 1995)
combined$Asco <- NA
combined$Asco[has_asco_i] <- combined$COccupB[has_asco_i]

save(combined, file='data/curf/combined.rda')
