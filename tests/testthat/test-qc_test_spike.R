
test_that("qc_test_spike() assigns 'Not evaluated' to first and last observation", {

 expect_equal(as.numeric(unique(qc_sp_2$spike_flag_value)), 2)

})

# temperature -------------------------------------------------------------

test_that("qc_test_spike() assigns correct flags to temperature data", {

  expect_equal(
    as.numeric(unique(temp_sp_1$spike_flag_temperature_degree_C)), 1
  )
  expect_equal(
    as.numeric(unique(temp_sp_3$spike_flag_temperature_degree_C)), 3
  )
  expect_equal(
    as.numeric(unique(temp_sp_4$spike_flag_temperature_degree_C)), 4
  )

})


# dissolved oxygen - concentration -----------------------------------------

test_that("qc_test_spike() assigns correct flags to dissolved oxygen concentration data", {

  expect_equal(
    as.numeric(unique(
      do_conc_sp_1$spike_flag_dissolved_oxygen_uncorrected_mg_per_L
    )), 1
  )
  expect_equal(
    as.numeric(unique(
      do_conc_sp_3$spike_flag_dissolved_oxygen_uncorrected_mg_per_L
    )), 3
  )
  expect_equal(
    as.numeric(unique(
      do_conc_sp_4$spike_flag_dissolved_oxygen_uncorrected_mg_per_L
    )), 4
  )

})

# dissolved oxygen - percent saturation -----------------------------------------

test_that("qc_test_spike() assigns correct flags to dissolved oxygen percent saturation data", {

  expect_equal(
    as.numeric(unique(
      do_sat_sp_1$spike_flag_dissolved_oxygen_percent_saturation
    )), 1
  )

  expect_equal(
    as.numeric(unique(
      do_sat_sp_4$spike_flag_dissolved_oxygen_percent_saturation
    )), 4
  )

})


# salinity ----------------------------------------------------------------

test_that("qc_test_spike() assigns correct flags to salinity data", {

  expect_equal(
    as.numeric(unique(
      sal_sp_1$spike_flag_salinity_psu
    )), 1
  )

  expect_equal(
    as.numeric(unique(
      sal_sp_3$spike_flag_salinity_psu
    )), 3
  )

  expect_equal(
    as.numeric(unique(
      sal_sp_4$spike_flag_salinity_psu
    )), 4
  )

})
