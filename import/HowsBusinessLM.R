#Not sure we want to use a straight linear regression model, especially if we're interested in prediction, but these models perform uncannily well on the data. All evidence points to the monthly being better than the quarterly, although both are strong, but some evidence points towards an intermediate model being adequate. The residuals of the monthly model seem to be a classic AR(1) time series. Predictive power is limited.

library(MASS)
library(leaps)
month_count <- read.csv("/Users/dacmorton/Documents/OpenCity/HowsBusiness/import/MonthlyLicense.csv")

month_count_ts <- ts(month_count[,2],start=2005,frequency=12)

#Factors for monthly variation
Months <- c(rep(c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep',"Oct",'Nov','Dec'),7),c('Jan','Feb','Mar','Apr','May','Jun'))
time <- 1:length(month_count_ts)
time.df.month <- data.frame(time,Months)
time.df.month.2 <- data.frame(time,time^2,Months)
time.df.month.3 <- data.frame(time,time^2,time^3,Months)

#Factors for quarterly variation
Qtrs <- c(rep(c("Qtr1",'Qtr2','Qtr3','Qtr4'),7),c('Qtr1','Qtr2'))

time.df.month.adj <-data.frame(time,Jan,Feb,Qtr1,Apr,May,Qtr2,Jul,Aug,Qtr3,Oct,Nov,Qtr4)
time.df.qtr <- data.frame(time,Qtrs)

#Box-Cox Test tells us to take the log of the response.
boxcox(lm(month_count_ts~.,data=time.df.month))

#Full Linear Model
hows.business.month <- lm(log(month_count_ts)~.,data=time.df.month)
summary(hows.business.month)
hows.business.month.2 <- lm(log(month_count_ts)~.,data=time.df.month.2)
summary(hows.business.month.2)
hows.business.month.3 <- lm(log(month_count_ts)~.,data=time.df.month.3)
summary(hows.business.month.3) #Looks like cubic term adds nothing.

#AIC and BIC for monthly models.
AIC(hows.business.month)
AIC(hows.business.month.2) #Best
AIC(hows.business.month.3)
BIC(hows.business.month)
BIC(hows.business.month.2) #Best
BIC(hows.business.month.3)


#Quarterly Model
hows.business.qtr <- lm(log(month_count_ts)~.,data=time.df.qtr)
summary(hows.business.qtr) #Low R^2

#Compare Models. Monthly superior.
anova(hows.business.qtr,hows.business.month)

#Monthly model adjusted so quarterly model is an explicit submodel.
hows.business.month.adj <- lm(log(month_count_ts)~.-1,data=time.df.month.adj)

#Use CP and BIC to check for superior submodels
Feb <- c(rep(c(0,1,0,0,0,0,0,0,0,0,0,0),7),c(0,1,0,0,0,0))
Mar <- c(rep(c(0,0,1,0,0,0,0,0,0,0,0,0),7),c(0,0,1,0,0,0))
Apr <- c(rep(c(0,0,0,1,0,0,0,0,0,0,0,0),7),c(0,0,0,1,0,0))
May <- c(rep(c(0,0,0,0,1,0,0,0,0,0,0,0),7),c(0,0,0,0,1,0))
Jun <- c(rep(c(0,0,0,0,0,1,0,0,0,0,0,0),7),c(0,0,0,0,0,1))
Jul <- c(rep(c(0,0,0,0,0,0,1,0,0,0,0,0),7),c(0,0,0,0,0,0))
Aug <- c(rep(c(0,0,0,0,0,0,0,1,0,0,0,0),7),c(0,0,0,0,0,0))
Sep <- c(rep(c(0,0,0,0,0,0,0,0,1,0,0,0),7),c(0,0,0,0,0,0))
Oct <- c(rep(c(0,0,0,0,0,0,0,0,0,1,0,0),7),c(0,0,0,0,0,0))
Nov <- c(rep(c(0,0,0,0,0,0,0,0,0,0,1,0),7),c(0,0,0,0,0,0))
Dec <- c(rep(c(0,0,0,0,0,0,0,0,0,0,0,1),7),c(0,0,0,0,0,0))
time.df.month.4 <- data.frame(time,time^2,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)

hows.business.month.leaps <- regsubsets(y=log(month_count_ts),x=time.df.month.4,int=T,method="ex",nbest=2,nvmax=20)
hb.month.leaps.summary <- summary(hows.business.month.leaps)

#Orders the feature selection by best Cp score. Full model is 7th best.
hb.month.leaps.summary$which[order(hb.month.leaps.summary$cp),]

#Orders the feature selection by best BIC score. Full model is best.
hb.month.leaps.summary$which[order(hb.month.leaps.summary$bic),]

#Residuals of the monthly series
hows.business.fitted_ts <- ts(exp(hows.business.month$fitted.values),start=2005,frequency=12)
month_count_resid <- month_count_ts - hows.business.fitted_ts

#Looks like a classic AR(1)
acf(month_count_resid)
pacf(month_count_resid)

#Take the seasonal-trend decomposition and them fit a linear model
hb_stl <- stl(log(month_count_ts),s.window=7,s.degree=1,t.window=9,robust=TRUE)
hb_trend <- hb_stl$time.series[,'trend']
hb.lm <- lm(hb_trend~time)