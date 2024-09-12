#stable codes and packages
# Sett working directory to source file location. Do that through the tab session.
rm(list=ls())
options(digits=5)
setwd("F:/LSU/2024spring/EXST7087_Digital_Agriculture/assignment/assignment10/Codes")
##===== Loads appropriate libraries. Make sure they are installed. If not install them from the tab "packages" in R-Studio======================================
library("easypackages")
libraries("tseries","dplyr","tidyr","htmltools","usefun","timetk","tidyverse","rlist","gridExtra","fpp2","quantmod","psych","broom","dygraphs","tidyquant","zoo")
source("./Functions/All_Functions.R") # adds all the custom functions 
#================= Load Data from yahoo finance simple view =========================
hotel<-read.csv("../Data/hotel_bookings.csv",stringsAsFactors = T)
print(colSums(is.na(hotel)))
hotel<-hotel %>% mutate(across(where(is.numeric), ~replace_na(., median(., na.rm=TRUE))))
hotel$reservation_status_date<-as.POSIXct(hotel$reservation_status_date,format="%m/%d/%Y")
hotel_adr_average<-hotel %>%
  # Specify group indicator, column, function
  group_by(reservation_status_date,hotel) %>%
  # Calculate the mean of the "Frequency" column for each group
  summarise_at(vars(adr),
               list(adr_average= mean))%>%filter(reservation_status_date>=as.Date("2015-07-01"))%>%filter(reservation_status_date<=as.Date("2017-09-07"))

cityhotel<-hotel_adr_average[hotel_adr_average$hotel=="City Hotel",]

resorthotel<-hotel_adr_average[hotel_adr_average$hotel=="Resort Hotel",]

# generate full date set
#all_dates_city <- data.frame(reservation_status_date = seq(min(cityhotel$reservation_status_date), max(cityhotel$reservation_status_date), by="day"))
#all_dates_city$reservation_status_date<-format(as.POSIXct(all_dates_city$reservation_status_date,format="%m/%d/%Y %H:%M:%S"),format='%m/%d/%Y')
#all_dates_city$reservation_status_date<-as.POSIXct(all_dates_city$reservation_status_date,format="%m/%d/%Y")
#all_city<-data.frame(hotel=rep("City Hotel",length(all_dates_city)),reservation_status_date = seq(min(cityhotel$reservation_status_date), max(cityhotel$reservation_status_date), by="day"))
#all_dates_resort <- data.frame(reservation_status_date = seq(min(resorthotel$reservation_status_date), max(resorthotel$reservation_status_date), by="day"))
#all_dates_resort$reservation_status_date<-format(as.POSIXct(all_dates_resort$reservation_status_date,format="%m/%d/%Y %H:%M:%S"),format='%m/%d/%Y')
#all_dates_resort$reservation_status_date<-as.POSIXct(all_dates_resort$reservation_status_date,format="%m/%d/%Y")

#complete_data_city <- left_join(cityhotel, all_dates_city)
#complete_data_resort <- left_join( resorthotel,all_dates_resort)


# set max gap
#complete_data_city$adr_average <- na.approx(complete_data_city$adr_average, maxgap = Inf, na.rm = FALSE)
#complete_data_resort$adr_average <- na.approx(complete_data_resort$adr_average, maxgap = Inf, na.rm = FALSE)

cityhotel1<-column_to_rownames(cityhotel,"reservation_status_date")
resorthotel1<-column_to_rownames(resorthotel,"reservation_status_date")



#dygraph(cityhotel1)
#dygraph(resorthotel1)

CTH<-ts(cityhotel1[,2],start = c(2015,07,01),frequency=365.25)
RSH<-ts(resorthotel1[,2],start = c(2015,07,01),frequency=365.25)



#test=c("City","Resort")


#objList=test;
#getSymbols(objList,src="yahoo",from= "2015-02-07"); #downloads data and saves them #search engine = yahoo
#StockList = lapply(objList, get);  # list of objects     
#dygraph(GOOGL[,6])
#dygraph(GOOGL[,5])
#GGL=ts(GOOGL[,6],start=c(2015,2,08),frequency=365.25)
##============== Basic Analysis =====================================================
#=============== Decomposing The Google timeseries =================
#city hotel
decomp_city=decompose(CTH,type="additive")
autoplot(decomp_city)#seasonal very small

detrend_city=CTH-decomp_city$trend
autoplot(detrend_city)

deseason_city=CTH-decomp_city$seasonal
autoplot(deseason_city)

autoplot(decomp_city$random)

#resort hotel
decomp_resort=decompose(CTH,type="additive")
autoplot(decomp_resort)#seasonal very small

