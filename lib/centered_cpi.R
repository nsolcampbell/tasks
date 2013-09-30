# This is from ABS cat. 640101, series A2325846C
# Australian quarterly CPI. We'll take the midpoint of the collection period, the
# mean of the CPI for quarters 4 and 1, as the income deflator.
CPI <- read.csv("~/Documents/School/polarization/data/6401.0/640101.csv", dec=",",skip=9,
                stringsAsFactors=FALSE)
cpi <- ts(as.numeric(CPI$A2325846C), start=c(1948,3), frequency=4)

##' Return mean of 2nd and 3rd fiscal quarters of given (calendar) year
centered_cpi <- function(years) {
    sapply(years, FUN=function(y) mean(window(cpi, start=c(y,4), end=c(y+1,1))))
}
