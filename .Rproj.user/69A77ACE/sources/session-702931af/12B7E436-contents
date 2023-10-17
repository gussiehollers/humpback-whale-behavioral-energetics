#HMM DEMO
library(fitdistrplus)
library(momentuHMM)
library(data.table)

# phils attempt 

# read in the data 
all_other = read.csv('all_other.csv')
all_rest = read.csv('all_rest.csv')
all_travel = read.csv('all_travel.csv')

# rename the columns 
col_names = c('date_no', 'avg_speed', 'mean_resultant_length', 
              'max_depth', 'msa')
names(all_other) = col_names
names(all_rest) = col_names
names(all_travel) = col_names

# look at distribution of all data
par(mfrow=c(1,1))
all_all = rbind(all_rest, all_travel, all_other)
hist(all_all$avg_speed, breaks=30)

# calculate parameters for gamma dist 
moment_match_gamma <- function(mu, sigma){
  # sigma is the standard deviation
  alpha = (mu ^ 2) / (sigma ^ 2)
  beta = mu / (sigma ^ 2)
  parameters = c(alpha, beta)
  names(parameters) = c('alpha', 'beta')
  parameters
}

# calculate the parameters for the travel state
travel_params = moment_match_gamma(
  mean(all_travel$avg_speed), 
  sd(all_travel$avg_speed)
)

# subplots
par(mfrow = c(2, 1))

# histogram for travel 
hist(all_travel$avg_speed, probability = TRUE, breaks=20, main = 'Travel', 
     xlim=c(0, max(all_travel$avg_speed)), xlab='')

# vertical line for mean
abline(v=mean(all_travel$avg_speed), col='red', lwd=2)

# curve for estimated gamma
curve(dgamma(x, travel_params['alpha'], travel_params['beta']), 
      add = T, col = 'blue', lwd = 2)

# ditto as above but for rest 
hist(all_rest$avg_speed, probability = TRUE, breaks=20, main = 'Rest',
     xlim=c(0, max(all_travel$avg_speed)))

rest_params = moment_match_gamma(
  mean(all_rest$avg_speed), 
  sd(all_rest$avg_speed)
)
abline(v=mean(all_rest$avg_speed), col='red', lwd=2)
curve(dgamma(x, rest_params['alpha'], rest_params['beta']), 
      add = T, col = 'blue', lwd = 2)


# simulate rest data from parameters
n_rest = nrow(all_rest)
sim_rest = rgamma(n_rest, rest_params['alpha'], rest_params['beta'])

# simulate travel data from parameters
n_travel = nrow(all_travel)
sim_travel = rgamma(n_travel, travel_params['alpha'], travel_params['beta'])

xlim = c(0, max(all_travel$avg_speed))

par(mfrow=c(2, 2))
hist(all_travel$avg_speed, breaks=30, xlim=xlim)
hist(all_rest$avg_speed, breaks=30, xlim=xlim)
hist(sim_travel, breaks=30, xlim=xlim)
hist(sim_rest, breaks=30, xlim=xlim)


#try the HMM on the simulated speed data
sim_speed<- c(sim_travel, sim_rest)
#does it matter the sequence of observations? that I'm putting all the travel data and then all the rest data?
combined_sim_speeds <- data.frame(avg_speed = sim_speed)

