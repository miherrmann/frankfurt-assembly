## Export results to CSV files

## Summary statistics of main parameter estimates

## Point estimates (posterior means) and ci CIs for
## members' positions
## votes parameters


library(cmdstanr)


path_out_pos_members <- "results/members-positions.csv"
path_out_par_votes <- "results/votes-parameters.csv"
path_out_summary <- "results/estimates-summary.csv"

dir_result_mcmc <- "results/estimation-output"

path_in_voting <- "data/voting.csv"
path_in_names <- "data/raw/names.tab"
path_in_votes <- "data/raw/votes.tab"

ci <- 95

par_mem <- c("x_1", "x_2")
par_vot <- c("alpha", "beta_1", "beta_2")


# Import raw Stan output (MCMC samples) ----

stan_fit <-
  dir_result_mcmc |>
  file.path(list.files(dir_result_mcmc, pattern = "\\.csv$")) |>
  as_cmdstan_fit(format = "df")


# Summary statistics of parameter estimates ----

par_mem |>
  c(par_vot) |>
  stan_fit$summary() |>
  write.csv(path_out_summary, row.names = FALSE)


# Export main estimates ----

quant <- c(-1, 1) * ci / 200 + 0.5

varnames <-
  list(mem = par_mem, vot = par_vot) |>
  lapply(rep, each = 3) |>
  lapply(FUN = paste0, c("", paste0("_", ci, c("_lo", "_up"))))

idx <-
  path_in_voting |>
  read.csv() |>
  subset(select = c(id_member, id_vote)) |>
  lapply(unique)

par_mem |>
  lapply(stan_fit$summary, mean, ~ quantile(., probs = quant)) |>
  data.frame() |>
  subset(select = -c(variable, variable.1)) |>
  round(digits = 4) |>
  setNames(varnames$mem) |>
  transform(id_member = idx$id_member) |>
  merge(x = read.table(path_in_names, header = TRUE), all.y = TRUE) |>
  write.csv(path_out_pos_members, row.names = FALSE)

par_vot |>
  lapply(stan_fit$summary, mean, ~ quantile(., probs = quant)) |>
  data.frame() |>
  subset(select = -c(variable, variable.1, variable.2)) |>
  round(digits = 4) |>
  setNames(varnames$vot) |>
  transform(id_vote = idx$id_vote) |>
  merge(x = read.table(path_in_votes, header = TRUE), all.y = TRUE) |>
  write.csv(path_out_par_votes, row.names = FALSE)
