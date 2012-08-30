library(tframe)
unemployment.df <- read.table('http://research.stlouisfed.org/fred2/data/ILCOOK1URN.txt',
                              skip=11,
                              header = TRUE)

names(unemployment.df) <- c("date", "value")
unemployment.df$date <- as.Date(unemployment.df$date, "%Y-%m-%d")
unemployment.df$date <- as.yearmon(unemployment.df$date)
unemployment_xts <- xts(unemployment.df$value,unemployment.df$date)
unemployment_qtr <- apply.quarterly(unemployment_xts,mean)
upl_qtr_ts <-ts(unemployment_qtr,start=c(1990,1),frequency=4)

upl_ts <-ts(unemployment$value,
                     start=c(1990, 1),
                     frequency=12)

#Take the stl decomposition and then linear and cubic models
upl_stl <- stl(log(upl_ts),s.window=7,s.degree=1,t.window=9,robust=TRUE)
upl_trend <- upl_stl$time.series[,'trend']
upl_trend <- tfwindow(upl_trend,start=c(2006,1))
upl_season <- upl_stl$time.series[,'seasonal']
upl_season <- tfwindow(upl_season,start=c(2006,1))

upl_ts <- tfwindow(upl_ts,start=c(2006,1))
updateFT(auth,login.table_id,'Cook County Unemployment',upl_ts)
updateFT(auth,login.table_id,'Cook County Unemployment Trend', exp(upl_trend))
updateFT(auth,login.table_id,'Cook County Unemployment Season', exp(upl_season))


#####################################################################
laborforce.df <- read.table('http://research.stlouisfed.org/fred2/data/ILCOOK1LFN.txt',
                              skip=11,
                              header = TRUE)

names(laborforce.df) <- c("date", "value")
laborforce.df$date <- as.Date(laborforce.df$date, "%Y-%m-%d")
laborforce.df$date <- as.yearmon(laborforce.df$date)
laborforce.df <- laborforce.df[laborforce.df$date <= "2012-01-01",]

population.df <- read.table('http://research.stlouisfed.org/fred2/data/ILCOOK1POP.txt',
                            skip=11,
                            header = TRUE)
population.df$DATE <- seq(as.yearmon("1971-01-01"),as.yearmon("2012-01-01"),1)

month_index <- seq(as.yearmon("1971-01-01"),as.yearmon("2012-01-01"),1/12)
full_month <- data.frame(month_index,rep(0,length(month_index)))
names(full_month) <- c("DATE","zero")
month_merge <- merge(population.df,full_month,by.x=1,by.y=1,all=T)[-3]
month_merge[is.na(month_merge[2]==T),2] <- 0

n <- round((as.numeric(month_merge$DATE) %% 1)*12)
x <- 1:dim(month_merge)[1]
x.n <- as.numeric(x-n)

month_VALUE <- (12-n)/12*month_merge$VALUE[x.n]+n/12*month_merge$VALUE[12+x.n]
month_merge$VALUE[1:(length(x.n)-1)] <- month_VALUE[1:(length(x.n)-1)]

month_merge <- month_merge[month_merge$DATE >= "1990-01-01",]

labor_rate.df <- data.frame(month_merge$DATE,laborforce.df$value/month_merge$VALUE)
names(labor_rate.df) <- c("Date","Value")

labor_rate_ts <- ts(labor_rate.df$Value,start=c(1990,1),frequency=12)
labor_rate_stl <- stl(labor_rate_ts,s.window=5,robust=TRUE)
plot(labor_rate_stl)

labor_rate_trend <- labor_rate_stl$time.series[,'trend']
labor_rate_season <- labor_rate_stl$time.series[,'seasonal']

updateFT(auth,login.table_id,'Cook County Labor Force Participation Rate',labor_rate_ts)
updateFT(auth,login.table_id,'Cook County Labor Force Participation Rate Trend', labor_rate_trend)
updateFT(auth,login.table_id,'Cook County Labor Force Participation Rate Season', labor_rate_season)