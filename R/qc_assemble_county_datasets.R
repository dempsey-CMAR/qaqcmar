#' Assemble county data
#'
#' Will add columns that do not already exist.
#'
#' @param path File path the the folder with the rds files to be assembled.
#' @param folder Name of the folder where the rds files are saved.
#'
#' @return Returns a data.frame with data from all deployments in folder.
#'
#' @importFrom dplyr %>% arrange distinct mutate select slice
#' @importFrom purrr list_rbind map
#'
#' @export
#'

qc_assemble_county_data <- function(path = NULL, folder) {

  if(is.null(path)) {
    path <- file.path(
      "R:/data_branches/water_quality/processed_data/qc_data")
  }

  # column order ------------------------------------------------------------

  # use for the join and to order columns in output
  depl_cols <- c(
    "county",
    "waterbody",
    "station",
    "lease",
    "latitude" ,
    "longitude" ,
    "deployment_range"   ,
    "string_configuration",
    "sensor_type"     ,
    "sensor_serial_number"  ,
    "timestamp_utc"  ,
    "sensor_depth_at_low_tide_m",
    "depth_crosscheck_flag"
  )

  var_cols <- c(
    "dissolved_oxygen_percent_saturation"   ,
    "dissolved_oxygen_uncorrected_mg_per_l",
    "salinity_psu",
    "sensor_depth_measured_m",
    "temperature_degree_c"
  )

  qc_test_cols <- thresholds %>%
    select(qc_test, variable) %>%
    distinct() %>%
    filter(qc_test != "depth_crosscheck") %>%
    mutate(col_name = paste(qc_test, "flag", variable, sep = "_")) %>%
    arrange(qc_test)
  qc_test_cols <- qc_test_cols$col_name

  qc_max_cols <- c(
    "qc_flag_dissolved_oxygen_percent_saturation"   ,
    "qc_flag_dissolved_oxygen_uncorrected_mg_per_l",
    "qc_flag_salinity_psu",
    "qc_flag_sensor_depth_measured_m",
    "qc_flag_temperature_degree_c"
  )

  # all columns that should be in the data
  all_cols <- c(depl_cols,  var_cols, qc_test_cols, qc_max_cols)
  df <- data.frame(matrix(nrow = 1, ncol = length(all_cols)))
  colnames(df) <- all_cols

  # list all files in county folder
  depls <- list.files(
    paste(path, county, sep = "/"),
    pattern = ".rds",
    full.names = TRUE
  )

  # read in data, bind together
  dat <- depls %>%
    map(readRDS) %>%
    list_rbind() #%>%

  # if any needed columns are NOT in dat, add them as na
  dat %>%
    bind_rows(df) %>%
    slice(-nrow(dat)) %>%     # last row will be all NA, so need to remove it
    select(all_of(all_cols))  # fix the order

  # dat2 <- dat %>%
  #   bind_rows(df) %>%
  #   filter(if_any(everything(), ~ !is.na(.)))

}
