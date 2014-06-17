library(foreach)
library(RODBC)
library(DBI)
channel <- odbcConnect("giko", uid="DB31433211A")
registerTwitterOAuth(twitCred)

getKijkcijfers <- function() {
  
dataBroadcast <- paste("SELECT MAX(STARTTIME) + interval 23 day_hour as STARTTIME from broadcast")
cmd <- sqlQuery(channel, dataBroadcast, as.is=TRUE)
Datum <- strptime(cmd$STARTTIME,'%Y-%m-%d')
  
url <- paste("http://cjss.scriptin.nl/download_csv.ashx?airedon=",Datum)
  
kijkcijfer = read.csv(url)

foreach(i=1:5) %do% {
  if (i == 5){
    uitzending = "RTL BOULEVARD"
    duration = "00:55"
    tvShowId = 5
  }
  if (i == 4){
    uitzending = "UTOPIA"
    duration = "00:30"
    tvShowId = 4
  }
  if (i == 3){
    uitzending = "HART VAN NEDERLAND VROEGE EDITIE"
    duration = "00:25"
    tvShowId = 3
  }
  if (i == 2){
    uitzending = "JOURNAAL 20 UUR"
    duration = "00:30"
    tvShowId = 2
  }
  if (i == 1){
    uitzending = "GOEDE TIJDEN SLECHTE TIJDEN"
    duration = "00:30"
    tvShowId = 1
  }
  
  get = kijkcijfer$Programma == uitzending
  getrow = kijkcijfer[get,]
  
  datum = paste(getrow$Datum,getrow$Tijd)
  newvalues <- paste("(",tvShowId,",'",datum,"','",getrow$Kijkcijfers,"','",duration,"')", sep="", collapse=",")
  newcmd <- paste("insert into broadcast(`TVS_ID`,`STARTTIME`,`OFFICIALRATING`,`DURATION`) values ", newvalues)
  sqlQuery(channel, newcmd, as.is=TRUE)
 }
}

getKijkcijfers()


