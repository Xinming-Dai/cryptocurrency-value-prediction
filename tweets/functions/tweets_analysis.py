import pandas as pd

# pd.set_option('display.max_columns', 4)
# newest_tweets = pd.read_json('../data_tweets/newest_tweets.json')
#
# # tweet_elon = tweet_elon.loc[tweet_elon['text']]
# print(newest_tweets.head())


# concat the newest tweets and the old tweets
tweet_elon = pd.read_csv('../data_tweets/tweet_elon.csv')
newest_tweets = pd.read_csv('../data_tweets/newest_tweets.csv')
frames = [newest_tweets, tweet_elon]
tweets = pd.concat(frames)
tweets = tweets.drop(columns=['Unnamed: 0'])
print(tweets)
tweets.to_csv('../data_tweets/tweets.csv')
