library(zoo)
library(xts)

geo_filtered_licenses <- read.csv('/Users/dacmorton/Documents/OpenCity/BusinessLicenseFiltered.csv')

#remove extraneous first column
geo_filtered_licenses <- geo_filtered_licenses[,-1]

#remove all rows where there is no ward data
geo_filtered_licenses_ward <- geo_filtered_licenses[is.na(geo_filtered_licenses[,"WARD"])==F,]

#The data needs to be split up 50 ways. Initializing items needed to hold it.
ward <- list()
ward_month_count <- list()
#ward_week_count <- list()
ward_month_count_ts <- list()
#ward_week_count_ts <- list()
ward_decomposed_month <- list()
ward_decomposed_log_month <- list()
#ward_decomposed_week <- list()
#ward_decomposed_log_week <- list()

#build a data frame necessary for dealing with gaps in the data
index <- seq(as.yearmon("2005-01-01"),as.yearmon("2012-06-30"),1/12)
full <- data.frame(index,rep(0,length(index)))
names(full) <- c("index","zero")

ward_no <- 1:50

for (i in ward_no){
	ward[[i]] <- geo_filtered_licenses_ward[geo_filtered_licenses_ward["WARD"]==i,c("LICENSE.DESCRIPTION","PAYMENT.DATE")]

	names(ward[[i]]) <- c("LICENSE.DESCRIPTION","date")
	ward[[i]]$date <- factor(ward[[i]]$date)

	ward_date_count <- table(ward[[i]]$date)
	ward_date_count <- as.data.frame(ward_date_count)
	names(ward_date_count) <- c("date","count")
	ward_date_count <- ward_date_count[ward_date_count$date != "",]

	ward_date_count$date <- as.Date(ward_date_count$date, "%m/%d/%Y")
	ward_date_count$date <- as.yearmon(ward_date_count$date)

	ward_date_count <- ward_date_count[ward_date_count$date >= "2005-01-01",]
	ward_date_count <- ward_date_count[ward_date_count$date < "2012-07-01",]

	ward_date_count_xts <- xts(ward_date_count$count, ward_date_count$date)

	ward_month_count[[i]] <- apply.monthly(ward_date_count_xts,sum)
	#ward_week_count[[i]] <- apply.weekly(ward_date_count_xts[[i]], sum)

	#Insert zeros into gaps in the data
	ward_month_df <- data.frame(index(ward_month_count[[i]]),ward_month_count[[i]])
	ward_month_merge <- merge(full,ward_month_df,by.x=1,by.y=1,all=T)[-2]
	ward_month_merge[is.na(ward_month_merge[2]==T),2] <- 0

	#Convert data to time series
	ward_month_count_xts <- xts(ward_month_merge[2],ward_month_merge[,1])
	ward_month_count_ts[[i]] <- ts(as.numeric(ward_month_count_xts),ward_month_merge[1,1],frequency = 12)

	#Will get to weekly data soon.
	#ward_week_count_ts[[i]] <- ts(as.numeric(ward_week_count[[i]]),as.numeric(format(start(ward_week_count[[i]]),"%Y")),frequency = 52)

	ward_decomposed_month[[i]] <- stl(ward_month_count_ts[[i]],s.window=7,s.degree=1,t.window=9,robust=T)
	ward_decomposed_log_month[[i]] <- stl(log(ward_month_count_ts[[i]]+0.1),s.window=7,s.degree=1,t.window=9,robust=TRUE)
	
	#ward_decomposed_week[[i]] <- stl(ward_week_count_ts[[i]],s.window=5,s.degree=0,t.window=19,robust=TRUE)
	#ward_decomposed_log_week[[i]] <- stl(log(ward_week_count_ts[[i]]),s.window=5,s.degree=0,t.window=19,robust=TRUE)
	
	write.csv(round(ward_decomposed_month[[i]]$time.series[,2],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_trend_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_month[[i]]$time.series[,2]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_trend_data_issued.csv"))
	write.csv(ward_month_count[[i]], paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_raw_data_issued.csv"))
	write.csv(round(ward_decomposed_month[[i]]$time.series[,1],2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_seasonal_data_issued.csv"))
	write.csv(round(exp(ward_decomposed_log_month[[i]]$time.series[,1]),2), paste0("/Users/dacmorton/Documents/OpenCity/HowsBusiness/Wards/ward",i,"_month_log_seasonal_data_issued.csv"))
}