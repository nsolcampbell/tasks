rm(list=ls())
library(reshape2)
source('analysis/quantile_regressions.R')
source('lib/centered_cpi.R')

# log factor to inflate 2001 prices to 2012 prices
cpi_factor <- log(centered_cpi(2012)) - log(centered_cpi(2001))

# quantiles are in logarithms
start_w <- read.csv("data/quantiles/2001_combined2.csv")[,-1]
start_w <- start_w + cpi_factor
end_w <- read.csv("data/quantiles/2012_combined2.csv")[,-1]
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
dset$occupation <- gsub('X', '', as.character(dset$occupation))
dset$occupation <- factor(dset$occupation)

dset <- within(dset, quantile <- relevel(quantile, ref=9))

# load base period (2000-01) population weights
pop01 <- read.csv("data/population/2001_combinedii.csv")
dset2 <- merge(x=dset, y=pop01, by.x="occupation", by.y="COMBINEDII")

library(nlme)
mdl <- lme(diff ~ 0 + occupation + quantile,
           random = ~ 0 + start|occupation, 
           data=dset2, weights=~Population)

A      <- fixef(mdl)[grep('occupation', names(fixef(mdl)))]
Lambda <- fixef(mdl)[grep('quantile', names(fixef(mdl)))]
B      <- ranef(mdl)

Lambda <- c(Lambda,0) # q=0.1 is the omitted group

load("data/all_tasks.rda")

A.df <- data.frame(A=A, occupation=1:length(A))
A.tasks <- merge(x=A.df, y=tasks.combinedii, by.x='occupation', by.y='COMBINEDII')
A.tasks$Population <- pop01$Population

B <- cbind(B, occupation=1:nrow(B))
names(B) <- c("B", "occupation")
B.tasks <- merge(x=B, y=tasks.combinedii, by.x='occupation', by.y='COMBINEDII')
B.tasks$Population <- pop01$Population

regress <- function(X, depvar) {
  cols <- (colnames(X))[-c(1,2)]
  results <- matrix(rep(NA, length(cols) * 8), ncol=8)
  for (i in 1:length(cols)) {
    f <- as.formula(sprintf("%s ~ %s", depvar, cols[i]))
    fit <- lm(f, weights = Population, data = X)
    results[i,1:4] <- summary(fit)$coefficients[2,]
    results[i,5:8] <- summary(fit)$coefficients[1,]
  }
  rownames(results) <- cols
  colnames(results) <- c("Estimate", "Std. Error", "t value", "Pr(>|t|)",
                         "Constant", "Std. Error", "t value", "Pr(>|t|)")
  return(results)
}

A.results <- regress(A.tasks, 'A')
B.results <- regress(B.tasks, 'B')

write.csv(A.results, file='/tmp/A.ii.results.csv')
write.csv(B.results, file='/tmp/B.ii.results.csv')
