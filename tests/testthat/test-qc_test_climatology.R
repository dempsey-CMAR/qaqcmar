
test_that("qc_test_climatology() assigns correct flags", {

  expect_equal(as.numeric(unique(qc_cl_1$climatology_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_cl_2$climatology_flag_value)), 2)

  expect_equal(as.numeric(unique(qc_cl_3$climatology_flag_value)), 3)

})
