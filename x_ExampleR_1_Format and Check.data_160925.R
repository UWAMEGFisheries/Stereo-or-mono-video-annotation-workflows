
###### Checking and writing tidy MaxN, Length and 3D points from EventMeasure queries ######

### Written by Tim Langlois 
### Any errors are due to Tim Langlois
### Please forward any updates and improvements to timothy.langlois@uwa.edu.au

# The following code forms an appendix to the manuscript:
#  "Langlois et al. 2015. Length selectivity of commercial fish traps assessed from in situ comparisons with stereo-videos: is there evidence of sampling bias? Fisheries Research"
# Please cite it if you like it

### Designed to: 
#   check data resulting in queries from EventMeasure. 
#   write tidy data for futher analyses. 

### objective is to 
# 1. Import data and add Genus_species column
# 2. run BASIC data checks
# 3. Limit length data by range and precision rules
# 4. run SERIOUS checks against a master species list
# 5. Remove species that can never be ID'd
# 6. Visualise what MaxN are missing in the stereoMaxN

# Naming conventions----
# data objects in lower case
# column names Capitalized


# Libraries required
detach("package:plyr", unload=TRUE)#will error - don't panic - need to make sure it is not loaded as will interfer with dplyr()
library(tidyr)
library(dplyr)
options(dplyr.width = Inf) #enables head() to display all coloums
library(ggplot2)
library(readxl)
library(googlesheets)


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



# Set directories----
rm(list=ls()) #clear memory
study<-"x_Example_BRUV"

# Add you work dir here-
work.dir=("C:/Tims Documents/ownCloud/GitHub_Example")


em.export=paste(work.dir,"Data/EM export",sep="/")
em.check=paste(work.dir,"Data/EM to check",sep="/")
tidy.data=paste(work.dir,"Data/Tidy data",sep="/")
plots=paste(work.dir,"Plots",sep="/")

# Read in data files----
setwd(em.export)
dir()
# Read in MaxN - make genus species and check format of colums
maxn<-read.delim("x_ExampleData_1_MaxN.TXT",skip = 4, header=T, stringsAsFactors = FALSE,strip.white = TRUE,na.strings = c("", " "))%>%
  mutate(Genus = ifelse(is.na(Genus), Family,Genus))%>% #fill in any blank Genus names with family
  mutate(Genus_species = paste(Genus, Species, sep = ' '))%>% #paste Genus species together
  mutate(MaxN=as.numeric(MaxN))
# Check maxn
head(maxn,2)


# Read in length/3d files - make genus species and check format of colums--
length<-read.delim("x_ExampleData_2_Length and 3Dpoints.TXT",skip = 4, header=T, stringsAsFactors = FALSE,strip.white = TRUE,na.strings = c("", " "))%>%
  mutate(Length=Length..mm.)%>%
  mutate(Range=Range..mm.)%>%
  mutate(Genus = ifelse(is.na(Genus), Family,Genus))%>% #fill in any blank Genus names with family
  mutate(Genus_species = paste(Genus, Species, sep = ' ')) #paste Genus species together
# Check length
head(length,2)


# Make Factors to merge back in after summarises -----
# Factors are in the googlesheet. Take them from "NCB Labsheets"
gs_ls()
sheet <- gs_title("NCB Labsheets")#register a sheet

factors<-sheet%>%
  gs_read_csv(ws = "OpCodeTrack")%>%
  filter(grepl('2015_09_Mackerel.Islands.shallow_stereoBRUVs', CampaignID))%>%
  select(CampaignID,OpCode,Depth,Latitude,Longitude,Location,Status,Site,MaxN.analyst,Length.analyst)
head(factors)

# Here we are using MaxN.analyst and Length.analyst to indicate if MaxN and Length were possible to collect - giving us our true zeros if the 
maxn.factors<-factors%>%
  filter(!is.na(MaxN.analyst))%>%
  filter(!MaxN.analyst %in% c("NA","N/A"))

length.factors<-factors%>%
  filter(!is.na(Length.analyst))%>%
  filter(!Length.analyst %in% c("NA","N/A"))
  

# BASIC Checks----
setwd(em.check)
head(maxn)
head(length)

