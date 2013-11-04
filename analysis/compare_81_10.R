rm(list=ls())
source('lib/centered_cpi.R')
library(reshape2)

cpi_82_10 <- log(centered_cpi(2010)) - log(centered_cpi(1982))

q82i <- read.csv("data/quantiles/overall_1982_i.csv")
q10i_rw <- read.csv("data/quantiles/overall_2010_i_reweighted.csv")
q10i <- read.csv("data/quantiles/overall_2010_i.csv")

cmp8210 <- data.frame(q=1:19*0.05, 
                      wage.structure=q10i_rw$est - cpi_82_10 - q82i$QUANTILES1,
                      composition=0,
                      total=q10i$est - cpi_82_10 - q82i$QUANTILES1)
cmp8210 <- within(cmp8210, composition <- total - wage.structure)
cmp8210.long <- melt(cmp8210, id.vars='q', variable.name='variable', value.name='lwage')

library(ggplot2)
p1 <- ggplot(cmp8210.long, aes(x=q, y=lwage, colour=variable, fill=variable)) + 
    geom_line(alpha=0.5, aes(group=variable)) + geom_point() +
    ggtitle("Aggregate Decomposition: 1981/2 - 2009/10") +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile") +
    geom_hline(y=0, color="black", alpha="0.5")
print(p1)

# ************* Compare 2000/1 to 2009/10 *************

cpi_01_10 <- log(centered_cpi(2010)) - log(centered_cpi(2001))

q01ii <- read.csv("data/quantiles/overall_2001_ii.csv")
q10ii_rw <- read.csv("data/quantiles/overall_2010_ii_reweighted.csv")
q10ii <- read.csv("data/quantiles/overall_2010_ii.csv")

cmp0110 <- data.frame(q=1:19*0.05, 
                      wage.structure=q10ii_rw$est - cpi_01_10 - q01ii$est,
                      composition=0,
                      total=q10ii$est - cpi_01_10 - q01ii$est)
cmp0110 <- within(cmp0110, composition <- total - wage.structure)
cmp0110.long <- melt(cmp0110, id.vars='q', variable.name='variable', value.name='lwage')

library(ggplot2)
p2 <- ggplot(cmp0110.long, aes(x=q, y=lwage, colour=variable, fill=variable)) + 
    geom_line(alpha=0.5, aes(group=variable)) + geom_point() +
    ggtitle("Aggregate Decomposition: 2000/1 - 2009/10") +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile") +
    geom_hline(y=0, color="black", alpha="0.5")
print(p2)

# ********** compare 2 on same chart **************

cmp8210.long$grouping <- "1981/82 -- 2009/10"
cmp0110.long$grouping <- "2000/01 -- 2009/10"
cmp.long <- rbind(cmp8210.long, cmp0110.long)

p.all <- ggplot(cmp.long, aes(x=q, y=lwage, colour=variable, fill=variable)) + 
    geom_line(alpha=0.5, aes(group=variable)) + geom_point() +
    ggtitle("Aggregate Decomposition of Wage Changes") +
    facet_grid(~grouping) +
    ylab("Wage difference (log points)") +
    xlab("Wage quantile") +
    geom_hline(y=0, color="black", alpha="0.5")
pdf("figure/aggregate_decomp.pdf", width=12, height=6)
print(p.all)
dev.off()
