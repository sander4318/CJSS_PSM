library(foreach)
library(RODBC)
library(DBI)
channel <- odbcConnect("giko", uid="DB31433211A")

analyseData <- function(x) {
    
    dataBroadcast <- paste("SELECT STARTTIME - INTERVAL 2 day_hour as STARTTIME, OFFICIALRATING, ADDTIME(STARTTIME, DURATION) - INTERVAL 2 day_hour as ENDTIME FROM broadcast where TVS_ID = ",x," AND OFFICIALRATING <> 0")
    cmd <- sqlQuery(channel, dataBroadcast, as.is=TRUE)
    #data <- data.frame(cmd$STARTTIME, cmd$OFFICIALRATING)
    starttime <- cmd$STARTTIME
    endtime <- cmd$ENDTIME
        
    #GET AND COUNT TWEETS ADD DATAFRAME
    dataBroadcast1 <- paste("SELECT count(*) as AANTAL from tweets WHERE DATETIME > '",starttime,"' AND DATETIME < '",endtime,"' AND TVS_ID = ",x,";")
    
    foreach(i=1:NROW(dataBroadcast1)) %do% {
      aantal <- sqlQuery(channel, dataBroadcast1[i], as.is=TRUE)
      cmd$aantal[[i]] <- aantal$AANTAL
    }
    assign("data", cmd , env = .GlobalEnv)
  }

analyseData(4)

#plot(strptime(data$STARTTIME, '%Y-%m-%d'), data$OFFICIALRATING, xlab = "Datum")