# Check if we have 3d points (Number) in addition to length----
three.d.points<-length%>%
  filter(is.na(Length))%>%
  filter(!is.na(Number))
head(three.d.points) #if there are any records here we have 3d points - yes we do


# Check if we have schools associated with single length measures----
schools<-filter(length,Number>1) #yes we do 
head(schools)


#finding sync points that are not fish----
# normally Lengths without a Number
sync.points<-filter(length,is.na(Number))
head(sync.points) 


#Standardise for RANGE and Error for Length----
# To standardise for RANGE and Error we can remove any length observations outside Range and Error rules
# i.e. the length data, and any abundnance calculated from it, will be restricted by range
setwd(em.check)
summary(length$Range)
  out.of.range<-filter(length,Range>8000);head(out.of.range)
  length <- filter(length,Range < 8000)
write.csv(out.of.range,file=paste(study,"out.of.range.csv",sep = "_"), row.names=FALSE)


# Check on the BIG fish length data----
fish.greater.than.1.meter<-filter(length,Length>1000) #All sharks, 
head(fish.greater.than.1.meter)
write.csv(fish.greater.than.1.meter,file=paste( study,"fish.greater.than.1.meter.csv",sep = "_"), row.names=FALSE)


# Plot to visualise length data----
setwd(em.check)
dir()
gg.check.length<-ggplot(data=length, aes(as.numeric(Length))) + 
  geom_histogram(aes(y =..density..), 
                 col="red", 
                 fill="blue", 
                 alpha = .2) 
gg.check.length
ggsave(gg.check.length,file=paste( study,"gg.check.length.png",sep = "_"),width = 8, height = 8,units = "in")
dir()

# Plot to visualise range data----
gg.check.range<-ggplot(data=length, aes(as.numeric(Range))) + 
  geom_histogram(aes(y =..density..), 
                 col="red", 
                 fill="green", 
                 alpha = .2) 
gg.check.range
ggsave(gg.check.range,file=paste( study,"gg.check.range.png",sep = "_"),width = 8, height = 8,units = "in")


# Plot to visualise length/range data----
gg.check.range.vs.length<-ggplot(data=length, aes(as.numeric(Length),as.numeric(Range))) + 
  geom_point()+
  geom_smooth()
gg.check.range.vs.length
ggsave(gg.check.range.vs.length,file=paste( study,"gg.check.range.vs.length.png",sep = "_"),width = 8, height = 8,units = "in")


# SERIOUS data checking to compare taxa and min/max lengths----
# using life history from google sheets
gs_ls()
Life_history <- gs_title("Life_history")#register a sheet
master<-Life_history%>%
  gs_read_csv(ws = "Life_history")%>%
  filter(grepl('Australia', Global.region))%>%
  filter(grepl('Ningaloo|Pilbara', Local.region))
head(master,7)
str(master)
names(master)


# Update names of species that may have changed----
change<-filter(master,!Change.to=="No change")
head(change)
# For MaxN
maxn$Genus_species <- gsr(maxn$Genus_species, change$Genus_species, change$Change.to)
# For Length
length$Genus_species <- gsr(length$Genus_species, change$Genus_species, change$Change.to)


# Check for taxa.not.match----
setwd(em.check)
dir()
x<-"maxn.taxa.not.match.life.history" #a quick look at taxa that do not match master list
maxn.taxa.not.match<-
  master%>%
  select(Genus_species)%>%
  anti_join(maxn,.,by="Genus_species")%>%
  distinct(Genus_species)%>% 
  select(Genus_species)
head(maxn.taxa.not.match)
write.csv(maxn.taxa.not.match,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)


x<-"maxn.taxa.by.opcode.not.match.life.history" #more useful list of taxa that do not match by OpCode
maxn.taxa.and.opcode.not.match<-
  master%>%
  select(Genus_species)%>%
  anti_join(maxn,.,by="Genus_species")%>%
  distinct(Genus_species,OpCode)%>% 
  select(Genus_species,OpCode)
head(maxn.taxa.and.opcode.not.match)
write.csv(maxn.taxa.and.opcode.not.match,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)