detrend_resort=CTH-decomp_resort$trend
autoplot(detrend_resort)

deseason_resort=CTH-decomp_resort$seasonal
autoplot(deseason_resort)

autoplot(decomp_resort$random)

#================ Combine multiple dygraphs ========================
dy_graph_city<-dygraph(cityhotel1,main = "City Hotel adr")
dy_graph_resort<-dygraph(resorthotel1,main = "Resort Hotel adr")
browsable(htmltools::tagList(list(dy_graph_city,dy_graph_resort)))

##============= Correlations =========================== 
cityhoteladr=as.vector(cityhotel1[,2])
resorthoteladr=as.vector(resorthotel1[,2])
#GOOGLPvec=as.vector(GOOGL[,6])
#GOOGLVvec=as.vector(GOOGL[,5])
#TSLAPvec=as.vector(TSLA[,6])
#============ Correlations among hotel styles ===============
cor(cityhoteladr,resorthoteladr)
ccf(cityhoteladr,resorthoteladr)
ccfvalues=ccf(cityhoteladr,resorthoteladr,lag.max = 15)
ccfvalues$acf
ccfvalues$acf[which.max(abs(ccfvalues$acf))]
which.max(abs(ccfvalues$acf))-30
#============ Dataset building ============================
df1=rbind(cityhotel1,resorthotel1)



#DF=list()
#for (i in 1:length(objList)){
#df1=as.data.frame(StockList[[i]])
df1=df1%>%rownames_to_column("DATE")


#df1=list.rbind(DF)
df1$DATE=as.Date(df1$DATE)
df1$MA_7_VALUE=ma(df1$adr_average,7)
df1$MA_7_VALUE=as.numeric(df1$MA_7_VALUE)

#=========== Simple Graphs ================================
p1=ggplot(df1, aes(x=DATE, y=MA_7_VALUE, colour=hotel)) +
  geom_line()+
  scale_x_date(breaks = "1 month",date_labels="%b")+
  xlab("") + ylab("7 Day Moving Average Price")+
  ggtitle("MA(7) Smoothed Timeseries ")+
  theme_bw() + theme(axis.text.x = element_text(angle = 90))
ggsave("../Results/Graphs/All_Hotels_Smoothed.jpg",width=10,heigh=10,p1) 

##============ Predictive algorithm comparisons ===================
city=df1%>%filter(hotel=="City Hotel")
resort=df1%>%filter(hotel=="Resort Hotel")

freq=365.25
k=20#not 80/20 split anymore, since forecasting needs way larger dataset to train
#d=0.1
#k=round(nrow(df1)*d)

#=============== Remove Random Noise and analyze =====================================================
#===city
nonoise_city=CTH-decomp_resort$random
autoplot(nonoise_city)
#decomp_city_ma=decompose(city,type = "additive")   ##not enough data
#nonoise_city=city-decomp_city$random#not enough data
#autoplot(nonoise_city)
#=====
sd(as.vector(na.omit(decomp_city$random)))
mean(as.vector(na.omit(decomp_city$random)))
#=====
clean_city=na.omit(nonoise_city)#not enough data
autoplot(clean_city)#not enough data

#clean_city_decomp=decompose(clean_city,type="additive")
#autoplot(clean_city_decomp)
#====resort
nonoise_resort=RSH-decomp_resort$random
autoplot(nonoise_resort)
#=====
sd(as.vector(na.omit(decomp_resort$random)))
mean(as.vector(na.omit(decomp_resort$random)))
#=====
clean_resort=na.omit(nonoise_resort)
autoplot(clean_resort)

#clean_resort_decomp=decompose(clean_resort,type="additive") not enough data
#autoplot(clean_resort_decomp) #not enough data

#=============== Test for stationary ==================================================================
adf.test(na.omit(clean_city)) #The small p value makes us reject the null in favor of the alternative. 
# I.e. the time series is stationary which means the mean, variance and autocorrelation don't change over time
###not stationary
Acf(clean_city) # The autocorrelation function
Pacf(clean_city) # The partial autocorrelation function

