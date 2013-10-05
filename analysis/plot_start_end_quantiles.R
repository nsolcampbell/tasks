rm(list=ls())
library(reshape2)
library(ggplot2)

source('lib/centered_cpi.R')

pdf("figure/quantile_changes_by_occupation.pdf", paper="a4r", width=12, height=8)
for (grouping in c(1,2)) {
if (grouping == 2) {
    start_w <- read.csv("data/quantiles/2001_combined2.csv")[,-1]
    start_w <- start_w - log(centered_cpi(2001)) + log(centered_cpi(2010))
    end_w <- read.csv("data/quantiles/2010_combined2.csv")[,-1]
    load("data/tasks.combinedii.rda")
    titles <- tasks.combinedii$CombinedII.Title
    load("data/lambdas/combinedii.rda")
    plot_title <- "Occupation Group #2: Log Wage Quantiles, 2000/01 - 2009/10"
} else {
    start_w <- read.csv("data/quantiles/1982_combined1.csv")[,-1]
    start_w <- start_w - log(centered_cpi(1982)) + log(centered_cpi(2010))
    end_w <- read.csv("data/quantiles/2010_combined1.csv")[,-1]
    end_w <- end_w
    load("data/tasks.combinedi.rda")
    titles <- tasks.combinedi$Title
    load("data/lambdas/combinedi.rda")
    plot_title <- "Occupation Group #1: Log Wage Quantiles, 1981/82 - 2009/10"
}

lambda_matrix <- matrix(rep(Lambda, nrow(end_w)), ncol=9, nrow=nrow(end_w), byrow=T)

diff_w = end_w - start_w - lambda_matrix
nocc <- ncol(diff_w)
colnames(diff_w) <- 1:nocc
colnames(start_w) <- 1:nocc

start_w <- data.frame(cbind(quantile=1:9, start_w))
diff_w <- data.frame(cbind(quantile=1:9, diff_w))

# mydf <- cbind(titles, data.frame(t(diff_w)), data.frame(start_w))
# mydfl <- melt(mydf[,1:10])
# mydfl$variable <- as.numeric(gsub("X","",mydfl$variable))
# names(mydfl) <- c("occ", "q", "chg")
# 
# ggplot(mydfl, aes(x=q, y=chg, group=occ, color=occ)) + geom_line()

end.df <- data.frame(occ=titles, t(end_w))
end_l <- melt(end.df, id.vars=1, value.name="q")
end_l$variable <- factor(as.numeric(gsub("X","",end_l$variable)), ordered=T)
end_l$group <- "end"

start.df <- data.frame(occ=titles, t(start_w[,-1]))
start_l <- melt(start.df, id.vars=1, value.name="q")
start_l$variable <- factor(as.numeric(gsub("X","",end_l$variable)), ordered=T)
start_l$group <- "start"

start_end <- rbind(start_l, end_l)

p <- ggplot(start_end, aes(x=variable, y=q, group=group, colour=group)) + 
    geom_line() + facet_wrap(~occ) +
    ggtitle(plot_title) +
    theme_bw()
print(p)
}
dev.off()