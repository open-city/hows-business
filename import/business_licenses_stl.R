suppressMessages(library(xts))

licenses <- read.csv("daily_count.csv")

names(licenses) <- c("date", "count")

licenses$date <- as.Date(licenses$date,"%m/%d/%Y")
licenses <- licenses[!is.na(licenses$date),]
#licenses <- licenses[order(licenses$date),]

# Select only whole months
begin_curr_month <- as.Date(as.yearmon(Sys.Date()))

licenses <- licenses[licenses$date >= "2005-1-01"
                     & licenses$date < begin_curr_month,]

licenses_xts <- xts::xts(licenses$count, licenses$date)
month_licenses <- apply.monthly(licenses_xts,sum)

month_count_ts <- ts(as.numeric(month_licenses), c(2005, 1), frequency=12)

trend <- lowess(log(month_count_ts), f=.3)

trend_output <- round(exp(trend$y),2)

month_data = paste(month_count_ts, collapse=',')

trend_data = paste(trend_output, collapse=',')

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
 
