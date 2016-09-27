###### Making PRIMER formated data from EventMeasure queries ######

### Written by Tim Langlois 
### Any errors are due to Tim Langlois
### Please forward any updates and improvements to timothy.langlois@uwa.edu.au

# The following code forms an appendix to the manuscript:
#  "McLean et al. 2016. Distribution, Abundance, Diversity and Habitat Associations of Fishes across a Bioregion Experiencing Rapid Coastal Development.” Estuarine, Coastal and Shelf Science 178 (September): 36–47"
# Please cite it if you like it



### objective is to 

# 1. Format data to PRIMER format - with samples as Rows and Species as coloums
# 2. With Factors, to the right, and Indicators, below, seperated by blank columns and rows respectively.
# 3. This is really hard to do in R!


# Naming conventions----
# data objects in lower case
# column names Capitalized



# Libraries required
detach("package:plyr", unload=TRUE)#will error - no worries
library(tidyr)
library(dplyr)
options(dplyr.width = Inf) #enables head() to display all coloums
library(ggplot2)
library(readxl)
library(googlesheets)


# Set directories----
rm(list=ls())
study<-"x_Example_BRUV"

# Add you work dir here-
# work.dir=("C:/Tims Documents/ownCloud/GitHub_Example")
work.dir=("~/ownCloud/GitHub_Example")


tidy.data=paste(work.dir,"Data/Tidy data",sep="/")
primer.data=paste(work.dir,"Data/PRIMER data",sep="/")


# Functions----
# For PRIMER - Append blank column to distiguish Factors--
append_col <- function(x, cols, after=length(x)) {
  x <- as.data.frame(x)
  if (is.character(after)) {
    ind <- which(colnames(x) == after)
    if (any(is.null(ind))) stop(after, "not found in colnames(x)\n")
  } else if (is.numeric(after)) {
    ind <- after
  }
  stopifnot(all(ind <= ncol(x)))
  cbind(x, cols)[, append(1:ncol(x), ncol(x) + 1:length(cols), after=ind)]
}


# Bring in the long data - with habitat-----
setwd(tidy.data)
dir()
primer.species<-read.csv("x_Example_BRUV_combined.factors.habitat.csv")%>%
  filter(Group=="Species")%>%
  group_by(Taxa,Sample) %>%
  summarise(Abundance = sum(Value))%>%
  spread(Taxa,Abundance, fill = 0)%>%
  select(-Total, -Rich, everything())

head(primer.species)


primer.species.factors.habitat<-read.csv("x_Example_BRUV_combined.factors.habitat.csv")%>%
  select(-Taxa,-Value,-Group,-Measure)%>%
  distinct()%>%
  left_join(primer.species,.,,by="Sample")%>%
  append_col(., list(blank=NA), after="Total")
head(primer.species.factors.habitat)


# Bring in the Indicators - Family/Feeding to put below the data----
gs_ls()
Life_history <- gs_title("Life_history")#register a sheet
history<-Life_history%>%
  gs_read_csv(ws = "Life_history")%>%
  filter(grepl('Australia', Global.region))%>%
  filter(grepl('Ningaloo|Pilbara', Local.region))%>%
  select(Genus_species,Family,Feeding.guild,Targeted)
head(history,7)


# Make the Indicators----
indicators<-read.csv("x_Example_BRUV_combined.factors.habitat.csv")%>%
  filter(Group=="Species")%>%
  select(Taxa)%>%
  distinct()%>%
  left_join(history,by=c("Taxa"="Genus_species"))
head(indicators)

indicators.t<-setNames(data.frame(t(indicators[,-1])),indicators[,1])%>%
  add_rownames("Sample")
head(indicators.t)


# Make the blank row----
temp.row<-matrix(c(rep.int("",length(primer.species.factors.habitat))),nrow=1,ncol=length(primer.species.factors.habitat))
blank.row<-data.frame(temp.row)
colnames(blank.row)<-colnames(primer.species.factors.habitat)
head(blank.row)


# Make the final PRIMER data----
primer.species.factors.habitat[]<-lapply(primer.species.factors.habitat,as.character) #have to make whole data.frame as.character
primer<-primer.species.factors.habitat%>%
  bind_rows(blank.row,indicators.t)
tail(primer)



# Write PRIMER data----
setwd(primer.data)
# For PRIMER - Make "blank" name blank - this can ONLY be done with plyr()---
detach("package:dplyr", unload=TRUE) #this fixes names of value problem
detach("package:plyr", unload=TRUE) #this fixes names of value problem
library(plyr) #plyr can do this be dplyr can't!

primer <- rename(primer, replace =c("blank"="") )
head(primer)
write.csv(primer,file=paste(study,"PRIMER.csv",sep = "_"), row.names=FALSE)