x<-"length.taxa.not.match.life.history" #quick look at taxa in length that don't match
length.taxa.not.match<-
  master%>%
  select(Genus_species)%>%
  anti_join(length,.,by="Genus_species")%>%
  distinct(Genus_species)%>% 
  select(Genus_species)
head(length.taxa.not.match)
write.csv(length.taxa.not.match,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)


x<-"length.taxa.by.opcode.not.match.life.history" #a more useful list of taxa in lenght that do not match
length.taxa.and.opcode.not.match<-
  master%>%
  select(Genus_species)%>%
  anti_join(length,.,by="Genus_species")%>%
  distinct(Genus_species,OpCode)%>% 
  select(Genus_species,OpCode)
head(length.taxa.and.opcode.not.match)
write.csv(length.taxa.and.opcode.not.match,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)



### SERIOUS Check for Min Max Length compared to Master list----
setwd(em.check)
x<-"out.of.bounds.length.vs.life.history"
# Before running the length check we must NOT have any non-matching taxa - so first remove these from
keep<-select(master,Genus_species)

length10<-length%>%
  semi_join(keep,by="Genus_species")%>%
  filter(!is.na(Length))

# Make a vector of names to compare against
Genus_species.Vec<- sort(unique(length10$Genus_species)) #Need to order by name

# Make a dummy list for checking
wrong.length=vector('list',length=length(Genus_species.Vec))
names(wrong.length)=Genus_species.Vec
Matching.Species.Table=filter(master,Genus_species%in%Genus_species.Vec)
Matching.Species.Table=Matching.Species.Table[order(Matching.Species.Table$Genus_species),]
head(Matching.Species.Table)
Min=Matching.Species.Table$Min_length #Vector of Min lengths
Max=Matching.Species.Table$Max_length #Vector of Max lengths
names(Min)=names(Max)=Matching.Species.Table$Genus_species #Add names to the Min and Max - very important vectors are in order

# Run the loop to check the length data---
test=NA
for(i in 1:length(Genus_species.Vec))  
{
  
  Data=subset(length10,Genus_species==Genus_species.Vec[i])
  Data=subset(Data,!is.na(Length))
  test=which(Data$Length  <Min[i])
  test=c(test,which(Data$Length  >Max[i]))
  test=Data[test,]
  wrong.length[[i]]=test
}
wrong.length1<-do.call(rbind,wrong.length)

# Merge with Matching.Species.Table
wrong.length.taxa<-wrong.length1%>%
  inner_join(Matching.Species.Table,by="Genus_species")%>%
  select(OpCode, Genus_species,Length,Min_length,Max_length,everything())
head(wrong.length.taxa)
write.csv(wrong.length.taxa,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)



###########################################
# # # Check how many MaxN per Genus_species are missing from StereoMaxN----
# e.g. how many lengths are missing from the possible MaxN
#############################################
setwd(em.check)

# Added this to look at influence of Stage
length<-length%>%
  filter(Stage=="AD")


length.to.match.maxn<-master%>%
  select(Genus_species)%>%
  semi_join(length,.,by="Genus_species")%>%
  distinct(Genus_species)%>% 
  select(Genus_species)%>%
  semi_join(maxn,.,by="Genus_species")%>%
  semi_join(length,.,by="Genus_species")%>% 
  select(Family,Genus_species,Number,OpCode)%>%
  mutate(Data = "StereoMaxN")

length.OpCode <- length.to.match.maxn %>%
  distinct(OpCode)%>% 
  select(OpCode)


maxn.match.length<-master%>%
  select(Genus_species)%>%
  semi_join(maxn,.,by="Genus_species")%>%
  distinct(Genus_species)%>% 
  select(Genus_species)%>%
  semi_join(length,.,by="Genus_species")%>%
  semi_join(maxn,.,by="Genus_species")%>%
  semi_join(length.OpCode,by="OpCode")%>% # subset maxn to only those OpCode that match OpCodes from length
  select(Family,Genus_species,MaxN,OpCode)%>%
  mutate(Data = "MaxN")%>%
  rename(Number = MaxN)%>%
  bind_rows(length.to.match.maxn)
head(maxn.match.length)


