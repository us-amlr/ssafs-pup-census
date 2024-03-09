# ssafs-pup-census

South Shetland Antarctic fur seal (SSAFS) total synoptic pup counts

Most of this dataset is published in [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488). Please contact the authors if you wish to use this data immediately.

This dataset is in the process of being published to the SCAR Antarctic Biodiversity Portal ([www.biodiversity.aq](www.biodiversity.aq), via the Integrated Publishing Toolkit at [ipt.biodiversity.aq](ipt.biodiversity.aq)).

## data

The data directory contains several forms of the SSAFS Pup Census data, contained in various data directory sub-folders. This section describes the contents of said sub-folders.

### dwca

Darwin Core Archive files for the SSAFS Pup Census data. These data are published at <TODO>. These files were generated using \<todo.R\>

### tmp

### supp-table-1

As described at the top of this repo, most of ssafs-pup-census data set is published in [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488). This data/supp-table-1 folder, along with the companion R script described below, contains and represents the formatting of these data such that they can easily be read into R when creating the complete data set. Specifically:

-   supptable1-counts.csv contains the counts from [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488) Supplementary Table 1, copied as long data into a CSV file. supptable1-references.csv is the reference key for the letter-reference pairs presented in Supplementary Table 1. The data in these CSV files can be joined using the 'ReferenceLetter' column.

-   [R/import_supptable1.R](R/import_supptable1.R) reads in supptable1-counts.csv and supptable1-references.csv, joins and processes them, and then writes the processed data to [Krauseetal2022_counts_references.csv](data/supp-table-1/Krauseetal2022_counts_references.csv). Krauseetal2022_counts_references.csv is what is used by later code to generate the full data set.22_counts_references.csv is what is used by later code to generate the full data set.

## Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an 'as is' basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.
