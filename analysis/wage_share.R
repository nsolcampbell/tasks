rm(list=ls())

require(plyr)
library('doBy')
library('reshape2')
library(ggplot2)
source('lib/plot_theme.R')
library('abind')

#####################
# first: subset the wage data
#####################
load("data/curf/ftwswaw.rda") # full-time, wage/salary, working age

# drop inconsistently coded industries
mysubset <- subset(ftwswaw, !CIndA %in% c("Unknown", "Other Services"))
# mysubset$Group <- recodeVar(as.character(mysubset$EducB),
#                              c("No Post-Secondary","Associate/Trade","Bachelor or Higher"),
#                              c("L","M","H"))
mysubset <- subset(mysubset, COccupA != "Other")
mysubset$Group <- recodeVar(as.character(mysubset$COccupA),
                           c("Nonroutine Manual","Routine","Nonroutine Nonmanual"),
                           c("L","M","H"))

mysubset <- subset(mysubset, Year %in% c("1996", "2003", "2010"))
#mysubset <- subset(mysubset, !Year %in% c("1982", "1986", "1995", "1996", "1997", "1998", "2003", "2008"))
#mysubset <- subset(mysubset, !Year %in% c("1982", "1986", "1995", "1996", "1997", "1998")) #, "2003", "2008"))
#mysubset <- subset(mysubset, !Year %in% c("1982", "1986")) #, "1995", "1996", "1997", "1998", "2003", "2008"))

# this list is useful for trimming national accounts data
year_list <- as.numeric(as.character(with(mysubset, unique(Year))))
Tobs <- length(year_list)
keep_years_from_90 <- 1990:2012 %in% year_list

# wage bill: Year/Group (scale by person weight)
ye_wb <- ddply(mysubset, .(Year, Group, CIndA), summarise, 
               mean_wage=weighted.mean(CInc, Weight),
               wage_bill=sum(Weight * CInc))
# wage bill: Year
y_wb <- ddply(mysubset, .(Year, CIndA), summarise,
              year_wage_bill=sum(Weight * CInc))
# industry weight : Year
total_weight <- sum(mysubset$Weight)

wb <- merge(ye_wb, y_wb, by=c("Year", "CIndA"))
wb$share <- with(wb, wage_bill / year_wage_bill)

# short format as array
share_arr <- acast(wb, Year ~ CIndA ~ Group, value.var="share")
wage_arr  <- acast(wb, Year ~ CIndA ~ Group, value.var="mean_wage")

HL <- wage_arr[,,"H"] / wage_arr[,,"L"]
ML <- wage_arr[,,"M"] / wage_arr[,,"L"]

#####################
# second: load, process and subset the national accounts
#####################
combined <- read.csv("data/5204.0/combined.csv")
rownames(combined) <- gsub(" $","", combined$Industry, perl=T)
combined <- combined[,-1]

# these rows get merged into one 
combrows <- c("Rental, hiring and real estate services",
              "Professional, scientific and technical services",
              "Administrative and support services")
combrows_idxs <- which(rownames(combined) %in% combrows)
combined["Property and Business Services",] <-
  colSums(combined[combrows_idxs,])
combined <- combined[-combrows_idxs,]
# these guys get removed because inconsistently coded
droprows <- c("Other services")
combined <- combined[-which(rownames(combined) %in% droprows),]

mysubset <- function(regex) {
  s <- combined[,grep(regex, colnames(combined))]
  s <- t(s[,(ncol(s)-22):ncol(s)])
  rownames(s) <- 1990:2012
  colnames(s) <- rownames(combined)
  # only keep the years we have data for
  return(s[keep_years_from_90,])
}

valadd <- mysubset("^GVA")
capital <- mysubset("^CS")
peripherals <- mysubset("^ICTPER")
equip <- mysubset("^ICTEQUIP")
software <- mysubset("^ICTSOFT")

l_nonict <- log((capital - peripherals - equip - software) / valadd)
l_ict    <- log((peripherals + equip + software) / valadd)
l_soft   <- log(software / valadd)
l_equip  <- log(equip / valadd)
l_periph <- log(peripherals / valadd)
l_valadd <- log(valadd)

X <- abind(H_share=share_arr[,,"H"],
           M_share=share_arr[,,"M"],
           L_share=share_arr[,,"L"],
           l_HL=log(HL),
           l_ML=log(ML),
           l_nonict=l_nonict, 
           l_ict=l_ict, 
           l_soft=l_soft, 
           l_equip=l_equip, 
           l_periph=l_periph, 
           l_valadd=l_valadd,
           along=3)

# calc number of years in periods
period_lengths <- year_list[2:Tobs] - year_list[1:(Tobs-1)]

# take difference of all variables
dX <- (X[2:Tobs,,] - X[1:(Tobs-1),,]) / period_lengths

# convert to long format for regression
regdata <- adply(dX, .margins=c(1,2))
colnames(regdata)[1:2] <- c("year","ind")

