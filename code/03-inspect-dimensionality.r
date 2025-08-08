## Inspect dimensionality

## Scree plot of first n_eigen (standardized) eigenvalues of
## double-centered distance matrix (cf. Poole 2005)


path_out <- "results/dimensions.png"
path_in <- "data/voting.csv"

n_eigen <- 10

pix_width <- 450
pix_resolution <- 110


# Helper function ----

source("code/functions/double-centered-distances.r")


# Normalized eigenvalues ----

eigenval <-
  path_in |>
  read.csv() |>
  reshape(direction = "wide", timevar = "id_vote", idvar = "id_member") |>
  subset(select = -id_member) |>
  double_center() |>
  eigen(symmetric = TRUE, only.values = TRUE) |>
  with(values / sqrt(sum(values^2)))


# Scree plot ----

png(path_out, width = pix_width, height = pix_width, res = pix_resolution)

plot(
  eigenval[seq_len(n_eigen)],
  ylab = "Eigenvalue",
  xlab = "Dimension",
  type = "b",
  pch = 16,
  cex = 0.6
)

axis(1, at = seq_len(n_eigen))

dev.off()
