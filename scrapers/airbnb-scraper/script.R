library(Rcrawler)
library(stringr)
library(data.table)
library(xml2)
library(httr)
library(RSelenium)
library(tidyverse)
library(readxl)

homes_db <- data.frame(url = character(0), title = character(0), price = character(0), rating = character(0), street = character(0))

streets <- read_excel("data.xlsx", sheet = 2)
rD <- rsDriver(browser = "chrome", chromever = "101.0.4951.41", port = 4444L)
remDr <- remoteDriver(browserName = "chrome", port = 4444L)
remDr$open()


#j <- 552
while(j<=609){
    i <- 1
    street_name <- streets[["adjust-for-url"]][j]
    url = paste("https://airbnb.com/s/",street_name,"--Truckee--CA--EUA/homes?items_offset=",(i-1)*20,"&locale=en&display_currency=USD",sep="")
    remDr$navigate(url)
    n = 0
    k = 10
    
    while(n  == 0 && k >0){
      n_pages <- try(remDr$findElements(using = "xpath", value = '//a[contains(@href,"offset")]'))
      pages <- sapply(n_pages, function(x) x$getElementText())  
      k = k-1
      Sys.sleep(1)
      n = length(pages)
    }
    if(k == 0){
      
      n = 1
    }else{
      

      
      n = as.numeric(pages[[length(pages)-1]]) 
        
    }
    
    
    
    while(i<=n){
    url = paste("https://airbnb.com/s/",street_name,"--Truckee--CA--EUA/homes?items_offset=",(i-1)*20,"&locale=en&display_currency=USD",sep="")
    remDr$navigate(url)
    Sys.sleep(3)
      
      home_url <- try(remDr$findElements(using = "xpath", value = '//*[@class="lwm61be dir dir-ltr"]'))
      home_title <- try(remDr$findElements(using = "xpath", value = '//*[@class="t1jojoys dir dir-ltr"]'))
      home_price <- try(remDr$findElements(using = "xpath", value = '//*[@class="_tyxjp1"]'))
      home_rating <- try(remDr$findElements(using = "xpath", value = '//*[@class="ru0q88m dir dir-ltr"]'))
      
      urls <- sapply(home_url, function(x) x$getElementAttribute("href"))  
      titles <- sapply(home_title, function(x) x$getElementText())
      prices <- sapply(home_price, function(x) x$getElementText())
      rating <- sapply(home_rating, function(x) x$getElementText())
      
      homes_db <- rbind(homes_db, data.frame(url = unlist(urls), title = unlist(titles), price = unlist(prices),rating = unlist(rating), street = streets[["street name"]][j]))
    
      i <- i+1
      print(j)
    }  
  j <- j+1
}      
  homes_db <- homes_db %>% mutate(rooms = NA, full_name = NA, description = NA, number_reviews = NA, maps_link = NA)  
  rD <- rsDriver(browser = "chrome", chromever = "101.0.4951.41", port = 4460L)
  remDr <- remoteDriver(browserName = "chrome", port = 4460L)
  remDr$open()
  o <- 0L
 # j <- 23322
  while(j<=98942){
  
  p <- try(remDr$navigate(paste(homes_db[["url"]][j], "&locale=en", sep = "")))
  while(class(p) == 'try-error'){
    o <- o+1L
    rD <- rsDriver(browser = "chrome", chromever = "101.0.4951.41", port = 4460L+o)
    remDr <- remoteDriver(browserName = "chrome", port = 4460L+o)
    remDr$open()
    p <- try(remDr$navigate(paste(homes_db[["url"]][j], "&locale=en", sep = "")))
    }
  Sys.sleep(1)
  webElem <- remDr$findElement("css", "body")
  webElem$sendKeysToElement(list(key = "end"))
  Sys.sleep(0.3)
  webElem$sendKeysToElement(list(key = "end"))
  Sys.sleep(0.3)
  webElem$sendKeysToElement(list(key = "end"))
  Sys.sleep(0.3)
  webElem$sendKeysToElement(list(key = "end"))
  Sys.sleep(1.2)
  homes_db[["rooms"]][j] <- try(remDr$findElement(using = "xpath", value = '//*[@class="l7n4lsf dir dir-ltr"]')$getElementText())[[1]]
  homes_db[["description"]][j] <- try(remDr$findElement(using = "xpath", value = '//*[@class="ll4r2nl dir dir-ltr"]')$getElementText())[[1]]
  homes_db[["number_reviews"]][j] <- try(remDr$findElement(using = "xpath", value = '//*[@class="_s65ijh7"]')$getElementText())[[1]]
  homes_db[["full_name"]][j] <- try(remDr$findElement(using = "xpath", value = '//*[@class="_fecoyn4"]')$getElementText())[[1]]
  mp_link <- try(remDr$findElement(using = "xpath", value = '//a[contains(@href,"maps.google")]')$getElementAttribute("href"))[[1]]
   
  
  while(class(mp_link) == 'try-error'){
    webElem <- remDr$findElement("css", "body")
    webElem$sendKeysToElement(list(key = "end"))
    Sys.sleep(0.3)
    mp_link <- try(remDr$findElement(using = "xpath", value = '//a[contains(@href,"maps.google")]')$getElementAttribute("href"))[[1]]  
    }
  homes_db[["maps_link"]][j] <- mp_link
  
  print(homes_db[["maps_link"]][j])
  print(j)
  j <- j+1
  }

    
  write_csv2(homes_db, "airbnb_data.csv")
  