# Oaxaca-Blinder decomposition
# Alex Cooper Oct 2013

## Perform a Oaxaca-Blinder decomposition with bootstrapped
## standard errors
ob.decomp <- function(formula, group, data, weights=NA,
                      bootstrap=T, reps=50) {
  call <- match.call()

  if (nlevels(factor(data[,group])) != 2)
    stop(paste0(group,"must have exactly 2 levels"))
  lvl1  <- levels(factor(data[,group]))[1]
  dataA <- data[data[,group] == lvl1,]
  dataB <- data[data[,group] != lvl1,]
  
  nA <- nrow(dataA); nB <- nrow(dataB)

  ob.compute <- function(formula, XA, XB, weights) {
    YbarA <- mean(XA[,attr(terms(formula),'response')])
    YbarB <- mean(XB[,attr(terms(formula),'response')])

    # linear models for both (which we know to be correctly specced)
    fitA   <- lm(formula, data=XA, weights=weights)
    fitB   <- lm(formula, data=XB, weights=weights)
    
    # mean covariate matrices
    XAbar <- colMeans(model.matrix(formula, data=XA))
    XBbar <- colMeans(model.matrix(formula, data=XB))

    return(list(O=YbarA - YbarB, # overall
                X=(XAbar - XBbar) %*% coef(fitA), # composition
                S=(coef(fitA) - coef(fitB)) %*% XAbar))
  }

  coef <- matrix(rep(NA,12), nrow=3,
                 dimnames=list(c("Delta_O","Delta_X","Delta_S"),
                   c("Coefficient","Bootstrap SE","z-score","Pr(>|z|)")))
  # get point estimates
  est <- ob.compute(formula, dataA, dataB, weights)
  coef[,1] <- c(est$O, est$X, est$S)

  if (bootstrap) {
    r.mat <- matrix(rep(NA,reps*3),nrow=3)
    for (i in 1:reps) {
      XAs <- dataA[sample(1:nA, replace=T),]
      XBs <- dataB[sample(1:nB, replace=T),]
      est <- ob.compute(formula, XAs, XBs, weights)
      r.mat[,i] <- c(est$O, est$X, est$S)
    }
    for (i in 1:3) {
      coef[i,2] <- sd(r.mat[i,]) # S.D.
      coef[i,3] <- coef[i,1] / coef[i,2]
      coef[i,4] <- 2*pnorm(sd=coef[i,2],q=abs(coef[i,1]),lower.tail=F)
    }
  }
  ob <- list(coef=coef, call=call, formula=formula, nA=nA, nB=nB, reps=reps,
             bootstrap=bootstrap)
  class(ob) <- "ob"
  return(ob)
}

print.ob <- function(x, digits = max(3, getOption("digits") - 3), ...) {
  cat("Oaxaca-Blinder decomposition results\n\n")
  cat("Call:  ", paste(deparse(x$call), sep = "\n", collapse = "\n"), 
      "\n\n", sep = "")
  print.default(format(x$coef, digits=digits, scientific=F), 
                print.gap=2, quote=FALSE)
  cat("\n\nSample A size:\t", x$nA, "\tSample B size:\t", x$nB, "\n")
  if(x$bootstrap) {
    cat("Bootstrap reps:\t", x$reps, "\n")
  }
}
