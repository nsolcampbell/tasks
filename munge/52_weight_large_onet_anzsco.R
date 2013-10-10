# Weight ALL the O*NET numbers to the task measures

rm(list=ls())
library(plyr)

census <- read.csv("data/census_4dig_FT_2011.csv")
census$Population = with(census, Employees+Employees+Unincorporated+ContribFamily+Not.Stated)

# anzsco_onet <- read.csv("data/anzsco_onet_combined.csv") # O*NET <-> ANZSCO at 4-digit level
load("data/anzsco_onet_all.rda")

# **** 2-digit ANZSCO classification ****
# note: some ANZSCO rows are coded according to the major/minor group, not occupation
# so, first take the rows that match off the bat
census$ANZSCO4 <- with(census, ANZSCO)
census$ANZSCO3 <- with(census, as.numeric(substr(as.character(ANZSCO), 1, 3)))

combined <- merge(x=census, y=all_content, by.x='ANZSCO', by.y='ANZSCO4',all=T)
content.unmatched <- all_content[is.na(combined$Population) & !is.na(combined$Information.Ordering),]
census.unmatched      <- census[is.na(combined$Information.Ordering),]
matched               <- combined[complete.cases(combined),]

# match at detailed occupation level
combined.sub      <- merge(x=census.unmatched, y=content.unmatched, by.x='ANZSCO3', by.y='ANZSCO3',all.y=T)
matched.sub       <- combined.sub[!is.na(combined.sub$Population),]
unmatched.sub     <- content.unmatched[is.na(combined.sub$Population),]

cols <- intersect(colnames(matched), colnames(matched.sub))
combined <- rbind(matched[,cols], matched.sub[,cols])
combined$ANZSCO2 <- factor(combined$ANZSCO2)

# Weight each column, by row weight, and reduce to the specified coding scheme
# indexes specifies the groups to map to, where groups are 1..n
# X and indexes must have the same length
weight_reduce <- function(X, indexes, weights) {
  n <- max(indexes)
  result <- matrix(rep(NA, ncol(X) * n), nrow=n)
  colnames(result) <- colnames(X)
  for (col in 1:ncol(X)) {
    for (group in 1:n) {
      subset <- which(indexes == group)
      result[group, col] <- weighted.mean(X[subset, col], weights[subset])
    }
  }
  return(result)
}

tasks.anzsco2 <- weight_reduce(as.matrix(combined[,29:209]), as.numeric(combined$ANZSCO2), combined$Population)

# The next two classifications get further merged by the COMBINEDI and COMBINEDII
# aggregate groupings.

# **** COMBINEDI classificaiton ****

combinedimap <- read.csv("data/mappings/anzsco_combinedi.csv")
combined.i   <- merge(x=combined, y=combinedimap, by.x='ANZSCO2', by.y='ANZSCO')
combined.i.tasks <- weight_reduce(as.matrix(combined.i[,29:209]),
                                  as.numeric(combined.i$COMBINED1),
                                  combined.i$Population)
tasks.combinedi <- as.data.frame(combined.i.tasks)
tasks.combinedi$COMBINED1 <- 1:nrow(tasks.combinedi)

# **** COMBINEDII classification ****

combinediimap <- read.csv('data/mappings/anzsco_combinedii.csv')
combined.ii  <- merge(x=combined, y=combinediimap, by.x='ANZSCO2', by.y='ANZSCO')
combined.ii.tasks <- weight_reduce(as.matrix(combined.ii[,29:209]),
                                   as.numeric(combined.ii$COMBINEDII),
                                   combined.ii$Population)
tasks.combinedii <- as.data.frame(combined.ii.tasks)
tasks.combinedii$COMBINEDII <- 1:nrow(tasks.combinedii)

save(tasks.combinedi, tasks.combinedii, tasks.anzsco2,
     file="data/all_tasks.rda")
