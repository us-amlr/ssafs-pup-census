# Create full SSAFS pup census data, from input CSVs and database

library(here)
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(tamatoamlr)
library(odbc)


################################################################################
# Read in, process, and join input files
path.in <- here("data", "input")
locations.values <- c("SSI", "STI", "CS")


#-------------------------------------------------------------------------------
# Import and format census data and associated references from Supp Table 1 CSV
# files. Info in counts and refs CSV files copied from Supp Table 1,
# https://doi.org/10.3389/fmars.2021.796488. See README.md for more info.

# Read in files
st1.counts <- read_csv(here(path.in, "supptable1-counts.csv"), 
                       col_types = "iccic")
st1.refs <- read_csv(here(path.in, "supptable1-references.csv"), 
                     col_types = "cc")

# Brief sanity checks
stopifnot(
  all(na.omit(st1.counts$ReferenceLetter) %in% st1.refs$ReferenceLetter), 
  all(st1.refs$ReferenceLetter %in% st1.counts$ReferenceLetter), 
  all(!is.na(st1.refs$Reference)), 
  all(st1.counts$Location %in% locations.values)
)

# Join counts and references and clean data
toremove.regex <- paste0("[", paste(c(letters, "-"), collapse = ""), "]")

supp.table1 <- left_join(st1.counts, st1.refs, 
                         by = join_by(ReferenceLetter)) %>% 
  select(-ReferenceLetter) %>% 
  rename(season_end = Season, location = Location, count = Count, 
         sd = SD, reference = Reference) %>% 
  mutate(count = as.integer(str_remove_all(count, toremove.regex))) %>% 
  filter(!is.na(count)) %>%
  arrange(season_end) %>% 
  filter(!(location == "CS" & season_end >= 2009)) %>% 
  mutate(season_name = amlr_season_from_date(ymd(paste0(season_end, "-01-01"))), 
         .before = 1) %>% 
  select(-c(season_end))


#-------------------------------------------------------------------------------
# Pull data from database, from 2008/09 and onwards
con <- dbConnect(odbc(), filedsn = here("amlr-pinniped-db-prod.dsn"))
cs.counts.view <- tbl(con, "vCensus_AFS_Capewide_Pup") %>%
  filter(exclude_count == 0) %>%
  filter(season_name != "2024/25") %>%
  arrange(census_date, observer, location) %>%
  collect()

dates <- cs.counts.view %>% 
  filter(census_date > as.Date("2008-07-01")) %>% 
  group_by(season_name) %>% 
  summarise(census_date_start = min(census_date), 
            census_date_end = max(census_date), 
            census_days = as.numeric(difftime(census_date_end, census_date_start, 
                                              units = "days")), 
            .groups = "drop")

cs.counts <- cwp_total(cs.counts.view) %>%
  mutate(count_mean = round_logical(count_mean, 0),
         count_sd = round_logical(count_sd, 2), 
         location = "CS", 
         census_date_tmp = amlr_date_from_season(season_name, m = 1, d = 1)) %>% 
  filter(census_date_tmp > ymd("2008-07-01")) %>% 
  rename(count = count_mean, sd = count_sd) %>% 
  select(-c(census_date_tmp, research_program))


#-------------------------------------------------------------------------------
# Import 'other' counts, meaning counts not in supp table 1 or ***REMOVED***
# E.g.,  STI counts
other.counts <- read_csv(here(path.in, "other-counts.csv"), 
                         col_types = "cDcddc") %>% 
  select(-census_date)

stopifnot(
  all(nchar(other.counts$season_name) == 7), 
  all(other.counts$location %in% locations.values)
)


################################################################################
# Combine data sets, and write to CSV file
ssafs.pup.counts <- bind_rows(supp.table1, cs.counts, other.counts) %>% 
  mutate(season_year = amlr_year_from_season(season_name), 
         reference = case_when(
           is.na(reference) & between(season_year, 2009, 2020) ~ 
             "https://doi.org/10.3389/fmars.2021.796488", 
           (season_year == 2023) ~ "https://doi.org/10.1111/mam.12327", 
           # between(season_year, 2010, 2020) & (location == "STI") ~ 
           #   "https://doi.org/10.1578/AM.47.4.2021.349", 
           .default = reference
         )) %>% 
  arrange(season_name, location)


stopifnot(
  all(nchar(ssafs.pup.counts$season_name) == 7), 
  all(ssafs.pup.counts$location %in% locations.values), 
  nrow(ssafs.pup.counts) == 
    with(ssafs.pup.counts, n_distinct(season_name, location))
)

write_csv(
  ssafs.pup.counts, 
  file = here("data", "ssafs-pup-counts-full.csv"), 
  na = ""
)

################################################################################
