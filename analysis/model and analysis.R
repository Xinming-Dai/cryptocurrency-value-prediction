source('C:/Users/wangy/Desktop/MDML/helper.R')
library(ggplot2)
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)


# Part I: Using tweets relates to cryptocurrency to build model and make prediction(easy model)-------------------------------------------------------------

# crypto data from 2021-04-28 to 2022-04-10
start_date <- "2021-04-28"
until_date <- "2022-04-10"

# we want those three companies' cryptocurrency data
tickers = c("ETH-USD", "BTC-USD", "DOGE-USD")


# For each company, use tq_get() to obtain their stock price from 2021-04-28 to 2022-04-10
# then compute the difference between their open value and close value 
doge <- 
  tq_get("DOGE-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(doge = (close-open)/open) %>% 
 dplyr:: select(date, doge)

eth <- 
  tq_get("ETH-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(eth = (close-open)/open) %>% 
  dplyr::select(date, eth)

btc <- 
  tq_get("BTC-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(btc = (close-open)/open) %>% 
  dplyr::select(date, btc)

# finally, we join them together with the number of tweets that elon musk post (those only relates to cryptocurrency)
doge <- 
  doge %>% 
  left_join(eth) %>% 
  left_join(btc) %>% 
  left_join(tweet) %>% 
  mutate(num_tweets = replace_na(num_tweets, 0))

## Simple logistic regression---------------------------------------------------------------
# we first fit the model with a simple logistic regression and calculate its AUC score
# we set the outcome be 1 if the daily return(close-open) is greater than 0.1, 0 otherwise
doge_log <- 
  doge %>% 
  mutate(doge = ifelse(abs(doge) > 0.1, 1, 0))

# fit a logistic regression 
logistic <- glm(doge ~ eth + btc + num_tweets, data = doge_log, family = 'binomial')
summary(logistic)

# fit a logistic regression with interaction terms 
logistic_inter <- glm(doge ~ eth + btc + num_tweets + eth*num_tweets + btc*num_tweets, data = doge_log, 
                  family = 'binomial')
summary(logistic_inter)

# make prediction for simple logistic regression and logi with interaction terms
logistic_prob <- predict(logistic, doge_log)
logistic_inter_prob <- predict(logistic_inter, doge_log)

# AUC
logistic_pred <- prediction(logistic_prob, doge_log$doge)
logistic_inter_pred <- prediction(logistic_inter_prob, doge_log$doge)
logisitc_performace <- performance(logistic_pred, 'auc')
logistic_inter_performace <- performance(logistic_inter_pred, 'auc')
cat('The AUC score of the simple logisitc is ', logisitc_performace@y.values[[1]], "\n")
cat('The AUC score of the logisitc with interaction term is ', logistic_inter_performace@y.values[[1]], "\n")

# Part II: Introducing time series in order to do a better fit (complex models)-----------------------------------------------------

