# Libraries ----
library(quantstrat)
library(TTR)
library(tidyverse)

# Variables ----
init_date <- "2004-12-31"
start_date <- "2005-01-01"
end_date <- "2014-12-31"
init_equity <- 1e4
symbols <- c("IWM", "QQQ", "TLT", "SPY")

# Settings ----
Sys.setenv(TZ = "UTC")
currency("USD")

getSymbols(
  Symbols = symbols,
  src = "yahoo",
  index.class = "POSIXct",
  from = start_date,
  to = end_date,
  adjust = TRUE
)

stock(symbols, currency = "USD", multiplier = 1)

#' Connors RSI strategy
walk(
  .x = c("strategy_bh", "portfolio_bh", "account_bh"),
  .f = assign,
  value = "buy_hold",
  envir = .GlobalEnv
)

rm.strat(portfolio_bh)
rm.strat(account_bh)

initPortf(name = portfolio_bh, symbols = symbols, initDate = init_date)

initAcct(
  name = account_bh,
  portfolios = portfolio_bh,
  initDate = init_date,
  initEq = init_equity
)

initOrders(portfolio = portfolio_bh, symbols = symbols, initDate = init_date)

strategy(portfolio_bh, store = TRUE)

strat <- getStrategy(portfolio_bh)

# Indicators ----

#' NA

# Signals ----
# add.signal(
#   strategy  = strategy_bh,
#   name      = "sigThreshold",
#   arguments = list(
#     column       = "Close",
#     threshold    = 0,
#     relationship = "gt",
#     cross        = FALSE
#   ),
#   label     = "bto"
# )

add.signal(
  strategy  = strategy_bh,
  name      = "sigTimestamp",
  arguments = list(
    timestamp = as.POSIXct("2005-01-03")
  ),
  label     = "bto"
)

# Rules ----
add.rule(
  strategy  = strategy_bh,
  name      = "ruleSignal",
  arguments = list(
    sigcol    = "timestamp.bto",
    sigval    = TRUE,
    orderqty  = 100,
    ordertype = "market",
    orderside = "long"
  ),
  type      = "enter"
)

# Apply Strategy ----
applyStrategy(strategy = strategy_bh, portfolios = portfolio_bh, prefer = "Open")

# Update ----
updatePortf(portfolio_bh)
updateAcct(account_bh)
updateEndEq(account_bh)

## Save

#' Save environment variables to be used in analysis
save(list = ls(),         file = here::here("./data/env_bh.rda"))

#' Save blotter variables which are to be loaded back into .blotter environment
#' during analysis
save(list = ls(.blotter), file = here::here("./data/blotter_bh.rda"), envir = .blotter)

#' Save instruments
saveInstruments(file_name = "instruments_bh", dir = here::here("./data"))
