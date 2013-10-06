#!/usr/bin/env python

# usage: ./make_rif_2010.py 1|2
# where 1 or 2 is the mapping scheme for 2009-10

import sys
mapping = int(sys.argv[1])

if mapping == 1:
    mapfile = "AnzscoCombined1Map"
    grpvar  = "COMBINEDI"
else:
    mapfile = "Combined2Map"
    grpvar  = "COMBINEDII"

print """* Perform a RIF regression on the 2010 CURF with the 1st combined grouping
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
joinby OCC6DIG using "`SAVED'%(mapfile)s", unmatched(both)

sort %(grpvar)s

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

svrmean IWSSUCP8, by(%(grpvar)s)

table %(grpvar)s

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

""" % {'grpvar': grpvar, 'mapfile': mapfile}

if mapping == 1:
    print """* generate potential experience flags
* (for this one we deem experience to start at 15)
egen potexp = cut(AGEEC), at(15,20,25,30,35,40,45,50,55,110) label
tabulate potexp, generate(expdum)
"""
else:
    print """* generate potential experience, in years,
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
"""

print """
*** BEGIN EXPECTED VALUE OF X
summarize expdum1-expdum8 female married ///
      educ1-educ5 inform routine face site decision [aweight = SIHPSWT]
*** END EXPECTED VALUE OF X
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
reg rif_%(i)02d expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = SIHPSWT], robust
""" % {'i': i, 'q': float(q), 'fy': float(fy)}


print """

"""
