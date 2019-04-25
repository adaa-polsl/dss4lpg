#' Generate a report with an evaluation of naive models for prediction of LPG
#' usage
#'
#' This function generates an HTML report with an evaluation of trivial models
#' used for prediction of LPG consumption.
#'
#' @param data_path Character. An absolute path to a directory with datasets
#'   containing basic information about consumption and temperature. See README
#'   in directory \code{inst/extdata} of package \code{lpg.short.pred} for more
#'   information about a structure of these files. The default value of this
#'   parameter is set to a directory with datasets shared with this package.
#' @param report_html_name Character. Name of a generated HTML file with a
#'   report. Default value is \emph{naive_models}.
#' @param report_html_directory Character. A directory where generated HTML
#'   report should be saved.
#'
#' @return A path to a generated HTML report.
#' @export
#'
#' @examples
#' generate_naive_models_report()
generate_naive_models_report <- function(
  data_path = system.file("extdata/datasets/", package = "lpg.short.pred"),
  report_html_name = "naive_models",
  report_html_directory = ".") {

  parameters <- list(
    data_path = data_path,
    pattern_datasets = "*.csv"
  )

  rmarkdown::render(
    input = system.file("rmd/naive_models.Rmd", package = "lpg.short.pred"),
    output_file =  paste(report_html_name, ".html", sep=''),
    output_dir = report_html_directory,
    params = parameters
  )
}


#' Generate a report with an evaluation of gradient boosting models for
#' prediction of LPG usage
#'
#' @param data_path Character. An absolute path to a directory with datasets
#'   containing basic information about consumption and temperature. See README
#'   in directory \code{inst/extdata} of package \code{lpg.short.pred} for more
#'   information about a structure of these files. The default value of this
#'   parameter is set to a directory with datasets shared with this package.
#' @param features_path Character. An absolute path to a directory with feature
#'   datasets. See README in directory \code{inst/extdata} of package
#'   \code{lpg.short.pred} for more information about a structure of these
#'   files. The default value of this parameter is set to a directory with
#'   feature datasets shared with this package.
#' @param ntrees Number of trees used in models.
#' @param report_html_name Character. Name of a generated HTML file with a
#'   report. Default value is \emph{gbm_report}.
#' @param report_html_directory Character. A directory where generated HTML
#'   report should be saved.
#'
#' @return A path to a generated HTML report.
#' @export
#'
#' @examples
#' generate_gradient_boosting_report()
generate_gradient_boosting_report <- function(
  data_path = system.file("extdata/datasets/", package = "lpg.short.pred"),
  features_path = system.file("extdata/features/", package = "lpg.short.pred"),
  ntrees = 100,
  report_html_name = "gbm_report",
  report_html_directory = ".") {

  parameters <- list(
    data_path = data_path,
    features_path = features_path,
    pattern_datasets = "*.csv",
    pattern_features = "*.csv",
    ntrees = ntrees,
    min_num_days = 50
  )

  rmarkdown::render(
    system.file("rmd/gradient_boosting/gbm_report.Rmd", package = "lpg.short.pred"),
    output_file =  paste(report_html_name, ".html", sep=''),
    output_dir = report_html_directory,
    params = parameters)
}
