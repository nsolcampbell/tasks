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

combined <- open_supertable_file("data/ft_occ_emp_quarter.txt")
p <- ggplot(combined, aes(x=quarter, y=prop, group=occupation, color=occupation)) + 
				geom_line() +
				scale_y_continuous(labels=percent) +
				ylab("Share of Employment") +
				xlab("Quarter") +
				ggtitle("Employment Share by Broad Occupational Group") +
				theme(legend.position='right')

# Compare males, females

male <- open_supertable_file("data/ft_occ_emp_quarter_male.txt")
male$sex <- "Male"
female <- open_supertable_file("data/ft_occ_emp_quarter_female.txt")
female$sex <- "Female"
malefemale <- rbind(male, female)

pdf("figure/occ_share.pdf", paper="a4r", height=8, width=12)
	p
	fn()
	p %+% malefemale + facet_grid(.~sex)
	fn()
dev.off()
