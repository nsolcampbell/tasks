library(foreign)
library(doBy)
source('lib/curfmunge.R')

curf <- data.frame(read.spss('data/curf/2006/sih05bp.sav'))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

curf$ID <- with(curf, paste(ABSHID, ABSFID, ABSIID, ABSPID, sep="."))
subs <- curf[,c("ID",
              "SEXP", 
              "IWSUCP",  # Total current weekly employee income from wages and salaries from main and second jobs
              "IWSTPP",  # Prev fin year employee income from all jobs (incl STRPs)
              "IWSSUCP", # Total current weekly employee income (incl overtime, salary sacrifice, bonuses and STRP)
              "IOBTCP",  # Current weekly income from own unincorporated business
              "IOBTCPF", # Current weekly income from own unincorporated business flag
              "IWSTPP",  # Total previous financial year income from wages and salaries
              "HQUALBC", # Level of highest non-school qualification
              "INDBC",   # Industry of main job
              "OCCCBC",  # Occupation of main job
              "AGEBC",   # Person's age
              "PSRC4CP", # Principal source of income, 2003-04 basis
              "PSRC4PP", # Principal source of PFY income, 2003-04 basis
              "FTPTSTAT",# Full-time/part-time status
              "SIHPSWT", # person weight
              sprintf("WPS%04d",101:160)  # replication weights
)]

recodeSource <- function(src) {
    recodeVar(as.character(src),
              list(c("Wage and salary"), 
                   c("Own unincorporated business income"), 
                   c("Government pensions and allowances", "Other income",
                     "Zero or negative income")),
               as.list(income_sources)
              )
}

subs$CPrincipalSource <- recodeSource(subs$PSRC4CP)
subs$PFYPrincipalSource <- recodeSource(subs$PSRC4PP)

subs$EducA <- 
    recodeVar(as.character(subs$HQUALBC),
              list(c("Postgraduate degree, graduate diploma/graduate certificate"), 
                   c("Bachelor degree"),
                   c("Advanced diploma / diploma", "Certificate III / IV", 
                     "Certificate I / II", "Certificate not further defined"), 
                   c("No non-school qualification", 
                     "Level not determined")),
              as.list(EducA_levels))

subs$EducB <- 
    recodeVar(as.character(subs$HQUALBC),
              list(c("Postgraduate degree, graduate diploma/graduate certificate", "Bachelor degree"),
                   c("Advanced diploma / diploma", "Certificate III / IV", 
                     "Certificate I / II", "Certificate not further defined"), 
                   c("No non-school qualification", 
                     "Level not determined")),
              as.list(EducB_levels))

subs$Age4 <- recodeVar(as.character(subs$AGEBC),
       list(c("15 years", "16 years", "17 years", "18 years", "19 years", 
              "20 years", "21 years", "22 years", "23 years", "24 years", "25 to 29 years", 
              "30 to 34 years"),
            c("35 to 39 years", "40 to 44 years", "45 to 49 years", "50 to 54 years"), 
            c("55 years", "56 years", "57 years", "58 years", 
              "59 years", "60 years", "61 years", "62 years", "63 years", "64 years", 
              "65 to 69 years", "70 to 74 years"), 
            c("75 to 79 years", "80 years and over"),
            c("Not Applicable")),
        age_level_list)

subs$CFullTime <- recodeVar(as.character(subs$FTPTSTAT),
                            c("Full time", "Part time", "Not applicable"),
                            c("Full-time", "Part-time", "Other"))

# ahem: TODO
subs$PFYFullTime <- subs$CFullTime # Hackity hack (TODO)
subs$FullYear <- "Full Year" # Hackity hack (TODO)

subs$Year <- 2006

subset_2006 <- subs[,c("ID", "Year", "SEXP", "Age4",
                       "IWSSUCP","IWSTPP",
                       "INDBC", "INDBC", "INDBC", "INDBC",
                       "OCCCBC", "OCCCBC", "OCCCBC", "OCCCBC",
                       "EducA", "EducB",
                       "CFullTime", "PFYFullTime", "FullYear",
                       "CPrincipalSource", "PFYPrincipalSource",
                       "SIHPSWT")]
colnames(subset_2006) <- standard_column_list

save(subset_2006, file='data/curf/2006.rda')
