##' Subset dataset, and rename the columns according to parameters
##' All rows are returned, but only a subset of columns are given
##' This is to deal with the ABS's pathological column naming in CURFs,
##' such as "PPPxxxx", etc.
curfsubset <- function(dataset, ...) {
    lst <- list(...)
    subset <- dataset[,names(lst)] # subset the columns
    newnames <- c(do.call("cbind",lst))
    names(subset) <- newnames
    return(subset)
}

# Columns the CURF munge files should export
standard_column_list <- c("ID", "Year", "Sex", "Age4",
                          "CInc","PFYInc",
                          "CIndA","CIndB","PFYIndA","PFYIndB",
                          "COccupA","COccupB","PFYOccupA","PFYOccupB",
                          "EducA","EducB",
                          "CFullTime", "PFYFullTime", "FullYear",
                          "CSource","PFYSource",
                          "Weight")

income_sources <- c("Wages and Salaries", "Unincorporated Entity", "Other")

##' Recode a 1990s principal source
recodePrincipalSource <- function(src) {
    recodeVar(as.character(src),
              list(c("Wages and salaries"),
                   c("Own unincorporated business income"),
                   c("Government pension and allowances", "Government pensions and allowances",
                     "Superannuation", "Property investments", 
                     "Other sources", "Not applicable")),
              as.list(income_sources))
}

EducA_levels <- c("No Post-Secondary","Associate/Trade","Bachelor", "Postgraduate")
##' Recode a 1990s dataset to the EducA coding
recodeEducA <- function(educ) {
    res <- recodeVar(as.character(educ), 
                     list(c("Still at school","No qualifications"),
                          c("Undergraduate diploma", "Associate diploma",
                            "Skilled vocational qualifications", "Basic vocational qualifications"),
                          c("Bachelor degree"),
                          c("Higher degree", "Postgraduate diploma")),
                     as.list(EducA_levels))
    factor(res, ordered=TRUE, 
           levels=EducA_levels)
}

EducB_levels <- c("No Post-Secondary","Associate/Trade","Bachelor or Higher")
##' Recode a 1990s dataset to the EducA coding
recodeEducB <- function(educ) {
    recodeVar(as.character(educ), 
                 list(c("Still at school","No qualifications"),
                      c("Undergraduate diploma", "Associate diploma", 
                        "Skilled vocational qualifications", "Basic vocational qualifications"),
                      c("Higher degree", "Postgraduate diploma", "Bachelor degree")), 
                 as.list(EducB_levels))
}

# Standard list of age levels
age_level_list <- list("15-34", "35-54", "55-74", "75 +", "NA")
age_levels <- c("15-34", "35-54", "55-74", "75 +", "NA")

##' Recode age as potential experience
##' NOTE: this has some more work to go on it; it's just a temporary series
recodeAge4 <- function(age) {
    recodeVar(as.character(age),
              list(c("15 years", "16 years", "17 years", "18 years", 
                     "19 years", "20 years", "21 years", "22 years", "23 years", "24 years", 
                     "25-29 years","25 - 29 years", "30 - 34 years", "30-34 years"), 
                   c("35 - 39 years", "40 - 44 years", "45 - 49 years", "50 - 54 years",
                     "35-39 years",   "40-44 years",   "45-49 years",   "50-54 years"), 
                   c("55 years", "56 years", "57 years", "58 years", "59 years", "60 years", 
                     "61 years", "62 years", "63 years", "64 years", "65-69 years", "65 - 69 years", 
                     "70 - 74 years","70-74 years"),
                   c("75 years and over"),
                   c("Not applicable")), # "Not applicable" level is left out here
              age_level_list)
}

lf_status <- c("Full-time", "Part-time", "Other")
recodeFullTime <- function(status) {
    recodeVar(as.character(status),
              list(c("Employed full-time"), 
                   c("Employed part-time"), 
                   c("Unemployed", "Not in the labour force")),
              as.list(lf_status))
}

