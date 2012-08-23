library(tframe)

unemployment.df <- read.table('http://research.stlouisfed.org/fred2/data/ILCOOK1URN.txt',
                                   skip=11,
                                   header = TRUE)

names(unemployment.df) <- c("date", "value")
unemployment.df$date <- as.Date(unemployment.df$date, "%Y-%m-%d")
unemployment.df$month <- months(unemployment.df$date)

unemployment.ts <-ts(unemployment$value,
                     start=c(1990, 1),
                     frequency=12)


#Take the stl decomposition and then linear and cubic models
upl_stl <- stl(log(upl_ts),s.window=7,s.degree=1,t.window=9,robust=TRUE)

upl_trend <- upl_stl$time.series[,'trend']
upl_truncate <- tfwindow(upl_trend,start=c(2005,1))

plot(upl_truncate)



plot(upl_trend)
plot(diff(upl_trend))
acf(diff(upl_trend),lag.max=50)
pacf(diff(upl_trend),lag.max=50)
upl_arima <- arima(upl_trend,order=c(3,1,0))
upl_arima
qqnorm(upl_arima$resid)
qqline(upl_arima$resid)
acf(upl_arima$resid,lag.max=50)
pacf(upl_arima$resid,lag.max=50)

box <- rep(0,17)
for (i in 4:20){
	box[i-3] <- Box.test(upl_arima$residuals,lag=i,type=c("Ljung-Box"),fitdf=3)$p.value
}
plot(1:17,box)
