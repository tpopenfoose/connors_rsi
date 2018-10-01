# Variables ----
init_date <- "2004-12-31"

start_date <- "2005-01-01"

end_date <- "2014-12-31"

init_equity <- 1e6

symbols <- c("IWM", "QQQ", "SPY", "TLT")

#' Benchmark symbol to compare performance of strategy
benchmark <- "SPY"
#' Clean benchmark symbol of special characters
clean_benchmark <- "SPY"
benchmark_portfolio <- "benchmark"

#' Theoretical portfolio to compare buy and hold to strategy
theo_portfolio <- "theo_portfolio"

strategy <- "connors_rsi"

portfolio <- strategy
account <- strategy
