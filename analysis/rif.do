cd "/Users/acooper/Documents/School/polarization"
clear
set more off
use "data/curf/2010/SIH10BE2 Component/sih10bp.dta"

keep FTPTSTAT SECEDQL OCCBASC AGEBC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
        IWSTPP WPS0101-WPS0160

* Log income
generate L_IWSTPP = log(IWSTPP) 
* Overall kernel density
kdensity L_IWSTPP [aweight = SIHPSWT], nograph generate(DENS_PTS DENS_Y) n(100)
mkmat DENS_PTS DENS_Y in 1/100, matrix(DENSITY)

* Overall distribution
pctile DEC_L_IWSTPP = L_IWSTPP [aweight = SIHPSWT] , nq(10)
mkmat DEC_L_IWSTPP in 1/9, matrix(A)
drop DEC_L_IWSTPP

forvalues occgroup = 1/9 {
	* Deciles of log income
	pctile DEC_L_IWSTPP = L_IWSTPP if (OCCBASC == `occgroup') ///
			[aweight = SIHPSWT] , nq(10)

	mkmat DEC_L_IWSTPP in 1/9, matrix(B)

	matrix A = A, B

	matrix drop B
	drop DEC_L_IWSTPP
}
matrix list A

* now write all the matrices to disk

drop _all
quietly svmat A
export delimited using "/tmp/A.csv", replace

drop _all
quietly svmat DENSITY, names(col) 
export delimited using "/tmp/density.csv", replace


* ************************* 1982 ****************************

clear
use "data/curf/1982/IDS82.dta"

keep IncomeWages CurrentOccup PERS_WT

* Log income
generate L_IWSTPP = log(IncomeWages) 

* Overall kernel density
kdensity L_IWSTPP [aweight = PERS_WT], nograph generate(DENS_PTS DENS_Y) n(100)
mkmat DENS_PTS DENS_Y in 1/100, matrix(DENSITY)

kdensity L_IWSTPP [aweight = PERS_WT], nograph generate(DENS_PTS DENS_Y) n(10)
mkmat DENS_PTS DENS_Y in 1/100, matrix(DENSITY10)
drop DENS_PTS, DENS_Y

* Overall distribution
pctile DEC_L_IWSTPP = L_IWSTPP [aweight = PERS_WT] , nq(10)
mkmat DEC_L_IWSTPP in 1/9, matrix(A)
drop DEC_L_IWSTPP

tabulate CurrentOccup

drop if CurrentOccup == 1

levelsof CurrentOccup, local(lvls)
foreach occgroup of local lvls {
	* Deciles of log income
	pctile DEC_L_IWSTPP = L_IWSTPP if (CurrentOccup == `occgroup') ///
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
export delimited using "/tmp/A82.csv", replace

drop _all
quietly svmat DENSITY, names(col) 
export delimited using "/tmp/density82.csv", replace
