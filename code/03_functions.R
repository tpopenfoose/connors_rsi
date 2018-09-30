## @knitr load_data
#' @title load_data
#' @description Load .blotter and .global environment from strategy. If do not
#'   exist, run strategy, save objects, and load.
#' @param symbols List of symbols strategy was executed against.
load_data <- function() {
  #' Check for the portfolio, account and env objects saved from the strategy run.
  #' If the files do not exist, run the strategy (which saves the objects), clear
  #' out the environment then load the saved data files.
  rqd_files <- c(
    "account", "theo_account", "portfolio", "theo_portfolio", "instruments",
    symbols
  )

  rqd_files_exist <- purrr::map_lgl(
    .x = rqd_files,
    .f = ~file.exists(here::here(glue::glue("./data/{.x}.RData")))
  )

  if (!all(rqd_files_exist)) {
    source(here::here("./code/04_strategy.R"))
    rm(list = ls())
  }

  symbols <- get("symbols")

  load(here::here("./data/account.RData"))
  blotter::put.account(account, a)

  load(here::here("./data/theo_account.RData"))
  blotter::put.account(account, abh)

  load(here::here("./data/portfolio.RData"))
  blotter::put.portfolio(portfolio, p)

  load(here::here("./data/theo_portfolio.RData"))
  blotter::put.portfolio(theo_portfolio, pbh)

  FinancialInstrument::loadInstruments(
    file_name = "instruments.RData",
    dir = here::here("./data")
  )

  purrr::walk(
    .x = symbols,
    .f = ~load(here::here(glue::glue("./data/{.x}.RData")), envir = .GlobalEnv)
  )

}
