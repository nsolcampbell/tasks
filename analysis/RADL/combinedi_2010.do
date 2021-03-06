***   Generated script: do not edit   ***
*** See analysis/RADL/gen_analysis.py ***


* EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
    WPS0101-WPS0160

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

* *** Overall distribution
pctile OVERALL_DECILES = L_IWSTPP [aweight = SIHPSWT] , nq(10)
list OVERALL_DECILES in 1/9
    * We can't use matrices, so we have to do the following

pctile OCC_01 = L_IWSTPP if (COMBINEDI == 1) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_02 = L_IWSTPP if (COMBINEDI == 2) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_03 = L_IWSTPP if (COMBINEDI == 3) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_04 = L_IWSTPP if (COMBINEDI == 4) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_05 = L_IWSTPP if (COMBINEDI == 5) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_06 = L_IWSTPP if (COMBINEDI == 6) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_07 = L_IWSTPP if (COMBINEDI == 7) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_08 = L_IWSTPP if (COMBINEDI == 8) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_09 = L_IWSTPP if (COMBINEDI == 9) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_10 = L_IWSTPP if (COMBINEDI == 10) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_11 = L_IWSTPP if (COMBINEDI == 11) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_12 = L_IWSTPP if (COMBINEDI == 12) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_13 = L_IWSTPP if (COMBINEDI == 13) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_14 = L_IWSTPP if (COMBINEDI == 14) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_15 = L_IWSTPP if (COMBINEDI == 15) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_16 = L_IWSTPP if (COMBINEDI == 16) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_17 = L_IWSTPP if (COMBINEDI == 17) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_18 = L_IWSTPP if (COMBINEDI == 18) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_19 = L_IWSTPP if (COMBINEDI == 19) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_20 = L_IWSTPP if (COMBINEDI == 20) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_21 = L_IWSTPP if (COMBINEDI == 21) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_22 = L_IWSTPP if (COMBINEDI == 22) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_23 = L_IWSTPP if (COMBINEDI == 23) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_24 = L_IWSTPP if (COMBINEDI == 24) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_25 = L_IWSTPP if (COMBINEDI == 25) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_26 = L_IWSTPP if (COMBINEDI == 26) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_27 = L_IWSTPP if (COMBINEDI == 27) ///
    [aweight = SIHPSWT] , nq(10)
pctile OCC_28 = L_IWSTPP if (COMBINEDI == 28) ///
    [aweight = SIHPSWT] , nq(10)
list OCC_01 OCC_02 OCC_03 OCC_04 OCC_05 in 1/9
list OCC_06 OCC_07 OCC_08 OCC_09 OCC_10 in 1/9
list OCC_11 OCC_12 OCC_13 OCC_14 OCC_15 in 1/9
list OCC_16 OCC_17 OCC_18 OCC_19 OCC_20 in 1/9
list OCC_21 OCC_22 OCC_23 OCC_24 OCC_25 in 1/9
list OCC_26 OCC_27 OCC_28 in 1/9
