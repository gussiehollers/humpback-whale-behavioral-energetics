# HMM probability distribution investigation
# load the data

#look at histograms of the different variables
hist(mn200219_98_HMM$pitch, breaks = 20, main = "Histogram of pitch")
hist(mn200219_98_HMM$roll, breaks = 20, main = "Histogram of roll")
hist(mn200219_98_HMM$heading, breaks = 20, main = "Histogram of heading")

# Remove missing values and infinite values
filtered_data <- na.omit(mn200219_98_HMM)
filtered_data <- filtered_data[is.finite(filtered_data)]

# Fit logistic distribution
fit <- fitdistr(filtered_data, "normal")
print(fit)


##trying to use the momentuHMM package 
mn200219_98_filter<-data.frame(filtered_data)
testCols<-mn200219_98_filter[, c("ID", "pitch", "roll", "heading", "depth", "speed")]
testData<-data.frame(testCols)
#I chose the variables I want to use for the HMM, and can incorporate the time of day and length in the fuller model 

pD<-prepData(testData, type='LL', coordNames=NULL)
#I could include hour of day or length using the covNames argument (identifies them as covariates instead of data streams)

# Fit distributions###########################################################################################################################################

testData<-mn200219.55_chunkavg
#PITCH
fit_pitch <- fitdist(testData$avg_pitch, "logis")
print(fit_pitch)
hist(testData$avg_pitch, probability = TRUE, main = "Histogram with Fitted Logistic Distribution")
curve(dlogis(x, fit_pitch$estimate[1], fit_pitch$estimate[2]), add = TRUE, col = "blue", lwd = 2)
#ok, the logistic distribution looks ok for the pitch data

#ROLL
fit_roll <- fitdist(testData$avg_roll, "norm")
print(fit_roll)
hist(testData$avg_roll, probability = TRUE, main = "Histogram with Fitted Distribution")
curve(dnorm(x, fit_roll$estimate[1], fit_roll$estimate[2]), add = TRUE, col = "blue", lwd = 2)

#I want to try a skew normal distribution 
fit_roll <- selm(testData$roll~1)
hist(testData$roll, freq = FALSE, main = "Histogram with Fitted Skew Distribution")
residuals <- resid(fit_roll)
# Estimate kernel density of the fitted residuals
res_density <- density(residuals)
# Plot the kernel density
lines(res_density, col = "blue", lwd = 2)
#I guess the skew normal is okay


#HEADING 
hist(testData$avg_heading, freq = FALSE, main = "Histogram with Fitted Skew Distribution")
fit_heading <- fitdist(testData$avg_heading, "norm")
curve(dnorm(x, fit_heading$estimate[1], fit_heading$estimate[2]), add = TRUE, col = "blue", lwd = 2)

fit_head <- selm(testData$heading~1)
hist(testData$heading, freq = FALSE, main = "Histogram with Fitted Skew Distribution")
residuals <- resid(fit_head)

# Estimate kernel density of the fitted residuals
res_density <- density(residuals)

# Plot the kernel density
lines(res_density, col = "blue", lwd = 2)
#I guess the skew normal is okay


#DEPTH
hist(testData$avg_depth, probability=TRUE)
fit_depth <- fitdist(testData$avg_depth, "gamma")

#This is going to be binomial SOS. Pilot whale paper used depth as gamma?


#SPEED
hist(testData$speed, probability=TRUE)
fit_speed<- fitdist(testData$speed, "gamma")
curve(dgamma(x, fit_speed$estimate[1], fit_speed$estimate[2]), add = TRUE, col = "blue", lwd = 2)
#ok the gamma distribution is okay!


distributions<-list(pitch="logistic", roll="", heading="", depth="", speed ="")


###############################################################################################################################################################

hmm_test<-fitHMM(data = pD, nbStates = 4, dist = , formula = , stationary = FALSE, Par0 = )










#chatgpt code about finding the best distribution
# List of distribution names
# List of distribution names
dist_names <- c("t", "norm", "cauchy", "lnorm", "genextreme", "logis")















