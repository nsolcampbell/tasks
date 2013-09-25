library(GGally)
library(ggplot2)
load("data/anzsco_onet.dta")

cols <- c("Information.Content", "Automation.Routinization","Face.to.Face", "On.Site.Job", "Decision.Making")
subtasks <- task_content[,cols]
names(subtasks) <- c("Information", "Automation","Face.to.Face", "Onsite", "Decisionmaking")
pdf("figure/correl.pdf", height=8, width=8)
ggpairs(subtasks, title="Correlation Plots: Derived Task Indexes")
dev.off()
