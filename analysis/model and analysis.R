source('C:/Users/wangy/Desktop/MDML/helper.R')
library(ggplot2)
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)


# Part I: Using tweets relates to cryptocurrency to build model and make prediction(easy model)-------------------------------------------------------------

# crypto data from 2021-04-28 to 2022-04-26
start_date <- "2021-04-28"
end_date <- "2022-04-26"

# we want those three companies' cryptocurrency data
tickers = c("ETH-USD", "BTC-USD", "DOGE-USD", "USDT-USD", "SOL-USD", "BCH-USD")

# we set the outcome be 1 if the daily the absolute return is greater than or equal to 5%, 0 otherwise
# For each company, use tq_get() to obtain their stock price from 2021-04-28 to 2022-04-26
# then compute the difference between their open value and close value 
eth <- 
  tq_get("ETH-USD",
         from = start_date,
         to = end_date,
         get = "stock.prices") %>% 
  mutate(eth_returns = pc_col(adjusted)) %>% 
  mutate(eth = ifelse(abs(eth_returns) < 5, 0, 1)) %>% 
  dplyr::select(date, eth_returns, eth)

doge <- 
  tq_get("DOGE-USD",
         from = start_date,
         to = end_date,
         get = "stock.prices") %>% 
  mutate(doge = pc_col(adjusted)) %>% 
  mutate(doge = ifelse(abs(doge) < 5, 0, 1)) %>% 
  dplyr:: select(date, doge)

btc <- 
  tq_get("BTC-USD",
         from = start_date,
         to = end_date,
         get = "stock.prices") %>% 
  mutate(btc = pc_col(adjusted)) %>% 
  mutate(btc = ifelse(abs(btc) < 5, 0, 1)) %>% 
  dplyr::select(date, btc)

sol <- 
  tq_get("SOL-USD",
         from = start_date,
         to = end_date,
         get = "stock.prices") %>% 
  mutate(sol = pc_col(adjusted)) %>% 
  mutate(sol = ifelse(abs(sol) < 5, 0, 1)) %>% 
  dplyr::select(date, sol)

bch <- 
  tq_get("BCH-USD",
         from = start_date,
         to = end_date,
         get = "stock.prices") %>% 
  mutate(bch = pc_col(adjusted)) %>% 
  mutate(bch = ifelse(abs(bch) < 5, 0, 1)) %>% 
  dplyr::select(date, bch)

# finally, we join them together with the number of tweets that elon musk post (those only relates to cryptocurrency)
eth <- 
  eth %>% 
  left_join(doge) %>% 
  left_join(btc) %>% 
  left_join(tweet) %>% 
  left_join(sol) %>% 
  left_join(bch) %>% 
  mutate(num_tweets = replace_na(num_tweets, 0))
eth <- eth[-1, ]

## Simple logistic regression---------------------------------------------------------------
# we first fit the model with a simple logistic regression and calculate its AUC score

# fit a logistic regression 
logistic <- glm(eth ~ doge + btc + sol + bch + num_tweets, data = eth, family = 'binomial')
summary(logistic)

# make prediction for simple logistic regression and logi with interaction terms
logistic_prob <- predict(logistic, eth_log)

# AUC
logistic_pred <- prediction(logistic_prob, eth_log$eth)
logisitc_performace <- performance(logistic_pred, 'auc')
cat('The AUC score of the simple logisitc is ', logisitc_performace@y.values[[1]], "\n")

# plot tweets and returns
eth_plot <- 
  eth %>% 
  mutate(eth = ifelse(abs(eth_returns) < 5, 0, abs(eth_returns))/3)

p1 <- 
  ggplot(data = eth_plot, aes(x = date)) +
  geom_line(aes(y = eth, colour = "eth_abs_returns/3")) +
  geom_line(aes(y = num_tweets, colour = "num_tweets")) +
  scale_colour_manual("", 
                      breaks = c("eth_abs_returns/3", "num_tweets"),
                      values = c("blue", "red"))
p1

ggsave(plot = p1, file = '../figures/tweets_and_returns.png', height = 5, width = 10)

# Part II: Introducing time series in order to do a better fit (complex models)-----------------------------------------------------