adf.test(na.omit(clean_resort)) #The small p value makes us reject the null in favor of the alternative. 
# I.e. the time series is stationary which means the mean, variance and autocorrelation don't change over time
Acf(clean_resort) # The autocorrelation function
Pacf(clean_resort) # The partial autocorrelation function
#=================================================================================================
#============= Train test split ================
#City
train_city=TSSplit(city,k)[[1]]
test_city=TSSplit(city,k)[[2]]
#============= Creating Time series ============
TS_Train_city=TSConvert(train_city,"MA_7_VALUE",freq)
TS_Test_city=TSConvert(test_city,"MA_7_VALUE",freq)
TS_All_city=c(TS_Train_city,TS_Test_city) ###STOP
#================ NN train and prediction =========================
fit1_city=nnetar(TS_Train_city,p=7,Size=10,repeats=50,lambda = "auto")#using modified neural network #past=7days (use previous 7 days to predict) # of nodes=10
for1_city=forecast(fit1_city,k)
autoplot(for1_city)
predictions1_city=for1_city$mean
autoplot(predictions1_city)

fit2_city=nnetar(TS_Train_city)#default settings
for2_city=forecast(fit2_city,k)
autoplot(for2_city)
predictions2_city=for2_city$mean
autoplot(predictions2_city)
#================ ARIMA and prediction =========================
fit3_city=auto.arima(TS_Train_city) 
for3_city=forecast(fit3_city,h=k)
autoplot(for3_city)
predictions3_city=for3_city$mean
autoplot(predictions3_city)

fit4_city=arima(TS_Train_city,order=c(7,0,1))
for4_city=forecast(fit4_city,k)
autoplot(for4_city)
predictions4_city=for4_city$mean
autoplot(predictions4_city)
#================ Comparing Predictions vs Truth ===================
results_city=data.frame(DATE=test_city$DATE,TEST=test_city$MA_7_VALUE,PREDNN=as.vector(predictions1_city),
                   PREDAUTONN=as.vector(predictions2_city),PREDAUTOARIMA=as.vector(predictions3_city),
                   PREDARIMA=as.vector(predictions4_city))

results_city$ENS1=rowMeans(results_city[,c(5,6)])#average out 2 ARIMAs
results_city$ENS2=rowMeans(results_city[,3:6])#average of all results

#================ Plotting Prediction vs Truth ====================
p1_city=ggplot() +
  geom_line(data=city, aes(x = DATE, y = MA_7_VALUE, colour = "Actual Values"))+
  geom_line(data = results_city, aes(x = DATE, y = TEST, colour = "Actual Values")) +
  geom_line(data = results_city, aes(x = DATE, y = PREDNN,   colour = "Predictions NN"))  +
  geom_line(data = results_city, aes(x = DATE, y = PREDARIMA,   colour = "Predictions ARIMA"))  +
  geom_line(data = results_city, aes(x = DATE, y = PREDAUTOARIMA,   colour = "Predictions Auto ARIMA"))  +
  geom_line(data = results_city, aes(x = DATE, y = PREDAUTONN,   colour = "Predictions Auto Neural Network"))  +
  geom_line(data = results_city, aes(x = DATE, y = ENS1,   colour = "Predictions Ensamble1"))  +
  geom_line(data = results_city, aes(x = DATE, y = ENS2,   colour = "Predictions Ensamble2"))  +
  ylab('PRICE')+
  scale_x_date(breaks = "1 month",date_labels="%b")+
  #scale_x_date(breaks=df1$Date ,labels=format(df1$Date,format="%m-%d"))+
  ggtitle(paste0("City Hotels Comparison of Predicted vs True Number of Smoothed (7) Cases for ",k," days"))+
  theme_bw()+
  theme(axis.text.x = element_text(angle=45, hjust = 1))
  
ggsave(paste0("../Results/Graphs/Predictions_vs_Test_days_",k,".jpg"),p1,width=10,heigh=8)
p1_city
#=============== Create Root Mean Square Errors ==================
RMSE_city=matrix(0,nrow=1,ncol = 6) 
RMSE_city=as.data.frame(RMSE_city)
colnames(RMSE_city)=colnames(results_city[,3:8])
for (i in 1:6){
  adr=results_city[,c(2,i+2)]
  adr$Diff=adr[,1]-adr[,2]
  adr1=adr$Diff[!is.na(adr$Diff)]
  RMSE_city[1,i]=sqrt(mean(adr1^2))
}
write.csv(RMSE_city,paste0("../Results/Smoothed_7_RMSE_days_",k,".csv"))

best_pred_city <- apply(RMSE_city, 1, function(x) {
  sorted_values <- order(x)[1:2]
  return(x[sorted_values])
})
best_pred_city

