setwd('~/public/hows-business/import/')
source('fusion-tables.R')
source('login.R')
suppressMessages(library(xts))

print('loading issued business licenses ...')

#import data

license.url <- "http://data.cityofchicago.org/api/views/xh8b-g55w/rows.csv"
raw_licenses <- read.csv(license.url)

derived_business_licenses <- c("Auto Gas Pump Certification",
                               "Special Event Food",
                               "Tobacco Retail Over Counter",
                               "Consumption on Premises - Incidental Activity",
                               "Hazardous Materials",
                               "Package Goods",
                               "Raffles",
                               "Outdoor Patio",
                               "Repossessor Class B Employee",
                               "Explosives, Certificate of Fitness",
                               "Caterer's Liquor License",
                               "Expediter - Class B Employee",
                               "Accessory Garage",
                               "Expediter - Class B",
                               "Retail Food Est.-Supplemental License for Dog-Friendly Areas",
                               "Food - Shared Kitchen Long-Term User",
                               "Class B - Indoor Special Event",
                               "Food - Shared Kitchen Short-Term User",
                               "Repossessor Class B",
                               "(Other)",
                               "Caterer's Registration (Liquor)",
                               "Food - Shared Kitchen - Supplemental")

#filter out licenses that alway require a business license
filtered_licenses <- raw_licenses[!raw_licenses$LICENSE.DESCRIPTION
                                  %in% derived_business_licenses,
                                  c("LICENSE.DESCRIPTION", "PAYMENT.DATE")]
names(filtered_licenses) <- c("LICENSE.DESCRIPTION", "date")
filtered_licenses$date <- factor(filtered_licenses$date)

# Count Licenses By Day
date_count <- table(filtered_licenses$date)
date_count <- as.data.frame(date_count)
names(date_count) <- c("date", "count")
date_count <- date_count[date_count$date != "",]
date_count$date <- as.Date(date_count$date, "%m/%d/%Y")

# Select only whole months
#begin_curr_month <- as.Date(as.yearmon(Sys.Date()))
#begin_last_month <- as.Date(as.yearmon(as.Date(as.yearmon(Sys.Date())) - 1))

date_count <- date_count[date_count$date >= "2006-01-01",]
date_count <- date_count[date_count$date < "2013-01-01",]
date_count <- xts(date_count$count, date_count$date)

month_count <- apply.monthly(date_count, sum)
month_count_ts <- ts(as.numeric(month_count),
                     c(2006, 1),
                     frequency = 12)

decomposed_month <- stl(log(month_count_ts),
                        s.window=9,
                        s.degree=1,
                        robust=TRUE)
plot(decomposed_month)

trend_output <- round(exp(decomposed_month$time.series[,2]),2)
season_output <- round(exp(decomposed_month$time.series[,1]),2)

auth = ft.connect(login.username, login.password)

month_data = paste(month_count_ts, collapse=',')
month_data = paste(paste(rep(',', 12), collapse=""), month_data, sep='')
month_data = paste(month_data, ',,,', sep='')


month_data = paste(month_data, ',', sep='')

updateFT(auth, login.table_id, 'License Raw', month_data)

trend_data = paste(trend_output, collapse=',')
trend_data = paste(paste(rep(',', 12), collapse=""), trend_data, sep='')
trend_data = paste(trend_data, ',,,', sep='')


updateFT(auth, login.table_id, 'License Trend', trend_data)


x <- 11:0
trend.y <- trend_output[length(trend_output)-x]
x <- 0:11
trend.lm <- lm(trend.y~x)

m <- trend.lm$coef[2]

updateFT(auth,login.table_id,'License Trend',m, 'CurrentTrend')


