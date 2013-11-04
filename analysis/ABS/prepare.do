***********************************************
******************** 1982 i *******************
***********************************************

cd "/Users/acooper/Documents/School/polarization"
set more off
clear
use "data/curf/1982/IDS82.dta"

keep IncomeWages CurrentOccup PrincipalSource FulltimeParttime HighestQual ///
	AgeGrp Sex Married PERS_WT

* Log income
generate lwage = log(IncomeWages) 

generate OCC6DIG = CurrentOccup
drop if PrincipalSource != 1
drop if FulltimeParttime != 1

quietly merge m:1 OCC using "analysis/CcloCombined1Map.dta"
drop if missing(COMBINEDI)

* Overall distribution
pctile qtiles = lwage [aweight = PERS_WT] , nq(20)
mkmat qtiles in 1/19, matrix(QUANTILES)

* Overall kernel density @ quantiles --> matrix DENSITY
kdensity lwage [aweight = PERS_WT], nograph generate(DENS_PTS DENS_Y) at(qtiles)
mkmat DENS_PTS DENS_Y in 1/19, matrix(DENSITY)

tabulate CurrentOccup

drop if CurrentOccup == 1

gen female = 0
replace female = 1 if (Sex == 2)

gen married = 0
replace married = 1 if Married == 1

gen educ = 1
replace educ = 2 if (HighestQual == 2 | HighestQual == 3)
replace educ = 3 if (HighestQual == 4 | HighestQual == 5)
replace educ = 4 if (HighestQual == 6)
replace educ = 5 if (HighestQual == 7)                     
tabulate educ, generate(educ)

tabulate AgeGrp, generate(expdum)

generate T = 0



save "1982_i", replace

clear

***********************************************
******************* 2001 ii *******************
***********************************************

* EXPANDED CURF
use "data/curf/2001/IDS00"

keep ABSHID ABSFID ABSIID ABSIID ABSPID ///
    PSRCCP FTPTSTAT OCCCP IWSUCP WTPSN ///
    SEXP HQUALCP AGECP MSTATCP ///
    REPWT1-REPWT30

* stone age STATA means we need a workaround for merge
sort OCCCP
joinby OCCCP using "`SAVED'AscoCombined2Map", unmatched(both)

sort COMBINEDII

svrset set meth jk1 pw WTPSN rw REPWT1-REPWT30 dof 29

* keep only full-time Wage & Salary records
drop if (PSRCCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCCCP == 0) | (OCCCP == 99)

generate T = 0

svrmean IWSUCP, by (OCCCP)
svrmean IWSUCP, by (COMBINEDII)

table COMBINEDII

* Log income
generate lwage = log(IWSUCP)

**** BEGIN OVERALL DISTRIBUTION
pctile OVERALL_DECILES = lwage [aweight = WTPSN] , nq(20)
list OVERALL_DECILES in 1/19
**** END OVERALL DISTRIBUTION

sort COMBINEDII

generate female = 0
replace  female = 1 if (SEXP == 2)

generate married = 0
replace  married = 1 if (MSTATCP == 1)

generate educ = .
* 1 = some high school or undetermined
replace educ = 1 if (HQUALCP == 1 | HQUALCP == 8)
* 2 = high school
replace educ = 2 if (HQUALCP == 9)
* 3 = non-bachelor tertiary qualification
replace educ = 3 if (HQUALCP == 7 | HQUALCP == 6 | HQUALCP == 5 )
* 4 = bachelor degree or grad dip/cert
replace educ = 4 if (HQUALCP == 4 | HQUALCP == 3)
* 5 = postgrad degree (master or higher)
replace educ = 5 if (HQUALCP == 2)

* now create education dummies
tabulate educ, generate(educ)


* generate potential experience, in years,
* which we then cut according to five-yearly bands
* we don't have year left school for everyone in 2000-1, 
* so assume experience starts at 18
gen potexpy = AGECP - 18
* reduce by years of postgraduate education
replace potexpy = potexpy - 5 if educ == 5
replace potexpy = potexpy - 3 if educ == 4
replace potexpy = potexpy - 2 if educ == 3
replace potexpy = max(potexpy, 0)
* now cut into 5 year bands
egen potexp = cut(potexpy), at (0,5,10,15,20,25,30,35,99) label
tabulate potexp, generate(expdum)

save "2001_ii", replace
clear

***********************************************
******************* 2010 i ********************
***********************************************

