
test_that("qc_test_rolling_sd() assigns correct flags", {

  expect_equal(as.numeric(unique(qc_roll_sd_1$rolling_sd_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_roll_sd_2$rolling_sd_flag_value)), 2)

  expect_equal(as.numeric(unique(qc_roll_sd_3$rolling_sd_flag_value)), 3)

})

test_that("qc_test_rolling_sd() assigns 2 for intervals > min_sample_interval", {

  expect_equal(as.numeric(unique(qc_roll_int$rolling_sd_flag_value)), 2)

})

