# get crypto_related_tweets
setwd('/Users/daixinming/PycharmProjects/crypto_prediction/tweets')
library(tidyverse)
library(tidytext)
source('analysis/bag_of_words.R')

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

write.csv(tweet_elon_crypto, 'data_tweets/tweet_elon_crypto.csv')