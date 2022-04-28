# get crypto_related_tweets
setwd('/Users/daixinming/PycharmProjects/crypto_prediction/tweets')
library(tidyverse)
library(tidytext)
library(lubridate)

source('cryptocurrency-value-prediction/bag_of_words.R')

tweet_elon <- read_csv('data_tweets/tweet_elon.csv')

tweet_elon <- 
  tweet_elon %>% 
  select(-...1)

tweet_elon_token <- 
  tweet_elon %>% 
  unnest_tokens(words, text)

tweet_elon_crypto <- 
  tweet_elon_token %>% 
  filter(words %in% bag_of_words)

# write.csv(tweet_elon_crypto, 'data_tweets/tweet_elon_crypto.csv')

# count how many tweets related to cryptocurrencies that Elon tweeted
tweet <- 
  tweet_elon_crypto %>% 
  mutate(date = as_date(format(created_at, format = "%Y-%m-%d"))) %>% 
  group_by(date) %>% 
  mutate(num_tweets = n()) %>% 
  distinct(date, num_tweets)

