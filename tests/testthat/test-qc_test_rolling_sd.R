
test_that("qc_test_rolling_sd() assigns correct flags", {

  expect_equal(as.numeric(unique(qc_roc_1$rolling_sd_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_roc_2$rolling_sd_flag_value)), 2)

  expect_equal(as.numeric(unique(qc_roc_3$rolling_sd_flag_value)), 3)

})

