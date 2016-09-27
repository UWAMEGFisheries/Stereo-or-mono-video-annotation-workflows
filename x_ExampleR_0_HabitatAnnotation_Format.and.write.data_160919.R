###### Importing Habitat Annotation points from TransectMeasure (Stereo)----


### Written by Tim Langlois 
### Any errors are due to Tim Langlois
### Please forward any updates and improvements to timothy.langlois@uwa.edu.au or make a pull request on the GitHub


### Designed to take direct output from an TransectMeasure project. 

### objective is to 
# 1 Import and combine data from .txt file data collected in a 4 x 5 grid of CATAMI and relief codes
# 2 Make % scores and levels for different groups


# Set directories----
rm(list=ls())
study<-"Example"

data.dir=("~/ownCloud/GitHub_Example")
# data.dir=("C:/Tims Documents/ownCloud/GitHub_Example")

habitat.data=paste(data.dir,"Data/Habitat",sep="/")
tidy.data=paste(data.dir,"Data/Tidy data",sep="/")
plots=paste(data.dir,"Plots",sep="/")


# Libraries required
detach("package:plyr", unload=TRUE)#will error - no worries
library(tidyr)
citation("tidyr")
library(dplyr)
citation("dplyr")
options(dplyr.width = Inf) #enables head() to display all coloums
library(ggplot2)
library(stringr)


# Load and format habitat annotation data from TransectMeasure----
setwd(habitat.data)
dir()
hab<-read.delim('x_ExampleData_BRUV_TM_HabitatAnnotation.txt',header=T,skip=4,stringsAsFactors=FALSE)%>%
  setNames(tolower(names(.)))%>%
  mutate(OpCode=str_replace_all(.$filename, "[.jpg_]", ""))%>%
  select(-c(filename,x,x.1,frame,time..mins.,date,location,site..,transect..,latitude,longitude,rugosity,depth,collector,fishing.status,spare,spare.1,code,radius..))
head(hab)

filter(hab,OpCode=="MNCB337")


# Create %fov----
fov<-hab%>%
  select(-c(broad,morphology,type,relief))%>%
  filter(!fieldofview=="")%>%
  filter(!is.na(fieldofview))%>%
  mutate(fieldofview=paste("fov",fieldofview,sep = "."))%>%
  mutate(count=1)%>%
  spread(key=fieldofview,value=count, fill=0)%>%
  select(-c(image.row,image.col))%>%
  group_by(OpCode)%>%
  summarise_each(funs(sum))%>%
  group_by(OpCode)%>%
  mutate_each(funs(.*5))%>%
  mutate_each(funs(replace(.,is.na(.),0)))

head(fov,30)
filter(fov,OpCode=="MNCB337")

# Create relief----
relief<-hab%>%
  filter(!broad%in%c("Unknown","Open Water"))%>%
  filter(!relief%in%c("Unknown",""))%>%
  select(-c(broad,morphology,type,fieldofview,image.row,image.col))%>%
  mutate(relief.rank=ifelse(relief==".0. Flat substrate, sandy, rubble with few features. ~0 substrate slope.",0,ifelse(relief==".1. Some relief features amongst mostly flat substrate/sand/rubble. <45 degree substrate slope.",1,ifelse(relief==".2. Mostly relief features amongst some flat substrate or rubble. ~45 substrate slope.",2,ifelse(relief==".3. Good relief structure with some overhangs. >45 substrate slope.",3,ifelse(relief==".4. High structural complexity, fissures and caves. Vertical wall. ~90 substrate slope.",4,ifelse(relief==".5. Exceptional structural complexity, numerous large holes and caves. Vertical wall. ~90 substrate slope.",5,relief)))))))%>%
  select(-c(relief))%>%
  mutate(relief.rank=as.numeric(relief.rank))%>%
  group_by(OpCode)%>%
  summarise(mean.relief= mean (relief.rank), sd.relief= sd (relief.rank))
head(relief)


# CREATE catami_broad------
broad<-hab%>%
  select(-c(fieldofview,morphology,type,relief))%>%
  mutate(broad=ifelse(broad=="Octocoral/Black","Octocoral.Black",ifelse(broad=="Stony corals","Stony.corals",ifelse(broad=="Open Water","Open.Water",broad))))%>% #correct bad names
  filter(!broad=="")%>%
  filter(!is.na(broad))%>%
  filter(!broad=="Unknown")%>%
  filter(!broad=="Open.Water")%>%
  mutate(broad=paste("broad",broad,sep = "."))%>%
  mutate(count=1)%>%
  group_by(OpCode)%>%
  spread(key=broad,value=count,fill=0)%>%
  select(-c(image.row,image.col))%>%
  group_by(OpCode)%>%
  # mutate_each(funs(replace(.,is.na(.),0)))%>%
  summarise_each(funs(sum))%>%
  mutate(Total.Sum=rowSums(.[,2:(ncol(.))],na.rm = TRUE ))%>%
  group_by(OpCode)%>%
  mutate_each(funs(./Total.Sum), matches("broad"))%>%
  select(-Total.Sum)%>%
  mutate(broad.Reef=broad.Consolidated+broad.Macroalgae+broad.Octocoral.Black) #Add in a Reef classification 
head(broad)


# CREATE catami_morphology------
morphology<-hab%>%
  select(-c(fieldofview,broad,type,relief))%>%
  filter(!morphology=="")%>%
  filter(!is.na(morphology))%>%
  filter(!morphology=="Unknown")%>%
  mutate(morphology=paste("morph",morphology,sep = "."))%>%
  mutate(count=1)%>%
  group_by(OpCode)%>%
  spread(key=morphology,value=count,fill=0)%>%
  select(-c(image.row,image.col))%>%
  group_by(OpCode)%>%
  # mutate_each(funs(replace(.,is.na(.),0)))%>%
  summarise_each(funs(sum))%>%
  mutate(Total.Sum=rowSums(.[,2:(ncol(.))],na.rm = TRUE ))%>%
  group_by(OpCode)%>%
  mutate_each(funs(./Total.Sum), matches("morph."))%>%
  select(-Total.Sum)
head(morphology)


# CREATE catami_type------
type<-hab%>%
  select(-c(fieldofview,broad,morphology,relief))%>%
  filter(!type=="")%>%
  filter(!is.na(type))%>%
  filter(!type=="Unknown")%>%
  mutate(type=paste("type",type,sep = "."))%>%
  mutate(count=1)%>%
  group_by(OpCode)%>%
  spread(key=type,value=count,fill=0)%>%
  select(-c(image.row,image.col))%>%
  group_by(OpCode)%>%
  # mutate_each(funs(replace(.,is.na(.),0)))%>%
  summarise_each(funs(sum))%>%
  mutate(Total.Sum=rowSums(.[,2:(ncol(.))],na.rm = TRUE ))%>%
  group_by(OpCode)%>%
  mutate_each(funs(./Total.Sum), matches("type."))%>%
  select(-Total.Sum)
head(type)


# Write final habitat data----
# join starting with relief - as this is most liekly to have the most samples with habitat data
setwd(tidy.data)
dir()

habitat<-relief%>%
  left_join(fov,by="OpCode")%>%
  left_join(broad,by="OpCode")
  # left_join(morphology,by="OpCode")%>%
  # left_join(type,by="OpCode")
head(habitat)
names(habitat)
write.csv(habitat,file=paste("x",study,"R_habitat.output.csv",sep = "_"), row.names=FALSE)


# Habitat.plot----
setwd(plots)
habitat.plot<-habitat%>%
  gather(key=habitat, value = value, 2:ncol(.))%>%
  filter(habitat%in%c("mean.relief","sd.relief","broad.Consolidated","broad.Macroalgae","broad.Octocoral.Black","broad.Sponges","broad.Stony.corals","broad.Unconsolidated","broad.Reef"))
head(habitat.plot)

habitat.ggplot<-ggplot(habitat.plot,aes(x=value))+
  geom_histogram()+
  facet_grid(habitat~.,scales="free")+
  ylab("Percent cover or Value")+
  theme(strip.text.y = element_text(angle=0))
habitat.ggplot
ggsave(habitat.ggplot,file=paste("x",study,"R_habitat.plot.png",sep = "_"), width = 10, height = 25,units = "cm")

