##' Subset dataset, and rename the columns according to parameters
##' All rows are returned, but only a subset of columns are given
##' This is to deal with the ABS's pathological column naming in CURFs,
##' such as "PPPxxxx", etc.
curfmunge <- function(dataset, ...) {
	lst <- list(...)
	subset <- dataset[,names(lst)] # subset the columns
	newnames <- c(do.call("cbind",lst))
	names(subset) <- newnames
	return(subset)
}