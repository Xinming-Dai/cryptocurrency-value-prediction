crypto_word_bag = ['blockchain', 'coin', 'coinbase', 'cryptocurrency', 'cryptocurrencies',
                   'decentralization', 'defi',
                   'altcoin', 'altcoins', 'bitcoin', 'bitcoins', 'Ethereum', 'dogecoin', 'dogecoins', 'cardano',
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
                   'binance', 'U+1F415']

def word_extraction(sentence):
    ignore = ['a', "the", "is"]
    words = re.sub("[^\w]", " ",  sentence).split()
    cleaned_text = [w.lower() for w in words if w not in ignore]
    return cleaned_text
