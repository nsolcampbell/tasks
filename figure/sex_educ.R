library(ggplot2)
library(scales)
library(plyr)
library(isotone) # for weighted median
load('data/curf/combined.rda')

years <- combined$Year %in% c("1982","1995","2008")
fy <- combined$FullYear == 'Full Year'
ft <- combined$CFullTime == 'Full-time'
ws <- combined$PFYSource == 'Wages and Salaries'
wk_age <- combined$PExp %in% c("0-24","25-39")

plot_data <- combined[which(years & fy & ft & wk_age),]

vline.data <- ddply(plot_data,~EducA + Sex + Year,summarise,
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

subs <- plot_data[,c("Sex","Year","EducA","Weight","PFYRInc","SexYearEducWeight")]
subs$Year <- factor(subs$Year, levels=c(1982,1995,2008), ordered=T)

# NB: we'll see warnings below, which we'll suppress, because we 
# are trimming the edges of the distribution, and so the area
# under the curve is no longer 1.
p <- ggplot(subs,aes(x=PFYRInc+1,color=Sex,fill=Sex,weight=SexYearEducWeight)) + 
    geom_density(bw="SJ",alpha=0.2) + 
    geom_vline(aes(xintercept=median,group=Sex,color=Sex),
               vline.data, linetype='solid', alpha=0.5) +
    scale_x_log10(labels = comma, limits=c(20e3,200e3), 
                  breaks=c(25e3,50e3,100e3,200e3)) +
    facet_grid(Year ~ EducA) +
    ggtitle("Annual real earned income distribution by education and sex (Australia)") +
    xlab("Previous Financial Year Real Income (log scale, 2013 dollars)") +
    theme_bw(15) +
    theme(legend.position="top") 
# Full-year, full-time.
# Weighted density by coarse education level. Gaussian Kernel. 
if (interactive()) {
    suppressWarnings(print(p))
} else {
    pdf("figure/rinc_density_sex_educ_year.pdf", paper="a4r", width=12, height=8)
    suppressWarnings(print(p))
    dev.off()
}