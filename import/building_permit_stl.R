library(xts)
library(RCurl)

#Permit Trend and Linear approximation
permit.url <- "https://data.cityofchicago.org/resource/ydr8-5enu.csv?$select=_issue_date,count(_issue_date)&$group=_issue_date&$where=_permit_type='PERMIT - NEW CONSTRUCTION' OR _permit_type='PERMIT - RENOVATION/ALTERATION'&$limit=100000"
permit.csv <- RCurl::getURLContent(URLencode(permit.url))
permit <- read.csv(textConnection(permit.csv))

names(permit) <- c("date", "count")

permit$date <- as.Date(permit$date,"%m/%d/%Y")
permit <- permit[!is.na(permit$date),]
permit <- permit[order(permit$date),]

#Remove outlier by averaging the other entries within one week.

permit$count[575] <- sum(permit[permit$date <= "2007-07-14"
                                & permit$date >= "2007-06-30"
                                & permit$date != "2007-07-07",
                                "count"])/10


# Select only whole months
begin_curr_month <- as.Date(as.yearmon(Sys.Date()))

permit <- permit[permit$date >= "2006-1-01"
                 & permit$date < begin_curr_month,]

permit_xts <- xts::xts(permit$count, permit$date)
month_permit <- apply.monthly(permit_xts,sum)

month_permit_ts <- ts(as.numeric(month_permit), c(2006, 1), frequency=12)

permit_stl <- stl(log(month_permit_ts),
                  s.window=5,
#                  s.degree=1,
#                  t.window=9,
#                  t.degree=1,
                  robust=T)
plot(permit_stl)

permit_trend <- round(exp(permit_stl$time.series[,'trend']), 2)

permit_season <- round(exp(permit_stl$time.series[,'seasonal']), 2)

month_data = paste(month_permit_ts, collapse=',')
month_data = paste(paste(rep('null', 12), collapse=","), ',', month_data, sep='')

trend_data = paste(permit_trend, collapse=',')
trend_data = paste(paste(rep('null', 12), collapse=","), ',', trend_data, sep='')

permits <- paste(
 'var permits = {"grouping" : "Building Permits",
 "Title" : "Monthly New Building Permits",
 "Source" : "City of Chicago",
 "Label" : "Issued building permits",
 "Start Year" : 2005,
 "Data Type" : "count",
 "Point Interval" : "month",
 "Data Raw" : [',
  month_data,
  '],
 "Data Trend" : [',
  trend_data,
  ']}')

write(permits, "permits.js")
