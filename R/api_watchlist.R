#' RobinHood API: watchlist
#'
#' Backend function called by watchlist(). Adds or remove instruments from the default watchlist. The create
#' and delete watchlist features are disabled as it appears that the functionality is not currently available
#' on the plateform.
#'
#' @param RH object of class RobinHood
#' @param watchlist_url (string) a single watchlist url
#' @param detail (logical) if null use header api only, otherwise pass options
#' @param delete (logical) send delete call
#' @import httr magrittr
#' @export
api_watchlist <- function(RH, watchlist_url, detail = FALSE, delete = FALSE) {

  # URL and token
  url <- watchlist_url
  token <- paste("Bearer", RH$api_response.access_token)

  # URL and token
  url <- watchlist_url
  token <- paste("Bearer", RH$api_response.access_token)

  # Send a command to delete a watchlist or instrument from a watchlist
  if (delete == TRUE) {

    # GET call
    dta <- GET(url,
               add_headers("Accept" = "application/json",
                           "Content-Type" = "application/json",
                           "Authorization" = token),
               config(customrequest = "DELETE"))
    httr::stop_for_status(dta)

    dta <- rawToChar(dta$content)

  }

  # Get all watchlists
  if (delete == FALSE & detail == FALSE) {

    # GET call
    dta <- GET(url,
               add_headers("Accept" = "application/json",
                           "Content-Type" = "application/json",
                           "Authorization" = token))
    httr::stop_for_status(dta)

    dta <- RobinHood::mod_json(dta, "fromJSON")

  }

  # Send a command to add an instrument to an existing watchlist
  if (delete == FALSE & detail != FALSE) {

    # POST call
    dta <- POST(url,
                add_headers("Accept" = "application/json",
                            "Content-Type" = "application/json",
                            "Authorization" = token),
                body = mod_json(detail, "toJSON"))
    httr::stop_for_status(dta)

    dta <- RobinHood::mod_json(dta, "fromJSON")

  }

  return(dta)
}
