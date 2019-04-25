#' Prepare table for summary of naive models for report
#'
#' @param table Table with summary of errors
#'
#' @return DT datatable
#' @export
naive_models_summary <- function(table) {
  rownames(table)[which(rownames(table) == "last_consumption_model")] <-
    "forecast using the latest consumption value"
  rownames(table)[which(rownames(table) == "mean_model")] <-
    "forecast using average consumption for the last 7 days"
  rownames(table)[which(rownames(table) == "median_model")] <-
    "forecast using median consumption for the last 7 days"
  rownames(table)[which(rownames(table) == "consumption_time_model")] <-
    "linear regression - consumption and index of proceding days"
  rownames(table)[which(rownames(table) == "consumption_predtemp_model")] <-
    "linear regression - consumption and temperature"
  min_values <- apply(table, 2, min, na.rm = TRUE)
  DT::datatable(table, colnames = paste("day", 1:ncol(table))) %>%
    DT::formatRound(columns = 1:ncol(table), digits = 6) %>%
    DT::formatStyle(columns = 1:ncol(table), backgroundColor = DT::styleEqual(
      min_values[1:ncol(table)], rep("lightgreen", ncol(table))
    ))
}

#' Knitr table for showing vector of values in naive model's report.
#'
#' In this vector result for each day should be presented.
#'
#' @param vector Vector of values.
#'
#' @return Knitr kable
#' @export
naive_models_tables <- function(vector) {
  vector %>% as.data.frame() %>% t() %>%
    knitr::kable(col.names = paste("day", 1:length(vector)), row.names = FALSE) %>%
    kableExtra::kable_styling()
}
