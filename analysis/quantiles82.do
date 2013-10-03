cd "/Users/acooper/Documents/School/polarization"

* ************************* 1982 ****************************

clear
use "data/curf/1982/IDS82.dta"

keep IncomeWages CurrentOccup PrincipalSource FulltimeParttime PERS_WT

generate OCC = CurrentOccup

drop if PrincipalSource != 1
drop if FulltimeParttime != 1

quietly merge m:1 OCC using "data/curf/1982/CcloCombined1Map.dta"
drop if missing(COMBINEDI)

* Log income
generate L_IWSTPP = log(IncomeWages) 

* Overall kernel density
kdensity L_IWSTPP [aweight = PERS_WT], nograph generate(DENS_PTS DENS_Y) n(100)
mkmat DENS_PTS DENS_Y in 1/100, matrix(DENSITY)

* Overall distribution
pctile DEC_L_IWSTPP = L_IWSTPP [aweight = PERS_WT] , nq(10)
mkmat DEC_L_IWSTPP in 1/9, matrix(A)
drop DEC_L_IWSTPP

tabulate COMBINEDI [aweight = PERS_WT]

* drop if CurrentOccup == 1

levelsof COMBINEDI, local(lvls)
foreach occgroup of local lvls {
*forvalues occgroup = 1/28 {
	* Deciles of log income
	pctile DEC_L_IWSTPP = L_IWSTPP if (COMBINEDI == `occgroup') ///
				[aweight = PERS_WT] , nq(10)

	mkmat DEC_L_IWSTPP in 1/9, matrix(B)

	matrix A = A, B

	matrix drop B
	drop DEC_L_IWSTPP
}
matrix list A

* now write all the matrices to disk

drop _all
quietly svmat A
export delimited using "data/quantiles/1982_combined1.csv", replace

drop _all
quietly svmat DENSITY, names(col) 
export delimited using "data/density/82.csv", replace
