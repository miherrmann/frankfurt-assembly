## Estimation of positions

## Bayesian 2D ideal point estimation using Stan (HMC/NUTS)

## Scale identified by rescaling positions to mean = 0 and SD = 1

## Dimensions identified by making two landmark decisions orthogonal
## 1st: vote on emperor's veto rights - ID: 127
## 2nd: vote on entering negotiations with Austria - ID: 159

## Directions identified through content of landmark decisions
## 1st: (republican) less veto power --- more veto power (monarchist)
## 2nd: (Greater Germany) with Austria --- without Austria (Lesser Germany)


## Starting values as suggested in

## Poole, Keith T. 2005. Spatial Models of Parliamentary Voting. Cambridge
## University Press: 130-4

## Positions: eigenvectors of double-centered distance matrix scaled such
## that maximum distance from origin is radius_max (Poole uses 1)

## Vote parameters: logit regressions


library(cmdstanr)


path_in <- "data/voting.csv"
path_stan_file <- "code/model.stan"

basename_files_mcmc <- "scaling-fa"
dir_result_mcmc <- "results/estimation-output"

n_chains <- 4
n_samples <- 3000
n_warmup <- 1000
stan_seed <- 876543

id_vote_left <- 127
id_vote_up <- 159


# Helper function ----

source("code/functions/double-centered-distances.r")


# Read data ----

voting <- read.csv(path_in)


# Starting values ----

radius_max <- 4
dims_keep <- 1:2

voting_mat <-
  voting |>
  reshape(direction = "wide", timevar = "id_vote", idvar = "id_member") |>
  data.frame(row.names = "id_member")

eigenvec <-
  voting_mat |>
  as.matrix() |>
  double_center() |>
  eigen(symmetric = TRUE) |>
  _$vectors[, dims_keep]

inv_eta <-
  eigenvec^2 |>
  rowSums() |>
  sqrt() |>
  max() / radius_max

x_init <-
  (eigenvec / inv_eta) |>
  data.frame() |>
  setNames(c("x_1_star", "x_2_star"))

ab_init <-
  voting_mat |>
  lapply(
    \(.y) suppressWarnings(glm(.y ~ as.matrix(x_init), family = binomial()))
  ) |>
  sapply(coef) |>
  t() |>
  data.frame() |>
  setNames(c("alpha_star", "beta_1_star_free", "beta_2_star_free"))

rm(voting_mat)


# Stan inputs ----

idx_member <- setNames(
  seq_along(unique(voting$id_member)),
  nm = unique(voting$id_member)
)

idx_vote <- setNames(
  seq_along(unique(voting$id_vote)),
  nm = unique(voting$id_vote)
)

stan_data <- list(
  N = nrow(voting),
  I = max(idx_member),
  J = max(idx_vote),
  behaviour = as.integer(voting$outcome),
  member = idx_member[as.character(voting$id_member)],
  vote = idx_vote[as.character(voting$id_vote)],
  not_vote_left = idx_vote[setdiff(names(idx_vote), id_vote_left)],
  not_vote_up = idx_vote[setdiff(names(idx_vote), id_vote_up)],
  vote_left = idx_vote[as.character(id_vote_left)],
  vote_up = idx_vote[as.character(id_vote_up)]
)

stan_inits <-
  ab_init |>
  as.list() |>
  within(
    expr = {
      beta_1_star_free <-
        beta_1_star_free[-idx_vote[as.character(id_vote_up)]]
      beta_2_star_free <-
        beta_2_star_free[-idx_vote[as.character(id_vote_left)]]
    }
  ) |>
  append(x_init) |>
  list() |>
  rep(n_chains) |>
  setNames(paste0("chain_", seq_len(n_chains)))


# Stan estimation ----

model <- cmdstan_model(path_stan_file)

stan_fit <- model$sample(
  data = stan_data,
  init = stan_inits,
  seed = stan_seed,
  chains = n_chains,
  parallel_chains = n_chains,
  iter_sampling = n_samples,
  iter_warmup = n_warmup
)

stan_fit$save_output_files(
  dir_result_mcmc,
  basename = basename_files_mcmc,
  timestamp = FALSE,
  random = FALSE
)
