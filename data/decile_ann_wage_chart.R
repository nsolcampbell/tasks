library(ggplot2)

deciles <- read.csv("deciles_ann_wage_growth.csv", skip=3)

# exclude 2007-2009 (wrong)
deciles <- deciles[deciles$Period != '2007 to 2009',]
deciles$Percentile <- as.factor(deciles$Percentile)

# Patterns of income growth by decile and period, Australia, 1981-82 to 2007-08 
# Average annual percentage change in real equivalent income unit income, working age

pdf("figure_wage_deciles.pdf", height=8, width=12)
ggplot(deciles, aes(y=Change*100, x=Percentile, group=Period)) + 
  geom_bar(stat="identity") +
  facet_wrap(~Period) +
#  ggtitle("Wage Changes by Decile") +
  ylab("Percentage change") +
  xlab("Decile") +
  theme_bw(base_size=18)
dev.off()
