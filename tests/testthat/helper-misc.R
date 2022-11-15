# November 8, 2022

# labels ------------------------------------------------------------------

flag_labels <- data.frame(flag = c(1, 2, 3, 4, 9)) %>%
  qc_assign_flag_labels()


# pivot -------------------------------------------------------------------

path <- system.file("testdata", package = "qaqcmar")

qc_tests <- c("climatology", "grossrange")

dat_wide <- readRDS(paste0(path, "/test_data_grossrange.RDS")) %>%
  qc_test_all(qc_tests = qc_tests)

dat_long <- dat_wide %>%
  qc_pivot_longer(qc_tests = qc_tests)

# qc_plot_flags(dat_long)

# max flag ----------------------------------------------------------------

dat_wide_max <- dat_wide %>%
  qc_assign_max_flag(qc_tests = c("climatology", "grossrange"))

dat_long_max <- dat_long %>%
  qc_assign_max_flag(qc_tests = c("climatology", "grossrange"))


df <- data.frame(
  variable = c("var1", "var2", "var3"),
  value = c(1, 2 ,3),
  flag1 = c(100, 1, 1),
  flag2 = c(1, 200, 1),
  flag3 = c(1, 1, 300)
)

df_max_flag <- qc_assign_max_flag(df)

# x <- dat_max_flag %>%
#   qc_pivot_longer(qc_tests = "qc")

# qc_plot_flags(dat_wide_max, qc_tests = c("qc"))

# check the pivot
# temp_4 <- dat_long  %>%
#   filter(
#     # hobo data
#     sensor_serial_number == 20495248,
#     (timestamp_utc > as_datetime("2021-10-04 00:00:00") &
#        timestamp_utc < as_datetime("2021-10-04 06:00:00")) |
#       (timestamp_utc > as_datetime("2021-10-09 00:00:00") &
#          timestamp_utc < as_datetime("2021-10-09 06:00:00"))
#   ) %>%
#   rbind(
#     dat_long %>%
#       filter(
#         # aquameasure data
#         variable == "temperature_degree_C",
#         sensor_serial_number == 670354,
#         (timestamp_utc > as_datetime("2021-10-02 00:00:00") &
#            timestamp_utc < as_datetime("2021-10-02 06:00:00")) |
#           (timestamp_utc > as_datetime("2021-10-08 00:00:00") &
#              timestamp_utc < as_datetime("2021-10-08 06:00:00"))
#       )
#   ) %>%
#   rbind(
#     # vemco data
#     dat_long %>%
#       filter(
#         variable == "temperature_degree_C",
#         sensor_serial_number == 549340,
#         (timestamp_utc > as_datetime("2021-10-05 00:00:00") &
#            timestamp_utc < as_datetime("2021-10-05 12:00:00")) |
#           (timestamp_utc > as_datetime("2021-10-10 00:00:00") &
#              timestamp_utc < as_datetime("2021-10-10 12:00:00"))
#       )
#   )