#Resort
train_resort=TSSplit(resort,k)[[1]]
test_resort=TSSplit(resort,k)[[2]]
#============= Creating Time series ============
TS_Train_resort=TSConvert(train_resort,"MA_7_VALUE",freq)
TS_Test_resort=TSConvert(test_resort,"MA_7_VALUE",freq)
TS_All_resort=c(TS_Train_resort,TS_Test_resort) ###STOP
#================ NN train and prediction =========================
fit1_resort=nnetar(TS_Train_resort,p=7,Size=10,repeats=50,lambda = "auto")#using modified neural network #past=7days (use previous 7 days to predict) # of nodes=10
for1_resort=forecast(fit1_resort,k)
autoplot(for1_resort)
predictions1_resort=for1_resort$mean
autoplot(predictions1_resort)

fit2_resort=nnetar(TS_Train_resort)#default settings
for2_resort=forecast(fit2_resort,k)
autoplot(for2_resort)
predictions2_resort=for2_resort$mean
autoplot(predictions2_resort)
#================ ARIMA and prediction =========================
fit3_resort=auto.arima(TS_Train_resort) 
for3_resort=forecast(fit3_resort,h=k)
autoplot(for3_resort)
predictions3_resort=for3_resort$mean
autoplot(predictions3_resort)

fit4_resort=arima(TS_Train_resort,order=c(7,0,1))
for4_resort=forecast(fit4_resort,k)
autoplot(for4_resort)
predictions4_resort=for4_resort$mean
autoplot(predictions4_resort)
#================ Comparing Predictions vs Truth ===================
results_resort=data.frame(DATE=test_resort$DATE,TEST=test_resort$MA_7_VALUE,PREDNN=as.vector(predictions1_resort),
                        PREDAUTONN=as.vector(predictions2_resort),PREDAUTOARIMA=as.vector(predictions3_resort),
                        PREDARIMA=as.vector(predictions4_resort))

results_resort$ENS1=rowMeans(results_resort[,c(5,6)])#average out 2 ARIMAs
results_resort$ENS2=rowMeans(results_resort[,3:6])#average of all results

#================ Plotting Prediction vs Truth ====================
p1_resort=ggplot() +
  geom_line(data=resort, aes(x = DATE, y = MA_7_VALUE, colour = "Actual Values"))+
  geom_line(data = results_resort, aes(x = DATE, y = TEST, colour = "Actual Values")) +
  geom_line(data = results_resort, aes(x = DATE, y = PREDNN,   colour = "Predictions NN"))  +
  geom_line(data = results_resort, aes(x = DATE, y = PREDARIMA,   colour = "Predictions ARIMA"))  +
  geom_line(data = results_resort, aes(x = DATE, y = PREDAUTOARIMA,   colour = "Predictions Auto ARIMA"))  +
  geom_line(data = results_resort, aes(x = DATE, y = PREDAUTONN,   colour = "Predictions Auto Neural Network"))  +
  geom_line(data = results_resort, aes(x = DATE, y = ENS1,   colour = "Predictions Ensamble1"))  +
  geom_line(data = results_resort, aes(x = DATE, y = ENS2,   colour = "Predictions Ensamble2"))  +
  ylab('PRICE')+
  scale_x_date(breaks = "1 month",date_labels="%b")+
  #scale_x_date(breaks=df1$Date ,labels=format(df1$Date,format="%m-%d"))+
  ggtitle(paste0("Comparison of Predicted vs True Number of Smoothed (7) Cases for ",k," days"))+
  theme_bw()+
  theme(axis.text.x = element_text(angle=45, hjust = 1))

ggsave(paste0("../Results/Graphs/Predictions_vs_Test_days_",k,".jpg"),p1,width=10,heigh=8)
p1_resort
#=============== Create Root Mean Square Errors ==================
RMSE_resort=matrix(0,nrow=1,ncol = 6) 
RMSE_resort=as.data.frame(RMSE_resort)
colnames(RMSE_resort)=colnames(results_resort[,3:8])
for (i in 1:6){
  adr=results_resort[,c(2,i+2)]
  adr$Diff=adr[,1]-adr[,2]
  adr1=adr$Diff[!is.na(adr$Diff)]
  RMSE_resort[1,i]=sqrt(mean(adr1^2))
}
write.csv(RMSE_resort,paste0("../Results/Smoothed_7_RMSE_days_",k,".csv"))

best_pred_resort <- apply(RMSE_resort, 1, function(x) {
  sorted_values <- order(x)[1:2]
  return(x[sorted_values])
})
best_pred_resort






##============== Increase - Decrease Analysis =====================
#df3_city=city%>%dplyr::select(DATE,MA_7_VALUE) %>%

#tq_mutate(select= MA_7_VALUE,mutate_fun = lag.xts,k=1)%>%tq_mutate(select= MA_7_VALUE,mutate_fun = lag.xts,k=1)
#rename_with(~ toupper(gsub(".", "", .x, fixed = TRUE)))











