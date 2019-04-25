#' Replace NA value with a previous one.
#'
#' Replacement will happen only if NA value is next to existing values or is the
#' last value.
#'
#' @param vec Vector of values
#'
#' @return Vector of values with replaced single missing values.
#' @export
fill_lonely_na <- function(vec) {
  na_id <- which(is.na(vec))

  new_vec <- vec
  new_vec[na_id] <- sapply(na_id, function(x) {
    if (x > 1) {
      # last element in a vector
      if (x == length(vec)) {
        if (!is.na(vec[x-1])) {
          return(vec[x-1])
        }
      } else {
        if (!is.na(vec[x-1]) && !is.na(vec[x+1])) {
          return(vec[x-1])
        }
      }
    }
    return(vec[x])
  })
  return(new_vec)
}

#' Get values of previous consumptions for defined number of days.
#'
#' @param data Dataset.
#' @param consumption_prefix Prefix of columns with consumption.
#' @param num_days Number of days for which consumption should be returned.
#'
#' @return Consumption of previous days.
#' @export
previous_consumptions <- function(data, consumption_prefix = "consumption_",
                                  num_days = 7) {
  data[, paste0(consumption_prefix, (num_days-1):0)]
}

#' Filter data from specific month
#'
#' @param data Dataset
#' @param month_number Number of month (from 1 to 12)
#' @param time_col Name of column with time
#'
#' @return Dataset from specific month
#' @export
filter_month_data <- function(data, month_number, time_col = "end_time") {
  data[lubridate::month(data[, time_col]) == month_number, ]
}