# Summarise the matched data by taxa
x<-"taxa.maxn.vs.stereo.summary"
taxa.maxn.vs.stereo.summary <- maxn.match.length %>%
  group_by(Genus_species,Family,OpCode,Data) %>%
  summarise(MaxN = sum(Number))%>%
  spread(Data,MaxN)%>%
  mutate(Percent.diff = (MaxN-StereoMaxN)/MaxN)
head(taxa.maxn.vs.stereo.summary)
write.csv(taxa.maxn.vs.stereo.summary,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)

# Summarise the matched data by family
x<-"family.maxn.vs.stereo.summary"
family.maxn.vs.stereo.summary <- maxn.match.length %>%
  group_by(Family,OpCode,Data) %>%
  summarise(MaxN = sum(Number))%>%
  spread(Data,MaxN)%>%
  mutate(Percent.diff = (MaxN-StereoMaxN)/MaxN)
head(family.maxn.vs.stereo.summary)
write.csv(family.maxn.vs.stereo.summary,file=paste( study,x,".csv",sep = "_"), row.names=FALSE)


# Plot of MaxN versus StereoMaxN by family----

head(family.maxn.vs.stereo.summary)

x<-"ggMaxNCheckzoomout"
ggMaxNCheckzoomout<-ggplot(data=family.maxn.vs.stereo.summary,aes(x=MaxN,y=StereoMaxN,colour=Family))+
  geom_point()+
  geom_text(aes(label=OpCode),hjust=0, vjust=0)+
  theme(legend.direction = "horizontal", legend.position = "bottom")+
  geom_abline()+
  geom_hline(yintercept=0)+
  geom_vline(xintercept=0)+
  ylab("StereoMaxN")+
  xlim(0, 45)+
  ylim(0, 45)
# coord_equal()
ggMaxNCheckzoomout
ggsave(ggMaxNCheckzoomout,file=paste( study,x,".png",sep = "_"),width = 8, height = 8,units = "in")

x<-"ggMaxNCheckzoomin"
ggMaxNCheckzoomin<-ggplot(data=family.maxn.vs.stereo.summary,aes(x=MaxN,y=StereoMaxN,colour=Family))+
  geom_point()+
  geom_text(aes(label=OpCode),hjust=0, vjust=0,angle=330)+
  theme(legend.direction = "horizontal", legend.position = "bottom")+
  geom_abline()+
  geom_hline(yintercept=0)+
  geom_vline(xintercept=0)+
  ylab("StereoMaxN")+
  coord_cartesian(xlim = c(-2,16), ylim = c(-2,16))
ggMaxNCheckzoomin
ggsave(ggMaxNCheckzoomin,file=paste( study,x,".png",sep = "_"),width = 8, height = 8,units = "in")



###
### Congratulate yourself that you will not have to do checking of species and lengths using filter and sort functions in Excel.
##


# WRITE FINAL checked data----
setwd(tidy.data)
dir()

x<-"maxn.factors"
write.csv(maxn.factors, file=paste( study,x,".csv",sep = "."), row.names=FALSE)

x<-"maxn"
maxn<-
  master%>%
  select(Genus_species)%>%
  semi_join(maxn,.,by="Genus_species") #this will drop any speices not in the Master list - that came from the Life_history sheet
head(maxn)
unique(maxn$Genus_species)
write.csv(maxn, file=paste( study,x,".csv",sep = "."), row.names=FALSE)


x<-"length.factors"
write.csv(length.factors, file=paste( study,x,".csv",sep = "."), row.names=FALSE)

x<-"length"
# USE THIS PART IF YOU WANT TO REMOVE LENGTHS OUTSIDE THE MIN/MAX OF MASTER LIST
# drop.length<-wrong.length.taxa %>% 
#   distinct(OpCode, Genus_species,Length)%>%
#   select(OpCode, Genus_species,Length)%>%
#   mutate(key = paste(OpCode, Genus_species, Length, sep = '_'))
length<-
  master%>%
  select(Genus_species)%>%
  semi_join(length,.,by="Genus_species")%>%#this will drop any speices not in the Master list - that came from the Life_history sheet
  mutate(key = paste(OpCode, Genus_species, Length, sep = '_'))
#   anti_join(drop.length,by="key") #for dropping wrong.lengths
write.csv(length, file=paste( study,x,".csv",sep = "."), row.names=FALSE)
