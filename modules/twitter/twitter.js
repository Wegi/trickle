// Generated by CoffeeScript 1.8.0
var $, OAuth, ab64, async, consumerSecret, consumer_key, exports, gui, loopObject, twitter_req;

exports = module.exports = {};

ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk=';

consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj';

consumerSecret = new Buffer(ab64, 'base64').toString('utf8');

OAuth = require('oauth').OAuth;

twitter_req = require('twitter-request');

async = require('async');

$ = require('jquery');

gui = window.require('nw.gui');

loopObject = {};

exports.destroy = function(boxOuterId, boxContentID, session) {
  var i;
  clearInterval(loopObject);
  $(boxOuterId).children("div.box-content").children('.trickle-twitter').remove();
  i = session.boxes[boxOuterId].loaded_modules.indexOf("twitter");
  if (i !== -1) {
    session.boxes[boxOuterId].loaded_modules.splice(i, 1);
  }
  return delete session.twitter[boxContentID];
};

exports.init = function(content_id, config_id, session) {
  var authenticate, awaiting_config, createTweetStream, get_stream, oauth, print_tweets, streamBuffer;
  awaiting_config = false;
  if (!session.twitter) {
    session.twitter = {};
  }
  if (!session.twitter[content_id]) {
    session.twitter[content_id] = {};
  }
  oauth = new OAuth("https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", consumer_key, consumerSecret, "1.0", "oob", "HMAC-SHA1");
  authenticate = function(callback) {
    awaiting_config = true;
    $(config_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Initializing...</span>");
    return oauth.getOAuthRequestToken(function(error, user_token, user_secret, results) {
      var link, query_html, snipid;
      session.twitter.user_token = user_token;
      session.twitter.user_secret = user_secret;
      link = 'https://twitter.com/oauth/authenticate?oauth_token=' + user_token;
      snipid = config_id.slice(1);
      query_html = "<div class=\"form-group\">\n    <label>Please visit the following Link and enter the PIN.<br>\n    <a id=\"twitter-link-" + snipid + "\">Click me</a><br></label>\n    <input type=\"number\" class=\"form-control\" id=\"twitter-input-" + snipid + "\" placeholder=\"PIN\">\n</div>\n<button class=\"btn btn-default\" id=\"twitter-pin-" + snipid + "\">Submit</button>";
      $(config_id).html(query_html);
      $("#twitter-link-" + snipid).click(function() {
        return gui.Shell.openExternal(link);
      });
      return $("#twitter-pin-" + snipid).click(function() {
        var PIN;
        PIN = $("#twitter-input-" + snipid).val();
        $(config_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Validating PIN...</span>");
        return oauth.getOAuthAccessToken(user_token, user_secret, PIN, function(error, oauth_access_token, oauth_access_token_secret, results) {
          if (error) {
            $(config_id).html("<span class='btn'><span class='glyphicon glyphicon-remove'></span> An error occured.</span>");
            console.log(error);
            return awaiting_config = false;
          } else {
            $(config_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Loading Tweets...</span>");
            session.twitter.access_token = oauth_access_token;
            session.twitter.access_secret = oauth_access_token_secret;
            awaiting_config = false;
            return callback(null, oauth_access_token);
          }
        });
      });
    });
  };
  get_stream = function(callback) {
    var query, readyoauth, treq;
    $(config_id).html("<span class='btn'><span class='glyphicon glyphicon-ok'></span> Everything worked. You can close the config now.</span>");
    readyoauth = {
      consumer_key: consumer_key,
      consumer_secret: consumerSecret,
      token: session.twitter.access_token,
      token_secret: session.twitter.access_secret
    };
    treq = new twitter_req(readyoauth);
    if (!session.twitter[content_id].last_id) {
      session.twitter[content_id].last_id = 1;
    }
    query = {
      since_id: session.twitter[content_id].last_id,
      count: 100
    };
    console.log(query);
    return treq.request('statuses/home_timeline', {
      query: query
    }, function(err, res, body) {
      var result;
      if (err) {
        return console.log("Error: " + err);
      } else {
        result = JSON.parse(body);
        if (result.length < 1) {
          return callback("No new tweets");
        } else {
          callback(null, body);
          return createTweetStream();
        }
      }
    });
  };
  print_tweets = function(err, result) {
    var tweet, tweet_entry, tweets, user_img, _i, _len, _ref, _results;
    if (err) {
      return console.log(err);
    } else {
      tweets = JSON.parse(result.tweets);
      if (tweets[tweets.length - 1]) {
        if (tweets[tweets.length - 1].id === session.twitter[content_id].last_id) {
          tweets.pop();
        }
      }
      if (tweets[0]) {
        session.twitter[content_id].last_id = Number(tweets[0].id);
      }
      try {
        _ref = tweets.reverse();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tweet = _ref[_i];
          user_img = tweet.user.profile_image_url;
          tweet_entry = "<div class=\"row trickle-twitter\" style=\"margin-bottom: 0.5em; margin-right: 0.5em;\">\n    <div class=\"col-md-2\"><img class=\"img-rounded \"src=\"" + user_img + "\" height=\"55\" width=\"55\"></div>\n    <div class=\"col-md-10\">" + tweet.text + "</div>\n    <div class=\"col-md-12\" style=\"padding-top: 0.5em; border-bottom: 1px solid #ccc;\"></div>\n</div>";
          _results.push($(content_id).prepend(tweet_entry));
        }
        return _results;
      } catch (_error) {
        return console.log("Tweet unreadable (probably Limit exceeded)");
      }
    }
  };
  streamBuffer = "";
  createTweetStream = function() {
    var home_stream, query, readyoauth, treq;
    readyoauth = {
      consumer_key: consumer_key,
      consumer_secret: consumerSecret,
      token: session.twitter.access_token,
      token_secret: session.twitter.access_secret
    };
    treq = new twitter_req(readyoauth);
    query = {
      'with': 'followings'
    };
    home_stream = treq.request('user', {
      body: query
    });
    return home_stream.on('data', function(data) {
      var end, result, tweet;
      end = data.toString().slice(-2);
      streamBuffer += data.toString();
      if (end === '\r\n') {
        try {
          tweet = JSON.parse(streamBuffer);
          if (tweet.text) {
            result = {
              tweets: "[" + streamBuffer + "]"
            };
            print_tweets(null, result);
          }
        } catch (_error) {}
        return streamBuffer = "";
      }
    });
  };
  if (!session.twitter.access_token || !session.twitter.access_secret) {
    return async.series({
      auth: authenticate,
      tweets: get_stream
    }, print_tweets);
  } else {
    return async.series({
      tweets: get_stream
    }, print_tweets);
  }
};
