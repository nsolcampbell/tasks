model <- fit

glm.sumSquares <- function (model) 
{
    tANOVA = Anova(model, type = 3)
    nEffects = nrow(tANOVA) - 1
    tSS = matrix(NA, nEffects + 2, 5) # was 6
    rownames(tSS) = c(row.names(tANOVA)[1:(nEffects)], "Error (SSE)", 
                      "Total (SST)")
    colnames(tSS) = c("SS", "dR-sqr", "pEta-sqr", "df", "F", 
                      "p-value")
    colnames(tSS) = c("SS", "dR-sqr", "pEta-sqr", "df", "F")
#                       "p-value")
    SSE = sum(model$residuals^2)
    tSS[nEffects + 1, 1] = SSE
    SST = sum((model$model[, 1] - mean(model$model[, 1]))^2)
    tSS[nEffects + 2, 1] = SST
    tSS[1:nEffects, 1] = tANOVA[1:nEffects, 1]
    tSS[1:nEffects, 2] = round(tSS[1:nEffects, 1]/SST, 4)
#     tSS[1:nEffects, 3] = round(tSS[1:nEffects, 1]/(SSE + tSS[1:nEffects, 
#                                                              1]), 4)
#     tSS[1:(nEffects + 1), 4] = tANOVA[1:(nEffects + 1), 2]
#     tSS[1:nEffects, 5] = round(tANOVA[1:nEffects, 3], 4)
#     tSS[1:nEffects, 6] = round(tANOVA[1:nEffects, 4], 4)
    return(tSS)
}