# a simple experiment to confirm I understand the bootstrap

set.seed(3141)

X <- 1:500
Y <- 0.005 * X + rnorm(length(X))
dat <- data.frame(X, Y)
fit <- lm(Y ~ X, data=dat)

res = matrix(rep(NA,8),nrow=2)
colnames(res) <- c("Coef", "S.E.", "z", "Pr(>|z|)")
rownames(res) <- rownames(summary(fit)$coefficients)
res[,1] <- coef(fit)
N <- 10000
reps <- matrix(rep(NA,2 * N), nrow=2)
for (rep in 1:N) {
  dataS <- dat[sample(1:nrow(dat), replace=T),]
  m <- lm(Y ~ X, data=dataS)
  reps[,rep] <- coef(m)
}
for (i in 1:2) {
  res[i,2] <- sd(reps[i,])
  res[i,3] <- res[i,1] / res[i,2]
  res[i,4] <- 2*pnorm(q=abs(res[i,3]), lower.tail=FALSE)
}

# now try with R boot library
library(boot)
mycoef <- function(formula, data, indices) {
  d <- data[indices,]
  fit <- lm(formula, data=d)
  return(coef(fit))
}
b <- boot(data=dat, statistic=mycoef, R=N, formula=Y~X)


summary(fit)
b
print(res, digits=6)
