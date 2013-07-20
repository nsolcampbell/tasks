library(foreign)
library(doBy)
source('lib/curfmunge.R')

curf <- data.frame(read.spss("data/curf/1986/IDS86MAIN/ids86.sav"))

subs <- curfsubset(curf,
    PPP0001="HOUSEHOLD_IDENT_NA_UNIT",
    PPP0002="RECORD_ID_NA_UNIT",
    PPP0003="FAMILY_NUMBER_NA_PSN",
    PPP0004="INCOME_UNIT_NUMBER_NA_PSN",
    PPP0005="PERSNR",
    PPP0025="SEX_NA_PSN",
    PPP0026="AGE_CUR_PSN",
    PPP0038="HIGHEST_EDUC_QUAL_CUR_PSN",
    PPP0039="QUALIFICATION_FIELD_CUR_PSN",
    PPP0040="AGE_LEFT_SCHOOL_NA_PSN",
    PPP0041="LFSTAT_ALL_BRIEF_CUR_PSN",      # labor force status in main & second jobs
    PPP0046="LABOUR_FORCE_STATUS_PRD_PSN",   # labor force status 1985-86, all jobs
    PPP0047="MAIN_INDUSTRY_CUR_PSN",         # Industry in current main job
    PPP0048="MAIN_INDUSTRY_PRD_PSN",         # Industry in main job during 1985-86
    PPP0049="SECTOR_OF_INDUSTRY_CUR_PSN",    # Industry sector for current main job
    PPP0050="SECTOR_OF_INDUSTRY_PRD_PSN",    # Industry sector for main job in 1985-86
    PPP0051="MAIN_OCCUPATION_CUR_PSN",       # Occupation in current main job
    PPP0052="MAIN_OCCUPATION_PRD_PSN",       # Occupation in main job during 1985-86
    PPP0053="OCCUPATION_2ND_JOB_CUR_PSN",    # Occupation in current second job
    PPP0054="HOURS_WORKED_ALL_JOBS_CUR_PSN", # Number of hours usually worked p/w in current main and second job
    PPP0055="HOURS_WORKED_MAIN_JOB_CUR_PSN", # Number of hours usually worked p/w in current main job
    PPP0056="HOURS_WORKED_2ND_JOB_CUR_PSN",  # Number of hours usually worked p/w in current second job
    PPP0057="HOURS_EMP_WAGE_SALARY_PRD_PSN", # Number of hours worked p/w for wages/sal (as	employee) during 1985-86
    PPP0058="HOURS_LLC_WAGE_SALARY_PRD_PSN", # Number of hours worked p/w for wages/sal (in own ltd	liabil co) during 1985-86
    PPP0059="HOURS_BUSINESS_TRUST_PRD_PSN",  # Number of hours worked p/w in own non-ltd liabilbus/trust during 1985-86
    PPP0060="WEEKS_WORKED_FULL_TIME_PRD_PSN",# Number of weeks worked full time during 1985-86.
    PPP0061="WEEKS_WORKED_PART_TIME_PRD_PSN",# Number of weeks worked part time only during 1985-86
    PPP0062="WEEKS_WORKED_PRD_PSN",          # Number of weeks worked during 1985-86
    PPP0063="WEEKS_EMP_WAGE_SALARY_PRD_PSN", # Number of weeks worked for wages/sal (as employee) during 1985-86
    PPP0064="WEEKS_LLC_WAGE_SALARY_PRD_PSN", # Number of weeks worked for wages/sal (in own ltd	liabil co) during 1985-86
    PPP0069="PRINCIPAL_SOURCE_INC_CUR_PSN",  # Principal source of current weekly income
    PPP0070="PRINCIPAL_SOURCE_INC_PRD_PSN",  # Principal source of annual income during 1985-86
    PPP0075="INC_USUAL_WAGE_SALARY_CUR_PSN", # Total current usual weekly income from wages or salary from main and second job
    PPP0081="INC_EMP_GR_WS_EXCL_JE_PRD_PSN", # Annual 1985-86 income from w/s (as employee)(incl leave load, tips, comms, bons)
    PPP0085="INC_TOT_GR_WS_EXCL_JE_PRD_PSN", # Total annual 1985-86 inc from w/s(from own llc and as
                                                             # employee)(incl leave load,tips,comms,bons)
    PPP0253="WEIGHT_PERSONS_NA_PSN"          # Weight for persons (needs division by 10,000)
    )
subs$Weight <- subs$WEIGHT_PERSONS_NA_PSN / 1000.0

# Supplement contains hours worked; needs to be linked via family and person number
# NOTE: don't need this at this stage, since we're using full-year data for now
# supp <- read.csv("data/curf/1986/IDS86SUP/Ids86sup.dat", 
# 									col.names=c("IDENTNP", # HOUSEHOLD_IDENT_NA_PSN
# 															"IDNP",    # RECORD_ID_NA_PSN
# 															"FAMNONP", # FAMILY_NUMBER_NA_PSN
# 															"IUNO",    # INCOME_UNIT_NUMBER_NA_PSN
# 															"PERSNONP",# PERSON_NUMBER_IN_INCOME_UNIT
# 															"HRSWKMCP",# HOURS WORKED IN MAIN CURRENT JOB
# 															"HRSWK2CP" # HOURS WORKED IN CURRENT 2ND JOB
# 									))
# subs_merged <- merge(ids_86, supp)

