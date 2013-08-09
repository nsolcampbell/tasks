cd "/Users/acooper/Documents/School/polarization/data/curf/2010/SIH10BE2 Component/"

clear *
set more off
input byte(OCCBASC FOUR) str5 MetaValue
1 9 "Managers nfc"
2 8 "Ted"
3 7 "Carol"
4 6 "Alice"
5 5 "asf"
6 4 "asdfw"
7 3 "wefsdf"
8 2 "1234"
9 1 "asd"
end
tempfile OccupMap
quietly save "`OccupMap'", replace
drop _all

* BASIC CURF
use "sih10bp.dta", clear

keep FTPTSTAT SECEDQL OCCBASC AGEBC PSRC4PP PSRCSCP IWSSUCP8 IWSUCP SIHPSWT ///
	WPS0101-WPS0160

merge m:1 OCCBASC using `OccupMap'

quietly replace MetaValue = "Not Mapped" if missing(MetaValue)

* see http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/3607C2551414E995CA257A5D000F7C5D?opendocument
svrset set meth jk1 pw SIHPSWT rw WPS0101-WPS0160 dof 59

* keep only full-time Wage & Salary records
drop if (PSRCSCP != 1) | (FTPTSTAT != 1)

* remove "Not Applicable" or "Inadequately Described" records
drop if (OCCBASC == 0) | (OCCBASC == 9)

* BASIC CURF
svrmean IWSSUCP8, by(OCCBASC)
svrtab OCCBASC
