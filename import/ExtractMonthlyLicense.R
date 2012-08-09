#Extract Montly License data and save it as a .csv file to save on preprocessing.

library(xts)
library(zoo)

geo_filtered_licenses <- read.csv('/Users/dacmorton/Documents/OpenCity/BusinessLicenseFiltered.csv')[-1]

names(geo_filtered_licenses) <- c("LICENSE.DESCRIPTION", "date","WARD","PRECINCT","POLICE.DISTRICT","LATITUDE","LONGITUDE")

geo_filtered_licenses$date <- factor(geo_filtered_licenses$date)

#Build data frame necessary for gaps in the data
month_index <- seq(as.yearmon("2005-01-01"),as.yearmon("2012-06-30"),1/12)
full_month <- data.frame(month_index,rep(0,length(index)))
names(full_month) <- c("index","zero")

week_index <- seq(as.Date("2005-01-07"),as.Date("2012-06-30"),7)
full_week <- data.frame(week_index,rep(0,length(week_index)))
week_in <- floor(as.numeric(as.yearmon(week_index)))

date_count <- table(geo_filtered_licenses$date)
date_count <- as.data.frame(date_count)
names(date_count) <- c("date", "count")
date_count <- date_count[date_count$date != "",]

date_count$date <- as.Date(date_count$date, "%m/%d/%Y")

date_count <- date_count[date_count$date >= "2005-01-01",]
date_count <- date_count[date_count$date < "2012-07-01",]

date_count <- xts(date_count$count, date_count$date)

month_count <- apply.monthly(date_count, sum)
month_count_ts <- ts(as.numeric(month_count),2005,frequency = 12)

write.csv(month_count_ts,"/Users/dacmorton/Documents/OpenCity/HowsBusiness/MonthlyLicense.csv")