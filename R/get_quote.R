#' Get a quote from RobinHood
#'
#' @param RH object class RobinHood
#' @param symbol (string) of ticker symbols
#' @param limit_output (logical) if TRUE (default) return less quote detail
#' @import httr magrittr
#' @export
#' @examples
#' \dontrun{
#' # Login in to your RobinHood account
#' RH <- RobinHood("username", "password")
#'
#' get_quote(RH, "IR")
#'}
get_quote <- function(RH, symbol, limit_output = TRUE) {

    # Check if RH is valid
    RobinHood::check_rh(RH)

    # Get latest quote
    quote <- paste(symbol, collapse = ",")

    # Quotes URL
    quote_url <- paste(RobinHood::api_endpoints(endpoint = "quotes"), quote, sep = "")

    # Get last price
    quotes <- RobinHood::api_quote(RH, quote_url)

    # Trim output
    quotes <- quotes[, !names(quotes) %in% c("instrument")]

    if (limit_output == TRUE) {

        quotes <- quotes %>%
            dplyr::select(c("symbol", "last_trade_price"))

    } else {

        quotes <- quotes %>%
          dplyr::select(c("symbol", "last_trade_price", "last_trade_price_source", "ask_price", "ask_size",
                          "bid_price", "bid_size", "previous_close", "adjusted_previous_close", "previous_close_date",
                          "last_extended_hours_trade_price", "trading_halted", "has_traded", "updated_at"))
    }

    return(quotes)

}
