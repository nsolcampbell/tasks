quantile_regressions <- function(A.tasks, B.tasks, notes,
                                 title, outfile, label) {
    
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
              float.env="sidewaystable",
              column.sep.width='0pt',
              type="text", title=title,
              omit='Constant',
              out=paste0(outfile, c(".txt", ".tex")),
              label=label,
              covariate.labels=c("Information content",
                "Automation/routinization",
                "No face-to-face contact",
                "No on-site work",
                "No decision-making"))
}
