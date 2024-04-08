# Write SSAFS pup census data to Darwin Core-compliant files

library(dplyr)
library(worrms)
library(here)


#-------------------------------------------------------------------------------
# Read CSV data, prep WoRMS
x <- read.csv(here("data", "ssafs-pup-counts-full.csv"))


matched_taxa <- bind_rows(wm_records_names("Arctocephalus gazella")) %>% 
  rename(scientificName = "scientificname") %>%
  select(scientificName, lsid, rank, kingdom)
