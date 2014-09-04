// Generated by CoffeeScript 1.8.0
var OAuth, ab64, async, consumeSecret, consumer_key, readline, twitter_req;

ab64 = 'QWJHZkNEOWJxWXBLcDBtYmtqTVF2QTJRWWxnWlZlUGNuZHcwMkxvOHBYSmdpVDk2WHk=';

consumer_key = '8CMdYgIYpDM6uknWRAfWEhGEj';

consumeSecret = new Buffer(ab64, 'base64').toString('utf8');

OAuth = require('oauth').OAuth;

readline = require('readline');

twitter_req = require('twitter-request');

async = require('async');

module.exports = function(div_id, session) {
  var authenticate, get_stream, oauth, rl;
  rl = readline.createInterface(process.stdin, process.stdout);
  oauth = new OAuth("https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", consumer_key, consumeSecret, "1.0", "oob", "HMAC-SHA1");
  authenticate = function(callback) {
    return oauth.getOAuthRequestToken(function(error, user_token, user_secret, results) {
      session.twitter.user_token = user_token;
      session.twitter.user_secret = user_secret;
      console.log('https://twitter.com/oauth/authenticate?oauth_token=' + user_token);
      return rl.question('Please Enter the PIN: ', function(PIN) {
        rl.close();
        process.stdin.destroy();
        return oauth.getOAuthAccessToken(user_token, user_secret, PIN, function(error, oauth_access_token, oauth_access_token_secret, results) {
          if (error) {
            return console.log(error);
          } else {
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
    query = {
      'count': 20
    };
    return treq.request('statuses/home_timeline', query, function(err, res, body) {
      return callback(null, body);
    });
  };
  if (!session.twitter) {
    session.twitter = {};
  }
  if (!session.twitter.access_token || !session.twitter.access_secret) {
    return async.series({
      one: authenticate,
      two: get_stream
    }, function(err, result) {
      var item, _i, _len, _ref, _results;
      _ref = JSON.parse(result.two);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(console.log(item.text));
      }
      return _results;
    });
  } else {
    return get_stream(function(a, b) {
      return null;
    });
  }
};
