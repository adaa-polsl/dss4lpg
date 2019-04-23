# R Package for performing prediction of LPG usage

This is a repository for R package which helps to perform prediction of LPG consumption.

## Installation

In order to use this package you should have installed:

* [R](https://cran.rstudio.com/)
* [RStudio](https://www.rstudio.com/products/rstudio/download/)

Then clone this repository.

Open RStudio. Go to `File -> Open Project` and go to the directory where your cloned project is. Select file `lpg.short.pred.Rproj` and click `Open`.


Open `Build - > Install and Restart`. Package `lpg.short.pred` should be then installed. In case of error with missing dependencies install them and repeat this action.

## Generate reports with evaluation of predictions

Generatng reports with evaluation of models' predictions can be done by sourcing R scripts:

* Trivial models - `./scripts/generate_naive_models_report.R`
* Temperature based model - `./scripts/generate_gradient_boosting_report.R`

In these scripts, you can adjust your parameters for example path where to save generated HTML reports.
