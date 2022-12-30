library(httr)
library(tidyverse)
library(lubridate)
library(RCurl)
library(RMySQL)
library(RJSONIO)
library(urltools)

foursquare_places <- function(queryString, api_token){

  response <- httr::GET(url = 'https://api.foursquare.com/v3/places/search',
                      add_headers('Authorization' = api_token),
                      query = queryString
                      ) 

  response_body <- response %>%
                   httr::content(as="text") %>%
                   fromJSON() 

  response_header <- response %>% headers()

  return(list(response_header = response_header, response_body = response_body))
  }

