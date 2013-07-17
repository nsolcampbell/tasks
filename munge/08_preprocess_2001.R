library(foreign)
library(doBy)
source('lib/curfmunge.R')

curf <- data.frame(read.spss('data/curf/2001/IDS00.SAV'))

# Note fields are described in "65410_1994-95 (Reissue).pdf", with
# person record notes starting on p.41

keepcols <- c("SEXP", 
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
              "WTPSN"    # Person weight
)
repcols <- paste("REPWT",1:30,sep="") # ignoring rep wts for now
subs <- curf[,keepcols]

subs$Weight <- subs$WTPSN / 10000.0

subs$CPrincipalSource <- recodePrincipalSource(subs$PSRCCP)
subs$PFYPrincipalSource <- recodePrincipalSource(subs$PSRCPP)

subs$EducA <- recodeEducA(subs$HQUALCP)
subs$EducB <- recodeEducB(subs$HQUALCP)

subs$PExp <- recodePExp(subs$AGECP)

subs$CFullTime <- recodeFullTime(status)

subs$Year <- 2001

# ahem: TODO
subs$PFYFullTime <- NA
subs$FullYear <- NA
subs$PFYIndA <- NA
subs$PFYIndB <- NA
subs$PFYOccupA <- NA
subs$PFYOccupB <- NA

subset_2001 <- subs[,c("Year", "SEXP", "PExp",
                       "IEARNCP","IEARNPP",
                       "INDCP", "INDCP", "PFYIndA", "PFYIndB",
                       "OCCCP", "OCCCP", "PFYOccupA", "PFYOccupB",
                       "EducA", "EducB",
                       "CFullTime", "PFYFullTime", "FullYear",
                       "CPrincipalSource", "PFYPrincipalSource",
                       "Weight"
)]
colnames(subset_2001) <- standard_column_list

save(subset_2001, file='data/curf/2001.rda')
