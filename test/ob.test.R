# Test of the Oaxaca-Blinder decomposition code
# replicates http://www.mathiassinning.com/program-code.html

# You'll need to download nldecomp.dta and put it in test/

source("lib/ob.decomp.R")

require(foreign)
nldecomp <- read.dta("test/nldecompose.dta")
XA <- nldecomp[nldecomp$group == 0,]
XB <- nldecomp[nldecomp$group == 1,]

fit <- ob.decomp(y_regress ~ x1 + x2 + x3, dataA=XA, dataB=XB)
fit

