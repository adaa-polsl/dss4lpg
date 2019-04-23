#' Create gradient boosting model
#'
#' @param train_features Dataset with features based on which model will be
#'   created.
#' @param ntrees Number of trees used in gradient boosting model.
#' @param decision Vector with decisions (what should be predicted).
#'
#' @return Gradient boosting model
#' @export
#' @importFrom gbm gbm
gradient_boosting_model <- function(train_features, decision, ntrees) {
  train_dataset <- dplyr::bind_cols(train_features, list(decision = decision))

  na_rows <- which(train_dataset$decision %>% is.na)

  if (length(na_rows) > 0) {
    train_dataset <- train_dataset[-na_rows, ]
  }

  consumption.boost = gbm::gbm(decision ~ . , data = train_dataset,
                               distribution = "gaussian", n.trees = ntrees)
  return(consumption.boost)
}

#' Test gradient boosting model on test dataset
#'
#' @param model Model
#' @param test_dataset Test dataset (with features)
#' @param test_ntrees Number of trees for which evaluation is made. It can one
#'   number or a vector of numbers for which test results should be returned.
#'
#' @return Root mean squared error
#' @export
test_gbm <- function(model, test_dataset, test_ntrees = 200) {
  predictions <- predict(model, test_dataset, n.trees = test_ntrees) %>%
    as.matrix()
  test_error <- sapply(as.data.frame(predictions),
                       function(x) {calc_rmse(error = x - test_dataset$decision)})
  return(test_error)
}

#' Evaluate incremental gradient boosting models on a dataset.
#'
#' For each horizon (1 to 7 days) models are created. For each horizon models
#' are created in incremental way. For example: first model is created on 2
#' first months and test on third month, second model is trained on 3 months and
#' evalueated on 4th etc.
#'
#' @param dataset Original ataset
#' @param features Dataset with features
#' @param min_examples_for_model Minimum examples that should be used in
#'   creation of a first model.
#' @param ntrees Number of trees used in training.
#' @param test_ntrees On which number of trees evaluation should be made?
#'
#' @return Dataframe. Every column is a different horizon. Every row is next
#'   iteration.
#' @export
use_gbm_for_dataset <- function(dataset,
                                features = NULL,
                                min_examples_for_model = 50,
                                ntrees = 200,
                                test_ntrees = 200) {
  if (is.null(features)) {
    features <- features_dataset(dataset)
  }
  features <- features %>% mutate(month = lubridate::month(end_time),
                                  year = lubridate::year(end_time)) %>% arrange(end_time)

  months_summarize <- features %>% group_by(year, month) %>%
    summarize(count = n()) %>% as.data.frame()
  months_summarize <- months_summarize %>% mutate(cumsum = cumsum(count))

  # Estimat which months will be taken into first training model
  id_first_month <- which.max(months_summarize$cumsum >= min_examples_for_model)

  results_dt <- data.frame()

  for (day_week in 1:7) {
    features$decision <- dataset[, paste0("decision_attr_", day_week)]

    # loop over every month which are stored in months_summarize
    # we stop one row before end because last month is a test data for last iteration
    error_each_iteration <- list()
    for(i in id_first_month:(nrow(months_summarize) - 1)) {

      train_dataset <- features %>%
        filter(year < months_summarize$year[i] |
                 (year == months_summarize$year[i] & month <= months_summarize$month[i])) %>%
        select(-c(month, year))

      test_dataset <- features %>%
        filter(year == months_summarize$year[i + 1] &
                 month == months_summarize$month[i + 1]) %>%
        select(-c(month, year))

      model <- gradient_boosting_model(train_features = train_dataset %>%
                                         select(-c(decision, end_time)),
                                       decision = train_dataset$decision,
                                       ntrees = ntrees)

      test_error <- test_gbm(model = model,
                             test_dataset = test_dataset %>%
                               select(-c(end_time)),
                             test_ntrees = test_ntrees)
      error_each_iteration <- append(error_each_iteration, test_error)

    }

    results_dt <- rbind(results_dt, as.data.frame(error_each_iteration))
  }

  results_dt <- results_dt %>% t()
  colnames(results_dt) <- paste0("day_", 1:7)
  rownames(results_dt) <- paste0("iter_", 1:nrow(results_dt))

  return(as.data.frame(results_dt))
}

#' Use gradient boosting model for many datasets.
#'
#' @param dataset_path Directory with datasets.
#' @param feature_path Directory with features from datasets.
#' @param pattern_datasets Regular expression. Only file names which match the
#'   regular expression will be used from directory \code{dataset_path}.
#' @param pattern_features Regular expression. Only file names which match the
#'   regular expression will be used from directory \code{feature_path}.
#' @param read_file_function Function used for reading files from
#'   \code{dataset_path} and \code{pattern_features}.
#' @param ntrees Number of trees used in models.
#' @param min_num_days Minimum number of rows based on which model can be
#'   created.
#' @param ... Additional parameters for function \code{read_file_function}.
#'
#' @return List with results of evaluation for every dataset.
#' @export
gbm_for_each_dataset <- function(dataset_path = "./data/datasets/",
                                 feature_path = "./data/features/",
                                 pattern_datasets = "*",
                                 pattern_features = "*",
                                 read_file_function = readr::read_csv,
                                 ntrees = 200,
                                 min_num_days = 50,
                                 ...) {

  datasets_files <- list.files(dataset_path, pattern = pattern_datasets)
  features_files <- list.files(feature_path,
                               pattern = pattern_features,
                               full.names = TRUE)

  datasets_results <- list()
  for (file in datasets_files) {
    print(file)
    dataset <- read_file_function(paste0(dataset_path, file), ...)
    dataset <- as.data.frame(dataset)
    matching_features <- which(grepl(pattern = file, x = features_files))
    if (length(matching_features) > 0) {
      features <- read_file_function(features_files[matching_features], ...)
      features <- as.data.frame(features)
      results <- lpg.short.pred::use_gbm_for_dataset(dataset = dataset,
                                                     features = features,
                                                     min_examples_for_model = min_num_days,
                                                     ntrees = ntrees,
                                                     test_ntrees = ntrees)
      print("Results of incremental models were saved.")
      datasets_results <- datasets_results %>% append(list(results))
    } else {
      stop(paste0("There is no matching features for dataset: ", file))
    }
  }
  names(datasets_results) <- datasets_files
  return(datasets_results)
}
