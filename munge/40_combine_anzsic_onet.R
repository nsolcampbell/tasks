# weight the O*NET mappings onto ANZSCO two- and three-digit codes
require(reshape2)

# Scales with "frequency" are given by their coded value, multiplied by
# their frequency coded value. This is totally arbitrary, but follows
# JK and FFL.
load.frequency <- function(filename) {
    longfmt <- read.delim(filename, stringsAsFactors=F, na.strings="n/a")
    # Approach: filter only the measurement fields, then merge.
    # Note these are in long format.
    longfmt <- longfmt[,c("O.NET.SOC.Code", "Element.Name", "Scale.ID", "Category", "Data.Value")]
    colnames(longfmt) <- c('onet','element','scale','cat','value')
    longfmt$fv <- with(longfmt, cat * value)
    wformat <- acast(subset(longfmt, scale %in% c('CXP')), onet ~ scale ~ element, value.var='fv', fun.aggregate=mean)
    # make sure names are syntactically valid
    dimnames(wformat)[[3]] <- make.names(dimnames(wformat)[[3]])
    freq <- data.frame(wformat[,"CXP",])
    
    # scale each column, to ensure equal weight
    maxes <- apply(freq, MARGIN=2, FUN="max")
    #mins  <- apply(freq, MARGIN=2, FUN="min")
    scaled <- data.frame(sweep(freq,MARGIN=2,maxes,`/`))
    
    return(list(scaled_values=scaled, elements=unique(longfmt$element)))
}

# Levels and importance are scaled by the arbitrary Cobb-Douglas weights
# of 1/3 and 2/3, respectively. Again, this follows FFL and JK.
load.level.importance <- function(filename) {
    longfmt <- read.delim(filename, stringsAsFactors=F)
    # Approach: filter only the measurement fields, then merge.
    # Note these are in long format.
    longfmt <- longfmt[,c("O.NET.SOC.Code", "Element.Name", "Scale.ID", "Data.Value")]
    colnames(longfmt) <- c('onet','element','scale','value')
    wformat <- acast(longfmt, onet ~ scale ~ element, value.var='value')
    # make sure names are syntactically valid
    dimnames(wformat)[[3]] <- make.names(dimnames(wformat)[[3]])
    levels <- data.frame(wformat[,"LV",])
    imptce <- data.frame(wformat[,"IM",])
    combined <- imptce^(2/3)*levels^(1/3)
    
    # scale each column, to ensure equal weight
    maxes <- apply(combined, MARGIN=2, FUN="max")
    scaled <- data.frame(sweep(combined,MARGIN=2,maxes,`/`))
    
    return(list(scaled_values=scaled, elements=unique(longfmt$element)))
}


# First load and merge ONET abilities, knowledge and work activities
abilities <- load.level.importance("data/onet/db_17_0/Abilities.txt")
knowledge <- load.level.importance("data/onet/db_17_0/Knowledge.txt")
tasks     <- load.level.importance("data/onet/db_17_0/Work Activities.txt")
context   <- load.frequency('data/onet/db_17_0/Work Context.txt')

# Context is missing some (very rare) values. We'll plug with zeros.
dummy_index <- data.frame(onet=rownames(tasks$scaled_values))
context$scaled_values$onet <- rownames(context$scaled_values)
context.all <- merge(x=dummy_index, y=context$scaled_values, by="onet", all.x=T)

context.all <- context.all[,-which(colnames(context.all) == "onet")]

all_scales = cbind(abilities$scaled_values, knowledge$scaled_values, tasks$scaled_values, context.all)
all_scales <- data.frame(apply(all_scales, 2, function(x){replace(x, is.na(x), 0)}))

# Combine; note each one is on a scale 0-1
onet_tasks <- with(all_scales,
             data.frame(
                    ONET = rownames(all_scales),
                    Information.Content =
                       (Getting.Information +
                        Processing.Information +
                        Analyzing.Data.or.Information +
                        Interacting.With.Computers +
                        Documenting.Recording.Information) / 5,
                    Automation.Routinization = 
                       (Degree.of.Automation +
                        Importance.of.Repeating.Same.Tasks +
                        (1- Structured.versus.Unstructured.Work) +
                        Pace.Determined.by.Speed.of.Equipment +
                        Spend.Time.Making.Repetitive.Motions) / 5,
                   Face.to.Face =
                       (Face.to.Face.Discussions +
                        Establishing.and.Maintaining.Interpersonal.Relationships +
                        Assisting.and.Caring.for.Others +
                        Performing.for.or.Working.Directly.with.the.Public +
                        Coaching.and.Developing.Others) / 5,
                   On.Site.Job =
                       (Inspecting.Equipment..Structures..or.Material +
                        Handling.and.Moving.Objects +
                        Controlling.Machines.and.Processes +
                        Operating.Vehicles..Mechanized.Devices..or.Equipment +
                        Repairing.and.Maintaining.Electronic.Equipment * 0.5 +
                        Repairing.and.Maintaining.Mechanical.Equipment * 0.5) / 5,
                   Decision.Making = 
                       (Making.Decisions.and.Solving.Problems + 
                        Thinking.Creatively +
                        Developing.Objectives.and.Strategies +
                        Responsibility.for.Outcomes.and.Results +
                        Frequency.of.Decision.Making) / 5
              )
         )

# for simplicity, we'll weight at 4-digit level, irrespective of industry
map <- read.csv("data/anzsco4_onet.csv", stringsAsFactors=F)

# drop all but the ONET mapping used for tasks (not the closest in meaning)
map <- map[,c("ANZSCO4","Title","Alt.ONET","Alt.ONET.Title")]
names(map) <- c("ANZSCO4","Title","ONET","ONET.Title")

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

task_content <- merge(x=map, y=onet_tasks, by="ONET")

ability_list=abilities$elements
task_list=tasks$elements
knowledge_list=knowledge$elements
context_list=context$elements

save(task_content, 
     ability_list, 
     task_list, 
     knowledge_list, 
     context_list,
     file="data/anzsco_onet.dta")

# also write out CSV copies for easy access
write.csv(task_content, 'data/anzsco_onet_combined.csv')
