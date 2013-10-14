library(reshape2)
library(ggplot2)
source("lib/plot_theme.R")

coli <- c(1, 15:19)
coln <- c("qtile", "inform", "routine", "face", "site", "decision")
# female = 13, married = 14
rifl_all <- NULL
# names(rifl_all) <- c("qtile", "year", "scheme", "variable", "value")

for (f in c("1982_i", "2012_i", "2001_ii", "2012_ii")) {
  rif <- read.csv(sprintf("data/rif/%s.csv", f), header=FALSE)[,coli]
  names(rif) <- coln
  rif <- within(rif, year <- substr(f,1,4))
  rif <- within(rif, scheme <- substr(f,6,7))

  cis <- read.csv(sprintf("data/rif/var_%s.csv", f), header=FALSE)[-1,coli]
  names(cis) <- coln
  cis$qtile <- cis$qtile - 0.05
  cis[,-1] <- sqrt(cis[,-1]) * 1.96
  cis <- within(cis, year <- substr(f,1,4))
  cis <- within(cis, scheme <- substr(f,6,7))

  avoid <- c(1,7,8)
  up <- rif
  up[,-1] <- rif[,-avoid] + cis[,-avoid]
  low <- rif
  low[,-1] <- rif[,-avoid] - cis[,-avoid]
  
  rifl <- melt(rif, id = c('qtile','year','scheme'))
  upl  <- melt(up, id=c('qtile')); names(upl)[3] <- 'up'
  lowl <- melt(low, id=c('qtile')); names(lowl)[3] <- 'low'

  rifl2 <- merge(merge(upl, rifl), lowl)
  
  if (is.null(rifl_all)) {
    rifl_all <- rifl2
  } else {
    rifl_all <- rbind(rifl_all, rifl2)
  }
}

rifl_all$period <- with(rifl_all, ifelse(year == "2010", "T=1", "T=0"))
rifl_all$panel <- with(rifl_all, paste(year, "Scheme", scheme))

pdf("figure/rif.pdf", height=8, width=8)
p <- ggplot(rifl_all,
            aes(x=qtile, y=value, colour=variable, linetype=variable)) +
    geom_line() +
    geom_ribbon(alpha=0.3, aes(ymin=low, ymax=up, fill=variable, colour=NA, linetype=NA)) +
    ggtitle("Occupational Task Measures and Log Wage Quantiles") +
    xlab("Log Wage Quantile") +
    ylab("Wage Impact (log points per scale unit)") +
    geom_hline(y=0, alpha=0.5, color="black") +
    facet_wrap(~panel)
print(p)
dev.off()
