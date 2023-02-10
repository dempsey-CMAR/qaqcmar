
test_that("qc_test_grossrange() assigns correct flags", {

  expect_equal(as.numeric(unique(qc_gr_1$grossrange_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_gr_3$grossrange_flag_value)), 3)

  expect_equal(as.numeric(unique(qc_gr_4$grossrange_flag_value)), 4)

  expect_equal(
    sort(as.numeric(unique(qc_gr$grossrange_flag_value))), c(1, 3, 4)
  )

})

