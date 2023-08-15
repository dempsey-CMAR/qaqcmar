test_that("qc_test_spike() assigns correct flags", {
  expect_equal(as.numeric(unique(qc_sp_1$spike_flag_value)), 1)

  expect_equal(as.numeric(unique(qc_sp_2$spike_flag_value)), 2)

  expect_equal(as.numeric(unique(qc_sp_3$spike_flag_value)), 3)

  expect_equal(as.numeric(unique(qc_sp_4$spike_flag_value)), 4)
})
