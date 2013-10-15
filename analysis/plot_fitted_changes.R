plot_fitted_changes<- function(A.tasks, B.tasks, notes, title, outfile) {

    A.lm <- lm(A ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work, #+ No.Decision.Making,
                data=A.tasks, weights = Population)
    
    B.lm <- lm(B ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work, #+ No.Decision.Making,
                          data=B.tasks, weights = Population)

    B.tasks2 <- B.tasks[B.tasks$Title != 'Teachers',]
    B.lm2 <- lm(B ~ Information.Content + Automation.Routinization + No.Face.to.Face + No.On.Site.Work + No.Decision.Making,
                          data=B.tasks2, weights = Population)

    stargazer(A.lm, B.lm, B.lm2, type='text')
    
    combo = data.frame(title=A.tasks$Title, base=A.tasks$A, slope=B.tasks$B, diff=t(diff_w[5,-1]))
    names(combo)[4] <- 'diff'
    combo$intercept <- with(combo, diff-base*slope)
    
    ggplot(combo, aes(x=base, y=diff, label=title)) +
      geom_point() +
      geom_abline(aes(intercept=intercept, slope=slope))

    plot(y=B.tasks$B, x=B.tasks$Automation.Routinization, data=B.tasks) #+ geom_text(aes(label=Title))
    abline(B.lm)
}
