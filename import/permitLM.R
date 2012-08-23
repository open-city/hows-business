#Permit Trend and Linear approximation
permit_stl <- stl(month_permit_ts,s.window=7,s.degree=1,t.window=9,robust=T)
permit_trend <- permit_stl$time.series[,'trend']
time <- 1:length(permit_trend)
permit.lm <- lm(permit_trend~time)
boxcox(permit.lm)
permit.lm <- lm(1/permit_trend~time) #Could also transform response variable