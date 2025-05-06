# ssafs-pup-census

<!-- badges: start 
[![DwCA](https://img.shields.io/badge/DwC–A%20Dataset-10.48361/gklk1u-violet)](https://doi.org/10.48361/gklk1u)
-->
DwCA DOI: in progress 
[![DOI](https://zenodo.org/badge/713157807.svg)](https://doi.org/10.5281/zenodo.15320134)
<!-- badges: end -->

South Shetland Antarctic fur seal (SSAFS) total synoptic pup counts. This repository is an R project that contains the data, code, and documentation relevant to the SSAFS pup census data set. Repo contents and structure are described below.

These data are in the process of being published to the SCAR Antarctic Biodiversity Portal at [biodiversity.aq](https://www.biodiversity.aq/).

An earlier version of this data set was published in [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488). See this manuscript for additional descriptions of or references to methods, other context, etc.

Meeting notes and decisions can be found [here](https://docs.google.com/document/d/1MU3mVxg_tjE_4HEOOJUf_ttoTV5eUMsgirkhnyg0oZY/edit?usp=sharing) (project authors only).

This project uses [renv](https://github.com/rstudio/renv/) to manage the project environment. Users can clone this repo and run `renv::restore()` as described in the [renv docs](https://rstudio.github.io/renv/).

## Repo structure

```
├── data
    ├── dwca      : Darwin Core Archive tables; presented in the manuscript
    ├── input     : standardized CSV files; referenced in the manuscript
    ├── ssafs-pup-counts-full.csv : described below
├── R
    ├── data-to-dwca.R : generating DwCA tables for publication at biodiversity.aq
    ├── create-ssafs-pup-census-full.R : create full SSAFS pup copunt data set
    ├── plot.R         : standard AMLR plot of the full SSAFS pup count data set
├── references : downloaded reference files
├── renv       : renv files, for managing renv environment
```

## data

The [data](data) directory contains SSAFS pup census input data files, the full and standardized data set, and the Darwin Core Archive files.

### dwca

SSAFS Pup Census Darwin Core Archive files. These data are published at <in progress>. These files were generated using [data-to-dwca.R](R/data-to-dwca.R).

### ssafs-pup-counts-full.csv

[ssafs-pup-counts-full.csv](data/ssafs-pup-counts-full.csv) is the full SSAFS Pup Census data set, presented as a long data CSV file. It is created by [create-ssafs-pup-census-full.R](R/create-ssafs-pup-census-full.R). This file contains the following columns:

-   season_name: the season of the census. For instance, "2022/23" means the census happened during the 2022-2023 austral summer (late December or early January).

-   location: the location of the census. SSI means South Shetland Islands, STI means San Telmo Island, and CS means Cape Shirreff.

-   count, sd: The census count and standard deviation values, respectively. Standard deviation values only exist when all individual observer census counts are available.

-   reference: The reference in which the census count was originally published, as applicable. All records without a reference were collected by the [U.S. AMLR Program](https://www.fisheries.noaa.gov/international/science-data/pinniped-research-antarctic), following sampling protocols described in [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488) or [Krause and Hinke 2021](https://doi.org/10.1578/AM.47.4.2021.349) for Cape Shirreff and San Telmo Island counts, respectively.

-   season_year: The 'AMLR year' of the austral summer field season. The AMLR year is the year that begins in January. For instance, for the '2000/01' season, the AMLR year is '2001.

### input

Input files used by [create-ssafs-pup-census-full.R](R/create-ssafs-pup-census-full.R) to create the full SSAFS Pup Census data set. Specifically:

-   [supptable1-counts.csv](data/input/supptable1-counts.csv) contains the counts from [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488) Supplementary Table 1, copied as long data into a CSV file. [supptable1-references.csv](data/input/supptable1-references.csv) is the reference key for the letter-reference pairs presented in Supplementary Table 1. The data in these CSV files can be joined using the 'ReferenceLetter' column.

-   [other-counts.csv](data/input/other-counts.csv) contains other SSAFS pup census counts. Here, 'other counts' means counts that are not a) presented in [Krause et al. 2022](https://doi.org/10.3389/fmars.2021.796488) Supplementary Table 1, or b) of SSAFS at Cape Shirreff recorded in the U.S. AMLR Pinnipeds database.

## Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an 'as is' basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.
