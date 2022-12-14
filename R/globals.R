# Need this so that package will play nice with dplyr package
# https://community.rstudio.com/t/how-to-solve-no-visible-binding-for-global-variable-note/28887
# more technical solution here: https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html

# other technical solution here:
# https://dplyr.tidyverse.org/articles/programming.html


utils::globalVariables(
  c(

    "sensor_serial_number",

    # qc_test_climatology
    "flag",
    "season_max",
    "season_min",
    "season",
    "tstamp",
    "climatology_flag",
    "numeric_month",
    "threshold_tables",

    # qc_test_grossrange
    "sensor",
    "sensor_type",
    "sensor_max",
    "sensor_min",
    "user_max",
    "user_min",
    "timestamp_utc",
    "grossrange_flag",
    "variable",
    "value",

    # qc_test_spike
    "lag_value",
    "lead_value",
    "spike_ref",
    "spike_flag",
    "spike_value",
    "threshold_high",
    "threshold_low",

    # qc_assign_max_flag
    "qc_col",
    "qc_flag",

    # ggplot_all_tests
    "depth",
    "sensor_depth_at_low_tide_m"


  )
)
