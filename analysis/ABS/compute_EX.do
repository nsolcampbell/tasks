* compute E[X|T=t] - weighted mean of all explanatory variables
*                    given the time period

clear
set more off
use "1982_i"

collapse expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = PERS_WT]

export delimited using "EX_1982_i.csv", replace

drop _all
use "2001_ii"

summarize expdum1-expdum3 expdum5-expdum8 female married ///
      educ1 educ2 educ4 educ5 ///
      inform routine face site decision [aweight = WTPSN]

export delimited using "EX_2001_ii.csv", replace

drop _all
use "2010_i"

summarize expdum1-expdum8 female married ///
      educ1-educ5 inform routine face site decision [aweight = SIHPSWT]

export delimited using "EX_2010_i.csv", replace

drop _all
use "2010_ii"

summarize expdum1-expdum8 female married ///
      educ1-educ5 inform routine face site decision [aweight = SIHPSWT]

export delimited using "EX_2010_i.csv", replace
