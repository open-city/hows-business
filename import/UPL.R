upl <- read.csv("cook_county_upl.csv")
upl_ts <-ts(upl[,2],start=1990,frequency=12)

Months <- c(rep(c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep',"Oct",'Nov','Dec'),22),c('Jan','Feb','Mar','Apr','May','Jun'))
upl.time <- 1:length(upl_ts)
upl.df.month <- data.frame(time,Months)
upl.df.month.2 <- data.frame(time,time^2,Months)
upl.df.month.3 <- data.frame(time,time^2,time^3,Months)
upl.df.month.4 <- data.frame(time,time^2,time^3,time^4,Months)

#Box-Cox Test tells us to take inverse square root of the response.
boxcox(lm(upl_ts~.,data=upl.df.month))
#But log when time^2 and time ^3 are added.

#Full Linear Model
upl.month <- lm(1/sqrt(upl_ts)~.,data=upl.df.month)
summary(upl.month) #R^2 is pathetic.
upl.month.2 <- lm(log(upl_ts)~.,data=upl.df.month.2)
summary(upl.month.2)
upl.month.3 <- lm(log(upl_ts)~.,data=upl.df.month.3)
summary(upl.month.3)
upl.month.4 <- lm(log(upl_ts)~.,data=upl.df.month.4)
summary(upl.month.4)

#Take the stl decomposition and then linear and cubic models
upl_stl <- stl(log(upl_ts),s.window=7,s.degree=1,t.window=9,robust=TRUE)
upl_trend <- upl_stl$time.series[,'trend']
upl_truncate <- tfwindow(upl_trend,start=c(2005,1))
upl.lm <- lm(upl_truncate~time)
upl.lm.3 <- lm(upl_truncate~time+I(time^2)+I(time^3))
#Cubic and linear models work best


#####################################################################
upl_decomp <- decompose(upl_ts,type=c('additive'))


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
