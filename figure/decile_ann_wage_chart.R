library(ggplot2)

deciles <- read.csv("data/deciles_ann_wage_growth.csv", skip=3)

# exclude 2007-2009 (wrong)
deciles <- deciles[deciles$Period != '2007 to 2009',]
deciles$Percentile <- as.factor(deciles$Percentile)

# Patterns of income growth by decile and period, Australia, 1981-82 to 2007-08 
# Average annual percentage change in real equivalent income unit income, working age

pdf("doc/slides/figure_wage_deciles.pdf", height=8, width=12)
ggplot(deciles, aes(y=Change*100, x=Percentile, group=Period)) + 
  geom_bar(stat="identity") +
#  ggtitle("Wage Changes by Decile") +
  ylab("percentage change") +
  xlab("real equivalized income decile") +
  theme_bw(base_size=32) +
  theme(strip.background = theme_rect(fill = 'white')) +
#  facet_grid(Period~.)
  facet_wrap(~Period)
dev.off()
