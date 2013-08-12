library(ggbiplot)
library(ggplot2)
source("lib/plot_theme.R")

load("data/anzsco_onet.dta")

# these columns are the "Work Activities"
task_cols <- which(colnames(levels) %in% make.names(task_list))

levels$Title1 <- substr(levels$Title1, 1, 25)

# work activites are columns 55:79
# levels has 135 columns, 10 of which have header information
levels.pca <- prcomp(levels[,task_cols], scale. = TRUE, center = T)

pdf("explore/prcomp_1digit.pdf", paper="a4r", height=8, width=16)
for (show_axes in c(T, F)) {
    g <- ggbiplot(levels.pca, obs.scale = 1, var.scale = 1, alpha = 0.5, 
                  groups = as.factor(levels$Title1), ellipse=!show_axes, var.axes=show_axes)
    g <- g + scale_color_discrete(name = "")
    g <- g + theme_bw(10) + theme(legend.position = "top") + 
        ggtitle("O*NET Work Activity: first 2 principal components\n4-digit ANZSCO occupations, grouped by 1-digit classification")
    print(g)
}
dev.off()
