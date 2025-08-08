## Run entire pipeline

library(cmdstanr)


download_source_data <- TRUE

run_estimation <- TRUE


if (download_source_data) {
  source("code/01-retrieve-source-data.r")
}

source("code/02-prepare-voting-data.r")
source("code/03-inspect-dimensionality.r")

if (run_estimation) {
  source("code/04-estimate-positions.r")
  source("code/05-export-results.r")
}

source("code/06-display-positions.r")
