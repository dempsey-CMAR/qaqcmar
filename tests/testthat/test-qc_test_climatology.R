test_that("qc_test_climatology() assigns correct flags", {
  expect_equal(as.numeric(unique(qc_cl_1$climatology_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_cl_3$climatology_flag_value)), 3)

  expect_equal(sort(as.numeric(unique(qc_cl$climatology_flag_value))), c(1, 3))
})
