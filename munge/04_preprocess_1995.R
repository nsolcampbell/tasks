library(foreign)
library(doBy)
source('lib/curfmunge.R')

curf <- data.frame(read.spss('data/curf/1995/IDS94PSN.SAV'))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

curf$ID <- with(curf, paste(ABSHID, as.numeric(FAMNO), 
                                 as.numeric(ABSIID), as.numeric(ABSPID), 
                                 sep="."))
subs <- curf[,c("ID",
            "SEXP", 
            "AGECP", 
            "LFSTFCP", # Labor force status, main job
            "LFST2CP", # Labor force status, second job
            "HRSWKMCP",# Usual HPW, main job
            "HRSWK2CP",# Usual HPW, second job
            "HRSWKACP",# Usual HPW, both jobs
            "LFSTBCP", # LF status, both jobs
            "OCCCP",   # Occupation, main job
            "INDCP",   # Industry, main job
            "HQUALCP", # Highest post-secondary education
            "STUDSTCP",# Study status
            "YRLSCHCP",# Year left school
            "MTHSCHCP",# Month left school
            "IWSUCP",  # Total current weekly employee income from wages and salaries from main and second jobs
            "IOBTCP",  # Current weekly income from own unincorporated business
            "IOBTCPF", # Current weekly income from own unincorporated business flag
            "IEARNCP", # Total current weekly earned income
            "IWSTPP",  # Total previous financial year income from wages and salaries
            "IEARNPP", # Total previous financial year earned income
            "PSRCCP",  # Principal source of current weekly income
            "PSRCPP",  # Principal source of previous financial year income
            paste("EMPD6M",1:7,sep=""), # LF status in month minus n
            paste("FTPTD7M",1:7,sep=""), # PT/FT status in month minus n
            "WTPSN",   # Person weight
            paste("REPWT",1:30,sep="") # replication weights
)]

subs$Weight <- subs$WTPSN / 10000.0

subs$CPrincipalSource <- recodePrincipalSource(subs$PSRCCP)
subs$PFYPrincipalSource <- recodePrincipalSource(subs$PSRCPP)

subs$EducA <- recodeEducA(subs$HQUALCP)
subs$EducB <- recodeEducB(subs$HQUALCP)

subs$Sex <- recodeVar(as.character(subs$SEXP), src=list("Males","Females"), tgt=list("Male","Female"))

subs$Age4 <- recodeAge4(subs$AGECP)

subs$CFullTime <- recodeFullTime(subs$LFSTBCP)

subs$Year <- 1995

# For "full year" status, we need that the respondent be employed for
# 48 weeks out of the last 52. But since only 7 months are available, we'll
# insist that this number is 6 months out of the last 7.
subs$FullYear <- with(subs, (
                      (EMPD6M1 == "Employed") +
                      (EMPD6M2 == "Employed") +
                      (EMPD6M3 == "Employed") +
                      (EMPD6M4 == "Employed") +
                      (EMPD6M5 == "Employed") +
                      (EMPD6M6 == "Employed") +
                      (EMPD6M7 == "Employed")) >= 6)
subs$FullYear <- ifelse(subs$FullYear, "Full Year", "Other")

# Want more than half of the previous year to be "Full-time"
# Unfortunately we only have the last 7 months, so use those.
# We take the most popular response out of PT/FT/NA.
cols <- paste("FTPTD7M",1:7,sep="")
subs$PFYFullTime <- apply(subs[,cols],1,
                        function(months) {names(sort(table(t(months)),decreasing=T))[1]})
subs$PFYFullTime <- recodeVar(as.character(subs$PFYFullTime),
                              c("Not applicable", "Full-time", "Part-time"),
                              c("Other","Full-time","Part-time"))

# ahem: TODO
subs$PFYIndA <- NA
subs$PFYIndB <- NA
subs$PFYOccupA <- NA
subs$PFYOccupB <- NA

subset_1995 <- subs[,c("ID", "Year", "Sex", "Age4",
                      "IEARNCP","IEARNPP",
                      "INDCP", "INDCP", "PFYIndA", "PFYIndB",
                      "OCCCP", "OCCCP", "PFYOccupA", "PFYOccupB",
                      "EducA", "EducB",
                      "CFullTime", "PFYFullTime", "FullYear",
                      "CPrincipalSource", "PFYPrincipalSource",
                      "Weight"
                      )]
colnames(subset_1995) <- standard_column_list

save(subset_1995, file='data/curf/1995.rda')
