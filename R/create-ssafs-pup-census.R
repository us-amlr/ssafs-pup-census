# Combine SSAFS pup census data form historical data CSV and database

# TODO: better name for this file and data set
# TODO: create CSV for STI counts, future non-CS counts

library(dplyr)
library(readr)
library(here)
library(lubridate)
library(tamatoamlr)


#-------------------------------------------------------------------------------
### Pull data from database, from 2008/09 and onwards
con <- amlr_dbConnect(Database = "***REMOVED***")
pup.cs.view <- tbl(con, "vCensus_AFS_Capewide_Pup") %>%
  filter(exclude_count == 0) %>%
  arrange(census_date, observer, location) %>%
  collect()

pup.cs <- cwp_total(pup.cs.view) %>%
  mutate(count_mean = round_logical(count_mean, 0),
         count_sd = round_logical(count_sd, 2), 
         location = "CS", 
         census_date_est = amlr_date_from_season(season_name, m = 1, d = 1)) %>% 
  filter(census_date_est > ymd("2008-07-01")) %>% 
  rename(count = count_mean, sd = count_sd) %>% 
  select(-c(census_date_est, research_program))


#-------------------------------------------------------------------------------
# Read in SuppTable1 data from CSV file
counts.historical.orig <- read_csv(
  here("data", "supp-table-1", "ssafs_pup_census_historical_counts.csv"), 
  col_types ="iciic"
)

# Process, including removing data that has been superseded by data from database
counts.historical <- counts.historical.orig %>% 
  filter(!(location == "CS" & season_end >= 2009)) %>% 
  mutate(season_name = amlr_season_from_date(ymd(paste0(season_end, "-01-01"))), 
         .after = season_end) %>% 
  select(-c(season_end))


#-------------------------------------------------------------------------------
# TODO: 2022/23 STI count, other?

#???: have data/input: in input folder is supptable1 stuff, STI, other.?

#-------------------------------------------------------------------------------
# Combine, and write to CSV file
x <- bind_rows(counts.historical, pup.cs) %>% 
  arrange(season_name, location)
