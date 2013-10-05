
* Perform a RIF regression on the 2010 CURF with the 1st combined grouping
*
* Generated file -- do not edit. Edit analysis/make_rif_2010.py instead.

cd "/Users/acooper/Documents/School/polarization"
clear
set more off

* BASIC CURF
use "data/curf/2010/SIH10BE2 Component/sih10bp.dta", clear

keep FTPTSTAT SECEDQL OCCBASC AGEBC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
	WPS0101-WPS0160
generate OCC6DIG = OCCBASC * 10 + 1

merge m:1 OCC6DIG using "analysis/Combined2Map.dta"

drop if missing(inform)

* quietly replace MetaValue = "Not Mapped" if missing(MetaValue)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCCBASC == 0) | (OCCBASC == 9)

* BASIC CURF
svrmean IWSSUCP8, by(OCCBASC)
svrtab OCCBASC

generate lwage = log(IWSSUCP8)

* find percentiles, as 19*0.5 increments
pctile pc_lwage = lwage [aweight = SIHPSWT] , nq(20)
* then densities at those particular percentile
kdensity lwage [aweight = SIHPSWT], nograph generate(density_pts density_ht) at(pc_lwage)
mkmat density_pts density_ht in 1/19, matrix(density)

mat params = J(1,7,.)


* manual RIF regression 2
generate rif_02 = 6.253829 - (6.253829 - (lwage < 6.253829))/0.156011
reg rif_02 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 3
generate rif_03 = 6.458777 - (6.458777 - (lwage < 6.458777))/0.430942
reg rif_03 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 4
generate rif_04 = 6.551080 - (6.551080 - (lwage < 6.551080))/0.583479
reg rif_04 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 5
generate rif_05 = 6.630683 - (6.630683 - (lwage < 6.630683))/0.705411
reg rif_05 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 6
generate rif_06 = 6.684612 - (6.684612 - (lwage < 6.684612))/0.759589
reg rif_06 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 7
generate rif_07 = 6.756932 - (6.756932 - (lwage < 6.756932))/0.788736
reg rif_07 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 8
generate rif_08 = 6.819470 - (6.819470 - (lwage < 6.819470))/0.793478
reg rif_08 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 9
generate rif_09 = 6.885653 - (6.885653 - (lwage < 6.885653))/0.793904
reg rif_09 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 10
generate rif_10 = 6.946187 - (6.946187 - (lwage < 6.946187))/0.787109
reg rif_10 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 11
generate rif_11 = 7.006161 - (7.006161 - (lwage < 7.006161))/0.781563
reg rif_11 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 12
generate rif_12 = 7.078341 - (7.078341 - (lwage < 7.078341))/0.752327
reg rif_12 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 13
generate rif_13 = 7.136905 - (7.136905 - (lwage < 7.136905))/0.718137
reg rif_13 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 14
generate rif_14 = 7.211911 - (7.211911 - (lwage < 7.211911))/0.685978
reg rif_14 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 15
generate rif_15 = 7.296644 - (7.296644 - (lwage < 7.296644))/0.656732
reg rif_15 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 16
generate rif_16 = 7.362652 - (7.362652 - (lwage < 7.362652))/0.619972
reg rif_16 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 17
generate rif_17 = 7.453545 - (7.453545 - (lwage < 7.453545))/0.515545
reg rif_17 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 18
generate rif_18 = 7.563143 - (7.563143 - (lwage < 7.563143))/0.400368
reg rif_18 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 19
generate rif_19 = 7.711822 - (7.711822 - (lwage < 7.711822))/0.288694
reg rif_19 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


* manual RIF regression 20
generate rif_20 = 7.962973 - (7.962973 - (lwage < 7.962973))/0.143471
reg rif_20 AGEBC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)


clear
quietly svmat params
export delimited using "data/params/2010_ii.csv", replace


