### objective is to 

# 1. Read in all the data sets made in "x_ExampleR_2_CalcBiomass and Tidy data for analysis_160925.R"
# 2. Format them so they can all be combined into one single datasets for modeling/plotting
# 3. Combine with Habitat data where avaialble


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


em.export=paste(work.dir,"Data/EM export",sep="/")
em.check=paste(work.dir,"Data/EM to check",sep="/")
tidy.data=paste(work.dir,"Data/Tidy data",sep="/")
habitat=paste(work.dir,"Data/Habitat",sep="/")
summaries=paste(work.dir,"Data/Summaries",sep="/")


# Functions----
gsr <- function(Source, Search, Replace) { 
  if (length(Search) != length(Replace))     stop("Search and Replace Must Have Equal Number of Items\n") 
  Changed <- as.character(Source) 
  for (i in 1:length(Search)) 
  { 
    cat("Replacing: ", Search[i], " With: ", Replace[i], "\n")
    Changed <- replace(Changed, Changed == Search[i], Replace[i])   } 
  cat("\n")    
  Changed 
}

# Read in the long data whilst standardising format----
setwd(tidy.data)
dir()
drop.cols <- c('MaxN.analyst', 'Length.analyst')

# MaxN based--

bruv.maxn.taxa<-read.csv("x_Example_BRUV.maxn.taxa.L.factors..csv")%>%
  mutate(Group="Species")%>%
  mutate(Measure="Abundance")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Genus_species)%>%
  rename(Value=Abundance)%>%
  select(-one_of(drop.cols))
head(bruv.maxn.taxa)

bruv.maxn.family<-read.csv("x_Example_BRUV.maxn.family.L.factors..csv")%>%
  mutate(Group="Family")%>%
  mutate(Measure="Abundance")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Family)%>%
  rename(Value=Abundance)%>%
  select(-one_of(drop.cols))
head(bruv.maxn.family)

bruv.maxn.feeding<-read.csv("x_Example_BRUV.maxn.feeding.L.factors..csv")%>%
  mutate(Group="Feeding")%>%
  mutate(Measure="Abundance")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Feeding.guild)%>%
  rename(Value=Abundance)%>%
  select(-one_of(drop.cols))
head(bruv.maxn.feeding)

bruv.maxn.legal<-read.csv("x_Example_BRUV.legal.maxn.taxa.L.factors..csv")%>%
  mutate(Group="Legal")%>%
  mutate(Measure="Abundance")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Genus_species)%>%
  rename(Value=Abundance)%>%
  select(-one_of(drop.cols))
head(bruv.maxn.legal)

# Mass based--

bruv.mass.taxa<-read.csv("x_Example_BRUV.mass.taxa.L.factors..csv")%>%
  mutate(Group="Species")%>%
  mutate(Measure="Mass")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Genus_species)%>%
  rename(Value=Mass)%>%
  select(-one_of(drop.cols))
head(bruv.mass.taxa)

bruv.mass.family<-read.csv("x_Example_BRUV.mass.family.L.factors..csv")%>%
  mutate(Group="Family")%>%
  mutate(Measure="Mass")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Family)%>%
  rename(Value=Mass)%>%
  select(-one_of(drop.cols))
head(bruv.mass.family)

bruv.mass.feeding<-read.csv("x_Example_BRUV.mass.feeding.L.factors..csv")%>%
  mutate(Group="Feeding")%>%
  mutate(Measure="Mass")%>%
  mutate(Method="BRUV")%>%
  rename(Taxa=Feeding.guild)%>%
  rename(Value=Mass)%>%
  select(-one_of(drop.cols))
head(bruv.mass.feeding)


# Combine the long data----
name<-"combined"
bruv<-list(bruv.maxn.taxa,bruv.maxn.family,bruv.maxn.feeding,bruv.maxn.legal,bruv.mass.taxa,bruv.mass.family,bruv.mass.feeding)
combined<-rbind_all(bruv)%>%
  rename(Sample=OpCode)
head(combined)

  

# Summarise the long data----
setwd(summaries)

tail(combined)

taxa.summary.mean<-combined%>%
  filter(Group=="Species")%>%
  group_by(Method,Measure,Taxa,Site) %>%
  summarise(Mean=mean(Value))%>%
  spread(key=Site,value=Mean, fill = 0)
head(taxa.summary.mean)
write.csv(taxa.summary.mean,file=paste(study,"taxa.summary.mean.csv",sep = "_"), row.names=FALSE)

family.summary.mean<-combined%>%
  filter(Group=="Family")%>%
  group_by(Method,Measure,Taxa,Site) %>%
  summarise(Mean=mean(Value))%>%
  spread(key=Site,value=Mean, fill = 0)
tail(family.summary.mean)
write.csv(family.summary.mean,file=paste(study,"family.summary.mean.csv",sep = "_"), row.names=FALSE)

feeding.summary.mean<-combined%>%
  filter(Group=="Feeding")%>%
  group_by(Method,Measure,Taxa,Site) %>%
  summarise(Mean=mean(Value))%>%
  spread(key=Site,value=Mean, fill = 0)
tail(feeding.summary.mean)
write.csv(feeding.summary.mean,file=paste(study,"feeding.summary.mean.csv",sep = "_"), row.names=FALSE)


# Bring in the enviromental data----
setwd(tidy.data)
dir()
bruv.fine.habitat<-read.csv("x_Example_BRUV_habitat.output.csv")%>%
  rename(Sample=OpCode)
head(bruv.fine.habitat)


# Write final data----
setwd(tidy.data)
head(combined)
data<-combined%>%
  inner_join(bruv.fine.habitat, by="Sample") #How many samples do not have habitat data? In this example I have made it obvious there are quite a few. Normally we are only missing the Habitat from samples that were facing up.
head(data)
write.csv(data, file=paste(study,"combined.factors.habitat.csv",sep = "_"), row.names=FALSE)


# # To check which Samples are missing habitat----
# missing.habitat<-combined%>%
#   anti_join(combined.habitat,by="Sample")%>%
#   distinct(Sample)
# tail(missing.habitat)
# # No habitat data missing!