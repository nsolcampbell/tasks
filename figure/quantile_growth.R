library(ggplot2)
library(scales)
library(plyr)
suppressMessages(library(lmSupport)) # for partial R^2
library(isotone) # for weighted median
library(xtable)
library(reshape2)
source('lib/footnote.R')
source('lib/plot_theme.R')
load('data/curf/harmonized.ft.rda')
# Standard footnote for figures
footnote <- function() { 
    makeFootnote("Composition-adjusted full-time wage/salary earners. CPI deflator. Source: ABS cat. 6401.0, 6543.0, 6541.0, 6503.0.")
}

wage_fractile_growth <- function(data, fracyears, sexes=c('Male','Female'), rel.median=TRUE) {
    fractiles <- matrix(nrow=length(fracyears), ncol=91)
    for (y in 1:length(fracyears)) {
        thisyear <- subset(data, Year == fracyears[y] & Sex %in% sexes)
        frac <- function(p) with(thisyear, weighted.fractile(y=log(CRInc), w=Weight, p=p))
        fractiles[y,] <- sapply((5:95)/100, frac)
    }
    # compute log difference (ie percentage change)
    fracgrowth <- matrix(ncol=91, nrow=length(fracyears)-1,
                         fractiles[2:length(fracyears),] - fractiles[1:(length(fracyears)-1),])
    colnames(fracgrowth) <- 5:95
    if (rel.median) {
        # make relative to median, so subtract the value in column "50" from each row
        for (r in 1:(length(fracyears)-1)) {
            fracgrowth[r,] <- fracgrowth[r,] - fracgrowth[r,50-5+1]
        }    
    }
    rownames(fracgrowth) <- paste(fracyears[1:(length(fracyears)-1)],
                                  fracyears[2:length(fracyears)],sep="-")
    fracgrowth_long <- melt(fracgrowth, id='YearRange')
    colnames(fracgrowth_long) <- c("YearRange","Percentile","Growth")
    return(fracgrowth_long)
}

pdf("figure/quantile_growth.pdf", width=8, height=6)
for (years in list(c(1982, 2010), c(1982, 2001, 2010), levels(harmonized.ft$Year))) {
    growth <- wage_fractile_growth(harmonized.ft, years, c('Male','Female'))
    
    leg.pos <- if (length(years) > 2) "right" else "hidden"
    
    p <- ggplot(growth, 
                aes(x=Percentile, y=Growth, group=YearRange, colour=YearRange)) +
        geom_line() +
        scale_x_continuous(breaks=c(5,25,50,75,95)) +
        ggtitle(paste("Changes in log weekly real wages by percentile",
                      "relative to median, persons, 1982-2010 (Australia)", sep="\n")) +
        xlab("Weekly earnings percentile") +
        ylab("Relative log earnings change") +
        theme(legend.position=leg.pos)
    print(p)
    footnote()
    
    mgrowth <- wage_fractile_growth(harmonized.ft, years, 'Male')
    mgrowth$Sex <- 'Male'
    fgrowth <- wage_fractile_growth(harmonized.ft, years, 'Female')
    fgrowth$Sex <- 'Female'
    
    p <- ggplot(rbind(mgrowth,fgrowth), 
                aes(x=Percentile, y=Growth, group=YearRange, colour=YearRange)) +
        geom_line() +
        facet_grid(.~Sex) +
        scale_x_continuous(breaks=c(5,25,50,75,95)) +
        ggtitle(paste("Changes in log weekly real wages by percentile",
                    "relative to median, by sex, 1982-2010 (Australia)", sep="\n")) +
        xlab("Weekly earnings percentile") +
        ylab("Relative log earnings change") +
        theme(legend.position=leg.pos)
    print(p)
    footnote()
}

# Now absolute plot
years <- c(1982,2010)
leg.pos <- "hidden"
mgrowth <- wage_fractile_growth(harmonized.ft, years, 'Male', rel.median=FALSE)
mgrowth$Sex <- 'Male'
fgrowth <- wage_fractile_growth(harmonized.ft, years, 'Female', rel.median=FALSE)
fgrowth$Sex <- 'Female'
p <- ggplot(rbind(mgrowth,fgrowth), 
            aes(x=Percentile, y=Growth, group=YearRange, colour=YearRange)) +
    geom_line() +
    facet_grid(.~Sex) +
    scale_x_continuous(breaks=c(5,25,50,75,95)) +
    scale_y_continuous(labels=percent) +
    ggtitle(paste("Percentage change in weekly real wages by percentile,",
                  "by sex, 1982-2010 (Australia)", sep="\n")) +
    xlab("Weekly earnings percentile") +
    ylab("Relative earnings change") +
    theme(legend.position=leg.pos)
print(p)
footnote()
dev.off()

pdf('figure/quantile_mf.pdf', height=5, width=10)
years <- c(1982,2010)
leg.pos <- "hidden"
mgrowth <- wage_fractile_growth(harmonized.ft, years, 'Male')
mgrowth$Sex <- 'Male'
fgrowth <- wage_fractile_growth(harmonized.ft, years, 'Female')
fgrowth$Sex <- 'Female'

p <- ggplot(rbind(mgrowth,fgrowth), 
            aes(x=Percentile, y=Growth, group=YearRange, colour=YearRange)) +
    geom_line() +
    facet_grid(.~Sex) +
    scale_x_continuous(breaks=c(5,25,50,75,95)) +
    ggtitle(paste("Changes in log weekly real wages by percentile,",
                  "relative to median, by sex, 1982-2010 (Australia)", sep="\n")) +
    xlab("Weekly earnings percentile") +
    ylab("Relative log earnings change") +
    theme(legend.position=leg.pos)
print(p)
footnote()
dev.off()

png('figure/quantile_mf_abs.png', height=480, width=640)
years <- c(1982,2010)
leg.pos <- "hidden"
mgrowth <- wage_fractile_growth(harmonized.ft, years, 'Male', rel.median=FALSE)
mgrowth$Sex <- 'Male'
fgrowth <- wage_fractile_growth(harmonized.ft, years, 'Female', rel.median=FALSE)
fgrowth$Sex <- 'Female'
p <- ggplot(rbind(mgrowth,fgrowth), 
            aes(x=Percentile, y=Growth, group=YearRange, colour=YearRange)) +
    geom_line() +
    facet_grid(.~Sex) +
    scale_x_continuous(breaks=c(5,25,50,75,95)) +
    scale_y_continuous(labels=percent) +
    ggtitle(paste("Percentage change in weekly real wages by percentile,",
                  "by sex, 1982-2010 (Australia)", sep="\n")) +
    xlab("Weekly earnings percentile") +
    ylab("Relative earnings change") +
    theme(legend.position=leg.pos)
print(p)
footnote()
dev.off()

pdf('figure/quantile_growth_percent.pdf', height=6, width=8)
growth <- wage_fractile_growth(harmonized.ft, c(1982,2010), c('Male','Female'), rel.median=F)
leg.pos <- if (length(years) > 2) "right" else "hidden"
p <- ggplot(growth, 
            aes(x=Percentile, y=(exp(Growth)-1), group=YearRange, colour=YearRange)) +
    geom_line() +
    scale_x_continuous(breaks=c(5,25,50,75,95)) +
    ggtitle(paste("Composition-adjusted changes in weekly real wages by percentile",
                  "1982-2010", sep="\n")) +
#    scale_y_log10(labels=percent, breaks=c()) +
    scale_y_continuous(labels=percent) +
    xlab("Weekly earnings percentile") +
    ylab("Relative earnings change") +
    theme(legend.position=leg.pos)
print(p)
footnote()
dev.off()
