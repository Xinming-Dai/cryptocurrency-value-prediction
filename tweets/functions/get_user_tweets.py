import tweepy
import __path
from twitter_credentials import bearer_token, consumer_key, consumer_secret, access_token, access_token_secret


def get_users_tweets(user_id, max_results=5, until_id=None):
    """
    get tweets from a user with the oldest tweet_id
    :param user_id: a user id
    :param max_results: default 5 tweets
    :param until_id: the oldest tweet id. default is None.
    :return: tweets in dict structure
    """

    # authorize twitter, initialize
    client = tweepy.Client(bearer_token=bearer_token,
                           consumer_key=consumer_key,
                           consumer_secret=consumer_secret,
                           access_token=access_token,
                           access_token_secret=access_token_secret)

    request_time = 0  # the number of requests
    tweets = []
    i = 0

    while (request_time <= 100) & (i != 99):  # the maximum number of requests that you want to send

        if until_id == None:  # send request to get the latest tweets
            for i in range(0, 100):  # try to send maximum 100 request
                tweet = client.get_users_tweets(id=user_id,
                                                max_results=max_results,
                                                expansions='author_id',
                                                tweet_fields='created_at')

                if tweet.data != None:  # successfully get response
                    tweets.append(tweet)
                    until_id = tweets[-1].meta['oldest_id']  # update until_id as the oldest one

                    print('API responses in the %sth request' % (i + 1))
                    request_time = request_time + (i + 1)

                    break

                elif i == 99:  # if send 99 requests and still get no response, then break the loop
                    print('You have gotten the oldest tweet.')
                    break

        else:  # send request to get tweets older than the until_id
            if len(tweets) == 0:
                for i in range(0, 100):
                    tweet = client.get_users_tweets(id=user_id,
                                                    max_results=max_results,
                                                    until_id=until_id,
                                                    expansions='author_id',
                                                    tweet_fields='created_at')

                    if tweet.data != None:
                        tweets.append(tweet)

                        print('API responses in the %sth request' % (i + 1))
                        request_time = request_time + (i + 1)

                        break

                    elif i == 99:
                        print('You have gotten the oldest tweet.')
                        break
            else:
                until_id = tweets[-1].meta['oldest_id']
                for i in range(0, 100):
                    tweet = client.get_users_tweets(id=user_id,
                                                    max_results=max_results,
                                                    until_id=until_id,
                                                    expansions='author_id',
                                                    tweet_fields='created_at')

                    if tweet.data != None:
                        tweets.append(tweet)

                        print('API responses in the %sth request' % (i + 1))
                        request_time = request_time + (i + 1)

                        break

                    elif i == 99:
                        print('You have gotten the oldest tweet.')
                        break

    return (tweets)


# the below doesn't run when script is called via 'import'
if __name__ == '__main__':
    user_id = '44196397'  # elon musk
    tweets = get_users_tweets(user_id, max_results=5, until_id='1387892910960615428')
    print(tweets)
