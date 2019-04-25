#' Create datasets with features from files with data
#'
#' @param dataset_path Directory where files wit data are stores.
#' @param features_path Directory where new files with features should be
#'   stored.
#' @param read_file_function Function used for reading files from
#'   \code{dataset_path}.
#' @param pattern_datasets Regular expression. Only file names which match the
#'   regular expression will be used from directory \code{dataset_path}.
#'
#' @return Nothing
#' @export
save_features_datasets <- function(dataset_path = "./data/datasets",
                                   features_path = "./data/features/",
                                   read_file_function = readr::read_csv,
                                   pattern_datasets = "*") {

  files <- list.files(dataset_path, pattern = pattern_datasets, full.names = TRUE)

  for (file in files) {
    data <- read_file_function(file)
    data <- as.data.frame(data)
    features_dataset <- features_dataset(data)

    # Save csv
    is.POSIXct <- function(x) inherits(x, "POSIXct")

    features_dataset <- dplyr::mutate_if(features_dataset, is.numeric, round, 6)
    features_dataset <- dplyr::mutate_if(features_dataset,
                                         function(x) {is.numeric(x) && !is.na(x)},
                                         format,
                             scientific=FALSE, drop0trailing = TRUE)
    features_dataset <- dplyr::mutate_if(features_dataset, is.POSIXct,
                                         format, "%Y-%m-%d %H:%M:%S")
    readr::write_csv(features_dataset,
                     paste0(features_path, "features_", basename(file)),
                     na = "")
  }
}