indA_list <- c("Agriculture, Forestry and Fishing", 
               "Mining", 
               "Manufacturing", 
               "Electricity, Gas, Water and Waste Services", 
               "Construction", 
               "Wholesale Trade", 
               "Retail Trade", 
               "Accommodation and Food Services", 
               "Transport, Postal and Warehousing", 
               "Information Media and Telecommunications", 
               "Financial and Insurance Services", 
               "Property and Business Services", 
               "Public Administration and Safety", 
               "Education and Training", 
               "Health Care and Social Assistance", 
               "Arts and Recreation Services", 
               "Other Services", 
               "Unknown")
recode_IndA <- function(ind) {
    require(doBy)
    recodeVar(as.character(ind),
              list(c("Agriculture, Forestry and Fishing", "Agriculture, forestry and fishing", "Agriculture,forestry, fishing and hunting"), 
                    c("Mining"), 
                    c("Manufacturing"), 
                    c("Electricity, Gas, Water and Waste Services", "Electricity, gas and water", "Electricity, gas and water supply",
                      "Electricity, Gas and Water Supply"), 
                    c("Construction"), 
                    c("Wholesale Trade", "Wholesale trade"), 
                    c("Retail Trade", "Retail trade"), 
                    c("Accommodation and Food Services", "Accommodation, cafes and restaurants", "Accommodation,cafes and restaurants",
                      "Accomodation, Cafes and Restaurants", "Accommodation, Cafes and Restaurants"), 
                    c("Transport, Postal and Warehousing", "Transport and storage", "Transport and Storage"), 
                    c("Information Media and Telecommunications", "Communication Services", "Communication services"), 
                    c("Financial and Insurance Services", "Finance and insurance", "Finance and Insurance"), 
                    c("Rental, Hiring and Real Estate Services", 
                      "Professional, Scientific and Technical Services", 
                      "Property and business services", "Property and business services",
                      "Administrative and Support Services"),
                    c("Public Administration and Safety", "Government administration and defence", "Government Administration and Ddefence",
                      "Government Administration and Defence"), 
                    c("Education and Training", "Education"), 
                    c("Health Care and Social Assistance", "Health and community services", "Health and Community Services"), 
                    c("Arts and Recreation Services", "Cultural and Recreational Sservices", "Cultural and recreational services",
                      "Cultural and Recreational Services"), 
                    c("Other Services", "Personal and Other Services", "Personal and other services"), 
                    c("Inadequately described", "Not applicable", "Invalid", "Not applicable and inadequately described", "Unknown")),
              as.list(indA_list)
              )
}

occupA_list <- c("Nonroutine Nonmanual", "Routine", "Nonroutine Manual","Other")
recode_occupA <- function(occ) {
    recodeVar(as.character(occ),
              list(c("Professionals", "Managers and Administrators", "Managers and administrators"),
                   c("Para-professionals","Para-professionals","Clerks","Salespersons and personal service workers",
                     "Associate professionals","Intermediate clerical, sales and service workers",
                     "Elementary clerical, sales and service workers","Associate Professionals",
                     "Elementary Clerical, Sales and Service Workers","Sales Workers","Clerical and Administrative Workers",
                     "Sales Workers","Intermediate Clerical, Sales and Service Workers","Advanced Clerical and Service Workers",
                     "Advanced clerical and service workers"),
                   c("Tradespersons","Defence forces","Plant and machine operators and drivers",
                     "Intermediate production and transport workers","Tradespersons and Related Workers",
                     "Intermediate Production and Transport Workers","Labourers and Related Workers",
                     "Technicians and Trade Workers","Machinery Operators and Drivers","Labourers","Tradespersons and related workers",
                     "Plant and machine operators, and drivers","Labourers and related workers","Community and Personal Service Workers"),
                   c("Inadequately described","Other", "Not applicable")
                  ),
              as.list(occupA_list)
    )
}