# Write SSAFS pup census data to Darwin Core-compliant files

library(dplyr)
library(worrms)
library(here)
library(readr)
library(glue)
library(odbc)


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
    "Antarctica | South Shetland Islands | San Telmo Islands", 
    "Antarctica | South Shetland Islands | Cape Shirreff, Livingston Island"),
  higherGeographyID = c(
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131934", 
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131166", 
    "https://data.aad.gov.au/aadc/gaz/scar/display_name.cfm?gaz_id=131551")
)

# Get start dates as possible
con <- dbConnect(odbc(), filedsn = here("amlr-pinniped-db-prod.dsn"))
census.dates <- tbl(con, "vCensus_AFS_Capewide_Pup") %>%
  filter(exclude_count == 0, 
         census_date > as.Date("2008-07-01")) %>% 
  collect() %>% 
  group_by(season_name) %>% 
  summarise(census_date_start = min(census_date), 
            .groups = "drop")


#-------------------------------------------------------------------------------
# Event info prep
eventID.jan.early <- c(
  "2001/02-CS", "2001/02-STI",
  "2007/08-CS", "2007/08-SSI", "2007/08-STI"
)
eventID.jan.late <- c("1958/59-CS", "1965/66-CS")

eventID.feb.early <- c(
  "1986/87-CS", "1986/87-SSI", "1986/87-STI", "1995/96-SSI", "1995/96-STI", 
  "2001/02-SSI"
)
eventID.feb.mid <- c("1970/71-CS", "1972/73-CS", "1972/73-STI")
eventID.feb.late <- c("1991/92-SSI", "1991/92-STI")
eventID.feb <- c(eventID.feb.early, eventID.feb.mid, eventID.feb.late)


#-------------------------------------------------------------------------------
# Create Event table
event <- x %>% 
  select(eventID, season_name, location, reference, season_year) %>% 
  left_join(geography, by = join_by(location)) %>% 
  left_join(census.dates, by = join_by(season_name)) %>% 
  mutate(continent = "Antarctica",
         countryCode = "AQ",
         geodeticDatum = "EPSG:4326", 
         eventDate = case_when(
           !is.na(census_date_start) ~ as.character(census_date_start), 
           eventID %in% eventID.feb ~ glue("{season_year}-02"), 
           .default = glue("{season_year}-01")
         ), 
         verbatimEventDate = case_when(
           eventID %in% eventID.jan.early ~ glue("early January {season_year}"), 
           eventID %in% eventID.jan.late ~ glue("late January {season_year}"), 
           eventID %in% eventID.feb.early ~ glue("early February {season_year}"), 
           eventID %in% eventID.feb.mid ~ glue("mid February {season_year}"), 
           eventID %in% eventID.feb.late ~ glue("late February {season_year}"), 
           nchar(eventDate) == 7 ~ glue("January {season_year}"),
           .default = NA_character_
         ), 
         eventRemarks = case_when(
           eventID == "2021/22-CS" ~ 
             paste("Note that census was conducted earlier", 
                   "due to field season timing constraints"), 
           nchar(verbatimEventDate) == 12 ~ "census date assumed", 
           .default = NA_character_
         ), 
         samplingProtocol = case_when(
           season_year >= 2009 & location == "CS" ~ 
             "https://doi.org/10.3389/fmars.2021.796488", 
           season_year >= 2009 & location == "STI" ~ 
             "https://doi.org/10.1578/AM.47.4.2021.349", 
           .default = reference
         )) %>% 
  arrange(eventID) %>% 
  select(eventID, everything()) %>% 
  select(-c(season_name, location, reference, season_year, census_date_start))

# write to file
write_tsv(event, here("data", "dwca", "event.txt"), na = "")
# write_csv(event, here("data", "dwca", "event.csv"), na = "")


#-------------------------------------------------------------------------------
# Create Occurrence table
occ <- x %>% 
  select(eventID, count, sd, reference) %>% 
  rename(associatedReferences = reference) %>% 
  bind_cols(matched_taxa) %>% 
  mutate(occurrenceID = paste(eventID, "SSAFS-pups", sep = "-"), 
         vernacularName = "South Shetland Antarctic fur seal", 
         organismName = "South Shetland Islands Antarctic fur seal subpopulation", 
         organismScope = "subpopulation", 
         basisOfRecord = "HumanObservation", 
         occurrenceStatus = "present",
         lifeStage = "pup",
         sex = "indeterminate", 
         organismQuantity = count, 
         organismQuantityType = "average individual count", 
         occurrenceRemarks = case_when(
           !is.na(sd) ~ paste(
             "the standard deviation of the individual counts is:",  sd), 
           .default = NA_character_), 
         identificationReferences = "https://doi.org/10.1016/C2012-0-06919-0") %>% 
  relocate(occurrenceID, .before = eventID) %>% 
  select(-c(count, sd))

# write to file
write_tsv(occ, here("data", "dwca", "occurrence.txt"), na = "")
# write_csv(occ, here("data", "dwca", "occurrence.csv"), na = "")
