# temperature -------------------------------------------------------------

test_that("qc_test_grossrange() assigns correct flags to temperature data", {

  expect_equal(
    sort(as.numeric(unique(qc_gr$grossrange_flag_temperature_degree_c))),
    c(1, 3, 4)
  )
  expect_equal(
    as.numeric(unique(temp_gr_1$grossrange_flag_temperature_degree_c)), 1
  )
  expect_equal(
    as.numeric(unique(temp_gr_3$grossrange_flag_temperature_degree_c)), 3
  )
  expect_equal(
    as.numeric(unique(temp_gr_4$grossrange_flag_temperature_degree_c)), 4
  )

})


# dissolved oxygen - percent saturation -----------------------------------

test_that("qc_test_grossrange() assigns correct flags to dissolved oxygen
(percent saturation) data", {

  expect_equal(
    sort(as.numeric(
      unique(qc_gr$grossrange_flag_dissolved_oxygen_percent_saturation))
    ),
    c(1, 3, 4)
  )
  expect_equal(
    as.numeric(
      unique(do_sat_gr_1$grossrange_flag_dissolved_oxygen_percent_saturation)
    ), 1
  )
  expect_equal(
    as.numeric(
      unique(do_sat_gr_3$grossrange_flag_dissolved_oxygen_percent_saturation)
    ), 3
  )
  expect_equal(
    as.numeric(
      unique(do_sat_gr_4$grossrange_flag_dissolved_oxygen_percent_saturation)
    ), 4
  )

})


# dissolved oxygen - concentration -------------------------------------------

test_that("qc_test_grossrange() assigns correct flags to dissolved oxygen
(concentration) data", {

  expect_equal(
    sort(as.numeric(
      unique(qc_gr$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_l))
    ),
    c(1, 3, 4)
  )
  expect_equal(
    as.numeric(
      unique(do_conc_gr_1$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_l)
    ), 1
  )
  expect_equal(
    as.numeric(
      unique(do_conc_gr_3$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_l)
    ), 3
  )
  expect_equal(
    as.numeric(
      unique(do_conc_gr_4$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_l)
    ), 4
  )

})

# salinity -------------------------------------------

test_that("qc_test_grossrange() assigns correct flags to salinity data", {

  expect_equal(
    sort(as.numeric(
      unique(qc_gr$grossrange_flag_salinity_psu))
    ),
    c(1, 3, 4)
  )
  expect_equal(
    as.numeric(
      unique(salinity_gr_1$grossrange_flag_salinity_psu)
    ), 1
  )
  expect_equal(
    as.numeric(
      unique(salinity_gr_3$grossrange_flag_salinity_psu)
    ), 3
  )
  expect_equal(
    as.numeric(
      unique(salinity_gr_4$grossrange_flag_salinity_psu)
    ), 4
  )

})
