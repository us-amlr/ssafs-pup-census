# Write SSAFS pup census data to Darwin Core-compliant files

library(dplyr)
library(worrms)
library(here)
library(readr)


#-------------------------------------------------------------------------------
# Read CSV data, prep WoRMS and geography data frames
x <- read.csv(here("data", "ssafs-pup-counts-full.csv")) %>% 
  mutate(eventID = paste(season_name, location, sep = "-"))


matched_taxa <- bind_rows(wm_records_names("Arctocephalus gazella")) %>% 
  rename(scientificName = "scientificname", 
         scientificNameID = lsid, 
         taxonRank = rank) %>%
  select(scientificName, scientificNameID, taxonRank, kingdom)

geography <- data.frame(
  location = c("SSI", "STI", "CS"),
  decimalLatitude = c("-62", "-62.47", "-62.47"),
  decimalLongitude = c("-58", "-60.83", "-60.77"),
  coordinateUncertaintyInMeters = c(275000, 1000, 2100), 
  locality = c(
    "South Shetland Islands", 
    "San Telmo Island", 
    "Cape Shirreff, Livingston Island"), 
  higherGeography = c(
    "Antarctica | South Shetland Islands", 
    "Antarctica | South Shetland Islands | San Telmo Island", 
    "Antarctica | South Shetland Islands | Cape Shirreff, Livingston Island"),
  higherGeographyID = c(
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131934", 
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131166", 
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131551")
)


#-------------------------------------------------------------------------------
# Create Event table
event <- x %>% 
  select(eventID, season_name, location, reference) %>% 
  left_join(geography, by = join_by(location)) %>% 
  mutate(eventDate = NA, 
         eventRemarks = NA_character_, 
         sampleSizeValue = NA_integer_,
         sampleSizeUnit = ifelse(sampleSizeValue <= 1, "day", "days"), 
         # TODO: fix dates and sampleSizeValues
         continent = "Antarctica",
         countryCode = "AQ",
         geodeticDatum = "EPSG:4326", 
         season_int = as.numeric(substr(x$season_name, 1, 4)), 
         samplingProtocol = case_when(
           season_int >= 2008 & location == "CS" ~ 
             "https://doi.org/10.3389/fmars.2021.796488", 
           season_int >= 2008 & location == "STI" ~ 
             "https://doi.org/10.1578/AM.47.4.2021.349", 
           .default = reference
         )) %>% 
  arrange(eventID) %>% 
  select(eventID, everything()) %>% 
  select(-c(season_name, location, reference, season_int))

# write to file
write_tsv(event, here("data", "dwca", "event.txt"), na = "")


#-------------------------------------------------------------------------------
# Create Occurrence table
occ <- x %>% 
  select(eventID, count, sd, reference) %>% 
  rename(individualCount = count, 
         associatedReferences = reference) %>% 
  bind_cols(matched_taxa) %>% 
  mutate(occurrenceID = paste(eventID, "SSAFS-pups", sep = "-"), 
         vernacularName = "South Shetland Antarctic fur seal", 
         #TODO: confirm basisOfRecord for averaged counts
         basisOfRecord = NA_character_, 
         # TODO confirm identificationReferences based on SSAFS strategy
         identificationReferences = "https://doi.org/10.1016/C2012-0-06919-0", 
         occurrenceStatus = "present",
         lifeStage = "pup",
         sex = "indeterminate") %>% 
  relocate(individualCount, sd, .after = sex) %>% 
  relocate(occurrenceID, .before = eventID)

# write to file
write_tsv(occ, here("data", "dwca", "occurrence.txt"), na = "")
