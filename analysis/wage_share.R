rm(list=ls())

require(plyr)
library('doBy')
library('reshape2')
library(ggplot2)
source('lib/plot_theme.R')

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
  s <- s[,(ncol(s)-22):ncol(s)]
  rownames(s) <- combined$Industry
  colnames(s) <- paste("Y",1990:2012, sep="")
  return(s)
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

load("data/curf/ftwswaw.rda") # full-time, wage/salary, working age

# drop inconsistently coded industries
mysubset <- subset(ftwswaw, !CIndA %in% c("Unknown", "Other Services"))
# mysubset$Group <- recodeVar(as.character(mysubset$EducB),
#                             c("No Post-Secondary","Associate/Trade","Bachelor or Higher"),
#                             c("L","M","H"))
mysubset <- subset(mysubset, COccupA != "Other")
mysubset$Group <- recodeVar(as.character(mysubset$COccupA),
                            c("Nonroutine Manual","Routine","Nonroutine Nonmanual"),
                            c("L","M","H"))

mysubset <- subset(mysubset, Year %in% c("1996", "2003", "2010"))

# wage bill: Year/Group (scale by person weight)
ye_wb <- ddply(mysubset, .(Year, Group, CIndA), summarise, 
               mean_wage=weighted.mean(CInc, Weight),
               wage_bill=sum(Weight * CInc))
# wage bill: Year
y_wb <- ddply(mysubset, .(Year, CIndA), summarise,
              year_wage_bill=sum(Weight * CInc))

wb <- merge(ye_wb, y_wb, by=c("Year", "CIndA"))
wb$share <- with(wb, wage_bill / year_wage_bill)

# short format as array
share_arr <- acast(wb, Year ~ CIndA ~ Group, value.var="share")
wage_arr  <- acast(wb, Year ~ CIndA ~ Group, value.var="mean_wage")

HL <- wage_arr[,,"H"] / wage_arr[,,"L"]
ML <- wage_arr[,,"M"] / wage_arr[,,"L"]

d_share9603 <- data.frame(share_arr["2003",,] - share_arr["1996",,])
d_share9603$Year <- 2003
# assemble regression data frame
regdata1 <- data.frame(cbind(
  d_share9603,
  ind=dimnames(share_arr)[[2]],
  dlog_HL=log(HL["2003",]) - log(HL["1996",]), # difference in log H/L ratio
  dlog_ML=log(ML["2003",]) - log(ML["1996",]), # difference in log M/L ratio
  d_HL=HL["2003",] - HL["1996",], # difference in H/L ratio
  d_ML=ML["2003",] - ML["1996",], # difference in M/L ratio
  dl_nonict=with(l_nonict, Y2003-Y1996), # dlog of non-ICT capital
  dl_ict   =with(l_ict,    Y2003-Y1996), # dlog of ICT capital
  dl_periph=with(l_periph, Y2003-Y1996), # dlog of ICT hardware capital
  dl_soft  =with(l_soft,   Y2003-Y1996), # dlog of ICT software capital
  dl_equip =with(l_equip,  Y2003-Y1996), # dlog of ICT equipment capital
  dl_valadd=with(l_valadd, Y2003-Y1996)  # dlog of value added
))

d_share0310 <- data.frame(share_arr["2010",,] - share_arr["2003",,])
d_share0310$Year <- 2010
# assemble regression data frame
regdata2 <- data.frame(cbind(
  d_share0310,
  ind=dimnames(share_arr)[[2]],
  dlog_HL=log(HL["2010",]) - log(HL["2003",]), # difference in log H/L ratio
  dlog_ML=log(ML["2010",]) - log(ML["2003",]), # difference in log M/L ratio
  d_HL=HL["2010",] - HL["2003",], # difference in H/L ratio
  d_ML=ML["2010",] - ML["2003",], # difference in M/L ratio
  dl_nonict=with(l_nonict, Y2010-Y2003), # dlog of non-ICT capital
  dl_ict   =with(l_ict,    Y2010-Y2003), # dlog of ICT capital
  dl_periph=with(l_periph, Y2010-Y2003), # dlog of ICT hardware capital
  dl_soft  =with(l_soft,   Y2010-Y2003), # dlog of ICT software capital
  dl_equip =with(l_equip,  Y2010-Y2003), # dlog of ICT equipment capital
  dl_valadd=with(l_valadd, Y2010-Y2003)  # dlog of value added
))

d_shares <- rbind(regdata1, regdata2)
colnames(d_shares) <- colnames(regdata1)

rd_long <- melt(d_shares, measure=c("L", "M", "H"),variable.name="group",value.name="dshare")

rd_long <- subset(rd_long, ind != 'Accommodation and Food Services') # badly coded

rd_long$group <- with(rd_long, recodeVar(as.character(group),
                                         c("L","M","H"),
                                         c("Low Skill", "Medium Skill", "High Skill")))
rd_long$group <- with(rd_long, factor(group, ordered=T,
                                      levels=c("Low Skill", "Medium Skill", "High Skill")))

summary(lm(dshare ~ dl_nonict + dl_ict + dl_valadd, data=rd_long))

qplot(dl_equip, dshare, color=group, fill=group, data=rd_long) + 
    geom_smooth(method="lm", alpha=0.25) + facet_grid(.~group) + 
    ggtitle("Change in Wage Share and ICT Equipment Investment 1996-2010") +
    xlab("Change in log equipment capital-value added ratio") +
    ylab("Change in wage share") +
    theme(legend.position="none")

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
