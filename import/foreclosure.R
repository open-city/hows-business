foreclosures <- read.csv("data/chicago_foreclosures.csv")

foreclosure.ts <- ts(colSums(foreclosures[,3:dim(foreclosures)[2]]),
                     start = c(2006, 1),
                     frequency = 4)

auth = ft.connect(login.username, login.password)
quarterly_data = paste(foreclosure.ts, collapse=",")
quarterly_data = paste(paste(rep('null', 4), collapse=","), ',', quarterly_data, sep='')
quarterly_data = paste(quarterly_data, ",null", sep='')

foreclosures_raw <- paste(
 '{"grouping" : "Foreclosures",
 "type" : "Raw",
 "Title" : "Quarterly Foreclosures",
 "Source" : "Woodstock Institute",
 "Label" : "Foreclosures",
 "Start Year" : 2005,
 "Point Interval" : "quarter",
 "Data" : [',
  quarterly_data,
  ']}')

write(foreclosures_raw, "foreclosures_raw.json")


