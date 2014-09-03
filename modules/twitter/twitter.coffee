a = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumerSecret = new Buffer(a, 'base64').toString 'utf8'
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'

OAuth = require('oauth').OAuth
readline = require 'readline'
rl = readline.createInterface(process.stdin, process.stdout)

async = require 'async'

OAuth = require('oauth').OAuth
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