* USE EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    SEXP LVLEDUA MSTATP ///
    WPS0101-WPS0160

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using "data/curf/2010/AnzscoCombined1Map", unmatched(both)

sort COMBINEDI

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

svrmean IWSSUCP8, by(COMBINEDI)

generate T = 1

table COMBINEDI

generate lwage = log(IWSSUCP8)

* [commented out below, is this what's upsetting the RADL??]
* find percentiles, as 19*0.05 increments
**** BEGIN OVERALL DISTRIBUTION
pctile pc_lwage = lwage [aweight = SIHPSWT] , nq(20)
list pc_lwage in 1/19
**** END OVERALL DISTRIBUTION

generate female = 0
replace  female = 1 if (SEXP == 2)

generate married = 0
replace  married = 1 if (MSTATP == 1)

generate educ = .
* 1 = some high school or undetermined
replace educ = 1 if (LVLEDUA == 0 | LVLEDUA == 13 | LVLEDUA == 12 | ///
         LVLEDUA == 11 | LVLEDUA == 10 | LVLEDUA == 9)
* 2 = high school
replace educ = 2 if (LVLEDUA == 8)
* 3 = non-bachelor tertiary qualification
replace educ = 3 if (LVLEDUA == 7 | LVLEDUA == 6 | LVLEDUA == 5 | LVLEDUA == 4)
* 4 = bachelor degree or grad dip/cert
replace educ = 4 if (LVLEDUA == 3 | LVLEDUA == 2)
* 5 = postgrad degree (master or higher)
replace educ = 5 if (LVLEDUA == 1)

* now create education dummies
tabulate educ, generate(educ)


* generate potential experience flags
* (for this one we deem experience to start at 15)
egen potexp = cut(AGEEC), at(15,20,25,30,35,40,45,50,55,110) label
tabulate potexp, generate(expdum)

save "2010_i", replace
clear

***********************************************
******************* 2010 ii *******************
***********************************************

* USE EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    SEXP LVLEDUA MSTATP ///
    WPS0101-WPS0160

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using "`SAVED'Combined2Map", unmatched(both)

sort COMBINEDII

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

svrmean IWSSUCP8, by(COMBINEDII)

table COMBINEDII

generate T = 1

generate lwage = log(IWSSUCP8)

* find percentiles, as 19*0.05 increments
**** BEGIN OVERALL DISTRIBUTION
pctile pc_lwage = lwage [aweight = SIHPSWT] , nq(20)
list pc_lwage in 1/19
**** END OVERALL DISTRIBUTION

generate female = 0
replace  female = 1 if (SEXP == 2)

generate married = 0
replace  married = 1 if (MSTATP == 1)

generate educ = .
* 1 = some high school or undetermined
replace educ = 1 if (LVLEDUA == 0 | LVLEDUA == 13 | LVLEDUA == 12 | ///
         LVLEDUA == 11 | LVLEDUA == 10 | LVLEDUA == 9)
* 2 = high school
replace educ = 2 if (LVLEDUA == 8)
* 3 = non-bachelor tertiary qualification
replace educ = 3 if (LVLEDUA == 7 | LVLEDUA == 6 | LVLEDUA == 5 | LVLEDUA == 4)
* 4 = bachelor degree or grad dip/cert
replace educ = 4 if (LVLEDUA == 3 | LVLEDUA == 2)
* 5 = postgrad degree (master or higher)
replace educ = 5 if (LVLEDUA == 1)

* now create education dummies
tabulate educ, generate(educ)


* generate potential experience, in years,
* which we then cut according to five-yearly bands
* we don't have year left school for everyone in 2000-1, 
* so assume experience starts at 18
gen potexpy = AGEEC - 18
* reduce by years of postgraduate education
replace potexpy = potexpy - 5 if educ == 5
replace potexpy = potexpy - 3 if educ == 4
replace potexpy = potexpy - 2 if educ == 3
replace potexpy = max(potexpy, 0)

* now cut into 5 year bands, make dummy variables
egen potexp = cut(potexpy), at (0,5,10,15,20,25,30,35,99) label
tabulate potexp, generate(expdum)

generate tstar = -1.004331 * expdum1 -.5248388 * expdum2  \\\
	-.3575683 * expdum3 -.3559735 * expdum5 -.2295657 * expdum6 \\\
	-.1990033 * expdum7 -.6299797 * expdum8 + .1662448 * female \\\
	-.110938 * married + 1.877307 * educ1 + -.5473764 * educ2 \\\
	.790891 * educ4 + 1.005428 * educ5 + .261753

generate tstar
