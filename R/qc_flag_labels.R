#' Assign text labels to flag values
#'
#' All columns with the string "flag" in the name will be converted from numeric
#' flags to text flags (e.g., 1 = Pass, 2 = Not Evaluated, 3 = Suspect, 4 =
#' Fail).
#'
#' @param dat Data frame of flagged sensor string data in long or wide format.
#'   Must include at least one column name with the string "flag".
#'
#' @return Returns \code{dat} with entries in the flag columns converted from
#'   numeric values to text labels (an ordered factor with levels "Pass", "Not
#'   Evaluated", "Suspect", "Fail", "Missing Data").
#'
#' @importFrom dplyr across case_when contains mutate
#'
#' @export
#'
#' @examples
#' path <- system.file("testdata", package = "qaqcmar")
#' dat <- readRDS(paste0(path, "/test_data.RDS"))
#'
#' dat_qc <- dat %>%
#'  qc_test_grossrange() %>%
#'  qc_assign_flag_labels()

qc_assign_flag_labels <- function(dat) {

  dat %>%
    mutate(
      across(
        contains("flag"),
        ~case_when(
          .x == 1 ~ "Pass",
          .x == 2 ~ "Not Evaluated",
          .x == 3 ~ "Suspect",
          .x == 4 ~ "Fail",
          .x == 9 ~ "Missing Data"
        )
      ),
      across(
        contains("flag"),
        ~ordered(
          .x,
          levels = c("Pass", "Not Evaluated", "Suspect", "Fail", "Missing Data")
        )
      )
    )
}


# path <- system.file("testdata", package = "qaqcmar")
#
# dat <- readRDS(paste0(path, "/test_data.RDS"))
#
# qc <- dat %>%
#   qc_test_grossrange() %>%
#   qc_pivot_longer(qc_tests = "grossrange")
#
#
#
# x <- qc %>%
#   mutate(
#     across(
#       contains("flag"),
#       ~case_when(
#         .x == 1 ~ "Pass",
#         .x == 2 ~ "Not Evaluated",
#         .x == 3 ~ "Suspect",
#         .x == 4 ~ "Fail",
#         .x == 9 ~ "Missing Data"
#       )
#     ),
#     across(
#       contains("flag"),
#       ~ordered(.x, levels = c("Pass", "Not Evaluated", "Suspect", "Fail", "Missing Data"))
#     )
#   )
#
# y <- x %>%
#   qc_pivot_longer(qc_tests = "grossrange")
#
#
#
# ggplot(y, aes(timestamp_utc, value, colour = grossrange_flag_value)) +
#   geom_point() +
#   facet_wrap(~ sensor_serial_number) +
#   theme_light() +
#   theme(
#     strip.text = element_text(colour = "black", size = 10),
#     strip.background = element_rect(fill = "white", colour = "darkgrey")
#   )

