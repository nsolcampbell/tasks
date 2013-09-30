library(plyr)

census <- read.csv("data/census_4dig_FT_2011.csv")
census$Total = with(census, Employees+Employees+Unincorporated+ContribFamily+Not.Stated)

anzsco_onet <- read.csv("data/anzsco_onet_combined.csv")
combined <- merge(x=census, y=anzsco_onet, by.x='ANZSCO', by.y='ANZSCO4')

combined.2dig <- ddply(combined, .(ANZSCO2), summarise, 
                       Information.Content=weighted.mean(Information.Content, Total),
                       Automation.Routinization=weighted.mean(Automation.Routinization, Total),
                       Face.to.Face=weighted.mean(Face.to.Face, Total),
                       On.Site.Job=weighted.mean(On.Site.Job, Total),
                       Decision.Making=weighted.mean(Decision.Making, Total))

save(combined.2dig, file='data/combined.2dig.rda')
