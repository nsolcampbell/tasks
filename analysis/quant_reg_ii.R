rm(list=ls())
library(reshape2)

source('lib/centered_cpi.R')
# log factor to inflate 2001 prices to 2010 prices
cpi_factor <- log(centered_cpi(2010)) - log(centered_cpi(2001))

# quantiles are in logarithms
start_w <- read.csv("data/quantiles/2001_combined2.csv")[,-1]
start_w <- start_w #+ cpi_factor
end_w <- read.csv("data/quantiles/2010_combined2.csv")[,-1]
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

# load base period (2000-01) population weights
pop01 <- read.csv("data/Population/2001_combinedii.csv")
dset2 <- merge(x=dset, y=pop01, by.x="occupation", by.y="COMBINEDII")

library(nlme)
mdl <- lme(diff ~ 0 + occupation + quantile, random = ~ 0 + start|occupation, 
           data=dset2, weights=~Population)

A      <- fixef(mdl)[grep('occupation', names(fixef(mdl)))]
Lambda <- fixef(mdl)[grep('quantile', names(fixef(mdl)))]
B      <- ranef(mdl)

load("data/tasks.combinedii.rda")

A.df <- data.frame(A=A, occupation=1:length(A))
A.tasks <- merge(x=A.df, y=tasks.combinedii, by.x='occupation', by.y='COMBINEDII')
A.tasks$pop <- pop01$Population

B <- cbind(B, occupation=1:nrow(B))
names(B) <- c("B", "occupation")
B.tasks <- merge(x=B, y=tasks.combinedii, by.x='occupation', by.y='COMBINEDII')
B.tasks$pop <- pop01$Population

A.lm.unweighted <- glm(A ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
            data=A.tasks, weights = pop, family = gaussian)

A.lm <- glm(A ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
            data=A.tasks, weights = pop, family = gaussian)

B.lm.unweighted <- glm(B ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
            data=B.tasks, weights = pop, family = gaussian)

B.lm <- glm(B ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
            data=B.tasks, weights = pop, family = gaussian)

library(stargazer)
stargazer(A.lm, A.lm.unweighted, B.lm, B.lm.unweighted, type="text", title="First-stage regression results")
