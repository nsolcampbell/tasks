load(file='data/combined.2dig.rda')

library(MASS)

lbls <- c("Information Content",
          "Routinization", "Face-to-Face",
          "On-Site Job", "Decision Making")

c2d <- as.matrix(combined.2dig[-1])
colnames(c2d) <- lbls

pdf('figure/parallel_2dig.pdf', width=8, height=6)
parcoord(c2d, 
         main="Parallel Coordinates: Occupational Task Measures"
         )
dev.off()