# We can't do EducA because higher degrees are missing from this survey
subs$EducA <- NA

old_educ <- list(
        c("Bachelor degree or higher"),
        c("Trade certificate", "Other certificate or diploma",
            "Other qualification"), 
        c("Not applicable", "Still at school", "Never went to school",
            "No qualifications since school, did not complete highest yea", 
            "Completed highest year secondary", 
            "Obtained secondary qualifications since leaving school"))
new_educ <- list("Bachelor or Higher","Associate Degree","None")
subs$EducB <- recodeVar(as.character(subs$HIGHEST_EDUC_QUAL_CUR_PSN), src=old_educ, tgt=new_educ)
subs$EducB <- factor(subs$EducB, ordered=TRUE, levels=new_educ)

# recode into experience groups
subs$Age4 <- recodeVar(as.character(subs$AGE_CUR_PSN),
                         list(c("Aged 15 years", "Aged 16 to 17 years", "Aged 18 to 20 years", 
                                "Aged 21 to 24 years", "Aged 25 to 29 years", "Aged 30 to 34 years"), 
                              c("Aged 35 to 39 years", "Aged 40 to 44 years", "Aged 45 to 49 years", 
                                "Aged 50 to 54 years"), 
                              c("Aged 55 to 59 years", "Aged 60 to 64 years", "Aged 65 to 69 years", "Aged 70 to 74 years"),
                              c("Aged 75 years or more"),
                              c("Not Applicable")),
                             age_level_list)

subs$CFullTime <- recodeVar(as.character(subs$LFSTAT_ALL_BRIEF_CUR_PSN),
                             list(c("Employed full-time"), 
                                  c("Employed part-time"),
                                  c("Not applicable", "Permanently unable to work", "Still at school", 
                                    "Studying full time", "Unpaid voluntary worker", "Unemployed", 
                                    "Not in the labour force")),
                             list("Full-time","Part-time","Other"))
subs$CFullTime <- factor(subs$CFullTime, ordered=T, 
                         levels=c("Full-time","Part-time","Other"))

subs$PFYFullTime <- recodeVar(as.character(subs$LABOUR_FORCE_STATUS_PRD_PSN),
                            list(c("Worked more than 49 weeks in year Less than half part-time", 
                                   "Worked up to 49 weeks in year Less than half part-time"), 
                                 c("Worked more than 49 weeks in year  Half or more part-time", 
                                   "Worked up to 49 weeks in year Half or more part-time"), 
                                 c("Did not work during the period",
                                   "Not applicable")),
                            list("Full-time","Part-time","Other"))
            subs$PFYFullTime <- factor(subs$PFYFullTime, ordered=T, 
                                       levels=c("Full-time","Part-time","Other"))

fy <- subs$WEEKS_WORKED_PRD_PSN %in% c("48 weeks", "49 weeks", "50 weeks", 
                                       "51 weeks", "52 weeks")
subs[which(fy), "FullYear"] <- 'Full Year'
subs[which(!fy),"FullYear"] <- 'Other'

recodePrincipalSource <- function(variable) {
	r <- recodeVar(as.character(variable),
                    list(c("Wage and salary"),
                             c("NLLC business or trust"),
                             c("Not applicable (respondent is stillat school or studying ful", 
                                "Government pensions and benefits", 
                                "Superannuation", "Interest, dividends, rent", "Other sources", 
                                "No regular income", "Not able to calculate as at least one component was not stat")),
                    list("Earned", "LLC or Trust", "Other"))
	factor(r, ordered=T, levels=c("Earned", "LLC or Trust", "Other"))
}
subs$CPrincipalSource   <- recodePrincipalSource(subs$PRINCIPAL_SOURCE_INC_CUR_PSN)
subs$PFYPrincipalSource <- recodePrincipalSource(subs$PRINCIPAL_SOURCE_INC_PRD_PSN)

# TODO: re-code industry and occupation

subs$Year <- 1986

subset_1986 <- subs[,c("Year", "SEX_NA_PSN", "Age4",
                         "INC_USUAL_WAGE_SALARY_CUR_PSN", "INC_TOT_GR_WS_EXCL_JE_PRD_PSN",
                         "MAIN_INDUSTRY_CUR_PSN", "MAIN_INDUSTRY_CUR_PSN", "MAIN_INDUSTRY_PRD_PSN", "MAIN_INDUSTRY_PRD_PSN",
                         "MAIN_OCCUPATION_CUR_PSN", "MAIN_OCCUPATION_CUR_PSN", "MAIN_OCCUPATION_PRD_PSN", "MAIN_OCCUPATION_PRD_PSN",
                         "EducA",	"EducB",
                         "CFullTime", "PFYFullTime", "FullYear",
                         "CPrincipalSource", "PFYPrincipalSource", 
                         "Weight")]
colnames(subset_1986) <- standard_column_list

save(subset_1986, file='data/curf/1986.rda')
