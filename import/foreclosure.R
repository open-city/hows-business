source('fusion-tables.R')
source('login.R')

foreclosures <- read.csv("data/chicago_foreclosures.csv")

foreclosure.ts <- ts(colSums(foreclosures[,3:dim(foreclosures)[2]]),
                     start = c(2007, 1),
                     frequency = 4)

auth = ft.connect(login.username, login.password)
quarterly_data = paste(foreclosure.ts, collapse=",")
quarterly_data = paste(paste(rep(',', 8), collapse=""), quarterly_data, sep='')
quarterly_data = paste(quarterly_data, "," sep='')
updateFT(auth, login.table_id, 'Foreclosure Quarterly', quarterly_data)



