# Hierarchical clustering of worker activities

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
		
		plot(hClustering, hang=0.1, 
			main=paste("30 O*NET occupations clustered by", file,measure), 
			cex.lab=0.5, cex=0.5)
		mtext(paste("Randomly sampled with seed =",seed))
	}
}
dev.off()
}

