#' RobinHood API: Option Contract Instruments
#'
#' @param RH object of class RobinHood
#' @param chain_symbol (string) a single ticker symbol
#' @param type (string) one of call or put
#' @import httr magrittr
#' @export
api_contracts <- function(RH, chain_symbol, type) {

  # URL and token
  url <- paste(RobinHood::api_endpoints(endpoint = "option_instruments"),
               "?state=active",
               "&type=", type,
               "&chain_symbol=", chain_symbol, sep = "")

  token <- paste("Bearer", RH$api_response.access_token)

  # GET call
  dta <- GET(url,
             add_headers("Accept" = "application/json",
                         "Content-Type" = "application/json",
                         "Authorization" = token))
  httr::stop_for_status(dta)

  # format return
  dta <- RobinHood::mod_json(dta, "fromJSON")
  dta <- as.data.frame(dta$results)

  # If returns no rows, no options exist
  if (nrow(dta) == 0) stop("No active contracts exist")

  # Format ticks
  dta$above_tick <- as.numeric(dta$min_ticks$above_tick)
  dta$below_tick <- as.numeric(dta$min_ticks$below_tick)
  dta$cutoff_price <- as.numeric(dta$min_ticks$cutoff_price)

  dta <- dta %>%
    dplyr::mutate_at(c("strike_price"), function(x) as.numeric(as.character(x))) %>%
    dplyr::mutate_at(c("issue_date", "expiration_date"), lubridate::ymd) %>%
    dplyr::mutate_at(c("created_at", "updated_at"), lubridate::ymd_hms) %>%
    dplyr::select(-c("min_ticks"))

  # Order by expiration date
  dta <- dta[order(x = dta$expiration_date), ]

  return(dta)
}
