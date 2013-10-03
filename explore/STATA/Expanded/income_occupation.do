input byte(OCC6DIG COMBINEDII)
10	1
11	1
12	2
13	3
14	4
20	5
21	5
22	6
23	7
24	8
25	9
26	6
27	11
30	12
31	12
32	13
33	14
34	15
35	16
36	17
39	18
40	29
41	31
42	20
43	4
44	18
45	18
50	19
51	20
52	21
53	19
54	19
55	19
56	19
59	22
60	23
61	30
62	23
63	23
70	24
71	24
72	24
73	25
74	26
80	27
81	28
82	27
83	26
84	27
85	27
89	27
end
tempfile AnzscoCombined2
quietly save "`AnzscoCombined2'", replace
drop _all

* EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
	WPS0101-WPS0160

* merge m:1 OCC6DIG using `AnzscoCombined2'

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using `AnzscoCombined2', unmatched(both)

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
