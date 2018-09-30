# Variables ----
init_date <- "2004-12-31"

start_date <- "2005-01-01"

end_date <- "2014-12-31"

init_equity <- 1e4

symbols <- c("IWM", "QQQ", "SPY", "TLT")

benchmark <- "^GSPC"

#' `theo_symbol` is the symbol used to create a buy and hold strategy from the
#' date of the first trade too `end_date`. This is used in places such as
#' `blotter::chart.Reconcile` to analyse the strategy versus a simple buy and
#' hold strategy.

#' Assign theoretical account the same name as theoretical portfolio
theo_account <- "buy_hold"

theo_portfolio <- theo_account

strategy <- "connors_rsi"
portfolio <- strategy
account <- strategy
