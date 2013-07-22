library(foreign)
library(doBy)
source('lib/curfmunge.R')

suppressWarnings(curf <- data.frame(read.spss('data/curf/2003/IDS02PER.SAV')))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

curf$ID <- with(curf, paste(ABSHID, ABSFID, ABSIID, ABSPID, sep="."))
subs <- curf[,c("ID", 
              "SEXP", 
              "AGEBC", 
              "LFSTBCP", # Labor force status, both jobs
              "OCCCBC",  # Occupation, main job
              "INDBC",   # Industry, main job
              "STOWCF",  # Status in employment
              "EMPSTAT", # Labour force status
              sprintf("EMPD6M%d",1:7), # Labour force status in month minus n
              "HQUALBC", # Highest post-secondary education
              "STUDSTCP",# Study status
              "FTPTSTAT", # Fulltime/parttime status
              sprintf("FTPTD7M%d",1:7), # Full-time/part-time status in month minus n
              "IWSUCP",  # Total current weekly employee income from wages and salaries from main and second jobs
              "IOBTCP",  # Current weekly income from own unincorporated business
              "IOBTCPF", # Current weekly income from own unincorporated business flag
              "IOBTPP",  # Previous financial year income from own unincorporated business
              "IOBTPPF", # Previous financial year income from own unincorporated business flag
              "IWSTPP",  # Total previous financial year income from wages and salaries
              "PSRCCP",  # Principal source of current weekly income
              "PSRCPP",  # Principal source of previous financial year income
              "WTPSN",   # Person weight
              sprintf("REPWT%02d",1:30)
)]

subs$Weight <- subs$WTPSN / 1.0e4

recodePrincipalSource <- function(src) {
    recodeVar(as.character(src),
              list("Wage and salary",
                   "Own unincorporated business income",
                   c("Government pensions and allowances", "Superannuation", "Property investments", 
                     "Other sources", "Not applicable")),
               as.list(income_sources)
              )
}
subs$CPrincipalSource <- recodePrincipalSource(subs$PSRCCP)
subs$PFYPrincipalSource <- recodePrincipalSource(subs$PSRCPP)

subs$EducA <- rep(NA, nrow(subs))
subs$EducB <- recodeVar(as.character(subs$HQUALBC), 
                        list("Higher/bachelor degree, postgraduate diploma",
                             "Other post school qualifications",
                             c("Not applicable", "Still at school",
                               "No qualifications")),
                        as.list(EducB_levels))

subs$Age4 <- recodeVar(as.character(subs$AGEBC),
                       list(c("15 years", "16 years", "17 years", "18 years", "19 years", 
                              "20 years", "21 years", "22 years", "23 years", "24 years", "25 to 29 years", 
                              "30 to 34 years"),
                            c("35 to 39 years", "40 to 44 years", "45 to 49 years", 
                              "50 to 54 years"), 
                            c("55 years", "56 years", "57 years", "58 years", 
                              "59 years", "60 years", "61 years", "62 years", "63 years", "64 years", 
                              "65 to 69 years", "70 to 74 years"), 
                            c("75 to 79 years", "80 years and over"),
                            c()),
                       age_level_list
                       )

subs$CFullTime <-     
    recodeVar(as.character(subs$LFSTBCP),
                list(c("Employed Full-time"), 
                     c("Employed Part-time"), 
                     c("Not applicable")),
                list("Full-time", "Part-time", "Other"))

subs$Year <- 2003

# ahem: TODO
subs$PFYFullTime <- NA
subs$FullYear <- NA
subs$PFYIndA <- subs$INDBC
subs$PFYIndB <- subs$INDBC
subs$PFYOccupA <- subs$OCCCBC
subs$PFYOccupB <- subs$OCCCBC

subset_2003 <- subs[,c("ID", "Year", "SEXP", "Age4",
                       "IWSUCP","IWSTPP",
                       "PFYIndA", "PFYIndB", "PFYIndA", "PFYIndB",
                       "PFYOccupA", "PFYOccupA", "PFYOccupA", "PFYOccupB",
                       "EducA", "EducB",
                       "CFullTime", "PFYFullTime", "FullYear",
                       "CPrincipalSource", "PFYPrincipalSource",
                       "Weight"
)]
colnames(subset_2003) <- standard_column_list

save(subset_2003, file='data/curf/2003.rda')
