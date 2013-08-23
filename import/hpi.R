library(tframe)

hpi <- read.csv("ihs_index.csv")

hpi.ts <- ts(hpi$Single.Family,
             start = c(1997, 1),
             frequency = 4)
hpi.ts <- tframe::tfwindow(hpi.ts, start=c(2005,1))

quarterly_data = paste(hpi.ts, collapse=",")

hpi <- paste(
 'var hpi = {"grouping" : "HPI",
 "Title" : "Cook County Housing Price Index",
 "Source" : "Depaul Institute of Housing Studies",
 "Label" : "HPI",
 "Start Year" : 2005,
 "Data Type" : "count",
 "Point Interval" : "quarter",
 "Data Raw" : [], 
 "Data Trend" : [',
  quarterly_data,
  ']}')

write(hpi, "hpi.js")


