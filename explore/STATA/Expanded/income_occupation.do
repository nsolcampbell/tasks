input byte(OCC6DIG ASCO2)
0	.
10	10
11	11
12	13
13	12
14	33
20	20
21	25
22	22
23	21
24	24
25	23
26	22
27	25
30	30
31	31
32	41
33	44
34	43
35	45
36	46
39	39
40	30
41	34
42	63
44	39
45	39
50	60
51	32
52	51
53	61
54	61
55	61
56	81
59	59
60	80
61	33
62	82
63	82
70	70
71	72
72	71
73	73
74	79
80	90
81	91
82	99
82	99
83	92
84	99
85	99
89	99
99	.
end
tempfile OccupMap
quietly save "`OccupMap'", replace
drop _all

* EXPANDED CURF
use "`SIH10EP'"

keep ABSHID ABSFID ABSIID ABSLID ABSPID ///
    FTPTSTAT SECEDQL OCC6DIG AGEEC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
	WPS0101-WPS0160

* merge m:1 OCC6DIG using `OccupMap'

* stone age STATA means we need a workaround for merge
sort OCC6DIG
joinby OCC6DIG using `OccupMap', unmatched(both)

svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCC6DIG == 0) | (OCC6DIG == 99)

svrmean IWSSUCP8, by(OCC6DIG)
svrmean IWSSUCP8, by(ASCO2)

* svrtab OCC6DIG
