* re-weight samples using probit model
* grouping I, first

clear
use "1981_i"
append using "2010_i"

* note, the following is unweighted
probit T expdum1-expdum8 female married ///
      educ1-educ5 inform routine face site decision
predict THat

replace SIHPSWT2 = THat * SIHPSWT
replace PERS_WT = THat * PERS_WT

keep if T == 0 
* or keep if T == 1

* empty row matrix, header for all parameter estimates (B)
* and t-ratios, one col for each parameter in regression in loop
matrix B = J(1,19,.) 
matrix V = J(1,19,.) 

* i indexes rows of DENSITY = {q, y}_i
forvalues i = 1/19 {
    generate rif = DENSITY[`i',1] + (DENSITY[`i',1] - (lwage < DENSITY[`i',1]))/DENSITY[`i',2]
    
    quietly reg rif expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = PERS_WT2], robust

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
export delimited using "rif_1982_i.csv", replace

* drop _all
* quietly svmat V
* export delimited using "/tmp/T82.csv", replace

* the quantiles and densities where we estimated this guy
drop _all
quietly svmat DENSITY, names(col) 
export delimited using "density_1982_i.csv", replace

drop _all
quietly svmat QUANTILES
export delimited using "quantiles_overall_1982_i.csv", replace
