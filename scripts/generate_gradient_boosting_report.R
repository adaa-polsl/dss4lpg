# ------------------------------------------------------------------------------
# This script generates reports for naive_models.Rmd.
# For every report, in 'parameters' list should be given
# this informations:
#
# data_path - Directory with datasets, probably it is "../../data/datsets/".
#   It is a relative directory for report.
# features_path - Directory with features datasets, probably it is "../../data/features/".
#   It is a relative directory for report.
# pattern_datasets - Regular expression. Pattern of datasets in directory.
# pattern_features - Regular expression. Pattern of names of features files in directory.
# ntrees - Number of trees used in models.
# min_num_days - Minimum number of rows based on which model can be created.
# report_html_name - name of HTML file
# dir_save_html - directory where HTML report should be saved
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
data_path <- "../../extdata/datasets/"
features_path <- "../../extdata/features/"
pattern_datasets <- "*.csv"
pattern_features <- "*.csv"
ntrees <- 100
min_num_days <- 50

report_html_name <- "gbm_report"
dir_save_html <- "./inst/rmd/gradient_boosting/"

p <- list(
  data_path = data_path,
  features_path = features_path,
  pattern_datasets = pattern_datasets,
  pattern_features = pattern_features,
  ntrees = ntrees,
  min_num_days = min_num_days
)

# ------------------------------------------------------------------------------
# Generate report
# ------------------------------------------------------------------------------
rmarkdown::render("./inst/rmd/gradient_boosting/gbm_report.Rmd",
                  output_file =  paste(report_html_name, ".html", sep=''),
                  output_dir = dir_save_html,
                  params = p)
