import pandas as pd

pd.set_option('display.max_columns', 4)
tweet_elon = pd.read_json('../data_tweets/tweet_elon.json')

# tweet_elon = tweet_elon.loc[tweet_elon['text']]
print(tweet_elon.head())
tweet_elon.to_csv('../data_tweets/tweet_elon.csv')