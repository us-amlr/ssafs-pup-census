# This is code to plot the three SSI census data, i.e., pup counts from Cape
# Shirreff (CS), San Telmo Islets (STI), and the South Shetland Islands (SSI)

library(dplyr)
library(ggplot2)
library(here)

data <- read.csv(here("data", "ssafs-pup-counts-full.csv")) %>% 
  mutate(Year = as.numeric(substr(season_name, 1, 4)) + 1)
#   
# data <-read.csv("~/Research/AFS Pup Mortality/AFS Pup Census Data/Pupplotdata.csv", 
#                 header=TRUE, stringsAsFactors=TRUE)
# datacs <-read.csv("~/Research/AFS Pup Mortality/AFS Pup Census Data/Pupplotdata_cs_2023.csv", 
#                 header=TRUE, stringsAsFactors=TRUE)
# dataman <-read.csv("~/Research/AFS Pup Mortality/AFS Pup Census Data/Pupplotdata_sti man.csv", 
#                   header=TRUE, stringsAsFactors=TRUE)

# Create a comparative line graph with three lines filled by location

# Set factor levels for "Location"
fac <- c('SSI','CS','STI')

# Create a color blind friendly pallette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00","#999999", "#CC79A7")

# # Plot for pups counted -----------------------------------------------
plot1 <- ggplot(data, aes(x= Year, y=Pups, colour=factor(Location,level=fac), 
                          group=factor(Location,level=fac), 
                          shape=factor(Location,level=fac))) + #to use diff points
  geom_line(data=data[!is.na(data$Pups),]) + # a little trick to skip NAs
  geom_point(size=2)+
  #scale_colour_manual(values=cbPalette)+
  #geom_errorbar(aes(ymin=Pups-sd, ymax=Pups+sd), colour="black", width=.1) +
  xlab("Year") +
  ylab("Pup Count") +
  scale_colour_manual(name="Location", # Legend label for line
                      breaks=fac,
                      labels=c("South Shetland Islands", "Cape Shirreff","San Telmo Islands"),
                      values=cbPalette)+ # Use cb friendly palette
 
  scale_shape_discrete(name="Location", # Legend label for points
                       breaks=fac,
                       labels=c("South Shetland Islands", "Cape Shirreff","San Telmo Islands"))+
  #legend theme values should be between 0 and 1. c(0,0) corresponds to the "bottom left" 
  #and c(1,1) corresponds to the "top right" position.
  theme(legend.justification=c(0.02,0.98),
        legend.position=c(0.02,0.98))     
plot1


## Hires plot
tiff("Plotname.tiff", width = 5.8, height = 4, units = 'in', res = 300)
plot1
dev.off()
