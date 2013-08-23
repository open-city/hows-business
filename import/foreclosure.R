foreclosures <- read.csv("data/chicago_foreclosures.csv")

foreclosure.ts <- ts(colSums(foreclosures[,3:dim(foreclosures)[2]]),
                     start = c(2006, 1),
                     frequency = 4)

quarterly_data = paste(foreclosure.ts, collapse=",")
quarterly_data = paste(paste(rep('null', 4), collapse=","), ',', quarterly_data, sep='')
quarterly_data = paste(quarterly_data, ",null", sep='')

foreclosures <- paste(
 'var foreclosures = {"grouping" : "Foreclosures",
 "Title" : "Quarterly Foreclosures",
 "Source" : "Woodstock Institute",
 "Label" : "Foreclosures",
 "Start Year" : 2005,
 "Data Type" : "count",
 "Point Interval" : "quarter",
 "Data Trend" : [], 
 "Data Raw" : [',
  quarterly_data,
  ']}')

write(foreclosures, "foreclosures.js")


