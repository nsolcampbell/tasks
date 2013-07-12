
load('data/ids_82.rda')
load('data/ids_86.rda')
load('data/inc_h_94.rda')
load('data/ids_97.rda')

levels(ids_82$HighestQual)
names(ids_82)

col_n <- c("Sex","CurrentIncome","PFYIncome","Educ","Educ3","Weight")

s82 <- ids_82[,c("Sex","IncomeWages","IncomeWages8182","Educ","Educ3","Weight")]
names(s82) <- col_n
s82$Year <- rep("1982", nrow(s82))

s86 <- ids_86[,c("SEX_NA_PSN","INC_USUAL_WAGE_SALARY_CUR_PSN","INC_EMP_GR_WS_EXCL_JE_PRD_PSN",
								"Educ3","Educ3","WEIGHT_PERSONS_NA_PSN")]
names(s86) <- col_n
s86$Educ <- rep(NA, nrow(s86))
s86$Year <- rep("1986", nrow(s86))

s94 <- inc_h_94[,c("SEXP", "IEARNCP", "IEARNPP", "Educ", "Educ3", "WTPSN")]
names(s94) <- col_n
s94$Year <- rep("1994", nrow(s94))

s97 <- ids_97[,c("SEXP", "IEARNCP", "IEARNPP", "Educ", "Educ3", "WTPSN")]
names(s97) <- col_n
s97$Year <- rep("1997", nrow(s97))

ihs <- rbind(s82, s86, s94, s97)
ihs$Year <- factor(ihs$Year, ordered=TRUE, levels=c("1982","1986","1994", "1997"))

# get rid of <1000 prev yr earners
ihs <- ihs[ihs$PFYIncome >= 1000,]

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
curf_years <- c(1982, 1986, 1994, 1997) # ie fiscal years
centered_factors <- cpi_now / centered_cpi(cpi, curf_years)
for (yr_i in seq_along(curf_years)) {
	# need this because R handles factors horribly
	subsample <- which(ihs$Year == as.character(curf_years[yr_i]))
	ihs[subsample,"PFYRealIncome"] <- ihs[subsample,"PFYIncome"] * centered_factors[yr_i]
	ihs[subsample,"RealCurrentIncome"] <- ihs[subsample,"CurrentIncome"] * centered_factors[yr_i]
}

save(ihs, file='data/ihs.rda')
