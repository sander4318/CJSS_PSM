### Get your api to work for twitter the first time
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "http://api.twitter.com/oauth/authorize"
apiKey <- "Ln5GitLoHEOhcsjgWmWMaHTQn"
apiSecret <- "N85qIiMYBDwB8qCVknxIrBNi5lBLHogkL7JDFFPoQLes16Y1Ic"

twitCred <- OAuthFactory$new(
  consumerKey=apiKey,
  consumerSecret=apiSecret,
  requestURL=reqURL,
  accessURL=accessURL,
  authURL=authURL)

download.file(url="http://curl.haxx.se/ca/cacert.pem",
              destfile="cacert.pem")

#create the handshake en get your pin
twitCred$handshake(cainfo="cacert.pem")

# than register You need to do this when application is started again
registerTwitterOAuth(twitCred)

#save the pin
save(list="twitCred", file="twitCred")

##Only the for the firsttime when app will start
################################################
library(RODBC)
library(DBI)
library(twitteR)
registerTwitterOAuth(twitCred)
channel <- odbcConnect("MySQL", uid="root")
################################################

## Function Start
getTwittermessage <- function(x, y) {
  assign( "tvShowId" , x , env = .GlobalEnv )
  assign("hashtag", y , env = .GlobalEnv)

since <- sqlQuery(channel, paste("SELECT MAX(TWEETID) AS TWEETID FROM tweets WHERE TVS_ID = ", tvShowId))
sinceID <- NULL
sinceDate <- NULL
since <- since$TWEETID
if (is.na(since)) {
  ##sinceDate <- as.character(x["DATETIME"])
} else {
  sinceID <- as.character(since[1])
}

tweets <- searchTwitter(hashtag, n=10000, sinceID=sinceID, lang="nl", cainfo="cacert.pem")
tweets <- do.call("rbind", lapply(tweets, as.data.frame))
tweets <- tweets[,c("id", "created", "text", "screenName", "isRetweet")]

values <- paste("(",tvShowId,",",tweets$id,",'",strptime(tweets$created, '%Y-%m-%d %H:%M:%S'),"','",gsub("[[:punct:]]", "", tweets$text),"','",tweets$screenName,"',",tweets$isRetweet,")", sep="", collapse=",")
cmd <- paste("insert into TWEETS(`TVS_ID`,`TWEETID`,`DATETIME`,`TWEET`,`SCREENNAME`,`ISRETWEET`) values ", values)
sqlQuery(channel, cmd, as.is=TRUE)

return(sinceID)
}

getTwittermessage(1, "#gtst")
getTwittermessage(2, "#nosjournaal")
getTwittermessage(3, "#hvnl")
getTwittermessage(4, "#utopia")
getTwittermessage(5, "#rtlboulevard")
