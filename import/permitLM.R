#Permit Trend and Linear approximation

month_permit <- read.csv("building_permits.csv")
month_permit_ts <- ts(month_permit$x, month_permit$X, frequency=12)

permit_stl <- stl(month_permit_ts,s.window=7,s.degree=1,t.window=9,robust=T)

permit_trend <- permit_stl$time.series[,'trend']
time <- 1:length(permit_trend)
permit.lm <- lm(permit_trend~time)
boxcox(permit.lm)
permit.lm <- lm(1/permit_trend~time) #Could also transform response variable
