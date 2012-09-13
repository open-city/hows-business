library(tframe)
source('fusion-tables.R')
source('login.R')


illinois.laus <- read.table("ftp://ftp.bls.gov/pub/time.series/la/la.data.20.Illinois", fill=TRUE, header=TRUE)

unemployment.df <- illinois.laus[illinois.laus$series_id == "LAUPS17010003"
                                 & illinois.laus$period != "M13",]

unemployment.df$date <- as.Date(paste(unemployment.df$year,
                                      as.numeric(substr(unemployment.df$period,
                                                        2,3)),
                                      1),
                                "%Y %m %d")

unemployment.df$month <- months(unemployment.df$date)

upl_ts <-ts(unemployment.df$value,
                     start=c(1990, 1),
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



