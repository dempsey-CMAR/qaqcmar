# Need this so that package will play nice with dplyr package
# https://community.rstudio.com/t/how-to-solve-no-visible-binding-for-global-variable-note/28887
# more technical solution here: https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html

# other technical solution here:
# https://dplyr.tidyverse.org/articles/programming.html


utils::globalVariables(
  c(
    # qc_test_climatology
    "flag",
    "seasonmax",

    "seasonmax",
    "seasonmin",

    # qc_test_grossrange
    "sensor",
    "sensormax",
    "sensormin",
    "usermax",
    "usermin",
    "timestamp_utc",

    "TIMESTAMP"
  )
)
