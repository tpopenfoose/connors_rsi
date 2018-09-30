# Libraries ----
library(quantstrat)
library(TTR)

source(here::here("./code/02_settings.R"))

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

rm.strat(portfolio)
rm.strat(theo_portfolio)

initPortf(name = portfolio, symbols = symbols, initDate = init_date)
initPortf(name = theo_portfolio, symbols = symbols, initDate = init_date)

initAcct(
  name = account,
  portfolios = portfolio,
  initDate = init_date,
  initEq = init_equity
)

initAcct(
  name = theo_account,
  portfolios = theo_portfolio,
  initDate = init_date,
  initEq = init_equity
)

initOrders(portfolio = portfolio, symbols = symbols, initDate = init_date)
initOrders(portfolio = theo_portfolio, symbols = symbols, initDate = init_date)

strategy(portfolio, store = TRUE)
strategy(theo_portfolio, store = TRUE)

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

# Apply Strategy ----
applyStrategy(strategy = strategy, portfolios = portfolio)

#' Add buy and hold transactions
#' buy
purrr::walk(
  .x = symbols,
  .f = ~addTxn(
    Portfolio = theo_portfolio,
    Symbol = .x,
    TxnDate = strftime(first(time(get(x))), format = "%Y-%m-%d"),
    TxnQty = 100,
    TxnPrice = first(Ad(get(.x)))
  )
)

#' sell
purrr::walk(
  .x = symbols,
  .f = ~addTxn(
    Portfolio = theo_portfolio,
    Symbol = .x,
    TxnDate = strftime(last(time(get(x))), format = "%Y-%m-%d"),
    TxnQty = -100,
    TxnPrice = last(Ad(get(.x)))
  )
)

# Update ----
purrr::walk(.x = c(portfolio, theo_portfolio), .f = updatePortf)
purrr::walk(.x = c(account, theo_account), .f = updateAcct)
purrr::walk(.x = c(account, theo_account), .f = updateEndEq)

## Save

#' Save Instruments from FinancialInstruments environment
saveInstruments(file_name = "instruments.RData", dir = here::here("./data"))

#' Save strategy portfolio
p <- getPortfolio(Portfolio = portfolio)
save(p, file = here::here("./data/portfolio.RData"))

#' Save theoretical portfolio
pbh <- getPortfolio(Portfolio = theo_portfolio)
save(pbh, file = here::here("./data/theo_portfolio.RData"))

#' Save account
a <- getAccount(Account = account)
save(a, file = here::here("./data/account.RData"))

abh <- getAccount(Account = account)
save(abh, file = here::here("./data/theo_account.RData"))

#' Save symbol datasets
purrr::walk(symbols, ~save(list = .x, file = glue::glue("./data/{.x}.RData")))
