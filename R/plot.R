# This is code to plot the three SSI census data, i.e., pup counts from Cape
# Shirreff (CS), San Telmo Islets (STI), and the South Shetland Islands (SSI)
# Code by Doug Krause, adapted by Sam Woodman

library(dplyr)
library(ggplot2)
library(here)

data <- read.csv(here("data", "ssafs-pup-counts-full.csv"))

# Create a comparative line graph with three lines filled by location

# Set factor levels for "Location"
fac <- c('SSI','CS','STI')
lab <- c("South Shetland Islands", "Cape Shirreff","San Telmo Island")
stopifnot(all(data$location %in% fac))

# Create a color blind friendly pallette
cbPalette <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
  "#999999", "#CC79A7"
)

## Plot for pups counted -----------------------------------------------
data.plot <- ggplot(data, aes(x = season_year, y = count, 
                              colour = factor(location, level = fac), 
                              group = factor(location, level = fac), 
                              shape = factor(location, level = fac))) + 
  geom_line() +
  # geom_line(data = data[!is.na(data$count), ]) + # a little trick to skip NAs
  geom_point(size = 2) +
  #scale_colour_manual(values=cbPalette)+
  #geom_errorbar(aes(ymin=Pups-sd, ymax=Pups+sd), colour="black", width=.1) +
  xlab("Year") +
  ylab("Pup Count") +
  ggtitle("South Shetland Antarctic Fur Seal - Pup Census") + 
  scale_colour_manual(name = "Location", # Legend label for line
                      breaks = fac,
                      labels = lab,
                      values = cbPalette) + # Use cb friendly palette
  scale_shape_discrete(name = "Location", # Legend label for points
                       breaks = fac,
                       labels = lab) +
  theme(legend.justification = c(0.02, 0.98),
        legend.position = "inside", 
        legend.position.inside = c(0.02, 0.98))     
data.plot

## Save plot
ggsave(
  filename = "ssafs-pup-census.png", plot = data.plot, 
  width = 5.8, height = 4, units = 'in', dpi = 300
)

data.plot

# ## Hires plot
# tiff("Plotname.tiff", width = 5.8, height = 4, units = 'in', res = 300)
# data.plot
# dev.off()
