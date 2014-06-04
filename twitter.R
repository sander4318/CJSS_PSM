library(RODBC)
library("ROAuth")
library("twitteR")
library("plyr")
con <- odbcConnect("mysql", case="toupper")

requestURL <-  "https://api.twitter.com/oauth/request_token"
 accessURL =    "https://api.twitter.com/oauth/access_token"
 authURL =      "https://api.twitter.com/oauth/authorize"
 consumerKey =   "kpk2D9g5gdP6gV875T13ezNWS"
 consumerSecret = "E8sLpq1i77LsifrvCkqoklnIv7ypGWlJyXWsbK3Skm59RKaqp5"
 twitCred <- OAuthFactory$new(consumerKey=consumerKey,
                                                            consumerSecret=consumerSecret,
                                                             requestURL=requestURL,
                                                             accessURL=accessURL,
                                                          authURL=authURL)
#twitCred$handshake(cainfo="cacert.pem")

broadcasts <- sqlQuery(con, "SELECT * FROM broadcast");

f <- function(x) {
  tvshow <- sqlQuery(con, paste("SELECT * FROM tvshow WHERE TVS_id = ", x["TVS_ID"]))
  hashtag <- as.character(tvshow$HASHTAG[1])
  broadcastId <- x["BRD_ID"]
  since <- sqlQuery(con, paste("SELECT MAX(TWEETID) AS TWEETID FROM tweets WHERE BRD_ID = ", broadcastId))
  sinceID <- NULL
  since <- since$TWEETID
  if (length(since) == 1) {
    sinceID = as.character(since[1])
  }

  tweets <- searchTwitter(hashtag, n=1000, sinceID=sinceID, cainfo="cacert.pem")
  tweets <- do.call("rbind", lapply(tweets, as.data.frame))
  tweets <- tweets[,c("text", "created", "id")]
  tweets[,"BRD_ID"] <- broadcastId
  tweets[,"TWT_ID"] <- 0
  tweets <- rename(tweets, c("text"="TWEET", "created"="DATETIME", "id"="TWEETID"))
#  tweets
  sqlSave(con, tweets, tablename="tweets", rownames=F, append=T)
}

apply(broadcasts, 1, f)
 
close(con)
