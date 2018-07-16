# load packages
library(lubridate)
library(dplyr)
library(readxl)
library(zoo)
library(xts)


#Loading put (BR73) & call (BR77) options
BR73 <- read_excel("C:\\Users\\workgroup_2\\Documents\\FO\\BR73BS8_1Min_14072018.xlsx")
BR77 <- read_excel("C:\\Users\\workgroup_2\\Documents\\FO\\BR77BG8_1Min_14072018.xlsx")

# Tidy up them
# PUT
library(stringr)
BR73$Time <- BR73$Time %>% as.character() %>% 
  str_split(pattern = " ", simplify=T) %>%
  .[,2]

library(tidyr)
BR73_DT <-  
  BR73 %>% select(Date, Time, Close) %>% 
  unite(DateTime, Date, Time, sep = " ") 

# Set DateTime column to POSIXct format
BR73_DT$DateTime <- dmy_hms(BR73_DT$DateTime)  

# create xts format
dt <- BR73_DT$DateTime
cl <- BR73_DT$Close
BR73_option <- xts(cl, dt)

# CALL
BR77$Time <- BR77$Time %>% as.character() %>% 
  str_split(pattern = " ", simplify=T) %>%
  .[,2]

BR77_DT <-  
  BR77 %>% select(Date, Time, Close) %>% 
  unite(DateTime, Date, Time, sep = " ")

# Set DateTime column to POSIXct format
BR77_DT$DateTime <- dmy_hms(BR77_DT$DateTime)  

# create xts format
dt_call <- BR77_DT$DateTime
cl_call <- BR77_DT$Close
BR77_option <- xts(cl_call, dt_call)



# Upload Brent futures from Finam.ru
library(rusquant)
BRf <- getSymbols("SPFB.BR", 
                  src = 'Finam', 
                  from = "2018-05-18",
                  to = "2018-07-13",
                  period = "1min",
                  auto.assign = FALSE)

# select the closing price
BRf_Cl <- BRf %>% Cl()


# Sorted Futures and Put-Option tables for an exact coincidence of trade deal time
BRf_sorted <- BRf_Cl[as.POSIXct(BR73_option)]
BR73_sorted <- BR73_option[as.POSIXct(BRf_sorted)]

# Check for indentity size
length(BRf_sorted) == length(BR73_sorted)


# Sorted Futures and Call-Option tables for an exact coincidence of trade deal time
BRf_sorted_call <- BRf_Cl[as.POSIXct(BR77_option)]
BR77_sorted_call <- BR77_option[as.POSIXct(BRf_sorted_call)]

# Check for indentity size
length(BR77_sorted_call) == length(BRf_sorted_call)


# Putting all together
fut_put <- cbind(BRf_sorted, BR73_sorted)
names(fut_put) <- c("futures", "put")

fut_call <- cbind(BRf_sorted_call, BR77_sorted_call)
names(fut_call) <- c("futures", "call")
head(fut_call)

plot.zoo(fut_put)
plot.zoo(fut_call)