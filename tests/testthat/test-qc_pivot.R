test_that("qc_pivot_longer() returns correct number of flag columns", {
  expect_equal(
    ncol(select(dat_long, contains("flag"))), length(qc_tests))
})
