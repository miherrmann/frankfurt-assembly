## Map of Frankfurt Assembly

## Members' positions and votes' cutlines
## letters: club membership according to Koch et al. (1989)
## markers: size proportional to number of votes that member participated in


path_out_map <- "results/map-fa.png"

path_in_pos_members <- "results/members-positions.csv"
path_in_par_votes <- "results/votes-parameters.csv"
path_in_voting <- "data/voting.csv"
path_in_clubs <- "data/raw/clubs.tab"

clubs_codes <- c(
  "Augsburger Hof" = "A",
  "Casino" = "C",
  "Deutscher Hof" = "D",
  "Donnersberg" = "B",
  "Landsberg" = "L",
  "Café Milani" = "M",
  "Westendhall" = "H",
  "Neuwestendhall" = "H",
  "Württemberger Hof" = "W",
  "Pariser Hof" = "",
  "Nürnberger Hof" = "",
  "unaffiliated" = ""
)

pix_width <- 2700
pix_resolution <- 200
font_family <- "serif"

id_vote_left <- 127
id_vote_up <- 159


# Read data ----

pos_mem <- read.csv(path_in_pos_members)
par_vot <- read.csv(path_in_par_votes)
voting <- read.csv(path_in_voting)
clubs <- read.table(path_in_clubs, header = TRUE)


# Inputs for plot ----

markers <-
  clubs |>
  split(f = ~ id_member) |>
  lapply(FUN = "[", i = 1, j = c("id_member", "club")) |>
  do.call(what = rbind) |>
  merge(y = subset(pos_mem, select = id_member), all.y = TRUE) |>
  transform(club = replace(club, is.na(club), values = "unaffiliated")) |>
  transform(code = clubs_codes[club]) |>
  transform(
    symbol = ifelse(
      code == "",
      yes = 19,
      no = as.integer(sapply(code, charToRaw))
    )
  ) |>
  transform(color = ifelse(code == "", yes = "red", no = "black")) |>
  transform(
    size = as.vector(with(voting, table(id_member) / max(table(id_member))))
  )

cutlines <-
  par_vot |>
  transform(intercept = alpha / beta_2) |>
  transform(slope = -beta_1 / beta_2) |>
  subset(!is.infinite(intercept) & !is.infinite(slope)) |>
  subset(select = c(intercept, slope)) |>
  list(ab = _) |>
  append(
    par_vot |>
      subset(id_vote == id_vote_left, select = c(alpha, beta_1)) |>
      with(alpha / beta_1) |>
      list(v = _)
  )

at <-
  par_vot |>
  subset(id_vote %in% c(id_vote_left, id_vote_up)) |>
  transform(
    at = ifelse(
      id_vote == id_vote_left,
      yes = alpha / beta_1,
      no = alpha / beta_2
    )
  ) |>
  transform(side = ifelse(id_vote == id_vote_left, yes = 1, no = 2)) |>
  with(setNames(rep(at, times = 2), nm = c(side, side + length(side))))


# Plot -----

png(
  path_out_map,
  width = pix_width,
  height = pix_width,
  res = pix_resolution,
  family = font_family
)

par(bg = "antiquewhite2")

pos_mem |>
  subset(select = c(x_1, x_2)) |>
  plot(type = "n", axes = FALSE, xlab = "", ylab = "")

title(
  xlab = "Republican     -     Monarchist",
  ylab = "Greater Germany     -     Lesser Germany",
  line = 1.5,
  cex.lab = 2
)

cutlines |>
  getElement("ab") |>
  apply(MARGIN = 1, FUN = abline, col = "antiquewhite3", lwd = 0.5) |>
  invisible()

cutlines |>
  getElement("v") |>
  abline(v = _, col = "antiquewhite3", lwd = 0.5)

1:4 |>
  lapply(\(.side) rug(at[.side], side = .side, ticksize = 0.02)) |>
  invisible()

pos_mem |>
  subset(select = c(x_1, x_2)) |>
  points(pch = markers$symbol, col = markers$color, cex = 0.5 + markers$size)

box(col = "antiquewhite1")

dev.off()
