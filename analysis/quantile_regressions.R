quantile_regressions <- function(A.tasks, B.tasks, notes, title, outfile) {
    
    A.lm <- lm(A ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work + No.Decision.Making,
                data=A.tasks, weights = Population)
    
    A.lm.nooutsrc <- lm(A ~ Automation.Routinization + No.Decision.Making,
               data=A.tasks, weights = Population)
    
    A.lm.noroutine <- lm(A ~ Information.Content + No.Face.to.Face + No.On.Site.Work,
                          data=A.tasks, weights = Population)
    
    B.lm.unweighted <- lm(B ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work + No.Decision.Making,
                          data=B.tasks)
    
    B.lm <- lm(B ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work + No.Decision.Making,
                          data=B.tasks, weights = Population)
    
    B.lm.noroutine <- lm(B ~ Information.Content + No.Face.to.Face + No.On.Site.Work,
                          data=B.tasks, weights = Population)
    
    B.lm.nooutsrc <- lm(B ~ Automation.Routinization + No.Decision.Making,
                        data=B.tasks, weights = Population)
    
    library(stargazer)
    stargazer(A.lm, A.lm.noroutine, A.lm.nooutsrc, 
              B.lm, B.lm.noroutine, B.lm.nooutsrc,
              dep.var.labels=c("A (intercepts)", "B (slopes)"),
              digits=2, notes=notes, t.auto=T,
              type="text", title=title, out=paste0(outfile, c(".txt", ".tex")))
}
