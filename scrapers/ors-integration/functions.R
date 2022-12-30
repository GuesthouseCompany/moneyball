library(tidyverse)
library(httr)
library(lubridate)
library(openrouteservice)

ors_api_key("5b3ce3597851110001cf6248cde4d091417842aca141c3a122f781dd")

find_distance <- function(lat_1, lat_2, lng_1, lng_2){
    coordinates <- data.frame(lon = c(lng_1, lng_2), lat = c(lat_1, lat_2))
    
    route <- ors_directions(coordinates, radiuses = -1)
    
    return(unlist(route$features[[1]]$properties$summary) / c(1000, 3600))
    
}