import tweepy
import __path
from twitter_credentials import bearer_token, consumer_key, consumer_secret, access_token, access_token_secret


# get user id
def get_user_id(user_name):
    """
    according to user name to get user id that is needed for getting tweets
    :param user_name: a list of user name
    :return: user id
    """

    client = tweepy.Client(bearer_token=bearer_token, consumer_key=consumer_key, consumer_secret=consumer_secret,
                           access_token=access_token, access_token_secret=access_token_secret)

    user_id = []
    for username in user_name:
        get_user = client.get_user(username=username)
        user_id.append(get_user.data.id)

    return user_id

# the below doesn't run when script is called via 'import'
if __name__ == '__main__':
    user_name = ['elonmusk', 'WSJmarkets']
    print(get_user_id(user_name))
