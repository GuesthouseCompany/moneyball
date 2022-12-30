source("functions.R")


foursquare_data <- data.frame(city = character(0), name = character(0), address = character(0), zip_code = character(0), formatted_address = character(0), category = character(0), lat = numeric(0), lng = numeric(0))
cities <- read_csv2("AU_cities.csv") %>% filter(time <= 6,time >= 1 ,state_id == "TX", population <= 50000, population >= 15000)
categories <- read_csv2("categories.csv")

n <- nrow(cities)
n_c <- nrow(categories)
k <- 1

while(k <= n_c){
  i <- 1
  while(i <= n) {
    
    queryString <- list(
                        categories = categories[["Category IDs"]][k],
                        near = cities[["city"]][i],
                        limit = "50",
                        sort = "RATING",
                        cursor = '')
    
    data <- foursquare_places(queryString = queryString, api_token = 'fsq3ybsX+uiZ99Yvc222i/O26mQvjkdek8XExwO0ZdHm+WQ=') 
    
    j <- 1
    while(j <= length(data[["response_body"]][["results"]])){
      city = cities[["city"]][i]
      name = data[["response_body"]][["results"]][[j]][["name"]]
      address = ifelse(class(try(data[["response_body"]][["results"]][[j]][["location"]][["address"]]))=='try-error' || is.null(try(data[["response_body"]][["results"]][[j]][["location"]][["address"]])),"",try(data[["response_body"]][["results"]][[j]][["location"]][["address"]]))
      zip_code = ifelse(class(try(data[["response_body"]][["results"]][[j]][["location"]][["postcode"]]))=='try-error' || is.null(try(data[["response_body"]][["results"]][[j]][["location"]][["postcode"]])),"",try(data[["response_body"]][["results"]][[j]][["location"]][["postcode"]])) 
      formatted_address = data[["response_body"]][["results"]][[j]][["location"]][["formatted_address"]]
      category = data[["response_body"]][["results"]][[j]][["categories"]][[1]][["name"]]
      lat = ifelse(is.null(data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["latitude"]]), NA, data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["latitude"]])
      lng = ifelse(is.null(data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["longitude"]]), NA, data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["longitude"]])
      
      foursquare_data <- rbind(foursquare_data, data.frame(city = city, name = name, address = address, zip_code = zip_code, formatted_address = formatted_address, category = category, lat = lat, lng = lng))
      j <- j+1
    }
    
    i <- i+1
    Sys.sleep(0.2)
  }
  k <- k+1
  print(k)
}

write_csv2(foursquare_data, "foursquare_data_au.csv")