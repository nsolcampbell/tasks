rm(list=ls())

load('data/anzsco_onet_all.rda')
all_scales_m <- as.matrix(all_scales[,names(all_scales) != 'ONET'])
pc <- princomp(all_scales_m, cor=T) # similar o's of magnitude, no scaling
