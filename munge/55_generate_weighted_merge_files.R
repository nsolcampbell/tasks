rm(list=ls())
# this script creates reference data for STATA implementations of RIF regressions

# we take the weighted task measures for each grouping scheme, 
# and then do a cartesian product with the ANZSCO mapping

# COMBINED 1 mapping
load("data/tasks.combinedi.rda")
# map to CCLO (1981-82)
map.i <- read.csv("data/mappings/cclo_combinedi.csv")
merged.i <- merge(x=tasks.combinedi, y=map.i, by="COMBINED1")
cols.i <- c("CCLO", "COMBINED1", "Information.Content", "Automation.Routinization", 
            "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making", "Population", 
            "COMBINED1.Title")
write.csv(merged.i[,cols.i], file="data/mappings/tasks_mapped_cclo_i.csv")

map.i <- read.csv("data/mappings/anzsco_combinedi.csv")
merged.i <- merge(x=tasks.combinedi, y=map.i, by="COMBINED1")
cols.i <- c("ANZSCO", "COMBINED1", "Information.Content", "Automation.Routinization",
          "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making", "Population", "Title")
write.csv(merged.i[,cols.i], file="data/mappings/tasks_mapped_anzsco_i.csv")

# ### COMBINED II mapping ###

load("data/tasks.combinedii.rda")
# map to ASCOII (2000-1)
map.ii <- read.csv("data/mappings/ascoii_combinedii.csv")
merged.ii <- merge(map.ii, tasks.combinedii)
cols.ii <- c("ASCO2", "COMBINEDII", "Information.Content", 
             "Automation.Routinization", "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making", 
             "Population", "CombinedII.Title")
write.csv(merged.ii[,cols.ii], file="data/mappings/tasks_mapped_ascoii_ii.csv")

# map to ANZSCO (2009-10)
# and overwrite existing variables
map.ii <- read.csv("data/mappings/anzsco_combinedii.csv")
merged.ii <- merge(x=tasks.combinedii, y=map.ii, by="COMBINEDII")
cols.ii <- c("ANZSCO", "COMBINEDII", "Information.Content", "Automation.Routinization", 
             "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making", "Population", 
             "CombinedII.Title")
write.csv(merged.ii[,cols.ii], file="data/mappings/tasks_mapped_anzsco_ii.csv")

print("*** these files should be further processed by running make_do.py")
