
test_that("qc_test_rate_of_change() assigns correct flags", {

  expect_equal(as.numeric(unique(qc_roc_1$rate_of_change_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_roc_2$rate_of_change_flag_value)), 2)

  expect_equal(as.numeric(unique(qc_roc_3$rate_of_change_flag_value)), 3)

})

