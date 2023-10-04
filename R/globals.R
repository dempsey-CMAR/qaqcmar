# Need this so that package will play nice with dplyr package
# https://community.rstudio.com/t/how-to-solve-no-visible-binding-for-global-variable-note/28887
# more technical solution here: https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html

# other technical solution here:
# https://dplyr.tidyverse.org/articles/programming.html


utils::globalVariables(
  c(
    "sensor_serial_number",
    "threshold_value",

    # qc_test_climatology
    "flag",
    "season_max",
    "season_min",
    "season",
    "tstamp",
    "climatology_flag",
    "numeric_month",
    "qc_test",
    "thresholds",
    "months_seasons",
    "threshold",

    # qc_test_flat_line
    "flat_line_flag",
    "suspect",
    "fail",

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
    "spike_high",
    "spike_low",

    # qc_test_rolling_sd
    "county",
    "station",
    "deployment_range",
    "int_sample",
    "n_sample",
    "effective_sample",
    # "stdev_max",
    "rolling_sd_flag",
    "sd_roll",
    "n_sample_effective",

    # qc_assign_max_flag
    "qc_col",
    "qc_flag",

    # ggplot_all_tests
    "depth",
    "sensor_depth_at_low_tide_m",

    # qc_calculate_thresholds
    "rolling_sd_max",
    "mean_var",
    "sd_var",
    "threshold_value",
    "mean_sd_roll",
    "sd_sd_roll",
    "sensor_depth_measured_m",
    "min_measured",
    "abs_diff",
    "depth_diff_max",

    # qc_test_depth_crosscheck
    "depth_crosscheck_flag",
    "value_sensor_depth_measured_m",
    "depth_crosscheck_flag_sensor_depth_measured_m"

  )
)
