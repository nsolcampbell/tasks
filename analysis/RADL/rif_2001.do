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

svrmean IWSUCP, by (OCCCP)
svrmean IWSUCP, by (COMBINEDII)

table COMBINEDII

* Log income
generate lwage = log(IWSUCP)

**** OVERALL DISTRIBUTION
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
generate rif_01 = 6.253829 + (6.253829 - (lwage < 6.253829))/0.156011
reg rif_01 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 2
generate rif_02 = 6.458777 + (6.458777 - (lwage < 6.458777))/0.430942
reg rif_02 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 3
generate rif_03 = 6.551080 + (6.551080 - (lwage < 6.551080))/0.583479
reg rif_03 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 4
generate rif_04 = 6.630683 + (6.630683 - (lwage < 6.630683))/0.705411
reg rif_04 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 5
generate rif_05 = 6.684612 + (6.684612 - (lwage < 6.684612))/0.759589
reg rif_05 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 6
generate rif_06 = 6.756932 + (6.756932 - (lwage < 6.756932))/0.788736
reg rif_06 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 7
generate rif_07 = 6.819470 + (6.819470 - (lwage < 6.819470))/0.793478
reg rif_07 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 8
generate rif_08 = 6.885653 + (6.885653 - (lwage < 6.885653))/0.793904
reg rif_08 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 9
generate rif_09 = 6.946187 + (6.946187 - (lwage < 6.946187))/0.787109
reg rif_09 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 10
generate rif_10 = 7.006161 + (7.006161 - (lwage < 7.006161))/0.781563
reg rif_10 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 11
generate rif_11 = 7.078341 + (7.078341 - (lwage < 7.078341))/0.752327
reg rif_11 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 12
generate rif_12 = 7.136905 + (7.136905 - (lwage < 7.136905))/0.718137
reg rif_12 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 13
generate rif_13 = 7.211911 + (7.211911 - (lwage < 7.211911))/0.685978
reg rif_13 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 14
generate rif_14 = 7.296644 + (7.296644 - (lwage < 7.296644))/0.656732
reg rif_14 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 15
generate rif_15 = 7.362652 + (7.362652 - (lwage < 7.362652))/0.619972
reg rif_15 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 16
generate rif_16 = 7.453545 + (7.453545 - (lwage < 7.453545))/0.515545
reg rif_16 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 17
generate rif_17 = 7.563143 + (7.563143 - (lwage < 7.563143))/0.400368
reg rif_17 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 18
generate rif_18 = 7.711822 + (7.711822 - (lwage < 7.711822))/0.288694
reg rif_18 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust


* manual RIF regression 19
generate rif_19 = 7.962973 + (7.962973 - (lwage < 7.962973))/0.143471
reg rif_19 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust

