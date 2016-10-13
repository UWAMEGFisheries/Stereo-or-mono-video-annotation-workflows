####Exploratory plotting

# Libraries required
detach("package:plyr", unload=TRUE)#will error - no worries
library(tidyr)
library(dplyr)
options(dplyr.width = Inf) #enables head() to display all coloums
library(ggplot2)
library(ggmap)



# Set directories----
rm(list=ls())
study<-"x_Example_BRUV"

# Add you work dir here-
# work.dir=("C:/Tims Documents/ownCloud/GitHub_Example")
work.dir=("~/ownCloud/GitHub_Example")


tidy.data=paste(work.dir,"Data/Tidy data",sep="/")
plots=paste(work.dir,"Plots",sep="/")


# Read in the data----
setwd(tidy.data)
dir()
combined<-read.csv("x_Example_BRUV_combined.factors.habitat.csv")


# What to plot?----
tail(combined)
unique(combined$Group) #Family Genus_species
unique(combined$Measure) #Abundance Mass
unique(combined$Taxa)


# Plotting themes pallettes and function----
Theme1 <-
  theme( # use theme_get() to see available options
    strip.text.x = element_text(size = 8,angle = 0),
    strip.text.y = element_text(size = 8),
    axis.title.x=element_text(vjust=-0.0, size=12),
    axis.title.y=element_text(vjust=0.0, angle=90, size=12),
    axis.text.x=element_text(size=10, angle=90),
    axis.text.y=element_text(size=10))


# functions for summarising data on plots----
se <- function(x) sd(x) / sqrt(length(x))
se.min <- function(x) (mean(x)) - se(x)
se.max <- function(x) (mean(x)) + se(x)


# spatial plot to plot anything----
setwd(plots)

lat <- mean(combined$Latitude)                
lon <- mean(combined$Longitude) 
# 
# # base map
gg.map <- get_map(location = c(lon , lat ), source = "stamen", maptype = "toner-lite", zoom = 8)
gg.map<-ggmap(gg.map)
gg.map


ggplot.spatial<-gg.map+
  # geom_point(data=data,aes(Longitude,Latitude),alpha=0.1)+ 
  geom_point(data=filter(combined,Group=="Species"&Taxa%in%c("Total","Rich")&Value==0),aes(Longitude,Latitude,size=Value),shape=21,colour="black",fill="grey",alpha=0.75)+
  geom_point(data=filter(combined,Group=="Species"&Taxa%in%c("Total","Rich")&Value>0),aes(Longitude,Latitude,size=Value),shape=21,colour="black",fill="red",alpha=0.75)+
  scale_size_continuous(range = c(2,8))+
  xlab('Longitude')+
  ylab('Lattitude')+
  # Apperance
  Theme1+
  facet_grid(Measure~Taxa,scales = "free")
ggplot.spatial
ggsave(ggplot.spatial,file=paste(Sys.Date(),study,"ggplot.spatial.png",sep = "_"), width = 25, height = 14,units = "cm")


# box plot to plot anything----
ggplot.box<-ggplot(data=filter(combined,Group=="Species"&Taxa%in%c("Total","Rich")),aes(mean.relief,Value),alpha=0.75)+
  geom_boxplot(outlier.colour = NA, notch=FALSE, width=0.8)+
  geom_point(position = position_jitter(width = 0.1, h = 0),alpha = 1/4, size=4)+
  stat_summary(fun.y=mean, geom="point", shape=2, size=4)
  # Apperance
  Theme1+
  facet_grid(Measure~Taxa,scales = "free")
ggplot.box
ggsave(ggplot.box,file=paste(Sys.Date(),study,"ggplot.box.png",sep = "_"), width = 25, height = 14,units = "cm")


# regression plot to plot anything----
ggplot.regression<-ggplot(data=filter(combined,Group=="Species"&Taxa%in%c("Total","Rich")),aes(mean.relief,Value),alpha=0.75)+
  geom_point()+
  geom_smooth()+
  scale_y_log10()+
  # Apperance
  Theme1+
  facet_grid(Measure~Taxa,scales = "free")
ggplot.regression
ggsave(ggplot.regression,file=paste(Sys.Date(),study,"ggplot.regression.png",sep = "_"), width = 25, height = 14,units = "cm")

