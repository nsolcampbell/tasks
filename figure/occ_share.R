library(ggplot2)
library(scales)
source('lib/plot_theme.R')
source('lib/footnote.R')
fn <- function() makeFootnote("Full-time employees. Source: ABS Cat. No. 6291.0.55.003")

open_supertable_file <- function(filename) {
	require(reshape2)
	foe <- read.delim(filename, skip=5, stringsAsFactors=F)
	foe <- foe[!names(foe) %in% c("X", "X.1", "X.2")]
	foe.a <- array(foe)
	colnames(foe.a) <- names(foe)
	foe.pc <- prop.table(foe.a, margin=1)
	foe.df <- data.frame(cbind(foe.pc, index=(1996.5 + (1:nrow(foe.pc))/4.0)))
	datatable <- melt(foe.df, id.vars="index")
	datatable$variable <- gsub(datatable$variable, pattern='\\.', replacement=' ')
	# re-level occupation for clarity
	names(datatable) <- c("quarter", "occupation", "prop")
	datatable$occupation <- 
		factor(datatable$occupation, 
					 levels=c("Managers", "Professionals", "Technicians and Trades Workers", 
										"Community and Personal Service Workers", "Clerical and Administrative Workers", 
										"Sales Workers", "Machinery Operators And Drivers", "Labourers"
									),
					 ordered=T)
	return(datatable)
}

condense <- function(tenocc) {
	require(doBy)
	require(reshape2)
	short_data <- dcast(tenocc, quarter ~ occupation, value.var='prop')
	names(short_data) <- make.names(names(short_data))
	condensed_data <- with(short_data, data.frame(quarter, 
					manprof=Managers+Professionals+Technicians.and.Trades.Workers,
					cleric =Clerical.and.Administrative.Workers+Sales.Workers,
					produc =Machinery.Operators.And.Drivers+Labourers,
					service=Community.and.Personal.Service.Workers))
	datatable <- melt(condensed_data, id.vars="quarter")
	names(datatable) <- c("quarter", "occupation", "prop")
	datatable$occupation <- recodeVar(datatable$occupation,
																		c("manprof","cleric","produc","service"),
																		c("Professional, Managerial, Technical", 
																			"Clerical, Sales",
																			"Production, Operators",
																			"Service"))
	datatable$occupation <- 
		factor(datatable$occupation, 
					 levels=c("Professional, Managerial, Technical", 
					 				 "Clerical, Sales",
					 				 "Production, Operators",
					 				 "Service"),
					 ordered=T)
	return(datatable)
}

occupation_share_charts <- function() {
	combined <- open_supertable_file("data/ft_occ_emp_quarter.txt")
	combined.c <- condense(combined)
	
	p <- ggplot(combined, aes(x=quarter, y=prop, group=occupation, color=occupation)) + 
					geom_line() +
					scale_y_continuous(labels=percent) +
					ylab("Share of Employment") +
					xlab("Quarter") +
					ggtitle("Employment Share by Broad Occupational Group") +
					theme(legend.position='right')
	
	# Compare males, females
	
	male <- open_supertable_file("data/ft_occ_emp_quarter_male.txt")
	male.c <- condense(male)
	male$sex <- "Male"; male.c$sex <- "Male"
	female <- open_supertable_file("data/ft_occ_emp_quarter_female.txt")
	female.c <- condense(female)
	female$sex <- "Female"; female.c$sex <- "Female"
	malefemale <- rbind(male, female)
	malefemale.c <- rbind(male.c, female.c)
	
	print(p)
	fn()
	print(p %+% combined.c +
		ggtitle("Employment Share by Major Occupational Group"))
	fn()
	print(p %+% malefemale + facet_grid(.~sex) +
		ggtitle("Employment Share by Broad Occupational Group, by Sex"))
	fn()
	print(p %+% malefemale.c + facet_grid(.~sex)  +
		ggtitle("Employment Share by Major Occupational Group, by Sex"))
	fn()
}

occupation_share_charts_pdf <- function(filename="figure/occ_share.pdf") {
	pdf(filename, paper="a4r", height=8, width=12)
	occupation_share_charts()
	dev.off()
}