library(ggplot2)
library(scales)
library(plyr)
library(isotone) # for weighted median
save(fyftws, file='data/curf/fyftws.rda')

fyftws <- subset(fyftws, Age4 == '15-34')

vline.data <- ddply(fyftws,~EducA + Sex + Year,summarise,
                    mean=mean(PFYRInc),sd=sd(PFYRInc),
                    median=weighted.median(PFYRInc, Weight))

fyftws$SexYearEducWeight <- NA
for (s in levels(fyftws$Sex)) {
    sex <- fyftws$Sex == s
    for (y in levels(plot_data$Year)) {
        year <- fyftws$Year == y
        tot_educ = sum(fyftws$Weight[which(sex & year)])
        for (e in levels(fyftws$EducA)) {
            educ <- fyftws$EducA == e
            # so subs gives indexes for this cell
            subs <- which(sex & year & educ)
            
            fyftws$SexYearEducWeight[subs] <- 
                fyftws$Weight[subs] / tot_educ
        }
    }
}

subs <- fyftws[,c("Sex","Year","EducA","Weight","PFYRInc","SexYearEducWeight")]
subs$Year <- factor(subs$Year, levels=c(1982,1995,2008), ordered=T)

# NB: we'll see warnings below, which we'll suppress, because we 
# are trimming the edges of the distribution, and so the area
# under the curve is no longer 1.
p <- ggplot(fyftws,aes(x=PFYRInc+1,color=Sex,fill=Sex,weight=SexYearEducWeight)) + 
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