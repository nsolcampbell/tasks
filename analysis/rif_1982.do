cd "/Users/acooper/Documents/School/polarization"
set more off
clear
use "data/curf/1982/IDS82.dta"

keep IncomeWages CurrentOccup PrincipalSource FulltimeParttime HighestQual ///
	AgeGrp Sex Married PERS_WT

* Log income
generate lwage = log(IncomeWages) 

local nqtiles = 20

generate OCC6DIG = CurrentOccup
drop if PrincipalSource != 1
drop if FulltimeParttime != 1

quietly merge m:1 OCC using "analysis/CcloCombined1Map.dta"
drop if missing(COMBINEDI)

* Overall distribution
pctile qtiles = lwage [aweight = PERS_WT] , nq(`nqtiles')

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

* empty row matrix, header for all parameter estimates (B)
* and t-ratios, one col for each parameter in regression in loop
matrix B = J(1,19,.) 
matrix T = J(1,19,.) 

* i indexes rows of DENSITY = {q, y}_i
forvalues i = 1/19 {
    generate rif = DENSITY[`i',1] + (DENSITY[`i',1] - (lwage < DENSITY[`i',1]))/DENSITY[`i',2]
    
    reg rif expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = PERS_WT], robust

    * store parameter estimates in estimate matrix
    matrix B = B \ e(b)
    matrix T = T \ e(V)

    drop rif 
}

* write out parameter estimates
drop _all
quietly svmat B
export delimited using "data/rif/1982.csv", replace

* drop _all
* quietly svmat T
* export delimited using "/tmp/T82.csv", replace

* the quantiles and densities where we estimated this guy
drop _all
quietly svmat DENSITY, names(col) 
export delimited using "/tmp/density82.csv", replace
