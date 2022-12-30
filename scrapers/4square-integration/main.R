source("functions.R")

foursquare_data <- data.frame(name = character(0), address = character(0), zip_code = character(0), formatted_address = character(0), category = character(0), lat = numeric(0), lng = numeric(0))

queryString <- list(
                    categories = "16000",
                    near = "Palm Springs",
                    limit = "50",
                    sort = "RATING",
                    cursor = '')
i <- 1
while(i <= 5){
  data <- foursquare_places(queryString = queryString, api_token = 'fsq3ybsX+uiZ99Yvc222i/O26mQvjkdek8XExwO0ZdHm+WQ=')
  
  j <- 1
  while(j <= 50){
    name = data[["response_body"]][["results"]][[j]][["name"]]
    address = ifelse(class(try(data[["response_body"]][["results"]][[j]][["location"]][["address"]]))=='try-error',"",try(data[["response_body"]][["results"]][[j]][["location"]][["address"]]))
    zip_code = data[["response_body"]][["results"]][[j]][["location"]][["postcode"]]
    formatted_address = data[["response_body"]][["results"]][[j]][["location"]][["formatted_address"]]
    category = data[["response_body"]][["results"]][[j]][["categories"]][[1]][["name"]]
    lat = data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["latitude"]]
    lng = data[["response_body"]][["results"]][[j]][["geocodes"]][["main"]][["longitude"]]
    
    foursquare_data <- rbind(foursquare_data, data.frame(name = name, address = address, zip_code = zip_code, formatted_address = formatted_address, category = category, lat = lat, lng = lng))
    j <- j+1
  }
  
  if(!is.null(data[["response_header"]][["link"]])){
     link_params <- urltools::param_get(data[["response_header"]][["link"]])
     queryString <- list(
                     categories = "16000",
                     near = "Palm Springs",
                     limit = "50",
                     sort = "RATING",
                     cursor = link_params[["cursor"]])
     print(i)
     i <- i+1
  }
  else{
    i <- 6
  }
}

write_csv2(foursquare_data, "lakes.csv")