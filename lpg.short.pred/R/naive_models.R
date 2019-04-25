#' Main function for creating report with naive models
#'
#' @param path Directory with datasets.
#' @param pattern Regular expression. Only file names which match the
#'   regular expression will be used from directory \code{path}.
#' @param read_file_function Function used for reading files from \code{path}.
#' @param ... Additional parameters for function \code{read_file_function}.
#'
#' @return Information for report with naive models.
#' @export
naive_models_report <- function(path = "./data/datasets/",
                                pattern = "*",
                                read_file_function = readr::read_csv,
                                ...) {

  files <- list.files(path = path, pattern = pattern, full.names = TRUE)

  models_list <- lapply(files, function(file) {
    data <- read_file_function(file, ...)
    data <- as.data.frame(data)
    dataset_results <- naive_models_dataset(data)
    month_results <- results_for_every_month(data)
    return(list(dataset_results = dataset_results,
                month_results = month_results,
                file = basename(file),
                nrow = nrow(data),
                consumption_plot = consumption_plot(data)))
  })

  summary <- summary_of_models(
    lapply(models_list, function(dataset) {dataset$dataset_results})
  )
  summary_each_month <- summary_each_month(
    lapply(models_list, function(dataset) {dataset$month_results})
  )
  return(list(datasets_models_res = models_list,
              summary = summary,
              summary_each_month = summary_each_month))
}

results_for_every_month <- function(data, days = 1:7, time_col = "end_time") {
  months <- 1:12

  months_summary <- lapply(months, function(month) {
    dataset <- filter_month_data(data, month, time_col)
    naive_models_dataset(dataset, days = days, time_col = time_col)
  })
  names(months_summary) <- month.name
  return(months_summary)
}

summary_each_month <- function(results_months) {
  months <- 1:12
  summary <- list()
  for (m in months) {
    month_each_dataset <- lapply(results_months,
                                 function(dataset) {dataset[[month.name[m]]]})
    summary <- append(summary, list(summary_of_models(month_each_dataset)))
  }
  names(summary) <- month.name
  return(summary)
}

#' Create summary of models for all datasets
#'
#' @param models List with results of all models for all datasets.
#'
#' @return Summary.
#' @export
#' @import dplyr
summary_of_models <- function(models) {
  models_names <- names(models[[1]])
  models_mean_results <- lapply(models_names, function(name) {
    specific_model_results <- lapply(models, function(x) {x[[name]]})

    if (class(specific_model_results[[1]]) == "list") {
      specific_model_results <- lapply(specific_model_results, function(smr) {
        smr[["error_results"]]})
    }

    mean_results <- specific_model_results %>% as.data.frame() %>%
      apply(1, mean, na.rm=TRUE)
    return(mean_results)
  })
  models_mean_results <- models_mean_results %>% as.data.frame() %>% t()
  rownames(models_mean_results) <- models_names
  return(models_mean_results)
}

#' Get models accuarcy for one dataset
#'
#' @param data Dataset
#' @param days Number of days for which prediction should be made.
#' @param time_col Name of column with time.
#'
#' @return RMSE of all models for this dataset.
#' @export
naive_models_dataset <- function(data, days = 1:7, time_col = "end_time") {
  num_previous_days <- 7
  models <- list(
    last_consumption_model = last_consumption_model(data, days = days),
    mean_model = mean_model(data = data, days = days, num_previous_days = num_previous_days),
    median_model = median_model(data, days = days, num_previous_days = num_previous_days),
    consumption_time_model = consumption_time_model(data, days = days, num_previous_days = num_previous_days),
    consumption_predtemp_model = consumption_predtemp_model(data, days = days, time_col = time_col,
                                                            num_previous_days = num_previous_days))
  return(models)
}

#' Get accuracy for model based on value of last consumption
#'
#' @param data Dataset.
#' @param days Number of days for which prediction should be made.
#' @param actual_consumption_col Name of column with actual consumption.
#' @param decision_attr_prefix Prefix of columns with decision attribute.
#'
#' @return RMSE of this model for each horizon.
#' @export
last_consumption_model <- function(data, days = 1:7,
                                   actual_consumption_col = "consumption_0",
                                   decision_attr_prefix = "decision_attr_") {
  sapply(days, function(day) {
    decision <- data[, paste0(decision_attr_prefix, day)]
    error <- decision - data[, actual_consumption_col]
    calc_rmse(error = error)
  })
}

