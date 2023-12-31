#' Get portfolio summaries related to your RobinHood Account
#'
#' Returns a dataframe of portfolio summaries for a specific period of time. Default is current day.
#'
#' @param RH object of class RobinHood
#' @param interval (string) Interval of time to aggregate to (examples: hour, day, week, month)
#' @param span (string) Period of time you are interested in (examples: day, week, month, year)
#' @import httr magrittr
#' @export
#' @examples
#' \dontrun{
#' # Login in to your RobinHood account
#' RH <- RobinHood("username", "password")
#'
#' get_portfolios(RH)
#' get_portfolios(RH, interval = "day", span = "3month")
#'}
get_portfolios <- function(RH, interval = NULL, span = NULL) {

    # Check if RH is valid
    RobinHood::check_rh(RH)

    # Get account number
    account_number <- RobinHood::api_accounts(RH)
    account_number <- account_number$account_number

    # If no span or interval given, return current day value
    if (is.null(interval) | is.null(span)) {

        # Call portfolio api
        portfolio_url <- RobinHood::api_endpoints("portfolios")
        portfolios <- RobinHood::api_portfolios(RH, portfolio_url)

        # Reorder columns
        portfolios <- portfolios[, c("start_date",
                                     "unwithdrawable_grants",
                                     "excess_maintenance_with_uncleared_deposits",
                                     "excess_maintenance",
                                     "market_value", "withdrawable_amount",
                                     "last_core_market_value",
                                     "unwithdrawable_deposits",
                                     "extended_hours_equity",
                                     "excess_margin",
                                     "excess_margin_with_uncleared_deposits",
                                     "equity",
                                     "last_core_equity",
                                     "adjusted_equity_previous_close",
                                     "equity_previous_close",
                                     "extended_hours_market_value")]

    } else {

      # Get porfolio value for the specific span and interval
      portfolio_url <- paste(api_endpoints("portfolios"),
                             "historicals/", account_number,
                             "/?account_number=", account_number,
                             "&bounds=24_7",
                             "&interval=", interval,
                             "&span=", span,
                             sep = "")

      portfolios <- RobinHood::api_portfolios(RH, portfolio_url)

      # Reorder columns
      portfolios <- portfolios[, c("begins_at",
                                   "adjusted_open_equity",
                                   "adjusted_close_equity",
                                   "open_equity",
                                   "close_equity",
                                   "open_market_value",
                                   "close_market_value",
                                   "net_return",
                                   "session")]

   }

  return(portfolios)

}
