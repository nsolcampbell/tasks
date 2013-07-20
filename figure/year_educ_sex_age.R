library(ggplot2)
library(scales)
library(plyr)
library(isotone) # for weighted median
load('data/curf/combined.rda')

years <- combined$Year %in% c("1982","1995","2008", "2010")
fy <- combined$FullYear == 'Full Year'
ft <- combined$CFullTime == 'Full-time'
ws <- combined$PFYSource == 'Wages and Salaries'

pdf("figure/rinc_density_years_educ_sex_by_age.pdf", paper="a4r", height=8, width=12)
for (age in c("15-34", "35-54", "55-74")) {
    age_subset <- combined$Age4 == age
    
    plot_data <- combined[which(years & fy & ft & age_subset),]
    
    medians <- ddply(plot_data,~EducA + Sex + Year,summarise,
                     mean=mean(PFYRInc),sd=sd(PFYRInc),
                     median=weighted.median(PFYRInc, Weight))
    
    plot_data$SexYearEducWeight <- NA
    for (s in levels(plot_data$Sex)) {
        sex <- plot_data$Sex == s
        for (y in levels(plot_data$Year)) {
            year <- plot_data$Year == y
            for (e in levels(plot_data$EducA)) {
                educ <- plot_data$EducA == e
                # so subs gives indexes for this cell
                subs <- which(sex & year & educ)
                
                plot_data$SexYearEducWeight[subs] <- 
                    plot_data$Weight[subs] / sum(plot_data$Weight[subs])
            }
        }
    }
    
    # NB: we'll see warnings below, which we'll suppress, because we 
    # are trimming the edges of the distribution, and so the area
    # under the curve is no longer 1.
    p <- ggplot(plot_data,aes(x=PFYRInc+1,color=Year,fill=Year,weight=SexYearEducWeight)) + 
        geom_density(bw="SJ",alpha=0.2) + 
        geom_vline(aes(xintercept=median,group=Year,color=Year),
                   medians, linetype='solid', alpha=0.5) +
        scale_x_log10(labels = comma, limits=c(20e3,200e3), 
                      breaks=c(25e3,50e3,100e3,200e3)) +
        facet_grid(Sex ~ EducA) +
        ggtitle(paste("Annual real earned income distribution by education and sex, Australia, Age",age)) +
        xlab("Previous Financial Year Real Income (log scale, 2013 dollars)") +
        theme_bw(15) +
        theme(legend.position="top") 
    
    ggplot(plot_data, aes(x=Year, y=PFYRInc)) + geom_quantile(PFYRInc ~ Year + Sex + EducA)
    
    # Full-year, full-time.
    # Weighted density by coarse education level. Gaussian Kernel. 
    print(p)
}
dev.off()
