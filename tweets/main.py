if __name__ == "__main__":
    from twitter_credentials import bearer_token, consumer_key, consumer_secret, access_token, access_token_secret
    from get_user_tweets import GetUserTweets

    get_tweets = GetUserTweets(bearer_token, consumer_key, consumer_secret, access_token, access_token_secret)
    user_id = '44196397'  # elon musk
    get_tweets.get_users_latest_tweets(user_id, since_id='1520645386427195392', max_results=100)
    print(get_tweets.tweets)