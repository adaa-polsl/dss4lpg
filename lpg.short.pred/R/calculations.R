#' Calculate sum of the square of the residuals
#'
#' @param real_values Real values
#' @param pred_values Predicted values
#'
#' @return sum of the square of the residuals
#' @export
calc_ssr <- function(real_values, pred_values) {
  deviation <- (real_values - pred_values)^2
  ssr <- sum(deviation)
  return(ssr)
}

#' Calculate variance for polynomial regression model

#' @param ssr sum of the square of the residuals
#' @param degree Degree of polynomial
#' @param num_data_points Number of data points
#'
#' @return variance for polynomial regression model
#' @export
calc_variance_poly_reg <- function(ssr, degree, num_data_points) {
  return(ssr / (num_data_points - degree - 1))
}

#' Calculate root-mean-square error
#'
#' @param error Vector of errors
#'
#' @return Value of root-mean-square error
#' @export
calc_rmse <- function(error) {
  sqrt(mean(error^2, na.rm = TRUE))
}

#' Difference between max and min value
#'
#' @param v Vector with numbers
#' @param na.rm Should NA be removed
#'
#' @return Difference between max and min value in v vector
#' @export
calc_diff_max_min <- function(v, na.rm = TRUE) {
  if (any(!is.na(v))) {
    return(range(v, na.rm = na.rm) %>% diff)
  }
  return(NA)
}
