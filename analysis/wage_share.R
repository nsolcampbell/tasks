require(plyr)

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

mysubset <- subset(mysubset, Year %in% c("1995", "2010"))

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

# difference in wage share
d_share <- share_arr["2010",,] - share_arr["1995",,]
colnames(d_share) <- c("dshare_L", "dshare_M", "dshare_H")

# assemble regression data frame
regdata <- data.frame(cbind(
    d_share=d_share, # wage bill share
    dlog_HL=log(HL["2010",]) - log(HL["1995",]), # difference in log H/L ratio
    dlog_ML=log(ML["2010",]) - log(ML["1995",]), # difference in log M/L ratio
    d_HL=HL["2010",] - HL["1995",], # difference in H/L ratio
    d_ML=ML["2010",] - ML["1995",], # difference in M/L ratio
    dl_nonict=with(l_nonict, Y2010-Y1995), # dlog of non-ICT capital
    dl_ict   =with(l_ict,    Y2010-Y1995), # dlog of ICT capital
    dl_periph=with(l_periph, Y2010-Y1995), # dlog of ICT hardware capital
    dl_soft  =with(l_soft,   Y2010-Y1995), # dlog of ICT software capital
    dl_equip =with(l_equip,    Y2010-Y1995), # dlog of ICT equipment capital
    dl_valadd=with(l_valadd, Y2010-Y1995)  # dlog of value added
))
regdata$ind=as.factor(rownames(regdata))

rd_long <- melt(regdata, measure=c("dshare_L", "dshare_M", "dshare_H"),variable.name="group",value.name="dshare")
rd_long$group <- as.factor(recodeVar(as.character(rd_long$group), c("dshare_L", "dshare_M", "dshare_H"), c("L","M","H")))
rd_long$ind <- factor(rd_long$ind)

summary(lm(dshare_H ~ dlog_HL + dlog_ML + dl_nonict + dl_ict + dl_valadd, data=regdata))
summary(lm(dshare_M ~ dlog_HL + dlog_ML + dl_nonict + dl_ict + dl_valadd, data=regdata))
summary(lm(dshare_L ~ dlog_HL + dlog_ML + dl_nonict + dl_ict + dl_valadd, data=regdata))

summary(lm(dshare_H ~ dlog_HL + dlog_ML + dl_nonict + dl_periph + dl_soft + dl_valadd, data=regdata))
summary(lm(dshare_M ~ dlog_HL + dlog_ML + dl_nonict + dl_periph + dl_soft + dl_valadd, data=regdata))
summary(lm(dshare_L ~ dlog_HL + dlog_ML + dl_nonict + dl_periph + dl_soft + dl_valadd, data=regdata))

summary(lm(dshare_H ~ dl_nonict + dl_ict + dl_valadd, data=regdata))
summary(lm(dshare_M ~ dl_nonict + dl_ict + dl_valadd, data=regdata))
summary(lm(dshare_L ~ dl_nonict + dl_ict + dl_valadd, data=regdata))

summary(lm(dshare_H ~ dl_nonict + dl_ict, data=regdata))
summary(lm(dshare_M ~ dl_nonict + dl_ict, data=regdata))
summary(lm(dshare_L ~ dl_nonict + dl_ict, data=regdata))

# Does ICT investment even affect the differential? Nope.
summary(lm(d_HL ~ dl_nonict + dl_ict + dl_valadd, data=regdata))
summary(lm(d_ML ~ dl_nonict + dl_ict + dl_valadd, data=regdata))

