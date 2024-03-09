# Write SSAFS pup census data to Darwin Core-compliant files

library(dplyr)
# library(worrms)
library(here)
library(tamatoamlr)

con <- amlr_dbConnect("***REMOVED***")

#-------------------------------------------------------------------------------
### Pull data from db
pup.cs.view <- tbl(con, "vCensus_AFS_Capewide_Pup") %>%
  filter(exclude_count == 0) %>%
  arrange(season_name, observer, location) %>%
  collect()

pup.cs <- cwp_total(pup.cs.view)%>%
  mutate(count_mean = round_logical(count_mean, 0),
         count_sd = round_logical(count_sd, 2))


ssafs.counts.other <- read_csv()


# supp.table1 <- tibble(
#   # season_name = paste(1991:2022, c(92:99, sprintf("%02d", 0:23)), sep = "/"),
#   season_name = paste(2008:2019, sprintf("%02d", 9:20), sep = "/"),
#   SuppTable1 = c(4598, 4007, 3677, 3328, 2796, 2306, 2130,
#                  1681, 1546, 1267, 1064, 860)
# )

# ssafs.counts <- tribble(
#   ~Season, ~location, ~count, 
#   1987, "SSI", 3824,
#   1992, "SSI", 5313,
#   1996, "SSI", 9530, 
#   2002, "SSI", 10057, 
#   2008, "SSI", 7602, 
#   1973, "STI", 
#   1987, "STI", 
#   1992, "STI", 
#   1993, "STI", 
#   1994, "STI", 
#   1995, "STI", 
#   1996, "STI", 
#   1997, "STI", 
#   1998, "STI", 
#   1973, "STI", 
#   1973, "STI", 
#   1973, "STI", 
#   1973, "STI", 
#   1973, "STI", 
# )
# 
# #--------------------------------------------------
# # Using these vars, write single season summaries out for Doug
# 
# #--------------------------------------------------
# 
# z.summ <- afs_cwp_totals(z.summ.loc, x.bylocation = TRUE) %>% 
#   select(-research_program) %>% 
#   left_join(supp.table1, by = join_by(season_name)) %>%
#   mutate(count_mean = round_logical(count_mean, 0),
#          count_sd = round_logical(count_sd, 2), 
#          diff_SuppTable1 = if_else(
#            abs(SuppTable1 - count_mean) > 0, 
#            count_mean - SuppTable1, NA_integer_))
# 
# if (write.gs4) write_sheet(z.summ, ss = sheet.id, sheet = "totals")