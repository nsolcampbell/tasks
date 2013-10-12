# A simple power simulation to test our Oaxaca-Blinder decomposition
#
# We simulate a comparison between two periods, A and B, where thef
# covariate distributions are different: X_A ~ \Xi_A, X_B ~ \Xi_B.
#
# For the purposes of this simulation, the true models and parameters
# are known. We check that our decomposition and weighting procedure
# is unbiased.
#
# Note: a major simplifying assumption is that we use simple sampling.
# The real model is a clustered, hierarchical survey, and so we have to
# trust the weights given.
#
# This is an impelmentation in R, to test whether the STATA code is
# working correctly. It is not written in STATA because life is short,
# deadlines are soon, and self-flagellation isn't my idea of a good time.
#

rm(list=ls())
source("lib/ob.decomp.R")

# covariate matrix X_t, t=A,B:
#  X_ti = [ age educ female occ ]_ti
#
# age = [15, 99]
# female =
#    1 if female,
#    0 if male
# occ =
#    1 if professional,
#    2 if routine,
#    3 if unskilled
# educ =
#    1 for high school
#    2 for trade
#    3 for bachelor
#    4 for postgrad

set.seed(42037476)

# "true" model coefficients
coeffts.A <- c(log(622), # intercept is minimum wage
                .05,    # age
                -0.001, # age^2
                -0.25,  # female
                        # base occ: unskilled
                0.1,    # routine job
                1.0,    # professional
                        # base educ: HS
                0.5,    # trade qualification
                0.5,    # bachelor
                1.0,    # postgrad
                0.25    # talent bonus
                )
coeffts.B <- c(log(622), # intercept is minimum wage
                .05,    # age
                -0.001, # age^2
                -0.25,  # female
                        # base occ: unskilled
                0.1,    # routine job
                2.0,    # professional
                        # base educ: HS
                0.5,    # trade qualification
                0.5,    # bachelor
                2.0,    # postgrad
                0.25    # talent bonus
                )

wage <- function(X, model=c('A','B')) {
  Xt <- data.frame(X, talent = rnorm(nrow(X)))
  Xm <- model.matrix(~ 1 + age + I(age^2) + sex + occ + educ + talent,
                     data=Xt)
  if (model == 'A') {
    loadings <- coeffts.A
  } else {
    loadings = coeffts.B
  }
  Y <- Xm %*% matrix(loadings)
  return(Y)
}

## Generate a covariate matrix X
## The probabilities in the 
generate.X <- function(N,
                       pr.female = 0.5,
                       pr.prof = 0.3, pr.routine = 0.2,
                       pr.trade = 0.3, pr.bach = 0.3, pr.pg = 0.1) {
  # we'll leave the age distribution constant
  age <- sample(15:99, size=N, replace=T)
  sex <- sample(0:1, size=N, replace=T,
                  prob = c( 1-pr.female, pr.female))
  occ <- sample(1:3, size=N, replace=T,
                  prob = c(pr.prof, pr.routine, 1 - pr.prof - pr.routine))
  educ <- sample(1:4, size=N, replace=T,
                  prob = c(1-pr.trade-pr.bach-pr.pg, pr.trade,
                           pr.bach, pr.pg))

  X = data.frame(age=age,
    sex=factor(sex, levels=0:1, labels=c('male','female')),
    occ=factor(occ, levels=1:3,
      labels=c('unskilled','routine','professional')),
    educ=factor(educ, levels=1:4,
      labels=c('highschool','trade','bachelor','postgrad'))
    )
  return(X)
}

## Wrapper for all of the above generator functions
generate <- function(N, group, structure='A', ...) {
  X <- generate.X(N, ...)
  return(data.frame(Y=wage(X, structure), X, group=group, weights=1))
}

# first experiment: exactly the same weightings, but different covariates
set.seed(42037476)
x1 <- generate(1000, group='A', structure='A', pr.prof = 0.2)
x2 <- generate(1000, group='B', structure='A', pr.prof = 0.5)
X <- rbind(x1, x2)
ob.decomp(Y ~ 1 + age + I(age^2) + sex + educ + occ, group='group',
          data=X, reps=50, weights=weights)

# second experiment: different wage structures, same covariate distribution
set.seed(42037476)
x1 <- generate(10000, group='A', structure='A')
x2 <- generate(10000, group='B', structure='B')
X <- rbind(x1, x2)
ob.decomp(Y ~ 1 + age + I(age^2) + sex + educ + occ, group='group',
          data=X, weights=weights)

library(ggplot2)
ggplot(X, aes(x=Y, color=group)) + geom_density()
