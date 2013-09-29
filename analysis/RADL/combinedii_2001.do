***   Generated script: do not edit   ***
*** See analysis/RADL/gen_analysis.py ***


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

* *** Overall distribution
pctile OVERALL_DECILES = L_IWSTPP [aweight = WTPSN] , nq(10)
list OVERALL_DECILES in 1/9
    * We can't use matrices, so we have to do the following

pctile OCC_01 = L_IWSTPP if (COMBINEDII == 1) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_02 = L_IWSTPP if (COMBINEDII == 2) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_03 = L_IWSTPP if (COMBINEDII == 3) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_04 = L_IWSTPP if (COMBINEDII == 4) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_05 = L_IWSTPP if (COMBINEDII == 5) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_06 = L_IWSTPP if (COMBINEDII == 6) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_07 = L_IWSTPP if (COMBINEDII == 7) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_08 = L_IWSTPP if (COMBINEDII == 8) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_09 = L_IWSTPP if (COMBINEDII == 9) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_10 = L_IWSTPP if (COMBINEDII == 10) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_11 = L_IWSTPP if (COMBINEDII == 11) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_12 = L_IWSTPP if (COMBINEDII == 12) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_13 = L_IWSTPP if (COMBINEDII == 13) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_14 = L_IWSTPP if (COMBINEDII == 14) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_15 = L_IWSTPP if (COMBINEDII == 15) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_16 = L_IWSTPP if (COMBINEDII == 16) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_17 = L_IWSTPP if (COMBINEDII == 17) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_18 = L_IWSTPP if (COMBINEDII == 18) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_19 = L_IWSTPP if (COMBINEDII == 19) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_20 = L_IWSTPP if (COMBINEDII == 20) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_21 = L_IWSTPP if (COMBINEDII == 21) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_22 = L_IWSTPP if (COMBINEDII == 22) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_23 = L_IWSTPP if (COMBINEDII == 23) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_24 = L_IWSTPP if (COMBINEDII == 24) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_25 = L_IWSTPP if (COMBINEDII == 25) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_26 = L_IWSTPP if (COMBINEDII == 26) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_27 = L_IWSTPP if (COMBINEDII == 27) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_28 = L_IWSTPP if (COMBINEDII == 28) ///
    [aweight = WTPSN] , nq(10)
pctile OCC_29 = L_IWSTPP if (COMBINEDII == 29) ///
    [aweight = WTPSN] , nq(10)
list OCC_01 OCC_02 OCC_03 OCC_04 OCC_05 in 1/9
list OCC_06 OCC_07 OCC_08 OCC_09 OCC_10 in 1/9
list OCC_11 OCC_12 OCC_13 OCC_14 OCC_15 in 1/9
list OCC_16 OCC_17 OCC_18 OCC_19 OCC_20 in 1/9
list OCC_21 OCC_22 OCC_23 OCC_24 OCC_25 in 1/9
list OCC_26 OCC_27 OCC_28 OCC_29 in 1/9
