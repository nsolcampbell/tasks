pdf("dendro.pdf", height=12, width=8)
for (file in c("skills", "ability", "knowledge")) {
	ability <- read.csv(paste("../data/",file,".csv", sep=""))
	rownames(ability) <- ability[,"Title"]
	ability <- ability[,c(-1,-2)]
	
	for (seed in 1:2) {
		set.seed(seed)
		subset <- sample(1:nrow(ability), size=30)
		ability_sub <- ability[subset,]
		distxy <- dist(ability_sub)
		hClustering <- hclust(distxy, "average")
		dhc <- as.dendrogram(hClustering)
		# Rectangular lines
		ddata <- dendro_data(dhc, type="rectangle")
		
		plot(hClustering, hang=0.1, 
			main=paste("30 O*NET occupations clustered by", file), 
			cex.lab=0.5, cex=0.5)
		mtext(paste("Randomly sampled with seed =",seed))
	}
}
dev.off()

#library(devtools)
#install_github("ggbiplot", "vqv")

library(ggbiplot)
data(wine)
wine.pca <- prcomp(wine, scale. = TRUE)
g <- ggbiplot(wine.pca, obs.scale = 1, var.scale = 1, 
              groups = wine.class, ellipse = TRUE, circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + opts(legend.direction = 'horizontal', 
              legend.position = 'top')
print(g)



#pdf("pca.pdf")
skill <- read.csv("../data/knowledge.csv")
rownames(skill) <- skill[,2]
skill <- skill[,c(-1,-2)]
skill.pca <- prcomp(skill, scale. = TRUE)
#g <- ggbiplot(skill.pca, obs.scale = 1, var.scale = 1, 
#              ellipse = TRUE, circle = TRUE) #groups = skill.class, 
g <- ggbiplot(skill.pca, obs.scale=1, alpha=0.1)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
              legend.position = 'top')
print(g + theme_bw())
#dev.off()

pdf("heatmap.pdf",height=24,width=16)
heatmap(as.matrix(skill[sample(1:nrow(skill), 100),]))
dev.off()