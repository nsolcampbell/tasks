# Augmented Oaxaca-Blinder decompositions
# for wage quantiles between periods
library(ggplot2)
library(doBy)
library(reshape2)
source("lib/plot_theme.R")

# quantiles by year
qs_2010_i  <- as.matrix(read.csv("data/quantiles/overall_2010_i_reweighted.csv"))[,3]
qs_1982_i  <- as.matrix(read.csv("data/quantiles/overall_1982_i.csv"))
qs_2010_ii <- as.matrix(read.csv("data/quantiles/overall_2010_ii_reweighted.csv"))[,3]
qs_2001_ii <- as.matrix(read.csv("data/quantiles/overall_2001_ii.csv"))[,3]

# coefficient matrices
Gamma_2010_i  <- as.matrix(read.csv("data/rif/2010_i_reweighted.csv"))
Gamma_1982_i  <- as.matrix(read.csv("data/rif/1982_i.csv"))
Gamma_2010_ii <- as.matrix(read.csv("data/rif/2010_ii_reweighted.csv"))
Gamma_2001_ii <- as.matrix(read.csv("data/rif/2001_ii.csv"))

# expected value of covariates
Ex_2010_i  <- as.matrix(read.csv("data/EX/2010_i_reweighted.csv"))
Ex_1982_i  <- cbind(q=0, as.matrix(read.csv("data/EX/1982_i.csv")), Xconst=0)
Ex_2010_ii <- as.matrix(read.csv("data/EX/2010_ii_reweighted.csv"))
Ex_2001_ii <- as.matrix(read.csv("data/EX/2001_ii.csv"))
# which we now express as a (dim=1) matrix
rep.row <- function(x, n) {
    matrix(rep(x,each=n),nrow=n)
}
EX_2010_i  <- rep.row(Ex_2010_i,  19)
EX_1982_i  <- rep.row(Ex_1982_i,  19)
EX_2010_ii <- rep.row(Ex_2010_ii, 19)
EX_2001_ii <- rep.row(Ex_2001_ii, 19)

# ## Now compute Oaxaca-Blinder decompositions ###
#
# Recall that:
#
#    \Delta_O^q = \Delta_S^q + \Delta_X^q
#
#               = E[X|T=1] . (\gamma_1^q - \gamma_0^q)
#                 + (E[X|T=1]-E[X|T=0]) . \gamma_0^q
#
# NB: in the arithmetic that follows, matrix rows represent
#     the 19 quantiles of interest, {0.05 ... 0.95} 

# ### grouping I ###
Delta_O_i <- qs_2010_i - qs_1982_i
DGamma_i  <- cbind(Gamma_2010_i - Gamma_1982_i, q = 1:19)
DEX_i     <- EX_2010_i - EX_1982_i

Delta_S_i <- (Gamma_2010_i - Gamma_1982_i) %*% t(Ex_2010_i)
# and now disaggregated version
Delta_S_i_d <- (Gamma_2010_i - Gamma_1982_i) * EX_2010_i
Delta_X_i <- Gamma_2010_i %*% t(Ex_2010_i - Ex_1982_i)

# ### grouping II ###
Delta_O_ii <- qs_2010_ii - qs_2001_ii
DGamma_ii  <- cbind(Gamma_2010_ii - Gamma_2010_i, q = 1:19)
DEX_ii     <- EX_2010_ii - EX_2001_ii

Delta_S_ii <- (Gamma_2010_ii - Gamma_2001_ii) %*% t(Ex_2001_ii)
# and now disaggregated version
Delta_S_ii_d <- (Gamma_2010_ii - Gamma_2001_ii) * EX_2001_ii
Delta_X_ii <- Gamma_2010_ii %*% t(Ex_2010_ii - Ex_2001_ii)

# Convert the detailed \Delta_S matrix into a long-format data frame
# for plotting in ggplot
make.dframe <- function(Delta_S_d) {
    # modify for plotting
    cols_new <- c("<5 yrs exp", "5-10 yrs exp", "15-20 yrs exp", "25-30 yrs exp", 
                  "30-35 yrs exp", "35-40 yrs exp", "40+ yrs exp", "less than HS", 
                  "high school", "bachelor", "postgraduate", "female", "married", 
                  "information job", "routine job", "face-to-face job", "on-site job", 
                  "decision-making job")
    cols_old <- c("expdum1", "expdum2", "expdum3", "expdum5", 
                  "expdum6", "expdum7", "expdum8", "educ1", "educ2", "educ4", 
                  "educ5", "female", "married", "inform", "routine", "face", "site", 
                  "decision")
    dg.wide <- cbind(data.frame(Delta_S_d)[,cols_old], q=seq(0.05, 0.95, 0.05))
    dg.long <- melt(dg.wide, id='q')
    names(dg.long) <- c("q", "covariate", "value")
    dg.long$covariate <- with(dg.long, factor(covariate, ordered=T, levels=cols_old, labels=cols_new))
    return(dg.long)
}

