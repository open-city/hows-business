library(xts)
library(zoo)

source('fusion-tables.R')
source('login.R')

#Permit Trend and Linear approximation
permit.url <- "http://data.cityofchicago.org/api/views/k9hk-r56e/rows.csv"
permit <- read.csv(permit.url)
permit$ISSUE_DATE <- as.Date(permit$ISSUE_DATE,"%m/%d/%Y")
permit <- permit[order(permit$ISSUE_DATE),]

#Remove outlier by averaging the other entries within one week.
permit$PERMIT.[575] <- round(mean(permit[which(permit$ISSUE_DATE<"2007-07-14" & permit$ISSUE_DATE>"2007-06-30" & permit$ISSUE_DATE != "2007-07-07"),2]))

permit <- permit[is.na(permit$ISSUE_DATE)==F,]
permit <- permit[which(permit$ISSUE_DATE>="2006-01-01" & permit$ISSUE_DATE < "2012-08-01"),]
permit_xts <- xts(permit$PERMIT.,permit$ISSUE_DATE)
month_permit <- apply.monthly(permit_xts,sum)

month_permit_ts <- ts(as.numeric(month_permit),2006, frequency=12)

permit_stl <- stl(month_permit_ts,s.window=7,s.degree=1,t.window=9,t.degree=1,robust=T)
plot(permit_stl)

permit_trend <- permit_stl$time.series[,'trend']
permit_season <- permit_stl$time.series[,'seasonal']

auth = ft.connect(login.username, login.password)
updateFT(auth, login.table_id, 'Permit Raw', month_permit_ts)
updateFT(auth,login.table_id,'Permit Trend', permit_trend)
updateFT(auth,login.table_id,'Permit Season', permit_season)

time <- 1:length(permit_trend)
permit.lm <- lm(permit_trend~time)
boxcox(permit.lm)
permit.lm <- lm(1/permit_trend~time) #Could also transform response variable
