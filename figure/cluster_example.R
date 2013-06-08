# Hierarchical clustering of worker activities

ability <- read.delim(paste("../doc/wa_lvl_example.csv"))
rownames(ability) <- ability[,"Title"]
ability <- ability[,c(-1)]

set.seed(1)
distxy <- dist(ability)
hClustering <- hclust(distxy, "average")

pdf("../doc/slides/example_cluster.pdf", height=2.8, width=4.2)
	par(mar=c(0,0,0,0))
	plot(as.dendrogram(hClustering, hang=0.1, cex=2), horiz=T, 
#		main="Example O*NET occupations clustered by Work Activity", 
		cex.lab=5, cex=5)
#	mtext(paste("Randomly sampled with seed =",seed))
dev.off()

par(mar=c(10,10,10,10))
heatmap(as.matrix(ability), cexRow=1, cexCol=1, margins=c(10,10))

#library(devtools)
#install_github("ggbiplot", "vqv")

library(ggbiplot)

pdf("../doc/slides/pca_example.pdf", height=6, width=12, paper="a4r")
par(mar=c(0,0,0,0))
skill.pca <- prcomp(ability, scale. = TRUE)
kmeans <- kmeans(ability, centers=2)
variables <- c("Gather Data", "Analyze", "Creative", "Moving Objects", "Influence")
rownames(skill.pca$rotation) <- variables
g <- ggbiplot(skill.pca, obs.scale=1, var.scale=1, 
 			  alpha=1, scale=1,
		 	  groups = as.factor(kmeans$cluster),
		 	  labels = rownames(skill.pca$x),
		 	    labels.size=5,
		 	    ellipse=T)
g <- g + scale_color_discrete(name = '') 
#g <- g + geom_text(data=labeldata, aes(x=PC1,y=PC2, label=label))
g <- g + theme_bw() + theme(#legend.direction = 'horizontal', 
              legend.position = 'none') +
              ggtitle("PCA: Worker Activity Level")
print(g)
dev.off()
