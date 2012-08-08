library(zoo)
library(xts)

geo_filtered_licenses <- read.csv('/Users/dacmorton/Documents/OpenCity/BusinessLicenseFiltered.csv')

#remove extraneous first column
geo_filtered_licenses <- geo_filtered_licenses[,-1]

#remove all rows where there is no police_district data
geo_filtered_licenses_police_district <- geo_filtered_licenses[is.na(geo_filtered_licenses[,"POLICE.DISTRICT"])==F,]

#The data needs to be split up 50 ways. Initializing items needed to hold it.
police_district <- list()
police_district_month_count <- list()
police_district_week_count <- list()
police_district_month_count_ts <- list()
police_district_week_count_ts <- list()
police_district_decomposed_month <- list()
police_district_decomposed_log_month <- list()
police_district_decomposed_week <- list()
police_district_decomposed_log_week <- list()

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

police_district_no <- c(1:25)

for (i in police_district_no){
	police_district[[i]] <- geo_filtered_licenses_police_district[geo_filtered_licenses_police_district["POLICE.DISTRICT"]==i,c("LICENSE.DESCRIPTION","PAYMENT.DATE")]

	names(police_district[[i]]) <- c("LICENSE.DESCRIPTION","date")
	police_district[[i]]$date <- factor(police_district[[i]]$date)

	police_district_date_count <- table(police_district[[i]]$date)
	police_district_date_count <- as.data.frame(police_district_date_count)
	names(police_district_date_count) <- c("date","count")
	police_district_date_count <- police_district_date_count[police_district_date_count$date != "",]

	police_district_date_count$date <- as.Date(police_district_date_count$date, "%m/%d/%Y")
	police_district_date_merge <- merge(full_day,police_district_date_count,by.x=1,by.y=1,all=T)[-2]
	police_district_date_merge[is.na(police_district_date_merge[2]==T),2] <- 0
	names(police_district_date_merge) <- c("date","count") 

	police_district_date_count <- police_district_date_count[police_district_date_count$date >= "2005-01-01",]
	police_district_date_count <- police_district_date_count[police_district_date_count$date < "2012-07-01",]

    #Fill in entries for dates with zero. Necessary to regularize the data.
	police_district_date_merge <- merge(full_day,police_district_date_count,by.x=1,by.y=1,all=T)[-2]
	police_district_date_merge[is.na(police_district_date_merge[2]==T),2] <- 0
	names(police_district_date_merge) <- c("date","count")

	police_district_date_count_xts <- xts(police_district_date_merge$count, police_district_date_merge$date)

	police_district_month_count[[i]] <- apply.monthly(police_district_date_count_xts,sum)
	index(police_district_month_count[[i]]) <- as.yearmon(index(police_district_month_count[[i]]))
	police_district_week_count[[i]] <- apply.weekly(police_district_date_count_xts, sum)

	#Convert data to time series
	police_district_month_count_xts <- xts(police_district_month_count[[1]])
	police_district_month_count_ts[[i]] <- ts(as.numeric(police_district_month_count_xts),police_district_month_merge[1,1],frequency = 12)

	#Convert data to time series
	police_district_week_count_xts <- xts(police_district_week_count[[i]])
	police_district_week_count_ts[[i]] <- ts(as.numeric(police_district_week_count_xts),police_district_month_merge[1,1],frequency = 52)

	police_district_decomposed_month[[i]] <- stl(police_district_month_count_ts[[i]],s.window=7,s.degree=1,t.window=9,robust=T)
	police_district_decomposed_log_month[[i]] <- stl(log(police_district_month_count_ts[[i]]+0.1),s.window=7,s.degree=1,t.window=9,robust=TRUE)
	
	police_district_decomposed_week[[i]] <- stl(police_district_week_count_ts[[i]],s.window=5,s.degree=0,t.window=19,robust=TRUE)
	police_district_decomposed_log_week[[i]] <- stl(log(police_district_week_count_ts[[i]]+0.1),s.window=5,s.degree=0,t.window=19,robust=TRUE)
	
	write.csv(round(police_district_decomposed_month[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(police_district_decomposed_log_month[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_log_trend_data_issued.csv"))
	write.csv(police_district_month_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_raw_data_issued.csv"))
	write.csv(round(police_district_decomposed_month[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(police_district_decomposed_log_month[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_log_seasonal_data_issued.csv"))
	
	write.csv(round(police_district_decomposed_week[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(police_district_decomposed_log_week[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_log_trend_data_issued.csv"))
	write.csv(police_district_week_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_raw_data_issued.csv"))
	write.csv(round(police_district_decomposed_week[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(police_district_decomposed_log_week[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/PoliceDistricts/police_district",i,"_month_log_seasonal_data_issued.csv"))	
}