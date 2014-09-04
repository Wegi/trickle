a = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumerSecret = new Buffer(a, 'base64').toString 'utf8'
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'

OAuth = require('oauth').OAuth
readline = require 'readline'
twitter_req = require 'twitter-request'
async = require 'async'

rl = readline.createInterface(process.stdin, process.stdout)
oauth = new OAuth(
      "https://api.twitter.com/oauth/request_token",
      "https://api.twitter.com/oauth/access_token",
      consumer_key,
      consumerSecret,
      "1.0",
      "oob",
      "HMAC-SHA1"
    )

token = ''
token_secret = ''
access_token = ''
access_secret = ''

first = (callback) ->
    oauth.getOAuthRequestToken (error, user_token, user_secret, results) ->
        token = user_token
        token_secret = user_secret
        console.log('https://twitter.com/oauth/authenticate?oauth_token='+user_token)
        rl.question 'Please Enter the PIN: ', (PIN) ->
            rl.close()
            process.stdin.destroy()

            oauth.getOAuthAccessToken token, token_secret, PIN ,
            (error, oauth_access_token, oauth_access_token_secret, results) ->
                if error
                    console.log(error)
                else
                    access_token = oauth_access_token;
                    access_secret = oauth_access_token_secret;
                    console.log("Alles Tutti: "+access_token);
                    callback null, access_token


second = (callback) ->
    readyoauth =
        consumer_key: consumer_key
        consumer_secret: consumerSecret
        token: access_token
        token_secret: access_secret

    treq = new twitter_req(readyoauth)
    query =
        #'screen_name': 'darealwegi'
        'count': 20

    treq.request 'statuses/home_timeline', query,
                 (err, res, body) ->
                    callback null, body

async.series {one: first, two: second}, (err, result) ->
    for item in JSON.parse result.two
        console.log item.text

