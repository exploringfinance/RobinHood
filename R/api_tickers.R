#' RobinHood API: Tickers
#'
#' Backend function called by get_ticker. Returns a data frame of all instruments listed
#' on RobinHood.
#'
#' @param RH object of class RobinHood
#' @import httr magrittr
#' @export
api_tickers <- function(RH) {

  cat("Getting stock ticker data from RobinHood.com...")

  # Stopwatch
  start_time <- proc.time()

  # URL and token
  url <- RobinHood::api_endpoints("instruments")
  token <- paste("Bearer", RH$api_response.access_token)

  # GET call
  dta <- GET(url,
             add_headers("Accept" = "application/json",
                         "Content-Type" = "application/json",
                         "Authorization" = token))
  httr::stop_for_status(dta)

  # Format return
  dta <- RobinHood::mod_json(dta, "fromJSON")

  output <- dta$results

  # Cycle through the pages of tickers until all have been pulled
  while (length(dta$`next`) > 0) {

    # URL
    url <- dta$`next`

    # GET call
    dta <- GET(url,
               add_headers("Accept" = "application/json",
                           "Content-Type" = "application/json",
                           "Authorization" = token))
    httr::stop_for_status(dta)

    # Format return
    dta <- RobinHood::mod_json(dta, "fromJSON")

    output <- rbind(output, dta$results)

    profvis::pause(.25)
  }

  # Stopwatch
  end_time <- proc.time() - start_time

  cat("..........COMPLETE (", round(end_time[3] / 60, 2), "minutes)\n")


  return(output)
}
