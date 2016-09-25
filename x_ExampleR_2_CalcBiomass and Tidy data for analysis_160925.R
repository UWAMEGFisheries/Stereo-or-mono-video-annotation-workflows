
###### Format MaxN, Length and 3D point that results from Checked data outputed from EventMeasure ######

### Written by Tim Langlois 
### Any errors are due to Tim Langlois
### Please forward any updates and improvements to timothy.langlois@uwa.edu.au

# The following code forms an appendix to the manuscript:
#  "Langlois et al. 2015. Length selectivity of commercial fish traps assessed from in situ comparisons with stereo-videos: is there evidence of sampling bias? Fisheries Research"
# Please cite it if you like it


### objective is to 

# 1. Import checked data
# 2. Make mass estimates from Length
# 3. Make species richness and total
# 4. Write long and wide data sets for further analysis


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
work.dir=("C:/Tims Documents/ownCloud/GitHub_Example")

em.export=paste(work.dir,"Data/EM export",sep="/")
em.check=paste(work.dir,"Data/EM to check",sep="/")
tidy.data=paste(work.dir,"Data/Tidy data",sep="/")


# Read in the data----
# Change dates for the new data
setwd(tidy.data)
dir()
maxn.factors<-read.csv("x_Example_BRUV.maxn.factors..csv")
maxn<-read.csv("x_Example_BRUV.maxn..csv")

length.factors<-read.csv("x_Example_BRUV.length.factors..csv")
length<-read.csv("x_Example_BRUV.length..csv")


# MAKE mass data from Length data----
gs_ls()
Life_history <- gs_title("Life_history")#register a sheet
master<-Life_history%>%
  gs_read_csv(ws = "Life_history")%>%
  filter(grepl('Australia', Global.region))%>%
  filter(grepl('Ningaloo|Pilbara', Local.region))
head(master,7)


# Make complete master (with feeding guilds) and length data with no 3D points
master<-master%>%
  distinct(Genus_species)%>%
  filter(!is.na(a))%>%
  select(Genus_species,Family,Feeding.guild,a,b,aLL,bLL)

master.feed<-master%>%
  select(Genus_species,Feeding.guild)

# Adding in Feeding for BRUV data 
maxn<-maxn%>%
  left_join(master.feed,by="Genus_species")
head(maxn)
unique(maxn$Feeding.guild)

length<-length%>%
  left_join(master.feed,by="Genus_species")
head(length)

# Make length without NA for later---
length.no.na<-length%>%
  filter(!is.na(Length))


# 1.Check if we have species length-weight relationship----
setwd(em.check)
taxa.missing.lw <- length.no.na%>%
  distinct(Genus_species)%>%
  anti_join(master, by="Genus_species")%>%
  select(Genus_species)
head(taxa.missing.lw)
write.csv(taxa.missing.lw,file=paste(study,"taxa.missing.lw.versus.life.history.csv",sep = "."), row.names=FALSE)
#We have a few missing Taxa -   you can add these into the master table - or we can  use Family averages

# 1.Check if we have species missing feeding info----
taxa.missing.feeding <- maxn%>%
  distinct(Genus_species)%>%
  anti_join(master.feed, by="Genus_species")%>%
  select(Genus_species)
head(taxa.missing.feeding)
write.csv(taxa.missing.feeding,file=paste(study,"taxa.missing.feeding.versus.life.history.csv",sep = "."), row.names=FALSE)
#We have a few missing Taxa -   you can add these into the master table 


#2. Check if any familys are missing?----
family.missing.lw <- length.no.na%>%
  distinct(Family)%>%
  anti_join(master, by="Family")%>%
  select(Family)
head(family.missing.lw)
# We have 0 familys missing - they will be dropped from Mass cal - unitl the LW are filled in


#3. Make a family average master table - to use if species info not available----
master.Family <- master %>%
  group_by(Family) %>%
  summarise(a = mean(a,na.rm = T),
            b = mean(b,na.rm = T),
            aLL = mean(aLL,na.rm = T),
            bLL = mean(bLL,na.rm = T))
head(master.Family)

#4. Fill length data with relevant a and b and if blank use family?----
length.taxa.ab<-master%>% #done this way around to avoid duplicating Family coloum
  select(-c(Family,Feeding.guild))%>%
  inner_join(length,., by="Genus_species")

length.family.ab<-length%>%
  anti_join(master, by="Genus_species")%>%
  semi_join(master, by="Family")

