library(ggplot2)
library(plyr)
library(isotone) # for weighted median
source('lib/footnote.R')
source('lib/plot_theme.R')
load('data/curf/ftwswaw.rda')
# Standard footnote for figures
footnote <- function() { makeFootnote("Full-time wage/salary earners. 2013 AUD, CPI deflator. Source: ABS cat. 6543.0, 6541.0, 6503.0.")}


log_chg <- ddply(ftwswaw, ~Sex + Year, summarise, 
                 perc95 = weighted.fractile(log(CRInc), SexYearWeight, 0.95), 
                 perc5 = weighted.fractile(log(CRInc), SexYearWeight, 0.05), 
                 median = weighted.median(log(CRInc), Weight))
for (sex in c("Male", "Female")) {
    subs <- with(log_chg, which(Sex == sex))
    for (c in c("perc95", "perc5", "median")) {
        log_chg[subs, c] <- log_chg[subs, c] - log_chg[subs[1], c]
    }
}
pdf("figure/wage_change_time.pdf", width=9, height=5)
p <- ggplot(melt(log_chg), aes(x = as.numeric(as.character(Year)), y = value, group = variable, 
                          color = variable)) + geom_point() + geom_line() + facet_grid(. ~ Sex) + 
    scale_x_continuous() + xlab("Year") + ylab("Log points") + 
    ggtitle("Cumulative log change in real weekly earnings: 95th, 50th, 5th percentile")
print(p)
footnote()
dev.off()