sim_data<- prepData(combined_sim_speeds, type='LL', coordNames=NULL)
dist1<-list(avg_speed="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par01 <- list(avg_speed= c(rest_params['alpha'],travel_params['alpha'] , rest_params['beta'], travel_params['beta']))

stateNames1 <- c("traveling","resting")

sim_test1_speed <- fitHMM(sim_data, nbStates=2, dist=dist1, Par0=Par01, stateNames=stateNames1)
print(sim_test1_speed)

states <- viterbi(sim_test1_speed) #well that didn't really work
plot(sim_test1_speed, plotCI = TRUE, breaks=30)



#try the HMM on the real speed data 
all_speed<- c(all_travel$avg_speed, all_rest$avg_speed)
combined_avg_speeds <- data.frame(avg_speed = all_speed)

pD<- prepData(combined_avg_speeds, type='LL', coordNames=NULL)
dist<-list(avg_speed="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par0 <- list(avg_speed= c(rest_params['alpha'],travel_params['alpha'] , rest_params['beta'], travel_params['beta']))

stateNames <- c("traveling","resting")

test1_speed <- fitHMM(pD, nbStates=2, dist=dist, Par0=Par0, stateNames=stateNames)
print(test1_speed)

states <- viterbi(test1_speed)
table(states)/nrow(pD) #well that didn't really work
plot(test1_speed, plotCI = TRUE, breaks=30)

#the simulated data model results look pretty different to the real results?

#trying a model for ALL speed values with 2 states
total_speed<- c(all_travel$avg_speed, all_other$avg_speed, all_rest$avg_speed)
total_avg_speeds <- data.frame(avg_speed = total_speed)

total_speed_data<- prepData(total_avg_speeds, type='LL', coordNames=NULL)
dist<-list(avg_speed="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par0 <- list(avg_speed= c(rest_params['alpha'],travel_params['alpha'] , rest_params['beta'], travel_params['beta']))

stateNames <- c("traveling","resting")

test_total_speed <- fitHMM(total_speed_data, nbStates=2, dist=dist, Par0=Par0, stateNames=stateNames)
print(test_total_speed)

states <- viterbi(test_total_speed)
table(states)/nrow(total_speed_data) 
plot(test_total_speed, plotCI = TRUE, breaks=30)
#max log likelihood is -89.78344


#try it with 3 states, compare log likelihood
other_params = moment_match_gamma(
  mean(all_other$avg_speed), 
  sd(all_other$avg_speed)
)

Par05 <- list(avg_speed= c(rest_params['alpha'],travel_params['alpha'], other_params['alpha'], rest_params['beta'], travel_params['beta'], other_params['beta']))

stateNames5 <- c("traveling","resting", "other")
test_3st_total_speed <- fitHMM(total_speed_data, nbStates=3, dist=dist, Par0=Par05, stateNames=stateNames5)
print(test_3st_total_speed)
plot(test_3st_total_speed, plotCI = TRUE, breaks=30)
#max log likelihood -11.46294 

AIC(test_total_speed, test_3st_total_speed, k = 2, n = NULL)
#Model       AIC
# 1 test_3st_total_speed  50.92589
# 2     test_total_speed 193.56687
# so with 3 states, the AIC is a lot lower, so a better model 

AICweights(test_total_speed, test_3st_total_speed, k = 2, n = NULL)

#                 Model       weight
#1 test_3st_total_speed 1.000000e+00
#2     test_total_speed 1.061458e-31
#so i think the 3 state model is best for the speed data







########################## MRL DATA ####################################################

#look at the mean resultant length distributions
par(mfrow=c(1,1))
all_all = rbind(all_rest, all_travel, all_other)
hist(all_all$mean_resultant_length, breaks=30)

moment_match_beta <- function(mu, var){
  # var is the variance
  alpha = ((1 - mu) / var - 1 / mu) * mu ^ 2
  beta = alpha * (1 / mu - 1)
  parameters = c(alpha, beta)
  names(parameters) = c('alpha', 'beta')
  parameters
}

travel_mrl_params = moment_match_beta(
  mean(all_travel$mean_resultant_length), 
  var(all_travel$mean_resultant_length)
)

rest_mrl_params = moment_match_beta(
  mean(all_rest$mean_resultant_length), 
  var(all_rest$mean_resultant_length)
)


par(mfrow = c(2, 1))
hist(all_travel$mean_resultant_length, probability = TRUE, breaks=20, main = 'Travel', 
     xlim=c(0, max(all_travel$mean_resultant_length)), xlab='')

# vertical line for mean
abline(v=mean(all_travel$mean_resultant_length), col='red', lwd=2)

# curve for estimated beta
curve(dbeta(x, travel_mrl_params['alpha'], travel_mrl_params['beta']), 
      add = T, col = 'blue', lwd = 2)

# ditto as above but for rest 
hist(all_rest$mean_resultant_length, probability = TRUE, breaks=20, main = 'Rest',
     xlim=c(0, max(all_travel$mean_resultant_length)))

abline(v=mean(all_rest$mean_resultant_length), col='red', lwd=2)

curve(dbeta(x, rest_mrl_params['alpha'], rest_mrl_params['beta']), 
      add = T, col = 'blue', lwd = 2)


# simulate rest data from parameters
n_rest = nrow(all_rest)
sim_mrl_rest = rbeta(n_rest, rest_mrl_params['alpha'], rest_mrl_params['beta'])

# simulate travel data from parameters
n_travel = nrow(all_travel)
sim_mrl_travel = rbeta(n_travel, travel_mrl_params['alpha'], travel_mrl_params['beta'])

xlim = c(0, max(all_travel$mean_resultant_length))

par(mfrow=c(2, 2))
hist(all_travel$mean_resultant_length, breaks=30, xlim=xlim)
hist(all_rest$mean_resultant_length, breaks=30, xlim=xlim)
hist(sim_mrl_travel, breaks=30, xlim=xlim)
hist(sim_mrl_rest, breaks=30, xlim=xlim)


#try the HMM on the simulated mrl data
sim_mrl<- c(sim_mrl_travel, sim_mrl_rest)
#does it matter the sequence of observations? that I'm putting all the travel data and then all the rest data?
combined_sim_mrl <- data.frame(mrl = sim_mrl)

sim_mrl_data<- prepData(combined_sim_mrl, type='LL', coordNames=NULL)
dist2<-list(mrl="beta")

#has to be in the form mean1, mean2, sd1, sd2
Par02 <- list(mrl= c(rest_mrl_params['alpha'],travel_mrl_params['alpha'] , rest_mrl_params['beta'], travel_mrl_params['beta']))

stateNames2 <- c("traveling","resting")

sim_test2_mrl <- fitHMM(sim_mrl_data, nbStates=2, dist=dist2, Par0=Par02, stateNames=stateNames2)
print(sim_test2_mrl)

states <- viterbi(sim_test2_mrl)
plot(sim_test2_mrl, plotCI = TRUE, breaks=30)


#try the HMM on the real mrl data 
all_mrl<- c(all_travel$mean_resultant_length, all_rest$mean_resultant_length)
combined_mrl <- data.frame(mrl = all_mrl)

mrl_data<- prepData(combined_mrl, type='LL', coordNames=NULL)
dist3<-list(mrl="beta")

#has to be in the form mean1, mean2, sd1, sd2
Par03 <- list(mrl= c(rest_mrl_params['alpha'],travel_mrl_params['alpha'] , rest_mrl_params['beta'], travel_mrl_params['beta']))

stateNames3 <- c("traveling","resting")

test2_mrl <- fitHMM(mrl_data, nbStates=2, dist=dist3, Par0=Par03, stateNames=stateNames3)
print(test2_mrl)

states <- viterbi(test2_mrl)
table(states)/nrow(mrl_data) #well that didn't really work
plot(test2_mrl, plotCI = TRUE, breaks=30)








#####DEPTH DATA ##################################################################
#look at the max depth distributions
par(mfrow=c(1,1))
hist(all_all$max_depth, breaks=30) #looks like a gamma distribution unimodal

travel_depth_params = moment_match_gamma(
  mean(all_travel$max_depth), 
  sd(all_travel$max_depth)
)

rest_depth_params = moment_match_gamma(
  mean(all_rest$max_depth), 
  sd(all_rest$max_depth)
)


par(mfrow = c(2, 1))
hist(all_travel$max_depth, probability = TRUE, breaks=20, main = 'Travel', 
     xlim=c(0, max(all_travel$max_depth)), xlab='')

# vertical line for mean
abline(v=mean(all_travel$max_depth), col='red', lwd=2)

# curve for estimated gamma
curve(dgamma(x, travel_depth_params['alpha'], travel_depth_params['beta']), 
      add = T, col = 'blue', lwd = 2)

# ditto as above but for rest 
hist(all_rest$max_depth, probability = TRUE, breaks=20, main = 'Rest',
     xlim=c(0, max(all_travel$max_depth)))

abline(v=mean(all_rest$max_depth), col='red', lwd=2)

curve(dgamma(x, rest_depth_params['alpha'], rest_depth_params['beta']), 
      add = T, col = 'blue', lwd = 2)
#ok they don't look that different... but maybe they are

# simulate rest data from parameters
n_rest = nrow(all_rest)
sim_depth_rest = rgamma(n_rest, rest_depth_params['alpha'], rest_depth_params['beta'])

# simulate travel data from parameters
n_travel = nrow(all_travel)
sim_depth_travel = rgamma(n_travel, travel_depth_params['alpha'], travel_depth_params['beta'])

xlim = c(0, max(all_travel$max_depth))

par(mfrow=c(2, 2))
hist(all_travel$max_depth, breaks=30, xlim=xlim)
hist(all_rest$max_depth, breaks=30, xlim=xlim)
hist(sim_depth_travel, breaks=30, xlim=xlim)
hist(sim_depth_rest, breaks=30, xlim=xlim)


#try the HMM on the simulated depth data
sim_depth<- c(sim_depth_travel, sim_depth_rest)
#does it matter the sequence of observations? that I'm putting all the travel data and then all the rest data?
combined_sim_depth<- data.frame(max_depth = sim_depth)

sim_depth_data<- prepData(combined_sim_depth, type='LL', coordNames=NULL)
dist6<-list(max_depth="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par06 <- list(max_depth= c(rest_depth_params['alpha'],travel_depth_params['alpha'] , rest_depth_params['beta'], travel_depth_params['beta']))

stateNames6 <- c("traveling","resting")

sim_test2_depth <- fitHMM(sim_depth_data, nbStates=2, dist=dist6, Par0=Par06, stateNames=stateNames6)
print(sim_test2_depth)

states <- viterbi(sim_test2_depth)
plot(sim_test2_depth, plotCI = TRUE, breaks=30)
#well that actually worked on the sim data

#try the HMM on the real depth data 
all_depth<- c(all_travel$max_depth, all_rest$max_depth)
combined_depth <- data.frame(max_depth = all_depth)

depth_data<- prepData(combined_depth, type='LL', coordNames=NULL)
dist7<-list(max_depth="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par07 <- list(max_depth= c(rest_depth_params['alpha'],travel_depth_params['alpha'] , rest_depth_params['beta'], travel_depth_params['beta']))

stateNames7 <- c("traveling","resting")

test2_depth <- fitHMM(depth_data, nbStates=2, dist=dist7, Par0=Par07, stateNames=stateNames7)
print(test2_depth)

states <- viterbi(test2_depth)
table(states)/nrow(depth_data) #well that didn't really work
plot(test2_depth, plotCI = TRUE, breaks=30)
#that actually looks pretty good as well, now I have to find a way to combine all the streams into one model







#################################### MINIMUM SPECIFIC ACCELERATION #######################################
par(mfrow=c(1,1))
hist(all_all$msa, breaks=30) #looks like a gamma distribution unimodal

travel_msa_params = moment_match_gamma(
  mean(all_travel$msa), 
  sd(all_travel$msa)
)

rest_msa_params = moment_match_gamma(
  mean(all_rest$msa), 
  sd(all_rest$msa)
)


par(mfrow = c(2, 1))
hist(all_travel$msa, probability = TRUE, breaks=20, main = 'Travel', 
     xlim=c(0, max(all_travel$msa)), xlab='')

# vertical line for mean
abline(v=mean(all_travel$msa), col='red', lwd=2)

# curve for estimated gamma
curve(dgamma(x, travel_msa_params['alpha'], travel_msa_params['beta']), 
      add = T, col = 'blue', lwd = 2)

# ditto as above but for rest 
hist(all_rest$msa, probability = TRUE, breaks=20, main = 'Rest',
     xlim=c(0, max(all_travel$msa)))

abline(v=mean(all_rest$msa), col='red', lwd=2)

curve(dgamma(x, rest_msa_params['alpha'], rest_msa_params['beta']), 
      add = T, col = 'blue', lwd = 2)
#ok they don't look that different... but maybe they are

# simulate rest data from parameters
n_rest = nrow(all_rest)
sim_msa_rest = rgamma(n_rest, rest_msa_params['alpha'], rest_msa_params['beta'])

# simulate travel data from parameters
n_travel = nrow(all_travel)
sim_msa_travel = rgamma(n_travel, travel_msa_params['alpha'], travel_msa_params['beta'])

xlim = c(0, max(all_travel$msa))

par(mfrow=c(2, 2))
hist(all_travel$msa, breaks=30, xlim=xlim)
hist(all_rest$msa, breaks=30, xlim=xlim)
hist(sim_msa_travel, breaks=30, xlim=xlim)
hist(sim_msa_rest, breaks=30, xlim=xlim)


#try the HMM on the simulated msa data
sim_msa<- c(sim_msa_travel, sim_msa_rest)
#does it matter the sequence of observations? that I'm putting all the travel data and then all the rest data?
combined_sim_msa<- data.frame(msa = sim_msa)

sim_msa_data<- prepData(combined_sim_msa, type='LL', coordNames=NULL)
dist8<-list(msa="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par08 <- list(msa= c(rest_msa_params['alpha'],travel_msa_params['alpha'] , rest_msa_params['beta'], travel_msa_params['beta']))

stateNames8 <- c("traveling","resting")

sim_test2_msa<- fitHMM(sim_msa_data, nbStates=2, dist=dist8, Par0=Par08, stateNames=stateNames8)
print(sim_test2_msa)

states <- viterbi(sim_test2_msa)
par(mfrow=c(4,2))
plot(sim_test2_msa, plotCI = TRUE, breaks=30)
#DID NOT WORK????

#try the HMM on the real msa data 
all_msa<- c(all_travel$msa, all_rest$msa)
combined_msa <- data.frame(msa = all_msa)

msa_data<- prepData(combined_msa, type='LL', coordNames=NULL)
dist9<-list(msa="gamma")

#has to be in the form mean1, mean2, sd1, sd2
Par09 <- list(msa= c(rest_msa_params['alpha'],travel_msa_params['alpha'] , rest_msa_params['beta'], travel_msa_params['beta']))

stateNames7 <- c("traveling","resting")

test2_msa <- fitHMM(msa_data, nbStates=2, dist=dist9, Par0=Par09, stateNames=stateNames7)
print(test2_msa)

states <- viterbi(test2_msa)
table(states)/nrow(msa_data) #well that didn't really work
plot(test2_msa, plotCI = TRUE, breaks=30)

#the model didn't really converge, so maybe MSA is not a great summary statistic for traveling v resting?








####################### MUltivariate HMMS ###########################################

#fit a model with the average speed, mean resultant length, and the max depth. 
var3_test<-all_all[,c(2,3,4)]

var3_test_data<-prepData(var3_test, type='LL',coordNames = NULL)

dist<-list(avg_speed="gamma",mean_resultant_length="beta",max_depth="gamma")

Par0 <- list( avg_speed=c(rest_params['alpha'],travel_params['alpha'] , rest_params['beta'], travel_params['beta']),
              mean_resultant_length= c(rest_mrl_params['alpha'],travel_mrl_params['alpha'] , rest_mrl_params['beta'], travel_mrl_params['beta']), 
              max_depth=c(rest_depth_params['alpha'], travel_depth_params['alpha'], rest_depth_params['beta'], travel_depth_params['beta']))

stateNames <- c("traveling","resting")

test_3vars <- fitHMM(var3_test_data, nbStates=2, dist=dist, Par0=Par0, stateNames=stateNames)
print(test_3vars)

par(mfrow=c(3,2))
plot(test_3vars, plotCI = TRUE, breaks=30, sepStates=TRUE, ask=TRUE)

states <- viterbi(test_3vars)
table(states)/nrow(var3_test_data)
#it worked pretty well!
#log-likelihood: -862.7959

#now trying it with three states, see if it is better
#have to find the parameter estimates for the "other" state

other_params = moment_match_gamma(
  mean(all_other$avg_speed), 
  sd(all_other$avg_speed)
)

other_mrl_params = moment_match_beta(
  mean(all_other$mean_resultant_length), 
  var(all_other$mean_resultant_length)
)

other_depth_params = moment_match_gamma(
  mean(all_other$max_depth), 
  sd(all_other$max_depth)
)

dist<-list(avg_speed="gamma",mean_resultant_length="beta",max_depth="gamma") #same as before
Par0 <- list( avg_speed=c(rest_params['alpha'],travel_params['alpha'] , other_params['alpha'], rest_params['beta'], travel_params['beta'], other_params['beta']),
              mean_resultant_length= c(rest_mrl_params['alpha'],travel_mrl_params['alpha'], other_mrl_params['alpha'], rest_mrl_params['beta'], travel_mrl_params['beta'], other_mrl_params['beta']), 
              max_depth=c(rest_depth_params['alpha'], travel_depth_params['alpha'],other_depth_params['alpha'],  rest_depth_params['beta'], travel_depth_params['beta'], other_depth_params['beta']))

stateNames <- c("traveling", "other", "resting")

test_3vars_3st <- fitHMM(var3_test_data, nbStates=3, dist=dist, Par0=Par0, stateNames=stateNames)
print(test_3vars_3st)
plot(test_3vars_3st, plotCI = TRUE, breaks=30, sepStates=TRUE, ask=TRUE)
#log-likelihood: -659.3679 

AIC(test_3vars, test_3vars_3st, k = 2, n = NULL)
# 1 test_3vars_3st 1370.736
#2      test_3vars 1755.592

AICweights(test_3vars, test_3vars_3st, k = 2, n = NULL)
#1 test_3vars_3st 1.000000e+00
#2     test_3vars 2.688841e-84
#so the one with three states is better supported by the models


#could I try with 4 states? 







#seeing if my variables are correlated with each other
correlation_matrix <- cor(var3_test_data[,c(2,3,4)], method = "pearson")
print(correlation_matrix)
#so max_depth and average speed are pretty correlated (.08-0.9) but this kind of makes sense to me
#is this a problem?
getPar0(test_3vars_3st)


     