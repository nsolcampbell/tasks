for (measure in c("importance","level")) {
pdf(paste("dendro_",measure,".pdf",sep=""), height=12, width=8)
for (file in c("skill", "ability", "knowledge", "work_activity")) {
	ability <- read.csv(paste("../data/onet/tables/",file,"_",measure,".csv", sep=""))
	rownames(ability) <- ability[,"Title"]
	ability <- ability[,c(-1,-2)]
	
	for (seed in 1:2) {
		set.seed(seed)
		subset <- sample(1:nrow(ability), size=30)
		ability_sub <- ability[subset,]
		distxy <- dist(ability_sub)
		hClustering <- hclust(distxy, "average")
		#dhc <- as.dendrogram(hClustering)
		# Rectangular lines
		#ddata <- dendro_data(dhc, type="rectangle")
		
		plot(hClustering, hang=0.1, 
			main=paste("30 O*NET occupations clustered by", file,measure), 
			cex.lab=0.5, cex=0.5)
		mtext(paste("Randomly sampled with seed =",seed))
	}
}
dev.off()
}

#library(devtools)
#install_github("ggbiplot", "vqv")

library(ggbiplot)
library(ggplot2)

pdf("pca.pdf", height=18, width=24, paper="a4r")
for (measure in c("importance","level")) {
skill <- read.csv(paste("../data/onet/tables/work_activity_", measure, ".csv", sep=""))
rownames(skill) <- skill[,2]
skill <- skill[,c(-1,-2)]
skill.pca <- prcomp(skill, scale. = TRUE)
#g <- ggbiplot(skill.pca, obs.scale = 1, var.scale = 1, 
#              ellipse = TRUE, circle = TRUE) #groups = skill.class, 
g <- ggbiplot(skill.pca, obs.scale=1, var.scale=1, alpha=0.1)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
              legend.position = 'top') +
              ggtitle("PCA: Worker Activity Level")
print(g + theme_bw())
}
dev.off()

pdf("heatmap.pdf",height=24,width=16)
heatmap(as.matrix(skill[sample(1:nrow(skill), 100),]))
dev.off()