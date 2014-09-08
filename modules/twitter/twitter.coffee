ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'
consumerSecret = new Buffer(ab64, 'base64').toString 'utf8'

OAuth = require('oauth').OAuth
twitter_req = require 'twitter-request'
async = require 'async'
$ = require 'jquery'
gui = window.require 'nw.gui'

module.exports = (div_id, session) ->
    if not session.twitter
        session.twitter = {}
    # create session namespace if there is

    # Show spinner while loading
    $(div_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Initializing...</span>"

    oauth = new OAuth(
          "https://api.twitter.com/oauth/request_token",
          "https://api.twitter.com/oauth/access_token",
          consumer_key,
          consumerSecret,
          "1.0",
          "oob",
          "HMAC-SHA1"
        )

    authenticate = (callback) ->
        oauth.getOAuthRequestToken (error, user_token, user_secret, results) ->
            session.twitter.user_token = user_token
            session.twitter.user_secret = user_secret
            link = 'https://twitter.com/oauth/authenticate?oauth_token='+user_token
            snipid = div_id[1..]
            query_html = """
<div class="form-group">
    <label>Please visit the following Link and enter the PIN.<br>
    <a id="twitter-link-#{snipid}">Click me</a><br></label>
    <input type="number" class="form-control" id="twitter-input-#{snipid}" placeholder="PIN">
</div>
<button class="btn btn-default" id="twitter-pin-#{snipid}">Submit</button>
"""
            $(div_id).html query_html
            $("#twitter-link-#{snipid}").click ->
                gui.Shell.openExternal link
            $("#twitter-pin-#{snipid}").click ->
                PIN = $("#twitter-input-#{snipid}").val()

                # Show spinner while loading
                $(div_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Validating PIN...</span>"

                oauth.getOAuthAccessToken user_token, user_secret, PIN ,
                (error, oauth_access_token, oauth_access_token_secret, results) ->
                    if error
                        $(div_id).html "<span class='btn'><span class='glyphicon glyphicon-remove'></span> An error occured.</span>"
                        console.log(error)
                    else
                        $(div_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Loading tweets...</span>"
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
        #only get twees since last pull
        if not session.twitter.last_id
            session.twitter.last_id = 1
        query =
            since_id: session.twitter.last_id,
            count: 100
        console.log query
        treq.request 'statuses/home_timeline', query: query,
                     (err, res, body) ->
                        result = JSON.parse body
                        console.log "res: %j", res
                        if result.length < 1
                            callback null, tweets: false
                        else
                            session.twitter.last_id = (Number result[0].id)+1
                            callback null, body

    print_tweets = (err, result) ->
        if err
            return err
        else
            $(div_id).html " "
            console.log "##Result.tweets: "+result.tweets
            if result.tweets is not false
                console.log (JSON.parse result.tweets).length
                for tweet in (JSON.parse result.tweets).reverse()
                    tweet_entry = """
<div class="row">
    <div class="col-md-2">Here go Picture</div>
    <div class="col-md-10">#{tweet.text}</div>
</div>
"""
                    $(div_id).prepend tweet_entry
                    #set last retrieved tweet

    if not session.twitter.access_token || not session.twitter.access_secret
        async.series {auth: authenticate, tweets: get_stream}, print_tweets
    else
        async.series {tweets: get_stream}, print_tweets
