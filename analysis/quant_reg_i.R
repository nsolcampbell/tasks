rm(list=ls())
library(reshape2)
source('analysis/quantile_regressions.R')
source('lib/centered_cpi.R')

start_w <- read.csv("data/quantiles/1982_combined1.csv")[,-1]
start_w <- start_w - log(centered_cpi(1982))
end_w <- read.csv("data/quantiles/2012_combined1.csv")[,-1]
end_w <- end_w - log(centered_cpi(2012))
diff_w = end_w - start_w
nocc <- ncol(diff_w)
colnames(diff_w) <- 1:nocc
colnames(start_w) <- 1:nocc

start_w <- data.frame(cbind(quantile=1:9, start_w))
diff_w <- data.frame(cbind(quantile=1:9, diff_w))

# swap to long format
diff_l <- melt(diff_w, id.vars=1, value.name="diff")
start_l <- melt(start_w, id.vars=1, value.name="start")

dset <- merge(diff_l, start_l, by=c("quantile", "variable"))
names(dset) <- c("quantile", "occupation", "diff", "start")
dset$quantile <- factor(dset$quantile)
dset$occupation <- as.numeric(gsub('X', '', dset$occupation))
dset$occupation <- factor(dset$occupation)

# load 1982 population weights
pop82 <- read.csv("data/population/1982_combinedi.csv")
dset2 <- merge(x=dset, y=pop82, by.x="occupation", by.y="COMBINEDI")

library(nlme)
mdl <- lme(diff ~ 0 + occupation + quantile, random = ~ 0 + start|occupation, 
           data=dset2, weights=dset$population)

A      <- fixef(mdl)[grep('occupation', names(fixef(mdl)))]
Lambda <- fixef(mdl)[grep('quantile', names(fixef(mdl)))]
B      <- ranef(mdl)

Lambda <- c(0,Lambda) # because q=0.1 is the omitted group
save(Lambda, file="data/lambdas/combinedi.rda")

load("data/tasks.combinedi.rda")

A.df <- data.frame(A=A, occupation=1:length(A))
A.tasks <- merge(x=A.df, y=tasks.combinedi, by.x='occupation', by.y='COMBINED1')

B <- cbind(B, occupation=1:nrow(B))
names(B) <- c("B", "occupation")
B.tasks <- merge(x=B, y=tasks.combinedi, by.x='occupation', by.y='COMBINED1')

quantile_regressions(A.tasks, B.tasks, "Intercept and Slope of Change in Wage Quantiles, 1981/2 - 2011/12", 
                     notes="Occupational grouping #1 used, with 28 occupational groups.",
                     out="analysis/quant_reg_i")
