% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_historicals_options.R
\name{get_historicals_options}
\alias{get_historicals_options}
\title{Get historical options from RobinHood}
\usage{
get_historicals_options(
  RH,
  chain_symbol,
  type,
  strike_price,
  expiration_date,
  interval = NULL,
  span = NULL
)
}
\arguments{
\item{RH}{object of class RobinHood}

\item{chain_symbol}{(string) stock symbol}

\item{type}{(string) one of ("put", "call")}

\item{strike_price}{(numeric) strike price}

\item{expiration_date}{(string) expiration date (YYYY-MM-DD)}

\item{interval}{(string) one of ("5minute", "10minute", "hour", "day", "week")}

\item{span}{(string) one of ("day", "week", "month")}
}
\description{
Returns a data frame of historical options for a given symbol, strike price, and expiration date.
}
\examples{
\dontrun{
# Login in to your RobinHood account
RH <- RobinHood("username", "password")

get_historicals_options(RH = RH, chain_symbol = "AAPL", interval = "10minute", type = "call",
                        expiration_date = "2021-03-12", strike_price = 122)

}
}
