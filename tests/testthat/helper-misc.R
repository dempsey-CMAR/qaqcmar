# November 8, 2022

# labels ------------------------------------------------------------------

flag_labels <- data.frame(flag = c(1, 2, 3, 4, 9)) %>%
  qc_assign_flag_labels()

# pivot -------------------------------------------------------------------

path <- system.file("testdata", package = "qaqcmar")

qc_tests <- c("climatology", "depth_crosscheck",
              "grossrange", "rolling_sd", "spike")

n_var <- readRDS(paste0(path, "/test_data_rolling_sd.RDS")) %>%
  ss_pivot_longer() %>%
  distinct(variable)
n_var <- nrow(n_var)

dat_wide <- readRDS(paste0(path, "/test_data_rolling_sd.RDS")) %>%
  qc_test_all(
    qc_tests = qc_tests,
    county = "Halifax",
    join_column_spike = "sensor_type"
  )

dat_long <- dat_wide %>%
  qc_pivot_longer()

 #qc_plot_flags(dat_long)

# max flag ----------------------------------------------------------------

dat_wide_max <- dat_wide %>%
  qc_assign_max_flag()

dat_long_max <- dat_long %>%
  qc_assign_max_flag()


df <- data.frame(
  variable = c("var1", "var2", "var3"),
  value = c(1, 2, 3),
  flag1 = c(100, 1, 1),
  flag2 = c(1, 200, 1),
  flag3 = c(1, 1, 300)
)

df_max_flag <- qc_assign_max_flag(df)