length.mass<-length.taxa.ab%>%
  bind_rows(length.family.ab)%>%
  filter(!is.na(a))%>% #this gets rid of species with no lw
  mutate(Length.cm = Length..mm./10)%>%
  mutate(aLL=as.numeric(aLL))%>%
  mutate(bLL=as.numeric(bLL))%>%
  mutate(a=as.numeric(a))%>%
  mutate(b=as.numeric(b))%>%
  mutate(AdjLength = ((Length.cm*bLL)+aLL)) %>% # Adjusted length  accounts for a b not coming from for Fork length
  mutate(mass = (AdjLength^b)*a*Number)
head(length.mass)

#5. Check the mass estimates across species - in kg's----
setwd(em.check)
x<-"maximum.weight.by.top.50.species"
max<- length.mass %>%
  group_by(Genus_species) %>%
  summarise(Mean = mean(mass,na.rm = TRUE))%>%
  arrange(-Mean)
head(max) #looks OK
write.csv(head(max,50),file=paste(study,x,".csv",sep = "."), row.names=FALSE)
# NOTES: on mass estimates
# All looking OK


# Write WIDE and LONG data from maxn, length and mass----
setwd(tidy.data)

# Function to fill Samples with no fish as zeros - could try complete() next time?
left_join_NA <- function(x, y, ...) {
  left_join(x = x, y = y, by = ...) %>% 
    mutate_each(funs(replace(., which(is.na(.)), 0)))
}

name<-"maxn.taxa.W.factors"
maxn.taxa.W <- maxn %>%
  group_by(Genus_species,OpCode) %>%
  summarise(Abundance = sum(MaxN))%>%
  spread(Genus_species,Abundance, fill = 0)%>%
  mutate(Total=rowSums(.[,2:(ncol(.))],na.rm = TRUE ))#Add in Totals
    Presence.Absence <- maxn.taxa.W[,2:(ncol(maxn.taxa.W))-1]
for (i in 1:dim(Presence.Absence)[2]){
  Presence.Absence[,i] <- ifelse(Presence.Absence[,i]>0,1,0)
}
  maxn.taxa.W.factors<-maxn.taxa.W%>%
    mutate(Rich = rowSums(Presence.Absence,na.rm = TRUE))%>%
    left_join_NA(maxn.factors,., by="OpCode") #there are warnings here but they are OK just becasue of factors - there are no NA's in factors maxn.taxa.W.factors[is.na(x),]
    tail(maxn.taxa.W.factors)
