// Generated by CoffeeScript 1.8.0
var $, OAuth, ab64, async, consumerSecret, consumer_key, gui, twitter_req;

ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk=';

consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj';

consumerSecret = new Buffer(ab64, 'base64').toString('utf8');

OAuth = require('oauth').OAuth;

twitter_req = require('twitter-request');

async = require('async');

$ = require('jquery');

gui = window.require('nw.gui');

module.exports = function(div_id, session) {
  var authenticate, get_stream, oauth, print_tweets;
  if (!session.twitter) {
    session.twitter = {};
  }
  $(div_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Initializing...</span>");
  oauth = new OAuth("https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", consumer_key, consumerSecret, "1.0", "oob", "HMAC-SHA1");
  authenticate = function(callback) {
    return oauth.getOAuthRequestToken(function(error, user_token, user_secret, results) {
      var link, query_html, snipid;
      session.twitter.user_token = user_token;
      session.twitter.user_secret = user_secret;
      link = 'https://twitter.com/oauth/authenticate?oauth_token=' + user_token;
      snipid = div_id.slice(1);
      query_html = "<div class=\"form-group\">\n    <label>Please visit the following Link and enter the PIN.<br>\n    <a id=\"twitter-link-" + snipid + "\">Click me</a><br></label>\n    <input type=\"number\" class=\"form-control\" id=\"twitter-input-" + snipid + "\" placeholder=\"PIN\">\n</div>\n<button class=\"btn btn-default\" id=\"twitter-pin-" + snipid + "\">Submit</button>";
      $(div_id).html(query_html);
      $("#twitter-link-" + snipid).click(function() {
        return gui.Shell.openExternal(link);
      });
      return $("#twitter-pin-" + snipid).click(function() {
        var PIN;
        PIN = $("#twitter-input-" + snipid).val();
        $(div_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Validating PIN...</span>");
        return oauth.getOAuthAccessToken(user_token, user_secret, PIN, function(error, oauth_access_token, oauth_access_token_secret, results) {
          if (error) {
            $(div_id).html("<span class='btn'><span class='glyphicon glyphicon-remove'></span> An error occured.</span>");
            return console.log(error);
          } else {
            $(div_id).html("<span class='btn'><span class='glyphicon glyphicon-refresh'></span> Loading tweets...</span>");
            session.twitter.access_token = oauth_access_token;
            session.twitter.access_secret = oauth_access_token_secret;
            return callback(null, oauth_access_token);
          }
        });
      });
    });
  };
  get_stream = function(callback) {
    var query, readyoauth, treq;
    readyoauth = {
      consumer_key: consumer_key,
      consumer_secret: consumerSecret,
      token: session.twitter.access_token,
      token_secret: session.twitter.access_secret
    };
    treq = new twitter_req(readyoauth);
    if (!session.twitter.last_id) {
      session.twitter.last_id = 1;
    }
    query = {
      since_id: session.twitter.last_id,
      count: 100
    };
    console.log(query);
    return treq.request('statuses/home_timeline', {
      query: query
    }, function(err, res, body) {
      var result;
      result = JSON.parse(body);
      console.log("res: %j", res);
      if (result.length < 1) {
        return callback(null, {
          tweets: false
        });
      } else {
        session.twitter.last_id = (Number(result[0].id)) + 1;
        return callback(null, body);
      }
    });
  };
  print_tweets = function(err, result) {
    var tweet, tweet_entry, _i, _len, _ref, _results;
    if (err) {
      return err;
    } else {
      $(div_id).html(" ");
      console.log("##Result.tweets: " + result.tweets);
      if (result.tweets === !false) {
        console.log((JSON.parse(result.tweets)).length);
        _ref = (JSON.parse(result.tweets)).reverse();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tweet = _ref[_i];
          tweet_entry = "<div class=\"row\">\n    <div class=\"col-md-2\">Here go Picture</div>\n    <div class=\"col-md-10\">" + tweet.text + "</div>\n</div>";
          _results.push($(div_id).prepend(tweet_entry));
        }
        return _results;
      }
    }
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
