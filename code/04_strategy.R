# Libraries ----
library(quantstrat)
library(TTR)

source(here::here("./code/02_settings.R"))

# Settings ----
Sys.setenv(TZ = "UTC")

currency("USD")

getSymbols(
  Symbols = c(symbols, benchmark),
  src = "yahoo",
  index.class = "POSIXct",
  from = start_date,
  to = end_date,
  adjust = TRUE
)

stock(c(symbols, benchmark), currency = "USD", multiplier = 1)

rm.strat(portfolio)
rm.strat(theo_portfolio)
rm.strat(benchmark_portfolio)

initPortf(name = portfolio, symbols = symbols, initDate = init_date)
initPortf(name = theo_portfolio, symbols = symbols, initDate = init_date)
initPortf(name = benchmark_portfolio, symbols = symbols, initDate = init_date)

initAcct(
  name = account,
  portfolios = c(portfolio, theo_portfolio, benchmark_portfolio),
  initDate = init_date,
  initEq = init_equity
)

initOrders(portfolio = portfolio, symbols = symbols, initDate = init_date)
initOrders(portfolio = theo_portfolio, symbols = symbols, initDate = init_date)
initOrders(portfolio = benchmark_portfolio, symbols = symbols, initDate = init_date)

strategy(portfolio, store = TRUE)
strategy(theo_portfolio, store = TRUE)
strategy(benchmark_portfolio, store = TRUE)

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
    TxnDate = strftime(first(time(get(.x))), format = "%Y-%m-%d"),
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
    TxnDate = strftime(last(time(get(.x))), format = "%Y-%m-%d"),
    TxnQty = -100,
    TxnPrice = last(Ad(get(.x)))
  )
)

#' Add benchmark transaction
#' buy
addTxn(
  Portfolio = benchmark_portfolio,
  Symbol = benchmark,
  TxnDate = strftime(first(time(get(clean_benchmark))), format = "%Y-%m-%d"),
  TxnQty = 100,
  TxnPrice = first(Ad(get(clean_benchmark)))
)

#' sell
addTxn(
  Portfolio = benchmark_portfolio,
  Symbol = benchmark,
  TxnDate = strftime(last(time(get(clean_benchmark))), format = "%Y-%m-%d"),
  TxnQty = -100,
  TxnPrice = last(Ad(get(clean_benchmark)))
)

# Update ----
purrr::walk(
  .x = c(portfolio, theo_portfolio, benchmark_portfolio),
  .f = updatePortf
)

updateAcct(account)
updateEndEq(account)

## Save ----
#' Save account
a <- getAccount(Account = account)
save(a, file = here::here("./data/account.RData"))

#' Save Instruments from FinancialInstruments environment
saveInstruments(file_name = "instruments.RData", dir = here::here("./data"))

#' Save strategy portfolio
p <- getPortfolio(Portfolio = portfolio)
save(p, file = here::here("./data/portfolio.RData"))

#' Save theoretical portfolio
pbh <- getPortfolio(Portfolio = theo_portfolio)
save(pbh, file = here::here("./data/theo_portfolio.RData"))

#' Save theoretical portfolio
pbm <- getPortfolio(Portfolio = benchmark_portfolio)
save(pbm, file = here::here("./data/benchmark_portfolio.RData"))

#' Save symbol datasets
purrr::walk(
  #' Replace any special symbols (such as carets) with nothing
  .x = c(symbols, clean_benchmark),
  .f = ~save(list = .x, file = glue::glue("./data/{.x}.RData"))
)
