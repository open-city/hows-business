suppressMessages(library(xts))
library(RCurl)

print('loading issued business licenses ...')

#import data
license.url <- "http://data.cityofchicago.org/resource/r5kz-chrr.csv?$select=payment_date,count(payment_date)&$group=payment_date&$where=application_type='ISSUE' AND license_code='1010'&$order=payment_date&$limit=10000"
license.csv <- RCurl::getURLContent(URLencode(license.url))
licenses <- read.csv(textConnection(license.csv))

names(licenses) <- c("date", "count")

licenses$date <- as.Date(licenses$date,"%m/%d/%Y")
licenses <- licenses[!is.na(licenses$date),]
#licenses <- licenses[order(licenses$date),]

# Select only whole months
begin_curr_month <- as.Date(as.yearmon(Sys.Date()))

licenses <- licenses[licenses$date >= "2006-1-01"
                 & licenses$date < begin_curr_month,]

licenses_xts <- xts::xts(licenses$count, licenses$date)
month_licenses <- apply.monthly(licenses_xts,sum)

month_count_ts <- ts(as.numeric(month_licenses), c(2006, 1), frequency=12)

trend <- lowess(log(month_count_ts), f=.3)

trend_output <- round(exp(trend$y),2)

month_data = paste(month_count_ts, collapse=',')
month_data = paste(paste(rep('null', 12), collapse=","), ',', month_data, sep='')

trend_data = paste(trend_output, collapse=',')
trend_data = paste(paste(rep('null', 12), collapse=","), ',', trend_data, sep='')

license <- paste(
 'var licenses = {"grouping" : "Business Licenses",
 "Title" : "Monthly New Business Licenses",
 "Source" : "City of Chicago",
 "Label" : "Issued business licenses",
 "Start Year" : 2005,
 "Data Type" : "count",
 "Point Interval" : "month",
 "Data Raw" : [',
  month_data,
  '],
 "Data Trend" : [',
  trend_data,
  ']}')


write(license, "licenses.js")
 