#' Get accuracy for model based on mean value of consumption
#'
#' @param data Dataset.
#' @param days Number of days for which prediction should be made.
#' @param decision_attr_prefix Prefix of columns with decision attribute.
#' @param consumption_prefix Prfix of column with consumption.
#' @param num_previous_days For how many past days mean value should be
#'   calculated?
#'
#' @return RMSE of this model for each horizon.
#' @export
mean_model <- function(data, days = 1:7,
                       decision_attr_prefix = "decision_attr_",
                       consumption_prefix = "consumption_",
                       num_previous_days = 7) {
  previous_cons <- previous_consumptions(data, consumption_prefix, num_previous_days)
  cons_mean <- apply(previous_cons, 1, function(x) {mean(x, na.rm = TRUE)})

  sapply(days, function(day) {
    decision <- data[, paste0(decision_attr_prefix, day)]
    error <- decision - cons_mean
    calc_rmse(error = error)
  })
}

#' Get accuracy of model based on median value of consumption
#'
#' @param data Dataset.
#' @param days Number of days for which prediction should be made.
#' @param decision_attr_prefix Prefix of columns with decision attribute.
#' @param consumption_prefix Prfix of column with consumption.
#' @param num_previous_days For how many past days median value should be
#'   calculated?
#'
#' @return RMSE of this model for each horizon.
#' @export
median_model <- function(data, days = 1:7,
                         decision_attr_prefix = "decision_attr_",
                         consumption_prefix = "consumption_",
                         num_previous_days = 7) {
  previous_cons <- previous_consumptions(data, consumption_prefix, num_previous_days)
  cons_median <- apply(previous_cons, 1, function(x) {median(x, na.rm = TRUE)})

  sapply(days, function(day) {
    decision <- data[, paste0(decision_attr_prefix, day)]
    error <- decision - cons_median
    calc_rmse(error = error)
  })
}

#' Get accuarcy of model based on linear regession for consumption and time
#'
#' @param data Dataset.
#' @param days Number of days for which prediction should be made.
#' @param decision_attr_prefix Prefix of columns with decision attribute.
#' @param consumption_prefix Prfix of column with consumption.
#' @param num_previous_days On how many past days linear regression should be
#'   made?
#'
#' @return RMSE of this model for each horizon.
#' @export
consumption_time_model <- function(data, days = 1:7,
                                   decision_attr_prefix = "decision_attr_",
                                   consumption_prefix = "consumption_",
                                   num_previous_days = 7) {
  previous_cons <- previous_consumptions(data, consumption_prefix, num_previous_days)

  # Calculate predicted values using linear regression
  lm_pred <- apply(previous_cons, 1, function(consumption) {
    days_indexes <- seq(-num_previous_days + 1, 0)
    df <- data.frame(x = days_indexes, y = as.numeric(consumption))

    fit <- lm(y ~ x, data = df)
    new_df <- data.frame(x = days)
    predictions <- predict(fit, newdata = new_df)
    # If prediction is less than zero than it will be changed to zero
    predictions[which(predictions < 0)] <- 0
    return(predictions)
  })
  lm_pred <- lm_pred %>% t()

  errors <- sapply(days, function(day) {
    decision <- data[, paste0(decision_attr_prefix, day)]
    error <- decision - lm_pred[, day]
    calc_rmse(error = error)
  })

  not_na_values <- sapply(as.data.frame(lm_pred),
                          function(x) {length(which(!is.na(x)))})
  return(list(error_results = errors,
              not_na_values = not_na_values))
}

