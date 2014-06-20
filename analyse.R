## With mysqlget you ll generate data frame X1 for every show
## Calculate mean
## TODO get the outliers to calculate mean beter

test <- na.omit(data.frame(as.numeric(X4$OFFICIALRATING) / as.numeric(X4$aantal)))

names(test) <- c("Aantal")

mean(test$Aantal)

## TODO make plots from data?
#plot(strptime(X4$STARTTIME, '%Y-%m-%d'), X4$OFFICIALRATING, xlab = "Datum", type="b")
#factorial, mean, summary, sd

