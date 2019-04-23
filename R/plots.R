#' Plot for consumption
#'
#' @param data Dataframe with data
#' @param consumption_col Name of column with consumption
#' @param time_col Name of column with time
#'
#' @return ggplot
#' @import ggplot2
#' @export
consumption_plot <- function(data, consumption_col = "consumption_0",
                             time_col = "end_time") {
  ggplot(data = data, aes_string(time_col, consumption_col)) +
    geom_line() +
    xlab("time") +
    ylab("consumption")
}
