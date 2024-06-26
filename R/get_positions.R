#' Get the currently held positions for your RobinHood account
#'
#' @param RH object class RobinHood
#' @param limit_output (logical) if true, return a simplified positions table, false returns all position details
#' @import httr magrittr
#' @export
#' @examples
#' \dontrun{
#' # Login in to your RobinHood account
#' RH <- RobinHood("username", "password")
#'
#' get_positions(RH)
#'}
get_positions <- function(RH, limit_output = TRUE) {

    # Check if RH is valid
    RobinHood::check_rh(RH)

    # Get current positions
    positions <- RobinHood::api_positions(RH)


    # Use instrument IDs to get the ticker symbol and name
    instrument_id <- positions$instrument
    instruments <- c()

    # For each instrument id, get stocker symbols and names
    for (inst in instrument_id) {
      instrument <- RobinHood::api_instruments(RH, instrument_url = inst)

      # If any simple names are blank, use full name
      x <- data.frame(simple_name = ifelse(is.null(instrument$simple_name),
                                                   instrument$name,
                                                   instrument$simple_name),
                                           symbol = instrument$symbol)

      instruments <- rbind(instruments, x)
    }

    # If No positions, return empty DF
    if(length(instrument_id)==0){
      instruments = stats::setNames(data.frame(matrix(ncol = 2, nrow = 0)), c("simple_name", "symbol"))
    }

    ### 3/26/2024 - use left join instead of merge because positions now has symbols
    # Combine positions with instruments/
    sym_chk = 'symbol' %in% colnames(positions)
    if(sym_chk){
      positions <- dplyr::left_join(instruments, positions)
    } else {
      positions <- cbind(instruments, positions)
    }

    # Get latest quote
    symbols <- paste(as.character(positions$symbol), collapse = ",")

    # Quotes URL
    symbols_url <- paste(RobinHood::api_endpoints(endpoint = "quotes"), symbols, sep = "")

    # Check if symbols exist
    if(nchar(symbols)>0){
      # Get last price
      quotes <- RobinHood::api_quote(RH, symbols_url)
      quotes <- quotes[, c("last_trade_price", "symbol")]
    } else {
      # Otherwise return an empty data frame
      quotes = stats::setNames(data.frame(matrix(ncol = 2, nrow = 0)), c("last_trade_price", "symbol"))
    }

    # Combine quotes with positions
    positions <- merge(positions, quotes)

    # Get rid of arbitrary columns
    positions <- positions[, !names(positions) %in% c("account", "url", "instrument")]

    # Convert timestamp
    positions$updated_at <- lubridate::ymd_hms(positions$updated_at)
    positions$created_at <- lubridate::ymd_hms(positions$created_at)

    # Adjust data types
    positions$symbol <- as.character(positions$symbol)
    positions$quantity <- as.numeric(positions$quantity)
    positions$average_buy_price <- as.numeric(positions$average_buy_price)
    positions$last_trade_price <- as.numeric(positions$last_trade_price)
    positions$shares_held_for_stock_grants <- as.numeric(positions$shares_held_for_stock_grants)
    positions$shares_held_for_options_events <- as.numeric(positions$shares_held_for_options_events)
    positions$shares_held_for_options_collateral <- as.numeric(positions$shares_held_for_options_collateral)
    positions$shares_held_for_buys <- as.numeric(positions$shares_held_for_buys)
    positions$shares_held_for_sells <- as.numeric(positions$shares_held_for_sells)
    positions$shares_pending_from_options_events <- as.numeric(positions$shares_pending_from_options_events)
    positions$pending_average_buy_price <- as.numeric(positions$pending_average_buy_price)
    positions$intraday_average_buy_price <- as.numeric(positions$intraday_average_buy_price)
    positions$intraday_quantity <- as.numeric(positions$intraday_quantity)

    # Calculate extended cost and value
    positions$cost <- positions$average_buy_price * positions$quantity
    positions$current_value <- positions$last_trade_price * positions$quantity

    # Output Options
    if (limit_output == TRUE) {
      # Reorder dataframe
      positions <- positions[, c("simple_name",
                                 "symbol",
                                 "quantity",
                                 "average_buy_price",
                                 "last_trade_price",
                                 "cost",
                                 "current_value",
                                 "updated_at")]
                               }

    if (limit_output == FALSE) {
      positions <- positions[, c("symbol",
                                 "simple_name",
                                 "quantity",
                                 "average_buy_price",
                                 "last_trade_price",
                                 "cost",
                                 "current_value",
                                 "shares_held_for_stock_grants",
                                 "shares_held_for_options_events",
                                 "shares_held_for_options_collateral",
                                 "shares_held_for_buys",
                                 "shares_held_for_sells",
                                 "shares_pending_from_options_events",
                                 "pending_average_buy_price",
                                 "intraday_average_buy_price",
                                 "intraday_quantity",
                                 "created_at",
                                 "updated_at")]
                               }

    return(positions)
  }
