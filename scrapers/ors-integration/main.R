source("functions.R")

us_cities <- read_csv("uscities.csv")


#TODO: COLOCAR ALGUNS REQUISITOS PARA DIMINUIR AINDA MAIS O NUMERO DE REQUISIÇÕES DE API:
  #1. POPULAÇÃO
  #2. ESTADOS VIZINHOS (PRA GENERALIZAR OS CASOS EM QUE A CIDADE FICA NA FRONTEIRA)
distance_from_target <- us_cities %>% mutate(distance = NA, time = NA) %>% filter(state_id %in% c("CA"), population >= 5000, population <= 50000)

n <- nrow(distance_from_target)

i <- 1

while(i <= n){
  
  x <- find_distance(lat_1 = 37.7558,lat_2 =  distance_from_target[["lat"]][i], lng_1 = -122.4449, lng_2 =  distance_from_target[["lng"]][i])
  distance_from_target[["distance"]][i] <- x["distance"]
  distance_from_target[["time"]][i] <- x["duration"]
  Sys.sleep(0.3)
  print(i)
  
  i <- i+1

  }

write_csv2(distance_from_target, "SF_cities.csv")
