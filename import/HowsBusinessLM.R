#Not sure we want to use a straight linear regression model, especially if we're interested in prediction, but these models perform uncannily well on the data. All evidence points to the monthly being better than the quarterly, although both are strong, but some evidence points towards an intermediate model being adequate. The residuals of the monthly model seem to be a classic AR(1) time series. Predictive power is limited.

library(MASS)
library(leaps)
month_count <- read.csv("/Users/dacmorton/Documents/OpenCity/HowsBusiness/MonthlyLicense.csv")

month_count_ts <- ts(month_count[,2],start=2005,frequency=12)

#Factors for monthly variation
Jan <- c(rep(c(1,0,0,0,0,0,0,0,0,0,0,0),7),c(1,0,0,0,0,0))
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
time <- 1:length(month_count_ts)
time.df.month <- data.frame(time,Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)

#Factors for quarterly variation
Qtr1 <- c(rep(c(1,1,1,0,0,0,0,0,0,0,0,0),7),c(1,1,1,0,0,0))
Qtr2 <- c(rep(c(0,0,0,1,1,1,0,0,0,0,0,0),7),c(0,0,0,1,1,1))
Qtr3 <- c(rep(c(0,0,0,0,0,0,1,1,1,0,0,0),7),c(0,0,0,0,0,0))
Qtr4 <- c(rep(c(0,0,0,0,0,0,0,0,0,1,1,1),7),c(0,0,0,0,0,0))

time.df.month.adj <-data.frame(time,Jan,Feb,Qtr1,Apr,May,Qtr2,Jul,Aug,Qtr3,Oct,Nov,Qtr4)
time.df.qtr <- data.frame(time,Qtr1,Qtr2,Qtr3,Qtr4)

#Box-Cox Test tells us to take the log of the response.
boxcox(lm(month_count_ts~.-1,data=time.df.month))

#Full Linear Model
hows.business.month <- lm(log(month_count_ts)~.-1,data=time.df.month)
summary(hows.business.month)

#Quarterly Model
hows.business.qtr <- lm(log(month_count_ts)~.-1,data=time.df.qtr)
summary(hows.business.qtr)

#Compare Models. Monthly appears to be superior.
anova(hows.business.qtr,hows.business.month)

#Monthly model adjusted so quarterly model is an explicit submodel.
hows.business.month.adj <- lm(log(month_count_ts)~.-1,data=time.df.month.adj)

#Use CP and BIC to check for superior submodels
hows.business.month.leaps <- regsubsets(y=log(month_count_ts),x=time.df.month,int=F,method="ex",nbest=2,nvmax=13)
hb.month.leaps.summary <- summary(hows.business.month.leaps)

#Orders the feature selection by best Cp score. Full model is best.
hb.month.leaps.summary$which[order(hb.month.leaps.summary$cp),]

#Orders the feature selection by best BIC score. Full model is best.
hb.month.leaps.summary$which[order(hb.month.leaps.summary$bic),]

#Use CP and BIC to check for superior submodels when quarters is an explicit submodel.
hows.business.month.adj.leaps <- regsubsets(y=log(month_count_ts),x=time.df.month.adj,int=F,method="ex",nbest=2,nvmax=13)
hb.month.adj.leaps.summary <- summary(hows.business.month.adj.leaps)

#Orders the feature selection by best Cp score. Best model drops April, second best drops April and May. Full model is third best. Quarterly model underperforms
hb.month.adj.leaps.summary$which[order(hb.month.adj.leaps.summary$cp),]
#Actual Cp scores. Scores for three best models are close.
hb.month.adj.leaps.summary$cp[order(hb.month.adj.leaps.summary$cp)]

#Orders the feature selection by best BIC score. Best model drops April and May, second best also drops out July and August. Full model is number 11, but still outperforms the Quarterly model.
hb.month.adj.leaps.summary$which[order(hb.month.adj.leaps.summary$bic),]


#Residuals of the monthly series
hows.business.fitted_ts <- ts(exp(hows.business.month$fitted.values),start=2005,frequency=12)
month_count_resid <- month_count_ts - hows.business.fitted_ts

#Looks like a classic AR(1)
acf(month_count_resid)
pacf(month_count_resid)

month_count_resid.yw <- ar.yw(month_count_resid,order=1)
resid.pred <- predict(month_count_resid.yw,n.ahead=12)
U.pred = resid.pred$pred + 1.96*resid.pred$se
L.pred = resid.pred$pred - 1.96*resid.pred$se
minx = min(month_count_resid,L.pred); maxx = max(month_count_resid,U.pred)

#Prediction interval is too wide to be useful.
ts.plot(month_count_resid, resid.pred$pred, xlim=c(2005,2014), ylim=c(minx,maxx))
lines(resid.pred$pred, col="red", type="o")
lines(U.pred, col="blue", lty="dashed")
lines(L.pred, col="blue", lty="dashed")