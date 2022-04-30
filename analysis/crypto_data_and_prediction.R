# ------------------
# cryptocurrencies data
# ------------------
library(tidyquant)
library(ROCR)
library(forecast)
source('cryptocurrency-value-prediction/crypto_related_tweets.R')
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)

start_date <- "2021-04-28"
until_date <- "2022-04-10"

tickers = c("ETH-USD", "BTC-USD", "DOGE-USD")

# how to compute Volatility Index (VIX)?--------
# how to get volatility of S&P 500?---------
doge <- 
  tq_get("DOGE-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(doge = (close-open)/open) %>% 
  select(date, doge)

eth <- 
  tq_get("ETH-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(eth = (close-open)/open) %>% 
  select(date, eth)

btc <- 
  tq_get("BTC-USD",
         from = start_date,
         to = until_date,
         get = "stock.prices") %>% 
  mutate(btc = (close-open)/open) %>% 
  select(date, btc)
  
doge <- 
  doge %>% 
  left_join(eth) %>% 
  left_join(btc) %>% 
  left_join(tweet) %>% 
  mutate(num_tweets = replace_na(num_tweets, 0))

# attempt to fit a model,without split train and test---------------
## simple linear regression-----------
slr <- lm(doge ~ eth + btc + num_tweets, data = doge)
summary(slr)

## logistic regression-----------
### AUC = 0.6790507------------
doge_log <- 
  doge %>% 
  mutate(doge = ifelse(abs(doge) > 0.1, 1, 0))

logistic <- glm(doge ~ eth + btc + num_tweets, data = doge_log, family = 'binomial')
summary(logistic)

# make prediction
logistic_prob <- predict(logistic, doge_log)

# AUC
logistic_pred <- prediction(logistic_prob, doge_log$doge)
logisitc_performace <- performance(logistic_pred, 'auc')
cat('The AUC score of the logisitc is ', logisitc_performace@y.values[[1]], "\n")

## ARIMA(p, d, q)-----------
# p =  order of the autoregressive part;
# d = degree of first differencing involved;
# q =  order of the moving average part.
p = 3; d = 0; q = 3
fit_arima <- auto.arima(doge$doge, max.p = p, 
                        max.q = q, max.d = d)

plot(fit_arima$x,col="red")
lines(fitted(fit_arima),col="blue")


