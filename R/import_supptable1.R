# Import and format census data and associated references from CSV files
# Info in counts and refs CSV files copied from Supp Table 1, 
# https://doi.org/10.3389/fmars.2021.796488. 
# See data/supp-table-1/README.md for more info.

library(here)
library(readr)
library(dplyr)
library(stringr)

# Read in files
path.pre <- here("data", "supp-table-1")
counts <- read_csv(here(path.pre, "supptable1-counts.csv"), col_types = "iccic")
refs <- read_csv(here(path.pre, "supptable1-references.csv"), col_types = "cc")

# Brief sanity checks
stopifnot(
  all(na.omit(counts$ReferenceLetter) %in% refs$ReferenceLetter), 
  all(refs$ReferenceLetter %in% counts$ReferenceLetter), 
  all(!is.na(refs$Reference))
)

# Join counts and references, clean data, and write dataset to CSV file
remove.regex <- paste0("[", paste(c(letters, "-"), collapse = ""), "]")

x <- left_join(counts, refs, by = join_by(ReferenceLetter)) %>% 
  select(-ReferenceLetter) %>% 
  rename(season_end = Season, location = Location, count = Count, 
         sd = SD, reference = Reference) %>% 
  mutate(count = as.integer(str_remove_all(count, remove.regex))) %>% 
  filter(!is.na(count)) %>%
  arrange(season_end)

write_csv(x, file = here(path.pre, "Krauseetal2022_counts_references.csv"), 
          na = "")
