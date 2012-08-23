setwd('~/public/hows-business/import/')
source('fusion-tables.R')
source('login.R')
library(zoo)
library(xts)
print('loading issued business licenses ...')

#import csv
raw_licenses <- read.csv('data/BusinessLicenseIssued.csv')

derived_business_licenses <- c("Auto Gas Pump Certification",
                               "Special Event Food",
                               "Home Occupation",
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
filtered_licenses <- raw_licenses[!raw_licenses$LICENSE.DESCRIPTION %in% derived_business_licenses, c("LICENSE.DESCRIPTION", "PAYMENT.DATE")]


#filtered_licenses <- raw_licenses[,c("LICENSE.DESCRIPTION", "PAYMENT.DATE")]

names(filtered_licenses) <- c("LICENSE.DESCRIPTION", 
                              "date")

filtered_licenses$date <- factor(filtered_licenses$date)


date_count <- table(filtered_licenses$date)
date_count <- as.data.frame(date_count)
names(date_count) <- c("date", "count")
date_count <- date_count[date_count$date != "",]


date_count$date <- as.Date(date_count$date, 
          	                        "%m/%d/%Y")

date_count <- date_count[date_count$date >= "2005-01-01",]
date_count <- date_count[date_count$date < "2012-07-01",]

date_count <- xts(date_count$count, date_count$date)

month_count <- apply.monthly(date_count, sum)
week_count <- apply.weekly(date_count, sum)

month_count_ts <- ts(as.numeric(month_count),
                     start(month_count),
                     frequency = 12)

week_count_ts <- ts(as.numeric(week_count),
                     start(week_count),
                     frequency = 52)

decomposed_month <- stl(log(month_count_ts),
                         s.window=7,
                         s.degree=1,
                         t.window=9,
                         robust=TRUE)

plot(decomposed_month)


decomposed_week <- stl(log(week_count_ts),
                       s.window=5,
                       s.degree=0,
                       t.window=19,
                       robust=TRUE)

plot(decomposed_week)

#output raw and trend data to csv
write.csv(round(exp(decomposed_month$time.series[,2]),2), "data/trend_data_issued.csv")
write.csv(month_count, "data/raw_data_issued.csv")
write.csv(round(exp(decomposed_month$time.series[,1]),2), "data/seasonal_data_issued.csv")

# Transform the xts object into a dataframe where one column is the
# month ID and the other is the monthly count
mc <- as.data.frame(month_count)
mc <- cbind(rownames(mc), mc)
names(mc) <- c("month", "count")

#output raw and trend data to fusion table. We'll clear the table and
#rewrite
auth = ft.connect(login.username, login.password)
ft.executestatement(auth, sql)

updateFT(auth, login.table_id, 'License Raw', month_count)


