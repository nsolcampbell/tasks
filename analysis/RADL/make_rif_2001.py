#!/usr/bin/env python

# usage: ./make_rif_2010.py 1|2
# where 1 or 2 is the mapping scheme for 2009-10

print """* Perform a RIF regression on the 2000-1 CURF with the 2nd combined grouping
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

* *** Overall distribution
pctile OVERALL_DECILES = lwage [aweight = WTPSN] , nq(20)
list OVERALL_DECILES in 1/19

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

"""

print """* generate potential experience, in years,
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
egen potexp = cut(potexpy), at (0,5,10,15,20,25,30,35,40,45) label
tabulate potexp, generate(expdum)
"""

import csv
with open("../../data/density/2010.csv", 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    reader.next()
    i = 0
    for row in reader:
        i=i+1
        # rows are q_t(lwage), density
        q, fy = row
        print """
* manual RIF regression %(i)d
generate rif_%(i)02d = %(q)f + (%(q)f - (lwage < %(q)f))/%(fy)f
reg rif_%(i)02d expdum1-expdum3 expdum5-expdum9 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN], robust
""" % {'i': i, 'q': float(q), 'fy': float(fy)}
