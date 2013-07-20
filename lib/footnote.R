# Function for footnoting a ggplot2 chart
# taken from 
# http://www.r-bloggers.com/r-good-practice-%E2%80%93-adding-footnotes-to-graphics/
makeFootnote <- function(footnoteText=
                             format(Sys.time(), "%d %b %Y"),
                         size= .7, color= grey(.5))
{
    suppressMessages(require(grid))
    pushViewport(viewport())
    grid.text(label= footnoteText ,
              x = unit(1,"npc") - unit(2, "mm"),
              y= unit(2, "mm"),
              just=c("right", "bottom"),
              gp=gpar(cex= size, col=color))
    popViewport()
}
