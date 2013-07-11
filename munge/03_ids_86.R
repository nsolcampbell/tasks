library(foreign)
source('lib/curfmunge.R')

ids_86 <- data.frame(read.spss("data/curf/ids_86_comb/IDS86MAIN/ids86.sav"))

subs <- curfmunge(ids_86,
	PPP0001="HOUSEHOLD_IDENT_NA_UNIT",
	PPP0002="RECORD_ID_NA_UNIT",
	PPP0003="FAMILY_NUMBER_NA_PSN",
	PPP0004="INCOME_UNIT_NUMBER_NA_PSN",
	PPP0005="PERSNR",
	PPP0025="SEX_NA_PSN",
	PPP0026="AGE_CUR_PSN",
	PPP0027="MARITAL_STATUS_CUR_PSN",
	PPP0038="HIGHEST_EDUC_QUAL_CUR_PSN",
	PPP0039="QUALIFICATION_FIELD_CUR_PSN",
	PPP0040="AGE_LEFT_SCHOOL_NA_PSN",
	PPP0041="LFSTAT_ALL_BRIEF_CUR_PSN",      # labor force status in main & second jobs
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
	PPP0075="INC_USUAL_WAGE_SALARY_CUR_PSN", # Total current usual weekly income from wages or salary from main and second job
	PPP0081="INC_EMP_GR_WS_EXCL_JE_PRD_PSN", # Annual 1985-86 income from w/s (as employee)(incl leave load, tips, comms, bons)
	PPP0253="WEIGHT_PERSONS_NA_PSN"          # Weight for persons (needs division by 10,000)
)
subs$WEIGHT_PERSONS_NA_PSN <- subs$WEIGHT_PERSONS_NA_PSN / 1000.0

# Supplement contains hours worked; needs to be linked via family and person number
supp <- read.csv("data/curf/ids_86_comb/IDS86SUP/Ids86sup.dat", 
									col.names=c("IDENTNP", # HOUSEHOLD_IDENT_NA_PSN
															"IDNP",    # RECORD_ID_NA_PSN
															"FAMNONP", # FAMILY_NUMBER_NA_PSN
															"IUNO",    # INCOME_UNIT_NUMBER_NA_PSN
															"PERSNONP",# PERSON_NUMBER_IN_INCOME_UNIT
															"HRSWKMCP",# HOURS WORKED IN MAIN CURRENT JOB
															"HRSWK2CP" # HOURS WORKED IN CURRENT 2ND JOB
									))
# is there a way to index this merge?!
# subs_merged <- merge(ids_86, supp)

table(subs$HIGHEST_EDUC_QUAL_CUR_PSN)

save(ids_82=subs, file='data/ids_86.rda')