#' Get accuarcy of model based on linear regession for consumption and
#' temperature
#'
#' @param data Dataset.
#' @param days Number of days for which prediction should be made.
#' @param decision_attr_prefix Prefix of columns with decision attribute.
#' @param consumption_prefix Prfix of column with consumption.
#' @param num_previous_days On how many past days linear regression should be
#'   made?
#' @param time_col Name of column with time.
#' @param real_temp_col_prefix Prefix of columns with real temperatures.
#' @param pred_col_prefix Prefix of columns with predicted temperatures.
#'
#' @return RMSE of this model for each horizon.
#' @export
#' @importFrom stats lm
#' @importFrom stats predict
consumption_predtemp_model <- function(data, days = 1:7,
                                       decision_attr_prefix = "decision_attr_",
                                       consumption_prefix = "consumption_",
                                       num_previous_days = 7,
                                       time_col = "end_time",
                                       real_temp_col_prefix = "real_temp_",
                                       pred_col_prefix = "pred_temp_") {
  previous_cons <- previous_consumptions(data, consumption_prefix, num_previous_days)

  predicitions_df <- matrix(nrow = nrow(data), ncol = length(days)) %>% as.data.frame()
  for (i in 1:nrow(previous_cons)) {
    mean_real_temp <- get_previous_temp_for_days(i, data,
                                                 real_temp_col_prefix = real_temp_col_prefix,
                                                 num_days = num_previous_days,
                                                 time_col = time_col)
    df <- data.frame(x = mean_real_temp,
                     y = as.numeric(previous_cons[i,]))
    fit <- lm(y ~ x, data = df)
    mean_pred_temp <- get_pred_mean_temp(index = i, data,
                                         pred_col_prefix = pred_col_prefix,
                                         time_col = time_col)
    new_df <- data.frame(x = mean_pred_temp)
    predictions <- predict(fit, newdata = new_df)
    # If prediction is less than zero than it will be changed to zero
    predictions[which(predictions < 0)] <- 0
    predictions[which(is.nan(predictions))] <- NA
    predicitions_df[i, ] <- predictions
  }

  errors <- sapply(days, function(day) {
    decision <- data[, paste0(decision_attr_prefix, day)]
    error <- decision - predicitions_df[, day]
    calc_rmse(error = error)
  })

  not_na_values <- sapply(predicitions_df,
                          function(x) {length(which(!is.na(x)))})
  return(list(error_results = errors,
              not_na_values = not_na_values))
}

#' Get mean values of temperatures in previous days
#'
#' For each day mean temperature is calculated based on hourly values.
#'
#' @param index Index of row for 'data'.
#' @param data Dataset
#' @param real_temp_col_prefix Prefix of columns with real temperatures.
#' @param num_days Number of previous days for which mean temperatures for each
#'   day should be calculated.
#' @param time_col Name of column with time of a record.
#'
#' @return Vector of mean temperatures for each of previous days.
#' @export
get_previous_temp_for_days <- function(index, data,
                                       real_temp_col_prefix = "real_temp_",
                                       num_days = 7,
                                       time_col = "end_time") {
  dataset <- data[index,]
  current_time <- dataset[1, time_col] %>% trunc("hours") %>% as.POSIXct()

  hours <- current_time %>% lubridate::hour()
  temp_for_current_time <- dataset[, paste0(real_temp_col_prefix, seq(hours,0))] %>%
    as.numeric() %>% mean(na.rm = TRUE)

  hours_seqs <- lapply((num_days -2):0, function(x) {
    start_hour <- x*24+hours+1
    seq(start_hour + 23, start_hour)
  })

  temp_for_prev_days <- sapply(hours_seqs, function(hours_seq) {
    dataset[, paste0(real_temp_col_prefix, hours_seq)] %>%
      as.numeric() %>% mean(na.rm = TRUE)
  })

  mean_temp <- c(temp_for_prev_days,
                 temp_for_current_time)
  names(mean_temp) <- paste0("mean_temp_day_", (num_days-1):0)
  return(mean_temp)
}

#' Get mean values of predicted temperatures in future days
#'
#' @param index Index of row for 'data'.
#' @param data Dataset
#' @param pred_col_prefix Prefix of columns with predicted temperatures.
#' @param num_days Number of future days for which predicted mean temperature
#'   for each day should be calculated.
#' @param time_col Name of column with time of a record.
#'
#' @return Vector of predicted mean temperatures for each of future days.
#' @export
get_pred_mean_temp <- function(index, data,
                               pred_col_prefix = "pred_temp_",
                               num_days = 7,
                               time_col = "end_time") {
  dataset <- data[index,]

  mean_pred_temp <- sapply(0:(num_days-1), function(x) {
    dataset[, paste0(pred_col_prefix, seq(x*24, x*24+23))] %>%
      as.numeric() %>% mean(na.rm = TRUE)
  })
  names(mean_pred_temp) <- paste0("pred_temp_day_", 1:num_days)
  return(mean_pred_temp)
}
