# ------------------
# cryptocurrencies data
# ------------------
library(tidyquant)
source('cryptocurrency-value-prediction/crypto_related_tweets.R')
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)

start_date <- "2021-04-28"
until_date <- "2022-04-10"

tickers = c("ETH-USD", "BTC-USD", "DOGE-USD")

# how to compute Volatility Index (VIX)
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