pdf("figure/decomp2.pdf", paper="a4r", height=8, width=12)
p <- ggplot(make.dframe(Delta_S_i_d), aes(y=value, x=q, group=covariate)) + 
        geom_line(color='red') + facet_wrap(~ covariate) +
        ggtitle("Decomposition of effect of covariates on log wage quantiles, 1982-2010") +
        geom_hline(y=0, alpha=0.5) +
        ylab("Wage difference (log points)") +
        xlab("Wage quantile") +
        theme(legend.position='none')
print(p)
print(p %+% make.dframe(Delta_S_ii_d) +
          ggtitle("Decomposition of effect of covariates on log wage quantiles, 2001-2010"))
dev.off()

pdf("figure/decomp.pdf", paper="a4r", height=8, width=12)
cframe <- rbind(cbind(make.dframe(Delta_S_i_d), period='1981-2010'), 
                cbind(make.dframe(Delta_S_ii_d), period='2001-2010'))
p <- ggplot(cframe, aes(y=value, x=q, group=period, color=period)) + 
    geom_line() + facet_wrap(~ covariate) +
    ggtitle("Decomposition of effect of covariates on log wage quantiles, 1982-2010") +
    geom_hline(y=0, alpha=0.5) +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile")
print(p)
dev.off()

pdf("figure/rif.pdf", paper="a4r", height=8, width=12)
dframe <- make.dframe(Gamma_2010_i)
dframe <- dframe[dframe$covariate != '<5 yrs exp',]
p <- ggplot(dframe, aes(y=value, x=q, group=covariate)) + 
    geom_line(color='red') + facet_wrap(~ covariate) +
    ggtitle("RIF Regression Results 2010") +
    geom_hline(y=0, alpha=0.5) +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile") +
    theme(legend.position='none')
print(p)
dframe <- make.dframe(Gamma_1982_i)
# dframe <- dframe[dframe$covariate != '<5 yrs exp',]
print(p %+% dframe +
          ggtitle("RIF Regression Results 1982"))
dev.off()

# Summarize decomposition by grouping (summing) effects
summarize.decomp <- function(Delta) {
    exper  <- apply(Delta[,2:8], MARGIN=1, FUN=sum)
    educ   <- apply(Delta[,9:12], MARGIN=1, FUN=sum)
    auto   <- apply(Delta[,15:16], MARGIN=1, FUN=sum)
    outsrc <- apply(Delta[,17:19], MARGIN=1, FUN=sum)
    summ <- cbind(q=1:19*0.05, exper, educ, auto, outsrc)
    return(as.data.frame(summ))
}

decomp <- ggplot(cframe, aes(y=value, x=q, group=covariate, shape=covariate, color=covariate)) + 
    geom_line() + facet_wrap(~ period) +
    ggtitle("Decomposition of effect of covariates on log wage quantiles, 1982-2010") +
    geom_point() +
    geom_hline(y=0, alpha=0.5) +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile")

# Summarize decomposition by grouping (summing) effects
extract.covariates <- function(Delta) {
    summ <- cbind(q=1:19*0.05, Delta[,15:19])
    colnames(summ) <- c("q",
                        "Information","Routinization",
                        "No.Face.to.Face", "No.On.Site",
                        "No.Decision")
    return(as.data.frame(summ))
}
cov.decomp_i <- melt(extract.covariates(Delta_S_i_d), id='q',
                     variable.name='covariate')
cov.decomp_i$period <- "1981/82 -- 2009/10"

cov.decomp_ii <- melt(extract.covariates(Delta_S_ii_d), id='q',
                     variable.name='covariate')
cov.decomp_ii$period <- "2000/01 -- 2009/10"

pdf("figure/structure_decomp.pdf", width=8, height=5.5)
decomp %+% rbind(cov.decomp_i, cov.decomp_ii) +
    ggtitle("Wage Structure Effect: Detailed Decomposition")
dev.off()
