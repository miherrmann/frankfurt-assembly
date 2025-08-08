## Download source data files

## Voting in the Frankfurt Assembly Dataset
## https://doi.org/10.7910/DVN/E8XB5N


sources <- "data-sources.csv"

sources |>
  read.csv() |>
  with(mapply(download.file, url = url, destfile = path_save))
