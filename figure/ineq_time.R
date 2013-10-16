library(ggplot2)
library(plyr)
library(isotone) # for weighted median
library(doBy)
library(reshape2)
source('lib/footnote.R')
source('lib/plot_theme.R')
load('data/curf/ftwswaw.rda')

# Standard footnote for figures
footnote <- function() { makeFootnote("Measures refer to log difference in earnings percentiles. Full-time wage/salary earners. Source: ABS cat. 6543.0, 6541.0, 6503.0.")}


log_chg <- ddply(ftwswaw, ~Sex + Year, summarise, 
                 perc90 = weighted.fractile(log(CRInc), SexYearWeight, 0.95), 
                 perc10 = weighted.fractile(log(CRInc), SexYearWeight, 0.05), 
                 perc50 = weighted.median(log(CRInc), Weight))
log_chg <- within(log_chg, ineq9010 <- perc90 - perc10)
log_chg <- within(log_chg, ineq9050 <- perc90 - perc50)
log_chg <- within(log_chg, ineq5010 <- perc50 - perc10)

log_chg <- log_chg[,c("Sex","Year","ineq9010","ineq9050","ineq5010")]
for (sex in c("Male", "Female")) {
    subs <- with(log_chg, which(Sex == sex))
    for (c in c("ineq9010", "ineq9050", "ineq5010")) {
        log_chg[subs, c] <- log_chg[subs, c] - log_chg[subs[1], c]
    }
}
long_data <- melt(log_chg)
long_data$variable <- recodeVar(as.character(long_data$variable),
                                c("ineq9010", "ineq9050", "ineq5010"),
                                c("90-10 Inequality", "90-50 Inequality", "50-10 Inequality"))
long_data$variable2 <- factor(long_data$variable, ordered=T, 
                             levels=c("90-10 Inequality", "90-50 Inequality", "50-10 Inequality"))
pdf("figure/ineq_time.pdf", width=9, height=5)
p <- ggplot(long_data, aes(x = as.numeric(as.character(Year)), y = value, group = variable, 
                          color = variable, shape=variable)) + geom_point() + geom_line() + facet_grid(. ~ Sex) + 
    scale_x_continuous() + xlab("Year") + ylab("Log points") + 
    ggtitle("Income Inequality, Full-Time Workers, 1981/2-2011/12")
print(p)
footnote()
dev.off()

