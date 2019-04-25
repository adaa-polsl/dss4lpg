# R Package for performing prediction of LPG usage

This is a repository for R package which helps to perform prediction of LPG consumption.

## Installation

In order to use this package you should have installed:

* [R](https://cran.rstudio.com/)
* [RStudio](https://www.rstudio.com/products/rstudio/download/)

Then clone this repository.

Open RStudio. Go to `File -> Open Project` and go to the directory where your cloned project is. Select file `lpg.short.pred.Rproj` and click `Open`.


Open `Build - > Install and Restart`. Package `lpg.short.pred` should be then installed. In case of error with missing dependencies install them and repeat this action.

## Generate reports with the evaluation of predictions

Generating reports with the evaluation of models' predictions can be done by running R functions:

* Trivial models - `lpg.short.pred::generate_naive_models_report()`
* Temperature based model - `lpg.short.pred::generate_gradient_boosting_report()`

Calling these functions with default arguments generates reports using datasets delivered with this package. You can find them in the directory `inst\extdata`.
