rm(list=ls())
library(plyr)

census <- read.csv("data/census_4dig_FT_2011.csv")
census$Population = with(census, Employees+Employees+Unincorporated+ContribFamily+Not.Stated)

# anzsco_onet <- read.csv("data/anzsco_onet_combined.csv") # O*NET <-> ANZSCO at 4-digit level
load("data/anzsco_onet.rda")

# **** 2-digit ANZSCO classification ****
# note: some ANZSCO rows are coded according to the major/minor group, not occupation
# so, first take the rows that match off the bat
census$ANZSCO4 <- with(census, ANZSCO)
census$ANZSCO3 <- with(census, as.numeric(substr(as.character(ANZSCO), 1, 3)))
# census$ANZSCO2 <- with(census, as.numeric(substr(as.character(ANZSCO), 1, 2)))

combined <- merge(x=census, y=anzsco_onet, by.x='ANZSCO', by.y='ANZSCO4',all=T)
anzsco_onet.unmatched <- anzsco_onet[is.na(combined$Population) & !is.na(combined$Information.Content),]
census.unmatched      <- census[is.na(combined$Information.Content),]
matched               <- combined[complete.cases(combined),]

# match at detailed occupation level
combined.sub      <- merge(x=census.unmatched, y=anzsco_onet.unmatched, by.x='ANZSCO3', by.y='ANZSCO3',all.y=T)
matched.sub       <- combined.sub[!is.na(combined.sub$Population),]
unmatched.sub     <- anzsco_onet.unmatched[is.na(combined.sub$Population),]

# match at minor group (3 digit) level
# combined.maj   <- merge(x=census, y=unmatched.sub, by.x='ANZSCO2', by.y='ANZSCO2',all.y=T)
# matched.maj    <- combined.sub[!is.na(combined.maj$Population),]
# unmatched      <- unmatched[is.na(combined.maj$Population),]

cols <- c("ANZSCO", "Title.x", "Employees", "Incorporated", "Unincorporated", 
          "ContribFamily", "Not.Stated", "Population", "ANZSCO2", "Title2", 
          "Information.Content", "Automation.Routinization", "Face.to.Face", "On.Site.Job", "Decision.Making"
)

combined <- rbind(matched[,cols], matched.sub[,cols])

# Procedure to convert four-digit grouping to two-digit, weighted by
# census sub-population of each occupation, in each group
to_two_digit <- function(four_digit, col) {
    ddply(four_digit, col, summarise, 
          Information.Content=weighted.mean(Information.Content, Population),
          Automation.Routinization=weighted.mean(Automation.Routinization, Population),
          Face.to.Face=weighted.mean(Face.to.Face, Population),
          On.Site.Job=weighted.mean(On.Site.Job, Population),
          Decision.Making=weighted.mean(Decision.Making, Population),
          Population=sum(Population))
}

# normalize columns to unit standard deviation and zero mean
scale_tasks <- function(task_measures) {
    cols <- c("Information.Content", "Automation.Routinization",
                "Face.to.Face", "On.Site.Job", "Decision.Making")
    for (col in cols) {
        xbar <- mean(task_measures[,col])
        s    <- sd(task_measures[,col])
        task_measures[,col] <- (task_measures[,col] - xbar) / s + 1
    }
    return(task_measures)
}

tasks.anzsco2 <- to_two_digit(combined, .(ANZSCO2))
tasks.anzsco2 <- scale_tasks(tasks.anzsco2)
anzsco2.names <- read.csv("data/anzsco2_titles.csv")
tasks.anzsco2 <- merge(x=tasks.anzsco2, y=anzsco2.names, by="ANZSCO2")

# so, we've done the four-->two-digit classifications. Next, we want the very top
# level, the one-digit classifications

tasks.anzsco1 <- tasks.anzsco2
tasks.anzsco1$ANZSCO1 <- substr(as.character(tasks.anzsco1$ANZSCO2), 1, 1)
tasks.anzsco1 <- to_two_digit(tasks.anzsco1, .(ANZSCO1))
tasks.anzsco1$ANZSCO2 <- 10 * as.numeric(tasks.anzsco1$ANZSCO1)
anzsco1.names <- read.csv("data/anzsco1_titles.csv")
tasks.anzsco1 <- merge(x=tasks.anzsco1, y=anzsco1.names, by="ANZSCO1")[,-1]

cols <- names(tasks.anzsco2)
tasks.anzsco2 <- rbind(tasks.anzsco1[,cols], tasks.anzsco2)

save(tasks.anzsco2, file='data/tasks.anzsco2.rda')
write.csv(tasks.anzsco2, file='data/tasks.anzsco2.csv')

# The next two classifications get further merged by the COMBINEDI and COMBINEDII
# aggregate groupings.

# **** COMBINEDI classificaiton ****

combinedimap <- read.csv("data/mappings/anzsco_combinedi.csv")
# combined.i   <- merge(x=combined, y=combinedimap, by.x='ANZSCO2', by.y='ANZSCO')
combined.i   <- merge(x=tasks.anzsco2, y=combinedimap, by.x='ANZSCO2', by.y='ANZSCO')
tasks.combinedi <- to_two_digit(combined.i, .(COMBINED1))
tasks.combinedi <- scale_tasks(tasks.combinedi)
combinedi.titles <- read.csv("data/mappings/combinedi.csv")
tasks.combinedi <- merge(x=tasks.combinedi, y=combinedi.titles, by="COMBINED1")
save(tasks.combinedi, file='data/tasks.combinedi.rda')
write.csv(tasks.combinedi, file='data/tasks.combinedi.csv')

# **** COMBINEDII classification ****

combinediimap <- read.csv('data/mappings/anzsco_combinedii.csv')
combined.ii   <- merge(x=combined, y=combinediimap, by.x='ANZSCO2', by.y='ANZSCO')
tasks.combinedii <- to_two_digit(combined.ii, .(COMBINEDII))
tasks.combinedii <- scale_tasks(tasks.combinedii)
combinedii.titles <- read.csv("data/mappings/combinedii.csv")
tasks.combinedii <- merge(x=tasks.combinedii, y=combinedii.titles, by="COMBINEDII")
save(tasks.combinedii, file='data/tasks.combinedii.rda')
write.csv(tasks.combinedii, file='data/tasks.combinedii.csv')
