#' Assign text labels to flag values
#'
#' All columns with the string "flag" in the name will be converted from numeric
#' flags to text flags (e.g., 1 = Pass, 2 = Not Evaluated, 3 = Suspect/Of
#' Interest, 4 = Fail).
#'
#' @param dat Data frame of flagged sensor string data in long or wide format.
#'   Must include at least one column name with the string "flag".
#'
#' @return Returns \code{dat} with entries in the flag columns converted from
#'   numeric values to text labels (an ordered factor with levels "Pass", "Not
#'   Evaluated", "Suspect/Of Interest", "Fail", "Missing Data").
#'
#' @importFrom dplyr across case_when contains mutate
#'
#' @export

# @examples
# path <- system.file("testdata", package = "qaqcmar")
# dat <- readRDS(paste0(path, "/test_data.RDS"))
#
# dat_qc <- dat %>%
#  qc_test_grossrange() %>%
#  qc_assign_flag_labels()

qc_assign_flag_labels <- function(dat) {
  dat %>%
    mutate(
      across(
        contains("flag"),
        ~ case_when(
          .x == 1 ~ "Pass",
          .x == 2 ~ "Not Evaluated",
          .x == 3 ~ "Suspect/Of Interest",
          .x == 4 ~ "Fail"
         # .x == 9 ~ "Missing Data"
        )
      ),
      across(
        contains("flag"),
        ~ ordered(
          .x,
          levels = c("Pass", "Not Evaluated", "Suspect/Of Interest", "Fail")#, "Missing Data")
        )
      )
    )
}
