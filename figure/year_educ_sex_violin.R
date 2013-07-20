library(ggplot2)
library(scales)
library(plyr)
library(isotone) # for weighted median
load('data/curf/combined.rda')

fy <- combined$FullYear == 'Full Year'
ft <- combined$CFullTime == 'Full-time'
ws <- combined$PFYSource == 'Wages and Salaries'
wk_age <- combined$PExp %in% c("15-34","35-54","55-74")

plot_data <- combined[which(years & fy & ft),]

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

subs <- plot_data[,c("Sex","Year","EducA","Weight","PFYRInc")] #,"SexYearEducWeight")]
subs$Year <- factor(subs$Year, levels=c(1982,1995,2008), ordered=T)

subs$PFYRInc <- subs$PFYRInc + 1.0

# NB: we'll see warnings below, which we'll suppress, because we 
# are trimming the edges of the distribution, and so the area
# under the curve is no longer 1.
p <- ggplot(subs,aes(Year,PFYRInc,color=Sex,fill=Sex)) + 
    geom_violin(alpha=0.2) + 
    facet_grid(Sex ~ EducA) +
    scale_y_log10(labels=comma) +
    ggtitle("Annual real earned income distribution by education and sex (Australia)") +
    xlab("Previous Financial Year Real Income (log scale, 2013 dollars)") +
    theme_bw(15) +
    theme(legend.position="top") 
# Full-year, full-time.
# Weighted density by coarse education level. Gaussian Kernel. 
if (interactive()) {
    suppressWarnings(print(p))
} else {
    pdf("figure/year_educ_sex_violin.pdf", paper="a4r", width=12, height=8)
    suppressWarnings(print(p))
    dev.off()
}