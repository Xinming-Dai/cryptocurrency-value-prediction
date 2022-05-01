import json
from get_user_tweets import get_users_tweets, get_users_latest_tweets


def store_tweets_in_json(tweets):
    """
    convert tweets obtained from get_users_tweets() to json
    :param tweets:
    :return: tweets in json format
    """

    results = []

    for every_tweet in tweets:
        for tweet in every_tweet.data:
            obj = {}
            obj['author_id'] = tweet.author_id
            obj['tweet_id'] = tweet.id
            obj['text'] = tweet.text
            obj['created_at'] = tweet.created_at.isoformat().replace('+00:00', 'Z')
            results.append(obj)

    return results


# the below doesn't run when script is called via 'import'
if __name__ == '__main__':
    user_id = '44196397'  # elon musk
    tweets = get_users_latest_tweets(user_id, since_id='1513288055146225671', max_results=100)
    print(tweets)
    results = store_tweets_in_json(tweets)

    with open('../data_tweets/newest_tweets.json', 'a') as f:
        json.dump(results, f, indent=4)