write.csv(maxn.taxa.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

name<-"maxn.taxa.L.factors"
data<-maxn.taxa.W.factors
head(data)
out<-data%>%
  gather(key=Genus_species, value = Abundance, (match("Length.analyst",names(data))+1):ncol(data))
  head(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)


name<-"maxn.family.W.factors"
maxn.family.W.factors <- maxn %>%
  group_by(Family,OpCode) %>%
  summarise(Abundance = sum(MaxN))%>%
  spread(Family,Abundance, fill = 0)%>%
  left_join_NA(maxn.factors,., by="OpCode")
  head(maxn.family.W.factors)
write.csv(maxn.family.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-maxn.family.W.factors
name<-"maxn.family.L.factors"
out<-data%>%
  gather(key=Family, value = Abundance, (match("Length.analyst",names(data))+1):ncol(data))
head(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

head(maxn)
name<-"maxn.feeding.W.factors"
maxn.feeding.W.factors <- maxn %>%
  group_by(Feeding.guild,OpCode) %>%
  summarise(Abundance = sum(MaxN))%>%
  data.frame() %>%
  spread(Feeding.guild,Abundance, fill = 0)%>%
  left_join(maxn.factors,., by="OpCode") #left_join NA does not work here
maxn.feeding.W.factors[is.na(maxn.feeding.W.factors)] <- 0
head(maxn.feeding.W.factors)
write.csv(maxn.feeding.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-maxn.feeding.W.factors
name<-"maxn.feeding.L.factors"
out<-data%>%
  gather(key=Feeding.guild, value = Abundance, (match("Length.analyst",names(data))+1):ncol(data))
head(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

head(length)
name<-"legal.maxn.taxa.W.factors"
legal.maxn.taxa.W <- length %>%
  filter(Length>395)%>% #We can add detail in here for lots of different species - we will need to collect all the legal size data in the life-history shhet to do this properly
  group_by(Genus_species,OpCode) %>%
  summarise(Abundance = sum(Number))%>%
  spread(Genus_species,Abundance, fill = 0)%>%
  mutate(Total=rowSums(.[,2:(ncol(.))],na.rm = TRUE ))  #Add in Totals
legal.maxn.taxa.W.factors<-legal.maxn.taxa.W%>%
  left_join_NA(length.factors,., by="OpCode") #there are warnings here but they are OK just becasue of factors - make sure we use length factors
  head(legal.maxn.taxa.W.factors)
write.csv(legal.maxn.taxa.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-legal.maxn.taxa.W.factors
name<-"legal.maxn.taxa.L.factors"
out<-data%>%
  gather(key=Genus_species, value = Abundance, (match("Length.analyst",names(data))+1):ncol(data))
  head(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)



name<-"mass.taxa.W.factors"
mass.taxa.W.factors <- length.mass %>%
  group_by(Genus_species,OpCode) %>%
  summarise(mass = sum(mass))%>%
  spread(Genus_species,mass, fill = 0)%>%
  mutate(Total=rowSums(.[,2:(ncol(.))],na.rm = TRUE )) %>% #Add in Totals
  left_join_NA(length.factors,., by="OpCode") #there are warnings here but they are OK just becasue of factors - make sure we use length factors
  head(mass.taxa.W.factors)
write.csv(mass.taxa.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-mass.taxa.W.factors
name<-"mass.taxa.L.factors"
out<-data%>%
  gather(key=Genus_species, value = Mass, (match("Length.analyst",names(data))+1):ncol(data))
  tail(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)


name<-"mass.family.W.factors"
mass.family.W.factors <- length.mass %>%
  group_by(Family,OpCode) %>%
  summarise(mass = sum(mass))%>%
  spread(Family,mass, fill = 0)%>%
  left_join_NA(length.factors,., by="OpCode") #there are warnings here but they are OK just becasue of factors - make sure we use length factors
  head(mass.family.W.factors)
write.csv(mass.family.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-mass.family.W.factors
name<-"mass.family.L.factors"
out<-data%>%
  gather(key=Family, value = Mass, (match("Length.analyst",names(data))+1):ncol(data))
head(out)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)


name<-"mass.feeding.W.factors"
mass.feeding.W.factors <- length.mass %>%
  group_by(Feeding.guild,OpCode) %>%
  summarise(mass = sum(mass))%>%
  spread(Feeding.guild,mass, fill = 0)%>%
  left_join_NA(length.factors,., by="OpCode") #there are warnings here but they are OK just becasue of factors - make sure we use length factors
head(mass.feeding.W.factors)
write.csv(mass.feeding.W.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)

data<-mass.feeding.W.factors
name<-"mass.feeding.L.factors"
out<-data%>%
  gather(key=Feeding.guild, value = Mass, (match("Length.analyst",names(data))+1):ncol(data))
tail(out,50)
write.csv(out, file=paste(study,name,".csv",sep = "."), row.names=FALSE)




# Expand and tidy Length by Number of raw Length data and merge with Factors----
names(length.no.na) #length with no 3d points
length.expanded<-length.no.na%>%
  select(OpCode,Family,Genus,Genus_species,Length,Number)
# Expand the Length data by Number coloum
# This does a lot here as there were lots of schools on some length measures
unique(length.expanded$Number)
length.expanded <- length.expanded[rep(seq.int(1,nrow(length.expanded)), length.expanded$Number), 1:5];head(length.expanded)

name<-"length.expanded.factors"
length.expanded.factors<-length.expanded%>%
  inner_join(length.factors,., by="OpCode") #using inner_join here as we don't want zero/NA if there is no length data in a sample
  head(length.expanded.factors)
write.csv(length.expanded.factors, file=paste(study,name,".csv",sep = "."), row.names=FALSE)
  

# # ggmaps to check the spatial extent of the MaxN and Length data---- 
# ggmap is not currently working? try updatin the package
setwd(em.check)

head(maxn.taxa.W.factors)
head(length.expanded.factors)

library(ggplot2)
library(ggmap)
# ### 
lat <- mean(maxn.taxa.W.factors$Latitude)                
lon <- mean(maxn.taxa.W.factors$Longitude) 
# 
# # base map
ggcheck <- get_map(location = c(lon , lat ), source = "stamen", maptype = "toner-lite", zoom = 9)
ggcheck.map<-ggmap(ggcheck)
ggcheck.map


# Plotting----
head(maxn.factors)
ggmap.opcode<-ggcheck.map+
  geom_text(aes(Longitude,Latitude,label=OpCode),size=4,data=maxn.factors, nudge_x=0.05)+
  geom_point(data=maxn.factors,aes(Longitude,Latitude),size=3,colour="red")+ 
  geom_point(data=length.factors,aes(Longitude,Latitude),colour="green",size=3, alpha=0.5)+ 
  annotate("text", x = 114.7, y = -21.2, label = "Red - MaxN only",colour="red")+
  annotate("text", x = 114.7, y = -21.3, label = "Green - Length data",colour="darkgreen")+
  xlab('Longitude')+
  ylab('Lattitude')
#   coord_cartesian(xlim=c(114.5,115.25),ylim=c(-30.4,-29.9))
ggmap.opcode
ggsave(ggmap.opcode,file=paste(study,"ggmap.opcode.png",sep = "."), width = 25, height = 14,units = "cm")
