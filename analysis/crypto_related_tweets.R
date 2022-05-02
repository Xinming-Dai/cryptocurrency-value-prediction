# get crypto_related_tweets
library(tidyverse)
library(tidytext)
library(lubridate)

# bag of words related to cryptos----------------------
bag_of_words <- c('blockchain', 'coin', 'coinbase', 'cryptocurrency', 'cryptocurrencies',
                  'decentralization', 'defi',
                  'altcoin', 'altcoins', 'bitcoin', 'bitcoins', 'ethereum', 'ethereums', 'dogecoin', 'dogecoins', 'cardano',
                  'exchange', 'nft', 'nfts',
                  'btc', '#btc', '$btc',
                  'xbt', '#xbt', '$xbt',
                  'eth', '#eth', '$eth',
                  'doge', '#doge', '$doge',
                  'bnb', '#bnb', '$bnb',
                  'ada', '#ada', '$ada',
                  'xpr', '#xpr', '$xpr',
                  'dash', '#dash', '$dash',
                  'satoshi', 'nakamoto',
                  'binance', 'U+1F415')

tweet_elon <- read_csv('../tweets/data_tweets//tweet_elon.csv')

tweet_elon <- 
  tweet_elon %>% 
  select(-...1)

tweet_elon_token <- 
  tweet_elon %>% 
  unnest_tokens(words, text)

tweet_elon_crypto <- 
  tweet_elon_token %>% 
  filter(words %in% bag_of_words)

write.csv(tweet_elon_crypto, '../tweets/data_tweets/tweet_elon_crypto.csv')

# count how many tweets related to cryptocurrencies that Elon tweeted
tweet <- 
  tweet_elon_crypto %>% 
  mutate(date = as_date(format(created_at, format = "%Y-%m-%d"))) %>% 
  group_by(date) %>% 
  mutate(num_tweets = n_distinct(tweet_id)) %>% 
  distinct(date, num_tweets)

