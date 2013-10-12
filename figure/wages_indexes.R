rm(list=ls())
library(ggplot2)
library(plyr)
library(reshape2)
source("lib/plot_theme.R")

# mean wages by occupation in 2010, grouping ii
wages.m <- t(as.matrix(read.csv("data/means/2010_ii.csv", header=F)))
wages <- data.frame(mean=wages.m, COMBINEDII=1:29)

load("data/tasks.combinedii.rda")

wages.df <- join(wages, tasks.combinedii, by="COMBINEDII")
wages.df$weight = with(wages.df, Population / sum(wages.df$Population))
#wages.df$mean <- with(wages.df, mean/1000.0)

# drop useless columns and melt into long format
keep.cols <- c("COMBINEDII", "mean",
               "Information.Content", "Automation.Routinization", 
               "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making", 
               "weight")
wages.long <- melt(wages.df[,keep.cols], 
                   id.vars=c('COMBINEDII', 'mean', 'weight'),
                   value.name='value',
                   variable.name='index')

pdf("figure/wages_indexes.pdf", height=8, width=12)
ggplot(wages.long, aes(x=mean, y=value, group=index,weight=weight)) + 
    geom_point(shape='o',aes(size=1000*weight)) +
    geom_smooth(method='loess', fill=NA) +
    facet_wrap(~index) +
    scale_x_log10(breaks=c(1,2,3)*1000) +
    geom_hline(y=0, alpha=0.3) +
    xlab("Occupational group weekly mean wage (log scale)") +
    ylab("Index value") +
    ggtitle("Task Indexes and Mean Wages, 2011/12") +
    theme(legend.position='none')
dev.off()
