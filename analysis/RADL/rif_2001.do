* Perform a RIF regression on the 2000-1 CURF with the 2nd combined grouping
*
* NB: All loops are unrolled, quantiles/densities are hard-coded and matrixes are
*     not used because of RADL restrictions. Results are computer-processed from 
*     output log files using the script analysis/parse_rif_2001.py
*
* This is a generated file -- do not edit. Edit analysis/make_rif_2001.py instead.
*
* EXPANDED CURF
use "`IDS00PTP'"

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

* So we have now generated our covariate matrix X.
* We need E[X|T=t], which is a column vector, to perform our decomposition
*** BEGIN EXPECTED VALUE OF X
summarize expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN]
*** END EXPECTED VALUE OF X


* manual RIF regression 1
generate rif_01 = 5.817111 + (5.817111 - (lwage < 5.817111))/0.149770
reg rif_01 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 2
generate rif_02 = 6.035482 + (6.035482 - (lwage < 6.035482))/0.360346
reg rif_02 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 3
generate rif_03 = 6.142037 + (6.142037 - (lwage < 6.142037))/0.595124
reg rif_03 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 4
generate rif_04 = 6.214608 + (6.214608 - (lwage < 6.214608))/0.776236
reg rif_04 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 5
generate rif_05 = 6.272877 + (6.272877 - (lwage < 6.272877))/0.891914
reg rif_05 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 6
generate rif_06 = 6.322565 + (6.322565 - (lwage < 6.322565))/0.939733
reg rif_06 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 7
generate rif_07 = 6.380123 + (6.380123 - (lwage < 6.380123))/0.928797
reg rif_07 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 8
generate rif_08 = 6.421622 + (6.421622 - (lwage < 6.421622))/0.942339
reg rif_08 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 9
generate rif_09 = 6.476973 + (6.476973 - (lwage < 6.476973))/0.917758
reg rif_09 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 10
generate rif_10 = 6.551080 + (6.551080 - (lwage < 6.551080))/0.914299
reg rif_10 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 11
generate rif_11 = 6.593045 + (6.593045 - (lwage < 6.593045))/0.915855
reg rif_11 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 12
generate rif_12 = 6.643790 + (6.643790 - (lwage < 6.643790))/0.860307
reg rif_12 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 13
generate rif_13 = 6.692084 + (6.692084 - (lwage < 6.692084))/0.803603
reg rif_13 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 14
generate rif_14 = 6.781058 + (6.781058 - (lwage < 6.781058))/0.707184
reg rif_14 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 15
generate rif_15 = 6.856462 + (6.856462 - (lwage < 6.856462))/0.665956
reg rif_15 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 16
generate rif_16 = 6.907755 + (6.907755 - (lwage < 6.907755))/0.635963
reg rif_16 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 17
generate rif_17 = 7.004882 + (7.004882 - (lwage < 7.004882))/0.513879
reg rif_17 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 18
generate rif_18 = 7.130899 + (7.130899 - (lwage < 7.130899))/0.336493
reg rif_18 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 19
generate rif_19 = 7.333023 + (7.333023 - (lwage < 7.333023))/0.178277
reg rif_19 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust

