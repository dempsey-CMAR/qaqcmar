
test_that("assert_county() returns errors if more than one county is detected", {

  # different county in dat compared to function argument
  expect_error(
    assert_county(
      data.frame(county = rep("x", times = 10)),
      county = "y",
      "qc_test_grossrange()")
  )

  # more than one county in dat
  expect_error(
    assert_county(
      data.frame(county = c(rep("x", 5), rep("y", 5))),
      county_arg = NULL,
      foo = "qc_test_grossrange()")
  )

  # no county specified
  expect_error(
    assert_county(
      data.frame(col1 = seq(1:10)),
      county_arg = NULL,
      foo = "qc_test_grossrange()")
  )

  # county specified in dat
  expect_equal(
    assert_county(
      data.frame(county = rep("x", 10)),
      county_arg = NULL,
      foo = "qc_test_grossrange()"),
    "x"
  )

  # county specified in arg
  expect_equal(
    assert_county(
      data.frame(col1 = seq(1:10)),
      county_arg = "y",
      foo = "qc_test_grossrange()"),
    "y"
  )

})
