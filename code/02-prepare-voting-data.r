## Data preparation

## Drop election of Vicar of the Empire (not Yes/No)
## Recode vote of emperor to Yes/No
## Convert to binary: No = 0, Yes = 1
## Drop abstentions and absentees
## Keep members who voted at least min_votes times


path_out <- "data/voting.csv"

path_in_voting <- "data/raw/behaviour.tab"
path_in_votes <- "data/raw/votes.tab"

min_votes <- 5

id_vote_vicar <- 10
id_vote_emperor <- 259

vote_recode_emperor <- c(
  "König von Preußen" = 1,
  "Enthaltung" = 0
)

vote_recode <- c(
  "Ja" = 1,
  "Nein" = 0
)

voting <-
  path_in_voting |>
  read.table(header = TRUE) |>
  subset(id_vote != id_vote_vicar) |>
  transform(
    outcome = ifelse(id_vote == id_vote_emperor,
      yes = vote_recode_emperor[vote],
      no = vote_recode[vote]
    )
  ) |>
  subset(outcome %in% vote_recode) |>
  split(f = ~ id_member) |>
  lapply(\(.df) transform(.df, n_votes = nrow(.df))) |>
  do.call(what = rbind) |>
  subset(n_votes >= min_votes, select = c(id_vote, id_member, outcome))

voting |>
  write.csv(path_out, row.names = FALSE)
