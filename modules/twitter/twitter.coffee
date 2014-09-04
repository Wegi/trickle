ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'

OAuth = require('oauth').OAuth
readline = require 'readline'
twitter_req = require 'twitter-request'
async = require 'async'

module.exports = (div_id, session) ->

    rl = readline.createInterface(process.stdin, process.stdout)
    oauth = new OAuth(
          "https://api.twitter.com/oauth/request_token",
          "https://api.twitter.com/oauth/access_token",
          consumer_key,
          new Buffer(ab64, 'base64').toString 'utf8',
          "1.0",
          "oob",
          "HMAC-SHA1"
        )

    authenticate = (callback) ->
        oauth.getOAuthRequestToken (error, user_token, user_secret, results) ->
            session.twitter.user_token = user_token
            session.twitter.user_secret = user_secret
            console.log('https://twitter.com/oauth/authenticate?oauth_token='+user_token)
            rl.question 'Please Enter the PIN: ', (PIN) ->
                rl.close()
                process.stdin.destroy()

                oauth.getOAuthAccessToken user_token, user_secret, PIN ,
                (error, oauth_access_token, oauth_access_token_secret, results) ->
                    if error
                        console.log(error)
                    else
                        session.twitter.access_token = oauth_access_token;
                        session.twitter.access_secret = oauth_access_token_secret;
                        callback null, oauth_access_token


    get_stream = (callback) ->
        readyoauth =
            consumer_key: consumer_key
            consumer_secret: consumerSecret
            token: session.twitter.access_token
            token_secret: session.twitter.access_secret

        treq = new twitter_req(readyoauth)
        query =
            #'screen_name': 'darealwegi'
            'count': 20

        treq.request 'statuses/home_timeline', query,
                     (err, res, body) ->
                        callback null, body


    if not session.twitter.access_token || not session.twitter.access_secret
        async.series {one: authenticate, two: get_stream}, (err, result) ->
            for item in JSON.parse result.two
                console.log item.text
    else
        get_stream (a, b) ->
            return null # placeholder
