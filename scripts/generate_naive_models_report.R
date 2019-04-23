# ------------------------------------------------------------------------------
# This script generates reports for naive_models.Rmd.
# For every report, in 'parameters' list should be given
# this informations:
#
# data_path - Directory with datasets, probably it is "../data/datsets/".
#   It is a relative directory for report.
# pattern_datasets - Regular expression. Pattern of datasets in directory
# report_html_name - name of HTML file
# dir_save_html - directory where HTML report should be saved
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
data_path <- "../extdata/datasets/"
pattern_datasets <- "*.csv"
report_html_name <- "naive_models"
dir_save_html <- "./inst/rmd/"

p <- list(
  data_path = data_path,
  pattern_datasets = pattern_datasets
)

# ------------------------------------------------------------------------------
# Generate report
# ------------------------------------------------------------------------------
rmarkdown::render("./inst/rmd/naive_models.Rmd",
                  output_file =  paste(report_html_name, ".html", sep=''),
                  output_dir = dir_save_html,
                  params = p)
