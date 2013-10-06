cd "/Users/acooper/Documents/School/polarization"
set more off
use "data/curf/2001/IDS00.DTA", clear

* keep only full-time Wage & Salary records
* NOTE: ONE ADDED TO EACH OF THESE
drop if (PSRCCU != 2 & PSRCCU != 3)
drop if (FTPTSTAT != 2)
drop if (OCCCP == 1)

generate lwage = log(IWSUCP)

pctile qtiles = lwage [aweight = WTPSN] , nq(20)
mkmat qtiles in 1/19, matrix(QUANTILES)

kdensity lwage [aweight = WTPSN], nograph generate(density_pts density_ht) ///
            at(qtiles)
mkmat density_pts density_ht in 1/19, matrix(DENSITY)

drop _all
quietly svmat DENSITY, names(col)
export delimited using "data/density/2001_ii.csv", replace
