library(foreign)
library(plyr)
library(doBy)
source('lib/curfmunge.R')

# Only SPSS and SAS files available; since foreign only works with 
# SPSS, we'll use that file.
# suppressWarnings is applied to get rid of warnings about duplicate levels
suppressWarnings(curf <- data.frame(read.spss("data/curf/1982/IDS82.sav")))

subs <- curfsubset(curf,
                    PPP0001="IDENT_PSN",
                    PPP0003="FAMNO_PSN",
                    PPP0004="IUNO_PSN",
                    PPP0005="PERSON_NUMBER",
                    PPP0006="Sex",
                    PPP0007="Age",
                    PPP0014="AgeLeftSchool",
                    PPP0026="HighestQual",
                    PPP0027="QualField",
                    PPP0034="HoursWorkedAllJobs",
                    PPP0037="IndEmployer", 
                    PPP0038="SectorEmployer", 
                    PPP0039="CurrentOccup", 
                    PPP0040="ManualOccup", 
                    PPP0041="FulltimeParttime",
                    PPP0067="WeeksWorked8182",
                    PPP0068="WeeksParttime8182",
                    PPP0069="Occup8182",
                    PPP0070="Industry8182", 
                    PPP0096="IncomeWages", 
                    PPP0119="IncomeWages8182",
                    PPP0148="PrincipalSource",
                    PPP0149="PrincipalSource8182"
                    )
subs$IncomeWages[subs$IncomeWages==9999] <- NA
subs$IncomeWages8182[subs$IncomeWages8182==99999] <- NA

# convert identifiers to character, from levels
for (col in c("IDENT_PSN","FAMNO_PSN","IUNO_PSN")) {
        subs[,col] <- as.character(subs[,col])
}
# only needed for merge, so OK to un-level
subs$PERSON_NUMBER <- as.numeric(subs$PERSON_NUMBER) 

# The ABS didn't include the person weight in the SAS/SPSS files(!),
# so we have to extract it from the magnetic tape dump file. This CSV 
# was created by the script get_weights.py in the munge directory
weights <- read.csv("data/curf/1982/weights.csv", stringsAsFactors=F)

subs <- join(x=subs, y=weights, 
             by=c("IDENT_PSN", "FAMNO_PSN", "IUNO_PSN", "PERSON_NUMBER"))

# EducA
subs$EducA <- recodeVar(as.character(subs$HighestQual), 
                        list(c("Adult education/hobby course", "Other","Still at school",
                               "Secondary school course", "Never went to school", 
                               "No qualifications since school"),
                             c("Trade qualification", "Certificate/diploma"),
                             c("Bachelor degree/post.grad.diploma"),
                             c("Higher qualification")),
                        as.list(EducA_levels))

# EducB
subs$EducB <- recodeVar(as.character(subs$HighestQual), 
                        list(c("Adult education/hobby course", "Other","Still at school",
                               "Secondary school course", "Never went to school", 
                               "No qualifications since school"),
                             c("Trade qualification", "Certificate/diploma"),
                             c("Higher qualification","Bachelor degree/post.grad.diploma")),
                        as.list(EducB_levels))

subs$Age4 <- recodeVar(as.character(subs$Age), 
                         list(c("15", "16", "17", "18", "19", "20 - 24", "25 - 29", "30 - 34"), 
                              c("35 - 39", "40 - 44", "45 - 49", "50 - 54"), 
                              c("55 - 59", "60 - 64", "65 - 69", "70 - 74"), 
                              c("75 - 79", "80 - 84", "85 +"),
                              c("Not Applicable")), 
                         age_level_list)

# note this mapping makes sense because we're only interested 
# in currently employed workers
subs$CFullTime <- recodeVar(as.character(subs$FulltimeParttime),
                             list(c("Employed fulltime"), 
                                  c("Employed parttime"), 
                                  c("Unemployed-looking for fulltime work", 
                                    "Unemployed-looking for parttime work", 
                                    "Not in labour force")),
                             list("Full-time","Part-time","Other"))
subs$CFullTime <- factor(subs$CFullTime, ordered=T, 
                        levels=c("Full-time","Part-time","Other"))

# Have to have worked more than half the PFY, more than half full time
subs$wks_pt <- as.numeric(subs$WeeksParttime8182) - 1
subs$wks_wkd <- as.numeric(subs$WeeksWorked8182) - 1
subs$wkd_ft <- (subs$wks_wkd > subs$wks_pt * 2) & (subs$wks_wkd > 26)
subs$PFYFullTime <- ifelse(subs$wkd_ft, 'Full-time', 'Other')

fy <- subs$WeeksWorked8182 %in% c("48 weeks", "49 weeks", "50 weeks", 
                                  "51 weeks", "52 weeks")
subs[which(fy), "FullYear"] <- 'Full Year'
subs[which(!fy),"FullYear"] <- 'Other'

subs$Weight <- subs$PERS_WT / 10000.0

# TODO: re-code industry and occupation

subs$CSource <- 
    recodeVar(as.character(subs$PrincipalSource),
              list(c("Wages & salaries"), 
                   c("Business or farm", "Partnership"), 
                   c("Government cash benefits", "Superannuation", 
                     "Interest,dividends,bonds,rent", "Other sources", 
                     "Nil income")),
              list("Wages and Salaries", "Business or NLLC", "Other"))

subs$PFYSource <- 
    recodeVar(as.character(subs$PrincipalSource),
              list(c("Wages & salaries"), 
                   c("Business or farm", "Partnership"), 
                   c("Government cash benefits", "Superannuation", 
                     "Interest,dividends,bonds,rent", "Other sources", 
                     "Nil income")),
              list("Wages and Salaries", "Business or NLLC", "Other"))

subs$Year <- 1982

subset_1982 <- subs[,c("Year", "Sex", "Age4", 
                    "IncomeWages", "IncomeWages8182",
                    "IndEmployer", "IndEmployer", "Industry8182", "Industry8182",
                    "CurrentOccup", "CurrentOccup", "Occup8182", "Occup8182",
                    "EducA",        "EducB",
                    "CFullTime", "PFYFullTime", "FullYear",
                    "CSource", "PFYSource", 
                    "Weight")]
colnames(subset_1982) <- standard_column_list

save(subset_1982, file='data/curf/1982.rda')
