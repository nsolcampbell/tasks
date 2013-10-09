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
	  
save temp_data, replace

* compute E[X] - weighted mean of all explanatory variables
collapse expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = PERS_WT]

export delimited using "data/EX/1982_i.csv", replace

use temp_data, clear

* empty row matrix, header for all parameter estimates (B)
* and t-ratios, one col for each parameter in regression in loop
matrix B = J(1,19,.) 
matrix V = J(1,19,.) 

* i indexes rows of DENSITY = {q, y}_i
forvalues i = 1/19 {
    generate rif = DENSITY[`i',1] + (DENSITY[`i',1] - (lwage < DENSITY[`i',1]))/DENSITY[`i',2]
    
    quietly reg rif expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = PERS_WT], robust

    * store parameter estimates in estimate matrix
    matrix B = B \ e(b)
    matrix V = V \ e(V)

    drop rif 
}

* write out parameter estimates
drop _all
generate qtile = .
quietly svmat B
drop if _n == 1
replace qtile = _n * 0.05
export delimited using "data/rif/1982_i.csv", replace

* drop _all
* quietly svmat V
* export delimited using "/tmp/T82.csv", replace

* the quantiles and densities where we estimated this guy
drop _all
quietly svmat DENSITY, names(col) 
export delimited using "data/density/1982_i.csv", replace

drop _all
quietly svmat QUANTILES
export delimited using "data/quantiles/overall_1982_i.csv", replace
