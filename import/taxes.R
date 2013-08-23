library(tframe)

taxes <- read.csv("data/taxes.csv")

cpi <- read.table("ftp://ftp.bls.gov/pub/time.series/cu/cu.data.4.AsizeNorthCentral", fill=TRUE, header=TRUE)

cpi.df <- cpi[cpi$series_id == "CUURA207SA0"
              & cpi$period != "M13"
              & cpi$year > 1990,]

cpi.monthly <- ts(cpi.df$value, c(1991, 1), frequency=12)
cpi.quarterly <- aggregate(cpi.monthly, 4, mean)

tax <- taxes[taxes$tax_type == "HMR",]

tax_total <- aggregate(tax$total,
                       by=list(paste(tax$year,
                                     tax$quarter)),
                       FUN=sum)

tax_total <- ts(tax_total$x, c(1999,3), frequency=4)

chicago_rate = c(rep(.01, 24),
                 rep(.0125, length(tax_total) - 24))

taxable_sales <- tax_total/chicago_rate

cpi.quarterly <- tframe::tfwindow(cpi.quarterly,
                                  start=start(taxable_sales),
                                  end=end(taxable_sales))
#rebase to current dolars
cpi.quarterly <- cpi.quarterly/cpi.quarterly[length(cpi.quarterly)]

taxable_sales <- taxable_sales/cpi.quarterly
  
decomposed <- stl(taxable_sales,
                  s.window=9,
                  s.degree=1,
                  robust=TRUE)

taxable_sales <- tframe::tfwindow(taxable_sales,start=c(2005,1))
trend <- tframe::tfwindow(decomposed$time.series[, "trend"], start=c(2005,1))

quarterly_data = paste(taxable_sales, collapse=",")
trend_data = paste(trend, collapse=",")

taxes_js <- paste(
 'var taxable_sales = {"grouping" : "Taxable Sales",
 "Title" : "Quarterly Taxable Sales in Chicago",
 "Source" : "State of Illinois",
 "Label" : "Dollars",
 "Data Type" : "money", 
 "Start Year" : 2005,
 "Point Interval" : "quarter",
 "Data Trend" : [',
  trend_data,
 '], 
 "Data Raw" : [',
  quarterly_data,
  ']}')

write(taxes_js, "taxable_sales.js")


