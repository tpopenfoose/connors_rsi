# Libraries ----
library(quantstrat)
library(TTR)
library(tidyverse)

# Variables ----
init_date <- "2004-12-31"
start_date <- "2005-01-01"
end_date <- "2014-12-31"
init_equity <- 1e4
symbols <- c("IWM", "QQQ", "SPY")

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

walk(c("strategy", "portfolio", "account"), assign, value = "connors_rsi_2", envir = .GlobalEnv)
portfolio <- "connors_rsi"
account <- "connors_rsi"
strategy <- "connors_rsi"

rm.strat(portfolio)
rm.strat(account)

initPortf(name = portfolio, symbols = symbols, initDate = init_date)

initAcct(
  name = account,
  portfolios = portfolio,
  initDate = init_date,
  initEq = init_equity
)

initOrders(portfolio = portfolio, symbols = symbols, initDate = init_date)

strategy(portfolio, store = TRUE)

strat <- getStrategy(portfolio)

# Indicators ----

# * RSI(2) ----
add.indicator(
  strategy  = strategy,
  name      = "RSI",
  arguments = list(
    price     = quote(getPrice(mktdata)),
    n         = 2,
    maType    = "SMA"
  ),
  label     = "RSI2"
  )

# * SMA(5) ----
add.indicator(
  strategy  = strategy,
  name      = "SMA",
  arguments = list(
    x         = quote(Cl(mktdata)),
    n         = 5
  ),
  label     = "SMA5"
  )

# * SMA(200) ----
add.indicator(
  strategy  = strategy,
  name      = "SMA",
  arguments = list(
    x         = quote(Cl(mktdata)),
    n         = 200
  ),
  label     = "SMA200"
  )

# Signals ----

# * rsi2_lt_5 ----
add.signal(
  strategy  = strategy,
  name      = "sigThreshold",
  arguments = list(
    threshold    = 5,
    column       = "RSI2",
    relationship = "lt",
    cross        = FALSE
  ),
  label     = "rsi2_lt_5"
)

# * cl_gte_sma5 ----
add.signal(
  strategy  = strategy,
  name      = "sigCrossover",
  arguments = list(
    columns      = c("Close", "SMA5"),
    relationship = "gte"
  ),
  label     = "cl_gte_sma5"
)

# * cl_lt_sma200 ----
add.signal(
  strategy  = strategy,
  name      = "sigComparison",
  arguments = list(
    columns      = c("Close", "SMA200"),
    relationship = "lt"
  ),
  label     = "cl_lt_sma200"
)

# * bto ----
add.signal(
  strategy  = strategy,
  name      = "sigFormula",
  arguments = list(
    columns   = c("rsi2_lt_5", "cl_lt_sma200"),
    formula   = "rsi2_lt_5 == TRUE & cl_lt_sma200 == FALSE",
    label     = "trigger",
    cross     = TRUE
  ),
  label     = "bto"
)

# Rules ----

# * Enter ----
add.rule(
  strategy  = strategy,
  name      = "ruleSignal",
  arguments = list(
    sigcol    = "bto",
    sigval    = TRUE,
    orderqty  = 100,
    ordertype = "market",
    orderside = "long"
  ),
  type      = "enter"
)

# * Exit ----
add.rule(
  strategy  = strategy,
  name      = "ruleSignal",
  arguments = list(
    sigcol    = "cl_lt_sma200",
    sigval    = TRUE,
    orderqty  = "all",
    ordertype = "market",
    orderside = "long"
  ),
  type      = "exit"
)

# * Exit ----
add.rule(
  strategy  = strategy,
  name      = "ruleSignal",
  arguments = list(
    sigcol    = "cl_gte_sma5",
    sigval    = TRUE,
    orderqty  = "all",
    ordertype = "market",
    orderside = "long"
  ),
  type      = "exit"
)

applyStrategy(strategy = strategy, portfolios = portfolio)

# Update ----
updatePortf(portfolio)
updateAcct(account)
updateEndEq(account)

## Save

#' Save environment variables to be used in analysis
save(list = ls(),         file = here::here("./data/env.rda"))

#' Save blotter variables which are to be loaded back into .blotter environment
#' during analysis
save(list = ls(.blotter), file = here::here("./data/blotter.rda"), envir = .blotter)
