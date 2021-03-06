% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/naive_models.R
\name{last_consumption_model}
\alias{last_consumption_model}
\title{Get accuracy for model based on value of last consumption}
\usage{
last_consumption_model(data, days = 1:7,
  actual_consumption_col = "consumption_0",
  decision_attr_prefix = "decision_attr_")
}
\arguments{
\item{data}{Dataset.}

\item{days}{Number of days for which prediction should be made.}

\item{actual_consumption_col}{Name of column with actual consumption.}

\item{decision_attr_prefix}{Prefix of columns with decision attribute.}
}
\value{
RMSE of this model for each horizon.
}
\description{
Get accuracy for model based on value of last consumption
}
