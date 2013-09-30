library(plyr)

census <- read.csv("data/census_4dig_FT_2011.csv")
census$Total = with(census, Employees+Employees+Unincorporated+ContribFamily+Not.Stated)

# **** 2-digit ANZSCO classification ****
anzsco_onet <- read.csv("data/anzsco_onet_combined.csv")
combined <- merge(x=census, y=anzsco_onet, by.x='ANZSCO', by.y='ANZSCO4')

to_two_digit <- function(four_digit, col) {
    ddply(four_digit, col, summarise, 
          Information.Content=weighted.mean(Information.Content, Total),
          Automation.Routinization=weighted.mean(Automation.Routinization, Total),
          Face.to.Face=weighted.mean(Face.to.Face, Total),
          On.Site.Job=weighted.mean(On.Site.Job, Total),
          Decision.Making=weighted.mean(Decision.Making, Total))
}

# normalize columns to unit standard deviation and zero mean
scale_tasks <- function(task_measures) {
    cols <- c("Information.Content", "Automation.Routinization",
                "Face.to.Face", "On.Site.Job", "Decision.Making")
    for (col in cols) {
        xbar <- mean(task_measures[,col])
        s    <- sd(task_measures[,col])
        task_measures[,col] <- (task_measures[,col] - xbar) / s
    }
    return(task_measures)
}

tasks.anzsco2 <- to_two_digit(combined, .(ANZSCO2))
tasks.anzsco2 <- scale_tasks(tasks.anzsco2)
anzsco2.names <- read.csv("data/anzsco2_titles.csv")
tasks.anzsco2 <- merge(x=tasks.anzsco2, y=anzsco2.names, by="ANZSCO2")
save(tasks.anzsco2, file='data/tasks.anzsco2.rda')
write.csv(tasks.anzsco2, file='data/tasks.anzsco2.csv')

# The next two classifications get further merged by the COMBINEDI and COMBINEDII
# aggregate groupings.

# **** COMBINEDI classificaiton ****

combinedimap <- read.csv("data/mappings/anzsco_combinedi.csv")
combined.i   <- merge(x=combined, y=combinedimap, by.x='ANZSCO2', by.y='ANZSCO')
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
