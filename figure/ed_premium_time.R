rm(list=ls())

library(ggplot2)
library(plyr)
library(isotone) # for weighted median
library(doBy)
library(reshape2)
source('lib/footnote.R')
source('lib/plot_theme.R')
load('data/curf/harmonized.ft.rda')
# Standard footnote for figures
footnote <- function() { makeFootnote("Full-time wage/salary earners. 2013 AUD, CPI deflator. Source: ABS cat. 6543.0, 6541.0, 6503.0.")}

mydata <- harmonized.ft

mydata$Group <- recodeVar(as.character(mydata$EducB),
                            c("No Post-Secondary","Associate/Trade","Bachelor or Higher"),
                            c("L","M","H"))

log_median <- ddply(mydata, ~Sex + Year + Group, summarise, 
                 mean = weighted.mean(log(CRInc), Weight))
wide_median <- acast(log_median, Sex ~ Year ~ Group, value.var="mean")
wide_median[,,"H"] <- wide_median[,,"H"] - wide_median[,,"L"]
wide_median[,,"M"] <- wide_median[,,"M"] - wide_median[,,"L"]
premium <- melt(wide_median[,,c("H","M")])
colnames(premium) <- c("Sex","Year","Ratio","Premium")
premium$Ratio <- recodeVar(as.character(premium$Ratio),
                           c("M","H"),
                           c("Trade/associate degree vs none","Bachelor degree or higher vs none"))

pdf("figure/ed_premium_time.pdf", width=9, height=5)
p <- ggplot(premium, aes(x = Year, y = Premium, group = Ratio, 
                          color = Ratio)) + geom_point() + geom_line() + #facet_grid(. ~ Sex) + 
        scale_x_continuous() + xlab("Year") + ylab("Log points") + 
        ggtitle("Education Wage Premium 1981-2010")
print(p)
footnote()
dev.off()

# repeat the above, but with only two categories, and no sex variable
mydata$Group2 <- recodeVar(as.character(mydata$Group),
                           c("L","M","H"),
                           c("L","L","H"))
log_median <- ddply(mydata, .(Year, Group2), summarise, 
                    mean = weighted.mean(log(CRInc), Weight))
wide_median <- acast(log_median, Year ~ Group2, value.var="mean")
wide_median[,"H"] <- wide_median[,"H"] - wide_median[,"L"]
premium <- data.frame(Year=as.numeric(rownames(wide_median)), Premium=wide_median[,"H"])

pdf("figure/ed_premium_time_two.pdf", width=9, height=5)
p <- ggplot(premium, aes(x = Year, y = Premium)) + 
        geom_point() + geom_line() + 
        scale_x_continuous() + xlab("Year") + ylab("Log points") + 
        ggtitle("Education Wage Premium 1981-2010")
print(p)
footnote()
dev.off()
