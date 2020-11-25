library(tidyverse)
library(ggmap)
library(readxl)

#download NM Rapid Response XLSX file
download.file(url = "https://www.env.nm.gov/wp-content/uploads/covid/All%20Rapid%20Responses.xlsx",destfile = "NMRR.xlsx")

#Read data in from from Rapid resposne site
new_NMRR<-read_excel('NMRR.xlsx')

#add NM column to DF
new_NMRR <- new_NMRR %>% mutate(STATE="NM")

#read in current data
old_NMRR <- read_csv('NMRR.csv')

#get last data in current data
latest_date <- max(old_NMRR$`DATE INITIATED`)

#down select to only updated data
new_NMRR<-new_NMRR %>% filter(`DATE INITIATED`>latest_date)

#remove pound signs from address, caused an error in google API, could probably URL encode but whatever this works
new_NMRR <- new_NMRR %>% mutate(ADDRESS = gsub("#.*","",ADDRESS))

#add full address to NMRR address set
new_NMRR <- new_NMRR %>% 
              mutate(fulladdress = paste0(ADDRESS,",", CITY,",",STATE))

#registere geo-code API
register_google( key = 'XXXXXXX')

#add geocodes to new data
lat_long <- mutate_geocode(new_NMRR,location = fulladdress)

#add new data to old data frame
updated_NMRR <- rbind(old_NMRR,lat_long)
#backup only CSV
write_csv(old_NMRR,"NMRR_backup.csv")

#write new data CSV
write_csv(updated_NMRR,"NMRR.csv")

#update data source in Tableau



