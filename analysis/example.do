set more off
save tempcf, replace emptyok  

*** adjust the parameters of the forvalues command to estimate the quantiles of choice
*** in this example, the estimation is done at every fifth centile
*** you can remove quietly if you want to see the rif-regression results
forvalues q = 0.05(0.05)0.95 {
  use usmen0305_two, clear
  rifreg lwage union educ exp expsq, quantile(`q') w(0.06) 
  matrix B=e(b)
  svmat double B, name(coef)
  gen quant=`q'
  keep quant coef*
  keep if _n==1
  append using tempcf
  save tempcf, replace
 }

use tempcf, clear
sort quant
label var quant "Quantile"
*** choose the coefficient(s) that you want to graph, here coef1 is the coefficient of union coverage
graph twoway (connected coef1 quant if quant>0.0 & quant<1.0  ) /*
   */, xlabel(0.0 0.2 0.4 0.6 0.8 1.0) title("Union Premium") ytitle(" ") /*
   */  yline(0.0, lw(thin) lc(black)) saving(unionpr1,replace)

graph export unionpr1.wmf, replace
