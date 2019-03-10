#' Packages required for this project; in order of required install

#' devtools, tidyquant, tidyverse
install.packages(
  c("devtools", "here", "skimr", "tidyverse", "tidyquant", "tsibble")
)

#' Blotter
devtools::install_github("braverock/blotter@bc75cf5") #' v0.14.2 (May 12)

#' Quantstrat
devtools::install_github("braverock/quantstrat@be01b35") #' v0.14.6 (Jun 27)

#' hrbrthemes (not required but I like it and it's in use)
devtools::install_github("hrbrmstr/hrbrthemes@v0.6.0") #' Apr 29

#' workflowr
devtools::install_github('jdblischak/workflowr@v1.2.0')

#' tidyfinance
devtools::install_github("DavisVaughan/tidyfinance@56917ea")
