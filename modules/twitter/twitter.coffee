exports = module.exports = { }

ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk='
consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj'
consumerSecret = new Buffer(ab64, 'base64').toString 'utf8'

OAuth = require('oauth').OAuth
twitter_req = require 'twitter-request'
async = require 'async'
$ = require 'jquery'
gui = window.require 'nw.gui'


exports.destroy = (boxOuterId, boxContentId, session) ->
    # stop updates
    session.twitter[boxContentId].update_stream.removeAllListeners 'data'
    # kill all your posts
    $(boxContentId).children('.trickle-twitter').remove()
    # remove from loaded modules
    i = session.boxes[boxOuterId].loaded_modules.indexOf "twitter"
    if i != -1
        session.boxes[boxOuterId].loaded_modules.splice i, 1
    # delete your data
    delete session.twitter[boxContentId]

exports.init = (content_id, config_id, session) ->
    awaiting_config = false
    # create session namespace if there isn't one
    if not session.twitter
        session.twitter = {}
    # create window specific session namespace
    if not session.twitter[content_id]
        session.twitter[content_id] = {}

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
        awaiting_config = true
        # Show spinner while loading
        $(config_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Initializing...</span>"
        oauth.getOAuthRequestToken (error, user_token, user_secret, results) ->
            session.twitter.user_token = user_token
            session.twitter.user_secret = user_secret
            link = 'https://twitter.com/oauth/authenticate?oauth_token='+user_token
            snipid = config_id[1..]
            query_html = """
<div class="form-group">
    <label>Please visit the following Link and enter the PIN.<br>
    <a id="twitter-link-#{snipid}">Click me</a><br></label>
    <input type="number" class="form-control" id="twitter-input-#{snipid}" placeholder="PIN">
</div>
<button class="btn btn-default" id="twitter-pin-#{snipid}">Submit</button>
"""
            $(config_id).html query_html
            $("#twitter-link-#{snipid}").click ->
                gui.Shell.openExternal link
            $("#twitter-pin-#{snipid}").click ->
                PIN = $("#twitter-input-#{snipid}").val()

                # Show spinner while loading
                $(config_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Validating PIN...</span>"

                oauth.getOAuthAccessToken user_token, user_secret, PIN ,
                (error, oauth_access_token, oauth_access_token_secret, results) ->
                    if error
                        $(config_id).html "<span class='btn'><span class='glyphicon glyphicon-remove'></span> An error occured.</span>"
                        console.log(error)
                        awaiting_config = false
                    else
                        $(config_id).html "<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Loading Tweets...</span>"
                        session.twitter.access_token = oauth_access_token;
                        session.twitter.access_secret = oauth_access_token_secret;
                        awaiting_config = false
                        callback null, oauth_access_token


    get_stream = (callback) ->
        $(config_id).html "<span class='btn'><span class='glyphicon glyphicon-ok'></span> Everything worked. You can close the config now.</span>"
        readyoauth =
            consumer_key: consumer_key
            consumer_secret: consumerSecret
            token: session.twitter.access_token
            token_secret: session.twitter.access_secret
        console.log "hey dick im where im supposed to be"
        treq = new twitter_req(readyoauth)
        #only get twees since last pull
        if not session.twitter[content_id].last_id
            session.twitter[content_id].last_id = 1
        query =
            since_id: session.twitter[content_id].last_id,
            count: 100
        console.log query
        treq.request 'statuses/home_timeline', query: query,
                     (err, res, body) ->
                        if err
                            console.log "Error: "+err
                        else
                            result = JSON.parse body
                            if result.length < 1
                                callback "No new tweets"
                            else
                                callback null, body
                        # credentials should be ready now, create stream
                        createTweetStream()

    print_tweets = (err, result) ->
        if err
            console.log err
        else
            tweets = JSON.parse result.tweets
            # kill the duplicate tweet
            if tweets[tweets.length-1]
                if tweets[tweets.length-1].id == session.twitter[content_id].last_id
                    tweets.pop()
            if tweets[0]
                session.twitter[content_id].last_id = (Number tweets[0].id)

            # reverse array because we prepend and thus the oldest tweet goes first
            try
                for tweet in tweets.reverse()
                    user_img = tweet.user.profile_image_url
                    tweet_entry = """<div class="row trickle-twitter" style="margin-bottom: 0.5em; margin-right: 0.5em;">"""
                    if tweet.retweeted_status
                        tweet_entry += """<div class="col-md-2"><img class="img-rounded "src="#{tweet.retweeted_status.user.profile_image_url}" height="55" width="55"></div>"""
                        tweet_entry += """<div class="col-md-10"><div class="row"><div class="col-md-12"><strong>#{tweet.retweeted_status.user.name}</strong> <small>@#{tweet.retweeted_status.user.screen_name} (retweeted by #{tweet.user.name})</small></div></div> """
                        tweet_entry += """<div class="row"><div class="col-md-12">#{tweet.retweeted_status.text}</div></div>"""
                    else
                        tweet_entry += """<div class="col-md-2"><img class="img-rounded "src="#{user_img}" height="55" width="55"></div>"""
                        tweet_entry += """<div class="col-md-10"><div class="row"><div class="col-md-12"><strong>#{tweet.user.name}</strong> <small>@#{tweet.user.screen_name}</small></div></div> """
                        tweet_entry += """<div class="row"><div class="col-md-12">#{tweet.text}</div></div>"""
                    tweet_entry += """</div>"""
                    tweet_entry += """<div class="row" style="margin-right: 0.5em;">"""
                    tweet_entry += """<div class="col-md-12" style="padding-top: 0.5em; padding-right: 0.5em; border-bottom: 1px solid #ccc;"></div></div>"""

                    $(content_id).prepend tweet_entry
                    #set last retrieved tweet
            catch
                console.log "Tweet unreadable (probably Limit exceeded)"

    streamBuffer = ""
    createTweetStream = () ->
        readyoauth =
            consumer_key: consumer_key
            consumer_secret: consumerSecret
            token: session.twitter.access_token
            token_secret: session.twitter.access_secret

        treq = new twitter_req(readyoauth)
        query =
            'with': 'followings'
        update_stream = treq.request 'user', body: query
        update_stream.on 'data', (data) ->
            end = data.toString()[-2..]
            streamBuffer += data.toString()
            if end == '\r\n'
                console.log streamBuffer
                try
                    tweet = JSON.parse streamBuffer
                    if tweet.text
                        result =
                            tweets: "[#{streamBuffer}]"
                        print_tweets null, result
                streamBuffer = ""
        session.twitter[content_id].update_stream = update_stream

    console.log "bottom"
    if not session.twitter.access_token || not session.twitter.access_secret
        console.log "first"
        async.series {auth: authenticate, tweets: get_stream}, print_tweets
    else
        console.log "second"
        async.series {tweets: get_stream}, print_tweets



