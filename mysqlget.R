library(foreach)
library(RODBC)
library(DBI)
channel <- odbcConnect("giko", uid="DB31433211A")

analyseData <- function(x) {
    
    dataBroadcast <- paste("SELECT DISTINCT STARTTIME - INTERVAL 2 day_hour as STARTTIME, OFFICIALRATING, ADDTIME(STARTTIME, DURATION) - INTERVAL 2 day_hour as ENDTIME FROM broadcast where TVS_ID = ",x," AND OFFICIALRATING <> 0")
    cmd <- sqlQuery(channel, dataBroadcast, as.is=TRUE)
    
    starttime <- cmd$STARTTIME
    endtime <- cmd$ENDTIME
        
    #GET AND COUNT TWEETS ADD DATAFRAME
    dataBroadcast1 <- paste("SELECT count(*) as AANTAL from tweets WHERE DATETIME > '",starttime,"' AND DATETIME < '",endtime,"' AND TVS_ID = ",x,";")
    
    foreach(i=1:NROW(dataBroadcast1)) %do% {
      aantal <- sqlQuery(channel, dataBroadcast1[i], as.is=TRUE)
      if (aantal == 0){
        cmd$aantal[[i]] <- "NA"
      } else {
        cmd$aantal[[i]] <- aantal$AANTAL
      }
    }
    assign(make.names(x), cmd , env = .GlobalEnv)
        
  }

analyseData(5)



