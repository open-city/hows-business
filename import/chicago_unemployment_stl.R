library(tframe)
source('fusion-tables.R')
source('login.R')



unemployment.df <- read.csv("data/chicago_unemployment.csv")

unemployment.df$date <- as.Date(paste(unemployment.df$Year,
                                      unemployment.df$Month,
                                      1),
                                "%Y %m %d")

unemployment.df$month <- months(unemployment.df$date)

upl_ts <-ts(unemployment.df$Unemployment.Rate,
                     start=c(2003, 1),
                     frequency=12)

#Take the stl decomposition and then linear and cubic models
upl_stl <- stl(log(upl_ts),
               s.window=15,
               robust=TRUE)
plot(upl_stl)

upl_trend <- round(exp(upl_stl$time.series[,'trend']),2)
upl_trend <- tfwindow(upl_trend,start=c(2005,1))
upl_season <- round(exp(upl_stl$time.series[,'seasonal']),2)
upl_season <- tfwindow(upl_season,start=c(2005,1))
upl_ts <- tfwindow(upl_ts,start=c(2005,1))

x <- 11:0
trend.y <- upl_trend[length(upl_trend)-x]
x <- 0:11
trend.lm <- lm(trend.y~x)

m <- trend.lm$coef[2]

auth = ft.connect(login.username, login.password)

month_data = paste(upl_ts, collapse=',')
month_data = paste(month_data, ',', sep='')
updateFT(auth,login.table_id,'Chicago Unemployment Monthly',month_data)

trend_data = paste(upl_trend, collapse=',')
trend_data = paste(trend_data, ',,', sep='')
updateFT(auth,login.table_id,'Chicago Unemployment Trend', trend_data)



