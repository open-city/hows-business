month_count <- read.csv("/Users/dacmorton/Documents/OpenCity/HowsBusiness/MonthlyLicense.csv")

month_count_ts <- ts(month_count[,2],start=2005,frequency=12)
acf(month_count_ts)
pacf(month_count_ts)
acf(diff(log(month_count_ts)),lag.max=88)
pacf(diff(log(month_count_ts)),lag.max=88)

#Guess ARIMA(0,1,1) with seasonal (1,0,0) component with lag 6
month_count_arima <- arima(log(month_count_ts),order=c(0,1,1),seasonal=list(order=c(1,0,0),period=6))
month_count_arima

#Diagnostics
plot(month_count_arima$resid)
#Residuals pass QQ-test, but not with an A.
qqnorm(month_count_arima$resid)
qqline(month_count_arima$resid)
#Seems to be something lurking in period 4
acf(month_count_arima$resid)
pacf(month_count_arima$resid)

#Fails Ljung-Box test
box <- rep(0,18)
for (i in 3:20){
	box[i-2] <- Box.test(month_count_arima$resid,lag=i,type=c("Ljung-Box"),fitdf=2)$p.value
}
plot(3:20,box)


#Guess ARIMA(1,1,1) with seasonal (1,0,0) component with lag 6
month_count_arima <- arima(log(month_count_ts),order=c(1,1,1),seasonal=list(order=c(1,0,0),period=6))
month_count_arima #Better log likelihood and aic

#Diagnostics
plot(month_count_arima$resid)
#Residuals pass QQ-test.
qqnorm(month_count_arima$resid)
qqline(month_count_arima$resid)
#Seems to be something lurking in period 4
acf(month_count_arima$resid)
pacf(month_count_arima$resid)

#Fails Ljung-Box test
box <- rep(0,17)
for (i in 4:20){
	box[i-3] <- Box.test(month_count_arima$resid,lag=i,type=c("Ljung-Box"),fitdf=3)$p.value
}
plot(4:20,box)


#Guess ARIMA(1,1,1) with seasonal (1,0,0) component with lag 4
month_count_arima <- arima(log(month_count_ts),order=c(1,1,1),seasonal=list(order=c(1,0,0),period=4))
month_count_arima #Worse log likelihood and aic

#Diagnostics
plot(month_count_arima$resid)
#Residuals pass QQ-test maybe
qqnorm(month_count_arima$resid)
qqline(month_count_arima$resid)
#Seems to be something lurking in period 6
acf(month_count_arima$resid)
pacf(month_count_arima$resid)

#Fails Ljung-Box test
box <- rep(0,18)
for (i in 3:20){
	box[i-2] <- Box.test(month_count_arima$resid,lag=i,type=c("Ljung-Box"),fitdf=2)$p.value
}
plot(3:20,box)
abline(h=0.05)

#Try ARIMA(0,1,1) with seasonal (1,0,1) at lag 6
month_count_arima <- arima(log(month_count_ts),order=c(0,1,1),seasonal=list(order=c(1,0,1),period=6))
month_count_arima

#Seems to be something lurking in period 4
par(mfrow=c(2,1))
acf(month_count_arima$resid)
pacf(month_count_arima$resid)
qqnorm(month_count_arima$resid)
qqline(month_count_arima$resid)

#Passes Ljung-Box Test, maybe
par(mfrow=c(1,1))
box <- rep(0,17)
for (i in 4:20){
	box[i-3] <- Box.test(month_count_arima$resid,lag=i,type=c("Ljung-Box"),fitdf=3)$p.value
}
plot(4:20,box)
abline(h=0.05)

#Try ARIMA(0,0,0) with seasonal (0,0,1) at lag 4 four on the residuals
second_arima <- arima(month_count_arima$resid,order=c(0,0,0),seasonal=list(order=c(0,0,1),period=4))
second_arima

acf(second_arima$resid)
pacf(second_arima$resid)

#Solid pass of QQ-test
qqnorm(second_arima$resid)
qqline(second_arima$resid)

#Solid pass of Ljung-Box Test
box <- rep(0,19)
for (i in 2:20){
	box[i-1] <- Box.test(month_count_arima$resid,lag=i,type=c("Ljung-Box"),fitdf=1)$p.value
}
plot(2:20,box)
abline(h=0.05)
