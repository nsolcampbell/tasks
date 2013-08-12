suppressMessages(require(ggplot2))
suppressMessages(require(grid))
# A consistent, minimal theme for all plots
t <- theme_bw(15) +
    theme(plot.margin=unit(c(1,1,1,1),"cm"), 
          plot.title=element_text(size=18, vjust=2),
          axis.title.x=element_text(size=15, vjust=-0.5),
          axis.title.y=element_text(size=15, vjust=-0.25),
          strip.text=element_text(size=15),
          strip.background=element_rect(fill='white'),
          legend.position="top")
theme_set(t)
