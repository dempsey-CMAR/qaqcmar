
# test unique temp flags are 1, 3, 4
# and that get converted to the correct labels


# temperature -------------------------------------------------------------

test_that("temperature grossrange flags are assigned to correct observations", {

  expect_equal(
    sort(as.numeric(unique(qc_gr$grossrange_flag_temperature_degree_C))),
    c(1, 3, 4)
  )

  expect_equal(
    as.numeric(unique(temp_gr_1$grossrange_flag_temperature_degree_C)), 1
  )
  expect_equal(
    as.numeric(unique(temp_gr_3$grossrange_flag_temperature_degree_C)), 3
  )
  expect_equal(
    as.numeric(unique(temp_gr_4$grossrange_flag_temperature_degree_C)), 4
  )

})


# dissolved oxygen - percent saturation -----------------------------------

test_that("dissolved oxygen (percent saturation) grossrange flags
are assigned to correct observations", {

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

test_that("dissolved oxygen (concentration) grossrange flags
are assigned to correct observations", {

  expect_equal(
    sort(as.numeric(
      unique(qc_gr$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_L))
    ),
    c(1, 3, 4)
  )

  expect_equal(
    as.numeric(
      unique(do_conc_gr_1$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_L)
    ), 1
  )

  expect_equal(
    as.numeric(
      unique(do_conc_gr_3$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_L)
    ), 3
  )

  expect_equal(
    as.numeric(
      unique(do_conc_gr_4$grossrange_flag_dissolved_oxygen_uncorrected_mg_per_L)
    ), 4
  )

})

# salinity -------------------------------------------

test_that("salinity grossrange flags are assigned to correct observations", {

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
