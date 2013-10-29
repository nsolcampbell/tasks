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

load("data/anzsco_onet.rda")
measures <- c("Information.Content", "Automation.Routinization", 
                                  "No.Face.to.Face", "No.On.Site.Work", "No.Decision.Making")
anzsco_onet.4 <- anzsco_onet[,c("ANZSCO4", measures)]
anzsco_onet.4$ANZSCO <- anzsco_onet.4$ANZSCO4
census.merged.4 <- merge(x=census, y=anzsco_onet.4, by="ANZSCO")

anzsco_onet.3 <- anzsco_onet[,c("ANZSCO3", measures)]
anzsco_onet.3$ANZSCO <- as.numeric(anzsco_onet.3$ANZSCO3) * 10
census.merged.3 <- merge(x=census, y=anzsco_onet.3, by="ANZSCO")

anzsco_onet.2 <- anzsco_onet[,c("ANZSCO2", measures)]
anzsco_onet.2$ANZSCO <- as.numeric(anzsco_onet.2$ANZSCO2) * 100
census.merged.2 <- merge(x=census, y=anzsco_onet.2, by="ANZSCO")

anzsco_onet.1 <- anzsco_onet[,c("ANZSCO1", measures)]
anzsco_onet.1$ANZSCO <- as.numeric(anzsco_onet.1$ANZSCO1) * 1000
census.merged.1 <- merge(x=census, y=anzsco_onet.1, by="ANZSCO")

anzsco_onet.merged <- rbind(anzsco_onet.1[,-1], 
                             anzsco_onet.2[,-1], 
                             anzsco_onet.3[,-1], 
                             anzsco_onet.4[,-1])
census.merged <- merge(anzsco_onet.merged, census.inc)
tasks <- ddply(census.merged, .(ANZSCO), summarise, 
               Information.Content = mean(Information.Content),
               Automation.Routinization = mean(Automation.Routinization),
               No.Face.to.Face = mean(No.Face.to.Face),
               No.On.Site.Work = mean(No.On.Site.Work),
               No.Decision.Making = mean(No.Decision.Making),
               total = sum(total),
               pop = sum(pop)
               )
tasks$mean <- with(tasks, total/pop)
tasks$weight <- with(tasks, pop / sum(tasks$pop))

keep.cols <- c("mean", 'pop', 'weight', measures)
tasks.long <- melt(tasks[,keep.cols], 
                   id.vars=c('mean', 'pop', 'weight'),
                   value.name='value',
                   variable.name='index')
tasks.long$lpop <- with(tasks.long, log(pop))

# where to draw the vertical line for minimum wage
min.wage <- 589.30

pdf("figure/wages_indexes_4digit.pdf", height=12, width=8)
ggplot(tasks.long, aes(x=mean, y=value, group=index, weight=weight)) + 
    geom_point(shape='o',alpha=0.5, aes(size=lpop*4)) +
    geom_smooth(method='loess',fill=NA) +
    facet_wrap(~index, ncol=2, nrow=3) +
    scale_x_log10(breaks=c(0.5,1,2,3,4)*1000) +
    geom_vline(x=min.wage, linetype='dashed') +
    xlab("Occupational group weekly mean wage (log scale)") +
    ylab("Index value") +
    ggtitle("Task Indexes and Mean Reported Weekly Wages, 2011 Census") +
    theme(legend.position='none')
makeFootnote('Full-time workers. Source: ABS cat no 2072.0')
dev.off()
