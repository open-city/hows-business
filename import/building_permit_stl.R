library(xts)
source('fusion-tables.R')
source('login.R')

#Permit Trend and Linear approximation
permit.url <- "http://data.cityofchicago.org/api/views/k9hk-r56e/rows.csv"
permit <- read.csv(permit.url)
names(permit) <- c("date", "count")

permit$date <- as.Date(permit$date,"%m/%d/%Y")
permit <- permit[!is.na(permit$date),]
permit <- permit[order(permit$date),]

#Remove outlier by averaging the other entries within one week.

permit$count[575] <- mean(permit[permit$date < "2007-07-14"
                                 & permit$date > "2007-06-30"
                                 & permit$date != "2007-07-07",
                                 "count"])

# Select only whole months
begin_curr_month <- as.Date(as.yearmon(Sys.Date()))

permit <- permit[permit$date >= "2006-01-01"
                 & permit$date < begin_curr_month,]

permit_xts <- xts(permit$count, permit$date)
month_permit <- apply.monthly(permit_xts,sum)

month_permit_ts <- ts(as.numeric(month_permit), c(2006, 1), frequency=12)

permit_stl <- stl(log(month_permit_ts),
                  s.window=5,
#                  s.degree=1,
#                  t.window=9,
#                  t.degree=1,
                  robust=T)
plot(permit_stl)

permit_trend <- round(exp(permit_stl$time.series[,'trend']), 2)
permit_season <- round(exp(permit_stl$time.series[,'seasonal']), 2)

auth = ft.connect(login.username, login.password)
updateFT(auth, login.table_id, 'Permit Raw', month_permit_ts)
updateFT(auth,login.table_id,'Permit Trend', permit_trend)
updateFT(auth,login.table_id,'Permit Season', permit_season)

x <- 11:0
trend.y <- permit_trend[length(permit_trend)-x]
x <- 0:11
trend.lm <- lm(trend.y~x)

m <- trend.lm$coef[2]

updateFT(auth,login.table_id,'Permit Trend',m, 'CurrentTrend')