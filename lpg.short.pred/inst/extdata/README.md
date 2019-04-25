# Predictions of consumption for short horizon

This package helps to generate reports for comparison and analysis of different consumption prediction methods.


## Required data files

### Main data files

These CSV files should be stored in directory `./data/datasets/`.
Each file should contain data for one unique problem (e.g. a separate file for each tank). Each row corresponds to one observation for one day. Ideally, the dataset contains data for each subsequent day.

The data columns should be named precisely as it is shown below:

* `start_time` - start time of an observation. It should be in the format: "YYYY-mm-dd HH:MM:SS", e.g., "2018-09-12 12:00:00".
* `end_time` - end time of an observation. It should be in the format "YYYY-mm-dd HH:MM:SS", e.g., "2018-09-13 12:00:00". Ideally, it should be exactly the same as the start_time of row above.
* `consumption_X`, where X is a number from 0 to 30 - this is the name convention for 31 columns describing the product consumption. The column where X is equal to 0 stores current consumption. X equal to 1, 2, ..., 30 corresponds to consumption for 1, 2, ..., 30 days before the current observation (these columns store historical consumption).
* `end_percentage_X`, where X is a number from 0 to 30 - this is the name convention for 31 columns describing the end percentage of a tank filling. X equal to 0 corresponds to the end percentage of the current observation. X equal to 1, 2, ..., 30 are historical data for 1, 2, ..., 30 previous days.
* `real_temp_X`, where X is a number from 0 to 240 - this is the name convention for 241 columns describing temperature. X equal to 0 means temperature in the current day. X equal to 1, 2, ..., 240 corresponds to historical temperature for 1, 2, ..., 240 hours before the current observation. Hours should be calculated from the time stored in `start_time` column.
* `pred_temp_X`, where X is a number from 0 to 216 - these are 217 columns containing predicted temperatures. X represents a number of hours which should be added to 00:00:00 of the next day. Therefore, `pred_temp_0` contains predicted temperature for 00:00:00 of the next day. `pred_temp_1` contains predicted temperature for 01:00:00 of the next day, ..., `pred_temp_216` stores predicted temperature for 00:00:00 of the 10th day after the current observation.
* `month` - column with a number of the month of the observation.
* `day_month` - a day of the month of the current observation.
* `day_week` - a day of the week of the current observation. 1 corresponds to Monday, 7 corresponds to Sunday.
* `decision_attribute_X`, where X is a number from 1 to 7 - these columns store values of decision attributes for the future 7 days. Therefore, `decision_attribute_1` contains the value for the first day after observation, `decision_attribute_7` - for the 7th day. Probably, these will be the values of consumption for the next 7 days.

### Additional data files (datasets with features)

These CSV files should be stored in directory `./data/features/`.
Each file should contain data for one unique problem (e.g. a separate file for each tank). Each row corresponds to one observation for one day. Ideally, the dataset contains data for each subsequent day.

Names of these files should follow the pattern. The corresponding file containing features should be named as a file with the main dataset and with the prefix "features_". For example: if the main data file is named "data_1234.csv", then the corresponding feature file should be named "features_data_1234.csv".

Columns in these datasets:
* `end_time` - end time of an observation. Format od date: "YYYY-mm-dd HH:MM:SS". Values in this column should be the same as in column end_time.
* `mean_X_days`, where X is 3, 5 or 7 - these columns stores mean usage for 3, 5, 7 previous days.
* `change_cons_3_5` - change in mean usage for three and five days.
* `change_cons_3_7` - change in mean usage for three and seven days.
* `max_temp` - maximum temperature during the day.
* `min_temp` - minimum temperature during the day.
* `mean_temp` - mean temperature during the day.
* `median_temp` - a median of temperatures during the day.
* `range_temp` - range between maximum and minimum temperature during the day.
* `diff_cons_now_X_day`, where X is a number from 1 to 10 - a difference between consumption for the day of observation and consumption one day before, 2 days before, ..., 10 days before.
* `diff_max_temp_now_X_day`, where X is a number from 1 to 10 - a difference between the maximum temperature for the day of the observation and maximum temperature for one day before, 2 days before, ..., 10 days before.
* `diff_min_temp_now_X_day`, where X is a number from 1 to 10 - a difference between the minimum temperature for the day of the observation and minimum temperature for one day before, 2 days before, ..., 10 days before.
* `diff_mean_temp_now_X_day`, where X is a number from 1 to 10 - a difference between mean temperature for the day of observation and mean temperature for one day before, 2 days before, ..., 10 days before.

Function `save_features_datasets` can help create these files from datasets with main data.
