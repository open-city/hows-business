setwd('~/public/hows-business/import/')
source('fusion-tables.R')
source('login.R')
library(xts)
print('loading issued business licenses ...')

#import data
ridership.url <- "http://data.cityofchicago.org/api/views/6iiy-9s97/rows.csv"
date_count <- read.csv(ridership.url)

date_count <- unique(date_count)
date_count <- na.omit(date_count)

date_count$service_date <- as.Date(as.character(date_count$service_date),
                                   "%m/%d/%Y")


# Select only whole months
begin_curr_month <- as.Date(as.yearmon(Sys.Date()))

date_count <- date_count[date_count$service_date >= "2001-01-01",]
date_count <- date_count[date_count$service_date < begin_curr_month,]

date_count <- xts(date_count$total_rides, date_count$service_date)

month_count <- apply.monthly(date_count, sum)
month_count_ts <- ts(as.numeric(month_count),
                     c(2001, 1),
                     frequency = 12)

decomposed_month <- stl(log(month_count_ts),
                        s.window=7,
                        s.degree=1,
                        t.window=9,
                        robust=TRUE)

trend_ouput <- round(exp(decomposed_month$time.series[,2]),2)
season_output <- round(exp(decomposed_month$time.series[,1]),2)

#output raw and trend data to fusion table. We'll clear the table and
#rewrite
#auth = ft.connect(login.username, login.password)
#updateFT(auth, login.table_id, 'License Raw', month_count)
#updateFT(auth, login.table_id, 'License Trend', trend_output)
#updateFT(auth, login.table_id, 'License Season', season_output)



