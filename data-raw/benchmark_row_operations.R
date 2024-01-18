# compare different methods of finding the maximum of each row

library(microbenchmark)
library(purrr)

# benchmark 1 ---------------------------------------------------------------

y <- data.frame(
  x1 = c(1:10),
  x2 = c(5:10, 1:4)
)

microbenchmark(
  ymax <- y %>%
    rowwise() %>%
    mutate(ymax = max(c_across(contains("x")))),

  ymax2 <- y %>%
    mutate(
      ymax = pmap(., max, na.rm = TRUE),
      ymax = unlist(ymax)
    ),

  times = 100
)


# benchmark 2 -------------------------------------------------------------

y <- data.frame(
  x1 = c(1:10),
  x2 = c(5:10, 1:4),
  z3 = rep(100, 10),
  z4 = rep(NA, 10)
)

z1 <- y %>%
  mutate(
    ymax = pmap(list(x1, x2), max, na.rm = TRUE),
    ymax = unlist(ymax)
  )

z2 <- y %>%
  mutate(
    ymax = pmap(select(y, contains("x")), max, na.rm = TRUE),
    ymax = unlist(ymax)
  )

all.equal(z1, z2)


microbenchmark(
  ymax <- y %>%
    rowwise() %>%
    mutate(ymax = max(c_across(contains("x")))) %>%
    ungroup(),

  ymax2 <- y %>%
    mutate(
      ymax = pmap(select(y, contains("x")), max, na.rm = TRUE),
      ymax = unlist(ymax)
    ),

  times = 100
)

all.equal(ymax, ymax2)
all.equal(ymax, ymax2, check.attributes = FALSE)
