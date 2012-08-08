library(zoo)
library(xts)

geo_filtered_licenses <- read.csv('/Users/dacmorton/Documents/OpenCity/BusinessLicenseFiltered.csv')

#remove extraneous first column
geo_filtered_licenses <- geo_filtered_licenses[,-1]

#remove all rows where there is no precinct data
geo_filtered_licenses_precinct <- geo_filtered_licenses[is.na(geo_filtered_licenses[,"PRECINCT"])==F,]

#The data needs to be split up 50 ways. Initializing items needed to hold it.
precinct <- list()
precinct_month_count <- list()
precinct_week_count <- list()
precinct_month_count_ts <- list()
precinct_week_count_ts <- list()
precinct_decomposed_month <- list()
precinct_decomposed_log_month <- list()
precinct_decomposed_week <- list()
precinct_decomposed_log_week <- list()

#build a data frame necessary for dealing with gaps in the data
index <- seq(as.yearmon("2005-01-01"),as.yearmon("2012-06-30"),1/12)
full <- data.frame(index,rep(0,length(index)))
names(full) <- c("index","zero")

week_index <- seq(as.Date("2005-01-07"),as.Date("2012-06-30"),7)
full_week <- data.frame(week_index,rep(0,length(week_index)))
names(full_week) <- c("index","zero")
day_index <- seq(as.Date("2005-01-01"),as.Date("2012-06-30"),1)
full_day <- data.frame(day_index,rep(0,length(day_index)))
names(full_day) <- c("index","zero")

precinct_no <- c(1:76,999)

for (i in precinct_no){
	precinct[[i]] <- geo_filtered_licenses_precinct[geo_filtered_licenses_precinct["PRECINCT"]==i,c("LICENSE.DESCRIPTION","PAYMENT.DATE")]

	names(precinct[[i]]) <- c("LICENSE.DESCRIPTION","date")
	precinct[[i]]$date <- factor(precinct[[i]]$date)

	precinct_date_count <- table(precinct[[i]]$date)
	precinct_date_count <- as.data.frame(precinct_date_count)
	names(precinct_date_count) <- c("date","count")
	precinct_date_count <- precinct_date_count[precinct_date_count$date != "",]

	precinct_date_count$date <- as.Date(precinct_date_count$date, "%m/%d/%Y")
	precinct_date_merge <- merge(full_day,precinct_date_count,by.x=1,by.y=1,all=T)[-2]
	precinct_date_merge[is.na(precinct_date_merge[2]==T),2] <- 0
	names(precinct_date_merge) <- c("date","count") 

	precinct_date_count <- precinct_date_count[precinct_date_count$date >= "2005-01-01",]
	precinct_date_count <- precinct_date_count[precinct_date_count$date < "2012-07-01",]

    #Fill in entries for dates with zero. Necessary to regularize the data.
	precinct_date_merge <- merge(full_day,precinct_date_count,by.x=1,by.y=1,all=T)[-2]
	precinct_date_merge[is.na(precinct_date_merge[2]==T),2] <- 0
	names(precinct_date_merge) <- c("date","count")

	precinct_date_count_xts <- xts(precinct_date_merge$count, precinct_date_merge$date)

	precinct_month_count[[i]] <- apply.monthly(precinct_date_count_xts,sum)
	index(precinct_month_count[[i]]) <- as.yearmon(index(precinct_month_count[[i]]))
	precinct_week_count[[i]] <- apply.weekly(precinct_date_count_xts, sum)

	#Convert data to time series
	precinct_month_count_xts <- xts(precinct_month_count[[1]])
	precinct_month_count_ts[[i]] <- ts(as.numeric(precinct_month_count_xts),precinct_month_merge[1,1],frequency = 12)

	#Convert data to time series
	precinct_week_count_xts <- xts(precinct_week_count[[i]])
	precinct_week_count_ts[[i]] <- ts(as.numeric(precinct_week_count_xts),precinct_month_merge[1,1],frequency = 52)

	precinct_decomposed_month[[i]] <- stl(precinct_month_count_ts[[i]],s.window=7,s.degree=1,t.window=9,robust=T)
	precinct_decomposed_log_month[[i]] <- stl(log(precinct_month_count_ts[[i]]+0.1),s.window=7,s.degree=1,t.window=9,robust=TRUE)
	
	precinct_decomposed_week[[i]] <- stl(precinct_week_count_ts[[i]],s.window=5,s.degree=0,t.window=19,robust=TRUE)
	precinct_decomposed_log_week[[i]] <- stl(log(precinct_week_count_ts[[i]]+0.1),s.window=5,s.degree=0,t.window=19,robust=TRUE)
	
	write.csv(round(precinct_decomposed_month[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(precinct_decomposed_log_month[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_log_trend_data_issued.csv"))
	write.csv(precinct_month_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_raw_data_issued.csv"))
	write.csv(round(precinct_decomposed_month[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(precinct_decomposed_log_month[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_log_seasonal_data_issued.csv"))
	
	write.csv(round(precinct_decomposed_week[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(precinct_decomposed_log_week[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_log_trend_data_issued.csv"))
	write.csv(precinct_week_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_raw_data_issued.csv"))
	write.csv(round(precinct_decomposed_week[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(precinct_decomposed_log_week[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Precincts/precinct",i,"_month_log_seasonal_data_issued.csv"))	
}