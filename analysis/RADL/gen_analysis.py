#!/usr/bin/env python

def make_script(outfile, lincvar, combvar, wtvar, nocc, header):
    with open(outfile, 'w') as f:
        f.write("""***   Generated script: do not edit   ***
*** See analysis/RADL/gen_analysis.py ***

""")
        f.write(header)
        f.write("""\n* *** Overall distribution
pctile OVERALL_DECILES = %(lincvar)s [aweight = %(wtvar)s] , nq(10)
list OVERALL_DECILES in 1/9
    """ % {"lincvar": lincvar, "wtvar": wtvar})
        f.write("* We can't use matrices, so we have to do the following\n\n")
        LEN = nocc+1
        for occid in range(1,LEN):
            f.write("""pctile OCC_%(occ)02d = %(lincvar)s if (%(combvar)s == %(occ)d) ///
    [aweight = %(wtvar)s] , nq(10)
""" % {"occ": occid, "combvar": combvar, "lincvar": lincvar, "wtvar": wtvar})
        from math import ceil
        for i in range(0,int(ceil(LEN/5.0))):
            f.write("""list %(varlist)s in 1/9
""" % {"varlist": " ".join(["OCC_%02d" % i for i in range(1+5*i, min(5*(i+1)+1, LEN))])})

# *************************************************

make_script('combinedii_2010.do', "L_IWSTPP", "COMBINEDII", "SIHPSWT", 29, """
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
* tab OCC6DIG
* svrtab OCC6DIG

* Log income
generate L_IWSTPP = log(IWSSUCP8) 
""")

make_script('combinedii_2001.do', "L_IWSTPP", "COMBINEDII", "WTPSN", 29, """
* For coding information see
* https://www7.abs.gov.au/forums/radl.nsf/bd95505367a3a0e0ca256c3d0004f8ec/ae975d8873072f73ca256f480021cdfb/$FILE/Data%20item%20listing%20and%20frequencies.txt

* EXPANDED CURF
use "`IDS00PTP'"

keep ABSHID ABSFID ABSIID ABSIID ABSPID ///
    PSRCCP FTPTSTAT OCCCP IWSUCP WTPSN ///
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
generate L_IWSTPP = log(IWSUCP) 
""")

# ***********************

make_script('combinedi_2010.do', "L_IWSTPP", "COMBINEDI", "SIHPSWT", 28, """
* EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    WPS0101-WPS0160

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using "`SAVED'AnzscoCombined1Map", unmatched(both)

sort COMBINEDI

svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

svrmean IWSSUCP8, by(OCC6DIG)
svrmean IWSSUCP8, by(COMBINEDI)

table COMBINEDI

* Log income
generate L_IWSTPP = log(IWSSUCP8) 
""")
