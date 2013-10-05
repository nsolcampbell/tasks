#!/usr/bin/env python

print """
* Perform a RIF regression on the 2010 CURF with the 1st combined grouping
*
* Generated file -- do not edit. Edit analysis/make_rif_2010.py instead.

* EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    WPS0101-WPS0160

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

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

generate lwage = log(IWSSUCP8)

* find percentiles, as 19*0.5 increments
pctile pc_lwage = lwage [aweight = SIHPSWT] , nq(20)
* then densities at those particular percentile
kdensity lwage [aweight = SIHPSWT], nograph generate(density_pts density_ht) at(pc_lwage)
mkmat density_pts density_ht in 1/19, matrix(density)

mat params = J(1,7,.)
"""
import csv
with open("../data/density/2010.csv", 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    reader.next()
    i = 0
    for row in reader:
        i=i+1
        # rows are q_t(lwage), density
        q, fy = row
        print """
* manual RIF regression %(i)d
generate rif_%(i)02d = %(q)f - (%(q)f - (lwage < %(q)f))/%(fy)f
reg rif_%(i)02d AGEEC inform routine face site decision [aweight = SIHPSWT]
mat params = params \ e(b)
""" % {'i': i, 'q': float(q), 'fy': float(fy)}


print """
clear
quietly svmat params
list

"""
