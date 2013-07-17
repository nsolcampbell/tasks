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
standard_column_list <- c("Year", "Sex", "PExp",
                          "CInc","PFYInc",
                          "CIndA","CIndB","PFYIndA","PFYIndB",
                          "COccupA","COccupB","PFYOccupA","PFYOccupB",
                          "EducA","EducB",
                          "CFullTime", "PFYFullTime", "FullYear",
                          "CSource","PFYSource",
                          "Weight")

##' Recode a 1990s principal source
recodePrincipalSource <- function(src) {
    recodeVar(as.character(src),
              list(c("Wages and salaries"),
                   c("Own unincorporated business income"),
                   c("Government pension and allowances", 
                     "Superannuation", "Property investments", 
                     "Other sources", "Not applicable")),
              list("Wages and Salaries", "NLLC", "Other"))
}

##' Recode a 1990s dataset to the EducA coding
recodeEducA <- function(educ) {
    res <- recodeVar(as.character(educ), 
                     list(c("Higher degree", "Postgraduate diploma"),
                          c("Bachelor degree"),
                          c("Undergraduate diploma", "Associate diploma",
                            "Skilled vocational qualifications", "Basic vocational qualifications"),
                          c("Still at school","No qualifications")),
                     list("Postgraduate","Bachelor","Associate Degree","None"))
    factor(res, ordered=TRUE, 
           levels=c("Postgraduate","Bachelor","Associate Degree","None"))
}

##' Recode a 1990s dataset to the EducA coding
recodeEducB <- function(educ) {
    res <- recodeVar(as.character(educ), 
                     list(c("Higher degree", "Postgraduate diploma", "Bachelor degree"), 
                          c("Undergraduate diploma", "Associate diploma", 
                            "Skilled vocational qualifications", "Basic vocational qualifications"),
                          c("Still at school","No qualifications")), 
                     list("Bachelor or Higher","Associate Degree","None"))
    factor(res, ordered=TRUE, 
           levels=c("Bachelor or Higher","Associate Degree","None"))
}

##' Recode age as potential experience
##' NOTE: this has some more work to go on it; it's just a temporary series
recodePExp <- function (age) {
    recodeVar(as.character(age),
              list(c("15 years", "16 years", "17 years", "18 years", 
                     "19 years", "20 years", "21 years", "22 years", "23 years", "24 years", 
                     "25 - 29 years", "30 - 34 years", "35 - 39 years"), 
                   c("40 - 44 years", "45 - 49 years", "50 - 54 years", "55 years", 
                     "56 years", "57 years", "58 years", "59 years", "60 years", 
                     "61 years", "62 years", "63 years", "64 years"), 
                   c("65 - 69 years", "70 - 74 years", "75 years and over"),
                   c("Not applicable")),
              list("0-24","25-39","40 +","NA"))
}

recodeFullTime <- function(status) {
    recodeVar(as.character(subs$LFSTBCP),
              list(c("Employed full-time"), 
                   c("Employed part-time"), 
                   c("Unemployed", "Not in the labour force")),
              list("Full-time", "Part-time", "Other"))
}
