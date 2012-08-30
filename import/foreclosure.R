source('fusion-tables.R')
source('login.R')

foreclosure <- read.csv("data/chicago_foreclosures.csv")

foreclosure.ts <- ts(colSums(foreclosures[,3:dim(foreclosures)[2]]),
                     start = c(2008, 1),
                     frequency = 4)

auth = ft.connect(login.username, login.password)
updateFT(auth, login.table_id, 'Foreclosure Quarterly', foreclosure.ts)



