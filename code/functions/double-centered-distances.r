## Helper function

## Compute double-centered (i.e. row and column-standardized)
## distances between rows of input matrix
## Input: matrix
## Output: square symmetrical matrix



double_center <- function(mat) {

  na <- 0.25

  dissim <-
    mat |>
    dist(method = "manhattan") |>
    as.matrix() / ncol(mat)

  sq_dist <- dissim^2 |> replace(is.na(dissim), values = na)

  (scale(sq_dist, scale = FALSE) - rowMeans(sq_dist) + mean(sq_dist)) / -2

}
