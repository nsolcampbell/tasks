quantile_regressions <- function(A.tasks, B.tasks, notes, title, outfile) {
    
    A.lm <- lm(A ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
                data=A.tasks, weights = Population)
    
    A.lm.nooutsrc <- lm(A ~ Automation.Routinization + Decision.Making,
               data=A.tasks, weights = Population)
    
    A.lm.noroutine <- lm(A ~ Information.Content + Face.to.Face + On.Site.Job,
                          data=A.tasks, weights = Population)
    
    B.lm.unweighted <- lm(B ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
                          data=B.tasks)
    
    B.lm <- lm(B ~ Information.Content + Automation.Routinization + Face.to.Face + On.Site.Job + Decision.Making,
                          data=B.tasks, weights = Population)
    
    B.lm.noroutine <- lm(B ~ Information.Content + Face.to.Face + On.Site.Job,
                          data=B.tasks, weights = Population)
    
    B.lm.nooutsrc <- lm(B ~ Automation.Routinization + Decision.Making,
                        data=B.tasks, weights = Population)
    
    library(stargazer)
    stargazer(A.lm, A.lm.noroutine, A.lm.nooutsrc, 
              B.lm, B.lm.noroutine, B.lm.nooutsrc,
              dep.var.labels=c("A (intercepts)", "B (slopes)"),
              digits=2, notes=notes, t.auto=T,
              type="text", title=title, out=paste0(outfile, c(".txt", ".tex")))
}
