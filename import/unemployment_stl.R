library(tframe)
unemployment.df <- read.table('http://research.stlouisfed.org/fred2/data/ILCOOK1URN.txt',
                              skip=11,
                              header = TRUE)

names(unemployment.df) <- c("date", "value")
unemployment.df$date <- as.Date(unemployment.df$date, "%Y-%m-%d")
unemployment.df$month <- months(unemployment.df$date)

upl_ts <-ts(unemployment$value,
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

updateFT(auth,login.table_id,'Cook County Unemployment',upl_ts)
updateFT(auth,login.table_id,'Cook County Unemployment Trend', upl_trend)
updateFT(auth,login.table_id,'Cook County Unemployment Season', upl_season)
