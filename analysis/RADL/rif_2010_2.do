* Perform a RIF regression on the 2010 CURF with the 1st combined grouping
*
* NB: All loops are unrolled, quantiles/densities are hard-coded and matrixes are
*     not used because of RADL restrictions. Results are computer-processed from 
*     output log files using the script analysis/parse_rif_2010.py
*
* This is a generated file -- do not edit. Edit analysis/make_rif_2010.py instead.
*
* USE EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    SEXP LVLEDUA MSTATP ///
    WPS0101-WPS0160

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using "`SAVED'Combined2Map", unmatched(both)

sort COMBINEDII

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

svrmean IWSSUCP8, by(COMBINEDII)

table COMBINEDII

generate lwage = log(IWSSUCP8)

* [commented out below, is this what's upsetting the RADL??]
* find percentiles, as 19*0.05 increments
**** BEGIN OVERALL DISTRIBUTION
pctile pc_lwage = lwage [aweight = SIHPSWT] , nq(20)
list pc_lwage in 1/19
**** END OVERALL DISTRIBUTION

generate female = 0
replace  female = 1 if (SEXP == 2)

generate married = 0
replace  married = 1 if (MSTATP == 1)

generate educ = .
* 1 = some high school or undetermined
replace educ = 1 if (LVLEDUA == 0 | LVLEDUA == 13 | LVLEDUA == 12 | ///
         LVLEDUA == 11 | LVLEDUA == 10 | LVLEDUA == 9)
* 2 = high school
replace educ = 2 if (LVLEDUA == 8)
* 3 = non-bachelor tertiary qualification
replace educ = 3 if (LVLEDUA == 7 | LVLEDUA == 6 | LVLEDUA == 5 | LVLEDUA == 4)
* 4 = bachelor degree or grad dip/cert
replace educ = 4 if (LVLEDUA == 3 | LVLEDUA == 2)
* 5 = postgrad degree (master or higher)
replace educ = 5 if (LVLEDUA == 1)

* now create education dummies
tabulate educ, generate(educ)


* generate potential experience, in years,
* which we then cut according to five-yearly bands
* we don't have year left school for everyone in 2000-1, 
* so assume experience starts at 18
gen potexpy = AGEEC - 18
* reduce by years of postgraduate education
replace potexpy = potexpy - 5 if educ == 5
replace potexpy = potexpy - 3 if educ == 4
replace potexpy = potexpy - 2 if educ == 3
replace potexpy = max(potexpy, 0)

* now cut into 5 year bands, make dummy variables
egen potexp = cut(potexpy), at (0,5,10,15,20,25,30,35,99) label
tabulate potexp, generate(expdum)


*** BEGIN EXPECTED VALUE OF X
summarize expdum1-expdum8 female married ///
      educ1-educ5 inform routine face site decision [aweight = SIHPSWT]
*** END EXPECTED VALUE OF X


* manual RIF regression 1
generate rif_01 = 6.253829 + (6.253829 - (lwage < 6.253829))/0.156011
reg rif_01 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 2
generate rif_02 = 6.458777 + (6.458777 - (lwage < 6.458777))/0.430942
reg rif_02 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 3
generate rif_03 = 6.551080 + (6.551080 - (lwage < 6.551080))/0.583479
reg rif_03 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 4
generate rif_04 = 6.630683 + (6.630683 - (lwage < 6.630683))/0.705411
reg rif_04 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 5
generate rif_05 = 6.684612 + (6.684612 - (lwage < 6.684612))/0.759589
reg rif_05 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 6
generate rif_06 = 6.756932 + (6.756932 - (lwage < 6.756932))/0.788736
reg rif_06 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 7
generate rif_07 = 6.819470 + (6.819470 - (lwage < 6.819470))/0.793478
reg rif_07 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 8
generate rif_08 = 6.885653 + (6.885653 - (lwage < 6.885653))/0.793904
reg rif_08 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 9
generate rif_09 = 6.946187 + (6.946187 - (lwage < 6.946187))/0.787109
reg rif_09 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 10
generate rif_10 = 7.006161 + (7.006161 - (lwage < 7.006161))/0.781563
reg rif_10 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 11
generate rif_11 = 7.078341 + (7.078341 - (lwage < 7.078341))/0.752327
reg rif_11 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 12
generate rif_12 = 7.136905 + (7.136905 - (lwage < 7.136905))/0.718137
reg rif_12 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 13
generate rif_13 = 7.211911 + (7.211911 - (lwage < 7.211911))/0.685978
reg rif_13 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 14
generate rif_14 = 7.296644 + (7.296644 - (lwage < 7.296644))/0.656732
reg rif_14 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 15
generate rif_15 = 7.362652 + (7.362652 - (lwage < 7.362652))/0.619972
reg rif_15 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 16
generate rif_16 = 7.453545 + (7.453545 - (lwage < 7.453545))/0.515545
reg rif_16 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 17
generate rif_17 = 7.563143 + (7.563143 - (lwage < 7.563143))/0.400368
reg rif_17 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 18
generate rif_18 = 7.711822 + (7.711822 - (lwage < 7.711822))/0.288694
reg rif_18 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust


* manual RIF regression 19
generate rif_19 = 7.962973 + (7.962973 - (lwage < 7.962973))/0.143471
reg rif_19 expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust




