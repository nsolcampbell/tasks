rm(list=ls())
library(ggplot2)
library(gridExtra)

source('lib/centered_cpi.R')
source('lib/plot_theme.R')

ag1 <- read.csv('data/enc/aggregate_chart_i.csv',
                header=F, nrow=500,
                col.names=c("w_81_1", "d_81_1", "w_81_2", "d_81_2", "w_10_1", "d_10_1", "w_10_2", "d_10_2"))

deflate_81 <- log(centered_cpi(2010) / centered_cpi(1981))

p_i_81 <- ggplot(ag1, aes(y=w_81_1,x=d_81_1 + deflate_81)) + 
    geom_area(alpha=0.1, color="blue", fill="blue") +
    geom_area(alpha=0.1, color="orange", fill="orange", aes(y=w_10_1,x=d_10_1)) + 
    ggtitle("1981/82 density, 2009/10 density, reweighted to 1981/82")

p_i_10 <- ggplot(ag1, aes(y=w_81_2,x=d_81_2)) + geom_area(alpha=0.1, color="blue", fill="blue") +
    geom_area(alpha=0.1, color="orange", fill="orange", aes(y=w_10_2,x=d_10_2-deflate_81)) + 
    ggtitle("1981/82 and 2009/10 density, reweighted to 2009/10")

ag2 <- read.csv('data/enc/aggregate_chart_ii.csv',
                header=F, nrow=500,
                col.names=c("w_01_1", "d_01_1", "w_01_2", "d_01_2", "w_10_1", "d_10_1", "w_10_2", "d_10_2"))

deflate_10 <- log(centered_cpi(2010) / centered_cpi(2001))

p_ii_01 <- ggplot(ag2, aes(y=w_01_1,x=d_01_1)) + geom_area(alpha=0.1, color="blue", fill="blue") +
    geom_area(alpha=0.1, color="orange", fill="orange", aes(y=w_10_1,x=d_10_1 - deflate_10)) + 
    ggtitle("2000/01 density, 2009/10 density, reweighted to 2000/01")

p_ii_10 <- ggplot(ag2, aes(y=w_01_2,x=d_01_2 + deflate_10)) + geom_area(alpha=0.1, color="blue", fill="blue") +
    geom_area(alpha=0.1, color="orange", fill="orange", aes(y=w_10_2,x=d_10_2)) + 
    ggtitle("2000/01 density, 2009/10 density, reweighted to 2009/10")

all_four <- grid.arrange(p_i_81, p_i_10, p_ii_01, p_ii_10)

# now make one, neat 1981-2010 plot.
aggrsub <- with(ag1, rbind(cbind(d=w_81_1,w=exp(d_81_1 + deflate_81),year=1981),
                           cbind(d=w_10_1,w=exp(d_10_1),year=2010)))
aggrsub.df <- data.frame(aggrsub)
aggrsub.df$year <- factor(aggrsub.df$year)

pdf('figure/density_as_81.pdf', height=6, width=8)
ggplot(aggrsub.df, aes(y=d,x=w,fill=year,color=year)) + 
    geom_area(alpha=0.1) +
    scale_x_log10(limits=c(200,8000), breaks=c(250,500,1000,2000,4000,8000)) +
    ggtitle("1981/82 & 2009/10 wage densities, weighted as 1981/82") +
    xlab("Weekly real wage income ($2010)") +
    ylab("Density")
dev.off()