regdata <- subset(regdata, ind != 'Accommodation and Food Services') # badly coded

qplot(l_equip, M_share, data=regdata) + geom_smooth(method="lm")

summary(lm(M_share ~ l_nonict + l_soft + l_equip + l_valadd, data=regdata))
summary(lm(M_share ~ l_nonict + l_ict + l_valadd, data=regdata))
summary(lm(L_share ~ l_nonict + l_ict + l_valadd, data=regdata))
summary(lm(H_share ~ l_nonict + l_ict + l_valadd, data=regdata))

rd_long <- melt(d_shares, measure=c("L", "M", "H"),variable.name="group",value.name="dshare")

rd_long$group <- with(rd_long, recodeVar(as.character(group),
                                         c("L","M","H"),
                                         c("Low Skill", "Medium Skill", "High Skill")))
rd_long$group <- with(rd_long, factor(group, ordered=T,
                                      levels=c("Low Skill", "Medium Skill", "High Skill")))
rd_long$Year <- recodeVar(rd_long$Year, c(2003, 2010), c("1996-2003", "2004-2010"))
rd_long$Year <- as.factor(rd_long$Year)

summary(lm(dshare ~ dl_nonict + dl_ict + dl_valadd, data=rd_long))

# save or print chart depending on whether running interactively or in a script
save_or_print <- function(plot, filename) {
    if (interactive()) {
        print(plot)
    } else {
        pdf(filename, width=12, height=8)
        print(plot)
        dev.off()
    }
}

p <- qplot(dl_equip, dshare, color=group, fill=group, data=rd_long) + 
        geom_hline(y=0) +
        geom_smooth(method="loess", alpha=0.25) + facet_grid(.~group) + 
        ggtitle("Change in Wage Share and ICT Equipment Investment 1996-2010") +
        xlab("Change in log equipment capital-value added ratio") +
        ylab("Change in wage share") +
        theme(legend.position="none")

save_or_print(p, 'figure/wage_share_equipment_skill.pdf')
save_or_print(p + facet_grid(Year~group), 'figure/wage_share_equipment_skill_split.pdf')

p <- qplot(dl_soft, dshare, color=group, fill=group, data=rd_long) +
        geom_hline(y=0) +
        geom_smooth(method="loess", alpha=0.25) + facet_grid(.~group) +
        ggtitle("Change in Wage Share and ICT Software Investment 1996-2010") +
        xlab("Change in log software capital-value added ratio") +
        ylab("Change in wage share") +
        theme(legend.position="none")

save_or_print(p, 'figure/wage_share_software_skill.pdf')
save_or_print(p + facet_grid(Year~group), 'figure/wage_share_software_skill_split.pdf')

p <- qplot(dl_periph, dshare, color=group, fill=group, data=rd_long) +
        geom_hline(y=0) +
        geom_smooth(method="loess", alpha=0.25) + facet_grid(.~group) +
        ggtitle("Change in Wage Share and ICT Computers and Peripherals Investment 1996-2010") +
        xlab("Change in log computers and peripherals capital-value added ratio") +
        ylab("Change in wage share") +
        theme(legend.position="none")

save_or_print(p, 'figure/wage_share_peripherals_skill.pdf')
save_or_print(p + facet_grid(Year~group), 'figure/wage_share_peripherals_skill_split.pdf')

require(stargazer)
gdata <- subset(rd_long, group == "High Skill")
gdata$share.h <- gdata$dshare
full.h   <- lm(share.h ~ dl_equip + dl_soft + dl_nonict + dl_valadd, data=gdata)
equip.h  <- lm(share.h ~ dl_equip + dl_valadd, data=gdata)

gdata <- subset(rd_long, group == "Medium Skill")
gdata$share.m <- gdata$dshare
full.m   <- lm(share.m ~ dl_equip + dl_soft + dl_nonict + dl_valadd, data=gdata)
equip.m  <- lm(share.m ~ dl_equip + dl_valadd, data=gdata)

gdata <- subset(rd_long, group == "Low Skill")
gdata$share.l <- gdata$dshare
full.l   <- lm(share.l ~ dl_equip + dl_soft + dl_nonict + dl_valadd, data=gdata)
equip.l <- lm(share.l ~ dl_equip + dl_valadd, data=gdata)

stargazer(full.h, equip.h,
          full.m, equip.m,
          full.l, equip.l,
          covariate.labels=c("$\\Delta$log {\\em equipment}",
                            "$\\Delta$log {\\em software}",
                            "$\\Delta$log {\\em other capital}",
                            "$\\Delta$log {\\em value added}",
                            "Constant"),
          dep.var.labels=c("$\\Delta SHARE^H$", "$\\Delta SHARE^M$",
                           "$\\Delta SHARE^L$"),
          title="Wage Share Change Estimation Results: 1996-2010",
          label="tbl:reg",
          out='doc/conference_table_2.tex', 
          float.env="sidewaystable"
          )
