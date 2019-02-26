options(
  repos = c(
    CRAN = "https://mran.microsoft.com/snapshot/2019-01-01"
  ),
  download.file.method = "libcurl"
)

## This makes sure that R loads the workflowr package
## automatically, everytime the project is loaded
if (requireNamespace("workflowr", quietly = TRUE)) {
  message("Loading .Rprofile for the current workflowr project")
  library("workflowr")
} else {
  message("workflowr package not installed, please run devtools::install_github('jdblischak/workflowr') to use the workflowr functions")
}
