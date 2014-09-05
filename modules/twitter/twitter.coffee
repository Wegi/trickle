ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'
consumeSecret = new Buffer(ab64, 'base64').toString 'utf8'

OAuth = require('oauth').OAuth
readline = require 'readline'
twitter_req = require 'twitter-request'
async = require 'async'
$ = require 'jquery'
gui = window.require 'nw.gui'

module.exports = (div_id, session) ->

    rl = readline.createInterface(process.stdin, process.stdout)
    oauth = new OAuth(
          "https://api.twitter.com/oauth/request_token",
          "https://api.twitter.com/oauth/access_token",
          consumer_key,
          consumeSecret,
          "1.0",
          "oob",
          "HMAC-SHA1"
        )

    authenticate = (callback) ->
        oauth.getOAuthRequestToken (error, user_token, user_secret, results) ->
            session.twitter.user_token = user_token
            session.twitter.user_secret = user_secret
            link = 'https://twitter.com/oauth/authenticate?oauth_token='+user_token
            query_html = """
<form role="form" autocomplete="on">
  <div class="form-group">
    <label>Please visit the following Link and enter the PIN.<br><a id="twitter-link">Click me</a><br></label>
    <input type="number" class="form-control" id="exampleInputEmail1" placeholder="PIN">
  </div>
  <button type="submit" class="btn btn-default" id="twitter-pin">Submit</button>
</form>
"""
            $(div_id).html query_html
            $("#twitter-link").click ->
                gui.Shell.openExternal link
            $("#twitter-pin").click ->
                PIN = $("#twitter-input").val()

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


    if not session.twitter
        session.twitter = {}
    if not session.twitter.access_token || not session.twitter.access_secret
        async.series {one: authenticate, two: get_stream}, (err, result) ->
            for item in JSON.parse result.two
                console.log item.text
    else
        get_stream (a, b) ->
            return null # placeholder
