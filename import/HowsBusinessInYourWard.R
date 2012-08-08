library(zoo)
library(xts)
library(lubridate)

geo_filtered_licenses <- read.csv('/Users/dacmorton/Documents/OpenCity/BusinessLicenseFiltered.csv')

#remove extraneous first column
geo_filtered_licenses <- geo_filtered_licenses[,-1]

#remove all rows where there is no ward data
geo_filtered_licenses_ward <- geo_filtered_licenses[is.na(geo_filtered_licenses[,"WARD"])==F,]

#The data needs to be split up 50 ways. Initializing items needed to hold it.
ward <- list()
ward_month_count <- list()
ward_week_count <- list()
ward_month_count_ts <- list()
ward_week_count_ts <- list()
ward_decomposed_month <- list()
ward_decomposed_log_month <- list()
ward_decomposed_week <- list()
ward_decomposed_log_week <- list()

#build a data frame necessary for dealing with gaps in the data
month_index <- seq(as.yearmon("2005-01-01"),as.yearmon("2012-06-30"),1/12)
full_month <- data.frame(month_index,rep(0,length(month_index)))
names(full_month) <- c("index","zero")

week_index <- seq(as.Date("2005-01-01"),as.Date("2012-06-30"),7)
full_week <- data.frame(week_index,rep(0,length(week_index)))
names(full_week) <- c("index","zero")
day_index <- seq(as.Date("2005-01-01"),as.Date("2012-06-30"),1)
full_day <- data.frame(day_index,rep(0,length(day_index)))
names(full_day) <- c("index","zero")

ward_no <- c(1:50)

for (i in ward_no){
	ward[[i]] <- geo_filtered_licenses_ward[geo_filtered_licenses_ward["WARD"]==i,c("LICENSE.DESCRIPTION","PAYMENT.DATE")]

	names(ward[[i]]) <- c("LICENSE.DESCRIPTION","date")
	ward[[i]]$date <- factor(ward[[i]]$date)

	ward_date_count <- table(ward[[i]]$date)
	ward_date_count <- as.data.frame(ward_date_count)
	names(ward_date_count) <- c("date","count")
	ward_date_count <- ward_date_count[ward_date_count$date != "",]

	ward_date_count$date <- as.Date(ward_date_count$date, "%m/%d/%Y")
 

	ward_date_count <- ward_date_count[ward_date_count$date >= "2005-01-01",]
	ward_date_count <- ward_date_count[ward_date_count$date < "2012-07-01",]

    #Fill in entries for dates with zero. Necessary to regularize the data.
	#ward_date_merge <- merge(full_day,ward_date_count,by.x=1,by.y=1,all=T)[-2]
	#ward_date_merge[is.na(ward_date_merge[2]==T),2] <- 0
	#names(ward_date_merge) <- c("date","count")

	ward_date_count_xts <- xts(ward_date_count$count, ward_date_count$date)

	ward_month_count[[i]] <- apply.monthly(ward_date_count_xts,sum)
	index(ward_month_count[[i]]) <- as.yearmon(index(ward_month_count[[i]]))
	
	ward_month_df <- data.frame(index(ward_month_count[[i]]),ward_month_count[[i]][,1])
	names(ward_month_df) <- c("index","count")
	ward_month_merge <- merge(full_month,ward_month_df,by.x=1,by.y=1,all=T)[-2]
	ward_month_merge[is.na(ward_month_merge[2]==T),2] <- 0
	
	ward_week_count[[i]] <- apply.weekly(ward_date_count_xts, sum)
	index(ward_week_count[[i]]) <- ceiling_date(index(ward_week_count[[i]]),'week')-1
	
	ward_week_df <- data.frame(index(ward_week_count[[i]]),ward_week_count[[i]][,1])
	names(ward_week_df) <- c("index","count")
	ward_week_merge <- merge(full_week,ward_week_df,by.x=1,by.y=1,all=T)[-2]
	ward_week_merge[is.na(ward_week_merge[2]==T),2] <- 0

	#Convert data to time series
	ward_month_count_xts <- xts(ward_month_count[[1]])
	ward_month_count_ts[[i]] <- ts(as.numeric(ward_month_count_xts),ward_month_merge[1,1],frequency = 12)

	#Convert data to time series
	ward_week_count_xts <- xts(ward_week_count[[i]])
	ward_week_count_ts[[i]] <- ts(as.numeric(ward_week_count_xts),ward_month_merge[1,1],frequency = 52)

	ward_decomposed_month[[i]] <- stl(ward_month_count_ts[[i]],s.window=7,s.degree=1,t.window=9,robust=T)
	ward_decomposed_log_month[[i]] <- stl(log(ward_month_count_ts[[i]]+0.1),s.window=7,s.degree=1,t.window=9,robust=TRUE)
	
	ward_decomposed_week[[i]] <- stl(ward_week_count_ts[[i]],s.window=5,s.degree=0,t.window=19,robust=TRUE)
	ward_decomposed_log_week[[i]] <- stl(log(ward_week_count_ts[[i]]+0.1),s.window=5,s.degree=0,t.window=19,robust=TRUE)
	
	write.csv(round(ward_decomposed_month[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_month[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_trend_data_issued.csv"))
	write.csv(ward_month_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_raw_data_issued.csv"))
	write.csv(round(ward_decomposed_month[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_month[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_seasonal_data_issued.csv"))
	
	write.csv(round(ward_decomposed_week[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_week[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_trend_data_issued.csv"))
	write.csv(ward_week_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_raw_data_issued.csv"))
	write.csv(round(ward_decomposed_week[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_week[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_seasonal_data_issued.csv"))	
}