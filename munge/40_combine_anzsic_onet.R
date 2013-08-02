# weight the O*NET mappings onto ANZSCO two- and three-digit codes
require(reshape2)

# First load and merge ONET abilities, knowledge and work activities

abilities <- read.delim("data/onet/csv/Abilities.txt", stringsAsFactors=F)
knowledge <- read.delim("data/onet/csv/Knowledge.txt", stringsAsFactors=F)
tasks     <- read.delim("data/onet/csv/Work Activities.txt", stringsAsFactors=F)

# Approach: filter only the measurement fields, then merge.
# Note these are in long format.
cols      <- c("O.NET.SOC.Code", "Element.Name", "Scale.ID", "Data.Value")
merged_l  <- rbind(abilities[,cols], knowledge[,cols], tasks[,cols])
colnames(merged_l) <- c('onet','element','scale','value')
import_l  <- subset(merged_l, scale == 'IM')
level_l   <- subset(merged_l, scale == 'LV')
merged_w <- acast(merged_l, onet ~ scale ~ element, value.var='value')
# make sure names are syntactically valid
dimnames(merged_w)[[3]] <- make.names(dimnames(merged_w)[[3]])
levels <- data.frame(merged_w[,"LV",])
levels$onet <- rownames(levels)
imptce <- data.frame(merged_w[,"IM",])
imptce$onet <- rownames(imptce)

# for simplicity, we'll weight irrespective of industry
map <- read.csv("data/anzsco4_onet.csv", stringsAsFactors=F)

# now include 1, 2 and 3 digit codes, and merge in titles
map$ANZSCO1 <- substr(map$ANZSCO4, 1, 1)
map$ANZSCO2 <- substr(map$ANZSCO4, 1, 2)
map$ANZSCO3 <- substr(map$ANZSCO4, 1, 3)

titles1 <- read.csv("data/anzsco1_titles.csv", stringsAsFactors=F,
                    col.names=c("ANZSCO1","Title1"))
titles2 <- read.csv("data/anzsco2_titles.csv", stringsAsFactors=F,
                    col.names=c("ANZSCO2","Title2"))
titles3 <- read.csv("data/anzsco3_titles.csv", stringsAsFactors=F,
                    col.names=c("ANZSCO3","Title3"))

map <- merge(x=map, y=titles1, by='ANZSCO1')
map <- merge(x=map, y=titles2, by='ANZSCO2')
map <- merge(x=map, y=titles3, by='ANZSCO3')

# and finally, merge onet data over the ANZSCO classifications

imptce <- merge(x=map, y=imptce, by.x="ONET", by.y="onet")
levels <- merge(x=map, y=levels, by.x="ONET", by.y="onet")

save(imptce, levels, file="data/anzsco_onet.dta")

# also write out CSV copies for easy access
write.csv(imptce, 'data/anzsic_ability_knowledge_work_activity-importance.csv')
write.csv(levels, 'data/anzsic_ability_knowledge_work_activity-levels.csv')
