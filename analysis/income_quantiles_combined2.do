* EXPANDED CURF
use "`SIH10EP'"
set more off

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
	WPS0101-WPS0160

* merge m:1 OCC6DIG using `AnzscoCombined2'

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using "`SAVED'Combined2Map", unmatched(both)

sort COMBINEDII

svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

svrmean IWSSUCP8, by(OCC6DIG)
svrmean IWSSUCP8, by(COMBINEDII)

table COMBINEDII
* tab OCC6DIG
* svrtab OCC6DIG

* Log income
generate L_IWSTPP = log(IWSSUCP8) 
* Overall kernel density
kdensity L_IWSTPP [aweight = SIHPSWT], nograph generate(DENS_PTS DENS_Y) n(100)
mkmat DENS_PTS DENS_Y in 1/100, matrix(DENSITY)

* Overall distribution
pctile DEC_L_IWSTPP = L_IWSTPP [aweight = SIHPSWT] , nq(10)
mkmat DEC_L_IWSTPP in 1/9, matrix(A)
drop DEC_L_IWSTPP

forvalues occgroup = 1/29 {
	* Deciles of log income
	pctile DEC_L_IWSTPP = L_IWSTPP if (COMBINEDII == `occgroup') ///
			[aweight = SIHPSWT] , nq(10)

	mkmat DEC_L_IWSTPP in 1/9, matrix(B)

	matrix A = A, B

	matrix drop B
	drop DEC_L_IWSTPP
}
matrix list A
