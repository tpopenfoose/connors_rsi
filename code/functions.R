## @knitr load_data
#' @title load_data
#' @description Load .blotter and .global environment from strategy. If do not
#'   exist, run strategy, save objects, and load.
load_data <- function() {
  #' Check for the portfolio, account and env objects saved from the strategy run.
  #' If the files do not exist, run the strategy (which saves the objects), clear
  #' out the environment then load the saved data files.
  if (
    !all(
      file.exists(here::here("./data/blotter.rda")),
      file.exists(here::here("./data/env.rda"))
    )
  ) {
    source(here::here("./code/strategy.R"))
    rm(list = ls())
  }

  #' @TODO look at put.portfolio for putting portfolio object into blotter env
  load(here::here("./data/blotter.rda"), envir = .blotter)
  load(here::here("./data/env.rda"),     envir = .GlobalEnv)
}
