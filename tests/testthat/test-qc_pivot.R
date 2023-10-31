test_that("qc_pivot_longer() returns correct number of flag columns", {
  expect_equal(
    # this will not always be true - depends on which vars and qc_tests are included
    ncol(select(dat_long, contains("flag"))), (n_var * length(qc_tests) - 1)
  )
})
