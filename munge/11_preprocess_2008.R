library(foreign)
library(doBy)
source('lib/curfmunge.R')

curf <- data.frame(read.spss('data/curf/2008/SIH08BP.SAV'))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

keepcols <- c("SEXP", 
              "IWSUCP",  # Total current weekly employee income from wages and salaries from main and second jobs
              "IWSTPP8", # Prev fin year employee income from all jobs (incl STRPs)
              "IWSSUCP8",# Total current weekly employee income (incl overtime, salary sacrifice, bonuses and STRP)
              "IOBTCP",  # Current weekly income from own unincorporated business
              "IOBTCPF", # Current weekly income from own unincorporated business flag
              "IWSTPP",  # Total previous financial year income from wages and salaries
              "HQUALBC", # Level of highest non-school qualification
              "INDBC",   # Industry of main job
              "OCCBASC", # Occupation of main job
              "AGEBC",   # Person's age
              "PSRC4CP", # Principal source of income, 2003-04 basis
              "PSRC4PP", # Principal source of PFY income, 2003-04 basis
              "FTPTSTAT",# Full-time/part-time status
              "SIHPSWT"
)
repcols <- paste("REPWT",1:30,sep="") # ignoring rep wts for now
subs <- curf[,keepcols]

subs$Weight <- subs$SIHPSWT / 10000.0

recodeSource <- function(src) {
    recodeVar(as.character(src),
              list(c("Wage and salary"), 
                   c("Own unincorporated business income"), 
                   c("Government pensions and allowances", "Other income",
                     "Zero or negative income")),
              list("Wages and Salaries", "NLLC", "Other"))
}

subs$CPrincipalSource <- recodeSource(subs$PSRC4CP)
subs$PFYPrincipalSource <- recodeSource(subs$PSRC4PP)

subs$EducA <- 
    recodeVar(as.character(subs$HQUALBC),
              list(c("Postgraduate Degree, Graduate Diploma/Graduate Certificate"), 
                   c("Bachelor Degree"),
                   c("Advanced Diploma/Diploma", "Certificate III/IV", 
                     "Certificate I/II", "Certificate not further defined"), 
                   c("No non-school qualification", 
                     "Level not determined")),
              list("Postgraduate","Bachelor","Associate Degree","None"))

subs$EducB <- 
    recodeVar(as.character(subs$HQUALBC),
              list(c("Postgraduate Degree, Graduate Diploma/Graduate Certificate", "Bachelor Degree"),
                   c("Advanced Diploma/Diploma", "Certificate III/IV", 
                     "Certificate I/II", "Certificate not further defined"), 
                   c("No non-school qualification", 
                     "Level not determined")),
              list("Bachelor or Higher","Associate Degree","None"))

subs$PExp <- recodeVar(as.character(subs$AGEBC),
       list(c("15 years", "16 years", "17 years", "18 years", "19 years", 
              "20 years", "21 years", "22 years", "23 years", "24 years", "25 to 29 years", 
              "30 to 34 years", "35 to 39 years"), 
            c("40 to 44 years", "45 to 49 years", 
              "50 to 54 years", "55 years", "56 years", "57 years", "58 years", 
              "59 years", "60 years", "61 years", "62 years", "63 years", "64 years"), 
            c("65 to 69 years", "70 to 74 years", "75 to 79 years", "80 years and over")),
       list("0-24","25-39","40 +"))

subs$CFullTime <- recodeVar(as.character(subs$FTPTSTAT),
                            c("Full time", "Part time", "Not applicable"),
                            c("Full-time", "Part-time", "Other"))

# ahem: TODO
subs$PFYFullTime <- subs$CFullTime # Hackity hack (TODO)
subs$FullYear <- "Full Year" # Hackity hack (TODO)

subs$Year <- 2008

subset_2008 <- subs[,c("Year", "SEXP", "PExp",
                       "IWSSUCP8","IWSTPP8",
                       "INDBC", "INDBC", "INDBC", "INDBC",
                       "OCCBASC", "OCCBASC", "OCCBASC", "OCCBASC",
                       "EducA", "EducB",
                       "CFullTime", "PFYFullTime", "FullYear",
                       "CPrincipalSource", "PFYPrincipalSource",
                       "Weight")]
colnames(subset_2008) <- standard_column_list

save(subset_2008, file='data/curf/2008.rda')
