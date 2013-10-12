rm(list=ls())
library(plyr)
library(reshape2)
library(ggplot2)
source('lib/plot_theme.R')
source('lib/footnote.R')

cols <- c("ANZSCO", "X1.199", "X200.299", "X300.399", 
          "X400.599", "X600.799", "X800.999", "X1000.1249", "X1250.1500", 
          "X1500.1999", "X2000")

census <- read.csv("data/census_4dig_FT_2011.csv")[,cols]
inc.weights <- matrix(c(100, 250, 350, 500, 700, 900, 1125, 1375, 1750, 2800))
sum.weights <- matrix(rep(1,10))
census.inc <- data.frame(ANZSCO=census$ANZSCO, 
                         total=as.matrix(census[,-1]) %*% inc.weights,
                         pop=as.matrix(census[,-1]) %*% sum.weights)

load("data/anzsco_onet.dta")
task_content.4 <- task_content[,c("ANZSCO4", "Information.Content", "Automation.Routinization", 
                                  "Face.to.Face", "On.Site.Job", "Decision.Making")]
task_content.4$ANZSCO <- task_content.4$ANZSCO4
census.merged.4 <- merge(x=census, y=task_content.4, by="ANZSCO")

task_content.3 <- task_content[,c("ANZSCO3", "Information.Content", "Automation.Routinization", 
                                  "Face.to.Face", "On.Site.Job", "Decision.Making")]
task_content.3$ANZSCO <- as.numeric(task_content.3$ANZSCO3) * 10
census.merged.3 <- merge(x=census, y=task_content.3, by="ANZSCO")

task_content.2 <- task_content[,c("ANZSCO2", "Information.Content", "Automation.Routinization", 
                                  "Face.to.Face", "On.Site.Job", "Decision.Making")]
task_content.2$ANZSCO <- as.numeric(task_content.2$ANZSCO2) * 100
census.merged.2 <- merge(x=census, y=task_content.2, by="ANZSCO")

task_content.1 <- task_content[,c("ANZSCO1", "Information.Content", "Automation.Routinization", 
                                  "Face.to.Face", "On.Site.Job", "Decision.Making")]
task_content.1$ANZSCO <- as.numeric(task_content.1$ANZSCO1) * 1000
census.merged.1 <- merge(x=census, y=task_content.1, by="ANZSCO")

task_content.merged <- rbind(task_content.1[,-1], 
                             task_content.2[,-1], 
                             task_content.3[,-1], 
                             task_content.4[,-1])
census.merged <- merge(task_content.merged, census.inc)
tasks <- ddply(census.merged, .(ANZSCO), summarise, 
               Information.Content = mean(Information.Content),
               Automation.Routinization = mean(Automation.Routinization),
               Face.to.Face = mean(Face.to.Face),
               On.Site.Job = mean(On.Site.Job),
               Decision.Making = mean(Decision.Making),
               total = sum(total),
               pop = sum(pop)
               )
tasks$mean <- with(tasks, total/pop)
tasks$weight <- with(tasks, pop / sum(tasks$pop))

keep.cols <- c("mean", 'pop', 'weight',
               "Information.Content", "Automation.Routinization", 
               "Face.to.Face", "On.Site.Job", "Decision.Making"
               )
tasks.long <- melt(tasks[,keep.cols], 
                   id.vars=c('mean', 'pop', 'weight'),
                   value.name='value',
                   variable.name='index')
tasks.long$lpop <- with(tasks.long, log(pop))

pdf("figure/wages_indexes_4digit.pdf", height=8, width=12)
ggplot(tasks.long, aes(x=mean, y=value, group=index, weight=weight)) + 
    geom_point(shape='o',alpha=0.5, aes(size=lpop*4)) +
    geom_smooth(method='loess',fill=NA) +
    facet_wrap(~index) +
    scale_x_log10(breaks=c(0.5,1,2,3,4)*1000) +
    geom_hline(y=0, alpha=0.3) +
    xlab("Occupational group weekly mean wage (log scale)") +
    ylab("Index value") +
    ggtitle("Task Indexes and Mean Reported Weekly Wages, 2011 Census") +
    theme(legend.position='none')
makeFootnote('Full-time workers. Source: ABS cat no 2072.0')
dev.off()
