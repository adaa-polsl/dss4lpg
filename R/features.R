#' Create dataset with features for gradient boosting model
#'
#' @param data Dataset
#'
#' @return Features dataset
#' @export
#' @importFrom stats median
features_dataset <- function(data) {
  features <- data.frame(end_time = data$end_time)

  # Mean consumprion from 3, 5, 7 days --------------------------------------
  features$mean_3_days <- mean_cons_last_days(data, days = 3)
  features$mean_5_days <- mean_cons_last_days(data, days = 5)
  features$mean_7_days <- mean_cons_last_days(data, days = 7)

  # Change in mean consumption from 3 to 5 days and from 3 to 7 days --------
  features$change_cons_3_5 <- features$mean_3_days - features$mean_5_days
  features$change_cons_3_7 <- features$mean_3_days - features$mean_7_days

  # Max, min, mean, median, range of temperature during the day -------------
  features$max_temp <- fun_on_temperatures(data = data, fun = max,
                                           time_col = "end_time", num_day = 0,
                                           na.rm = TRUE)
  features$min_temp <- fun_on_temperatures(data = data, fun = min,
                                           time_col = "end_time", num_day = 0,
                                           na.rm = TRUE)
  features$mean_temp <- fun_on_temperatures(data = data, fun = mean,
                                            time_col = "end_time", num_day = 0,
                                            na.rm = TRUE)
  features$median_temp <- fun_on_temperatures(data = data, fun = median,
                                              time_col = "end_time", num_day = 0,
                                              na.rm = TRUE)
  features$range_temp <- fun_on_temperatures(data = data,
                                             fun = lpg.short.pred::calc_diff_max_min,
                                             time_col = "end_time", num_day = 0,
                                             na.rm = TRUE)

  # Difference of consumption between current day and previous days --------
  num_previous_days <- 10
  for (i in 1:num_previous_days) {
    diff_cons <- data[, paste0(consumption_prefx(), "0")] -
      data[, paste0(consumption_prefx(), i)]
    features[, paste0("diff_cons_now_", i, "_day")] <- diff_cons
  }


  # Difference between max temperatures between current day and previous days
  for (i in 1:(num_previous_days-1)) {
    diff <- features$max_temp - fun_on_temperatures(data = data, fun = max,
                                                    time_col = "end_time", num_day = i,
                                                    na.rm = TRUE)
    features[, paste0("diff_max_temp_now_", i, "_day")] <- diff
  }

  # Difference between min temperatures between current day and previous days
  for (i in 1:(num_previous_days-1)) {
    diff <- features$max_temp - fun_on_temperatures(data = data, fun = min,
                                                    time_col = "end_time", num_day = i,
                                                    na.rm = TRUE)
    features[, paste0("diff_min_temp_now_", i, "_day")] <- diff
  }

  # Difference between mean temperatures between current day and previous days
  for (i in 1:(num_previous_days-1)) {
    diff <- features$max_temp - fun_on_temperatures(data = data, fun = mean,
                                                    time_col = "end_time", num_day = i,
                                                    na.rm = TRUE)
    features[, paste0("diff_mean_temp_now_", i, "_day")] <- diff
  }

  return(features)
}

mean_cons_last_days <- function(data, days) {
  day_id <- 0:(days-1)
  cons_cols <- which(colnames(data) %in% paste0(consumption_prefx(), day_id))
  mean_cons <- rowMeans(data[, cons_cols], na.rm = TRUE)
  return(mean_cons)
}

get_temperatures_for_day <- function(row, time_col = "end_time", num_day = 0) {
  real_temp_col_prefix <- real_temp_prefix()
  current_time <- row[, time_col] %>% trunc("hours") %>% as.POSIXct()
  current_hour <- current_time %>% lubridate::hour()

  if (num_day == 0) {
    seq_hours <- seq(current_hour,0)
  } else {
    start_hour <- (num_day-1)*24+current_hour+1
    seq_hours <- seq(start_hour + 23, start_hour)
  }
  temperatures <- row[, paste0(real_temp_col_prefix, seq_hours)] %>%
    as.numeric()

  return(temperatures)
}

fun_on_temperatures <- function(data, fun, time_col = "end_time",
                                num_day = 0, ...) {
  ret <- sapply(1:nrow(data), function(i) {
    dataset <- data[i,]
    temperatures <- get_temperatures_for_day(dataset, time_col = time_col,
                                             num_day = num_day)
    fun(temperatures, ...)
  })
  return(ret)
}
