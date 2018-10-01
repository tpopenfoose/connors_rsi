## @knitr load_data
#' @title load_data
#' @description Load .blotter and .global environment from strategy. If do not
#'   exist, run strategy, save objects, and load.
#' @param symbols List of symbols strategy was executed against.
load_data <- function() {
  #' Check for the portfolio, account and env objects saved from the strategy run.
  #' If the files do not exist, run the strategy (which saves the objects), clear
  #' out the environment then load the saved data files.

  symbols <- c(get("symbols"), get("clean_benchmark"))

  rqd_files <- c(
    "account", "portfolio", "theo_portfolio", "instruments", symbols,
    clean_benchmark
  )

  rqd_files_exist <- purrr::map_lgl(
    .x = rqd_files,
    .f = ~file.exists(here::here(glue::glue("./data/{.x}.RData")))
  )

  if (!all(rqd_files_exist)) {
    source(here::here("./code/04_strategy.R"))
    rm(list = ls())
  }

  load(here::here("./data/account.RData"))
  blotter::put.account(account, a)

  load(here::here("./data/portfolio.RData"))
  blotter::put.portfolio(portfolio, p)

  load(here::here("./data/theo_portfolio.RData"))
  blotter::put.portfolio(theo_portfolio, pbh)

  load(here::here("./data/benchmark_portfolio.RData"))
  blotter::put.portfolio(benchmark_portfolio, pbm)

  FinancialInstrument::loadInstruments(
    file_name = "instruments.RData",
    dir = here::here("./data")
  )

  purrr::walk(
    .x = symbols,
    .f = ~load(here::here(glue::glue("./data/{.x}.RData")), envir = .GlobalEnv)
  )

}
