/*
 * EndPoint of Twitter API
 */

/** https://dev.twitter.com/docs/api/1.1/ **/

var urlPattern = "https://%subdomain%.twitter.com%path%%endpoint%%ext%";

/*
 * %path%: {
 *  %subdomain%: {
 *    %endpoint%: {
 *      method: get/post,
 *      ext: %ext% [default = ".json"],
 *      endpoint: %endpoint% [Optional, will replace the default endpoint]
 *    }
 *  }
 * }
 */
var endpoints = {
  "/": {
    "api": {
      // OAuth
      "oauth/authenticate": {method: "get", 'ext': ''},
      "oauth/authorize": {method: "get", 'ext': ''},
      "oauth/access_token": {method: "post", 'ext': ''},
      "oauth/request_token": {method: "post", 'ext': ''},
      "oauth2/token": {method: "post", 'ext': ''},
      "oauth2/invalidate_token": {method: "post", 'ext': ''}
    }
  },

  "/1.1/": {
    api: {
      // Timelines
      "statuses/mentions_timeline": {method: "get"},
      "statuses/user_timeline": {method: "get"},
      "statuses/home_timeline": {method: "get"},
      "statuses/retweets_of_me": {method: "get"},

      // Tweets
      "statuses/retweets": {method: "get", endpoint: "statuses/retweets/:id"},
      "statuses/lookup": {method: "get"},
      "statuses/show": {method: "get",  endpoint: "statuses/show/:id"},
      "statuses/destroy": {method: "post", endpoint: "statuses/destroy/:id"},
      "statuses/update": {method: "post"},
      "statuses/retweet": {method: "post", endpoint: "statuses/retweet/:id"},
      "statuses/update_with_media": {method: "post"},
      "statuses/oembed": {method: "get"},
      "statuses/retweeters/ids": {method: "get"},

      // Search
      "search/tweets": {method: "get"},

      // Direct Messages
      "direct_messages": {method: "get"},
      "direct_messages/sent": {method: "get"},
      "direct_messages/show": {method: "get"},
      "direct_messages/destroy": {method: "post"},
      "direct_messages/new": {method: "post"},

      // Friends & Followers
      "friendships/no_retweets/ids": {method: "get"},
      "friendships/incoming": {method: "get"},
      "friendships/outgoing": {method: "get"},
      "friendships/lookup": {method: "get"},
      "friendships/create": {method: "post"},
      "friendships/destroy": {method: "post"},
      "friendships/update": {method: "post"},
      "friendships/show": {method: "get"},
      "friends/ids": {method: "get"},
      "friends/list": {method: "get"},
      "followers/ids": {method: "get"},
      "followers/list": {method: "get"},

      // Users
      "account/settings": {method: "post"},
      "account/verify_credentials": {method: "get"},
      "account/update_delivery_device": {method: "post"},
      "account/update_profile": {method: "post"},
      "account/update_profile_background_image": {method: "post"},
      "account/update_profile_colors": {method: "post"},
      "account/update_profile_image": {method: "post"},
      "blocks/list": {method: "get"}, "blocks/ids": {method: "get"},
      "blocks/create": {method: "post"},
      "blocks/destroy": {method: "post"},
      "users/lookup": {method: "get"},
      "users/show": {method: "get"},
      "users/search": {method: "get"},
      "users/contributees": {method: "get"},
      "users/contributors": {method: "get"},
      "account/remove_profile_banner": {method: "post"},
      "account/update_profile_banner": {method: "post"},
      "users/profile_banner": {method: "get"},

      // Suggested Users
      "users/suggestions": {method: "get"},
      "users/suggestions/:slug": {method: "get"},
      "users/suggestions/:slug/members": {method: "get"},

      // Favorites
      "favorites/list": {method: "get"},
      "favorites/destroy": {method: "post"},
      "favorites/create": {method: "post"},

      // Lists
      "lists/list": {method: "get"},
      "lists/statuses": {method: "get"},
      "lists/members/destroy": {method: "post"},
      "lists/memberships": {method: "get"},
      "lists/subscribers": {method: "get"},
      "lists/subscribers/create": {method: "post"},
      "lists/subscribers/show": {method: "get"},
      "lists/subscribers/destroy": {method: "post"},
      "lists/members/create_all": {method: "post"},
      "lists/members/show": {method: "get"},
      "lists/members": {method: "get"},
      "lists/members/create": {method: "post"},
      "lists/destroy": {method: "post"},
      "lists/update": {method: "post"},
      "lists/create": {method: "post"},
      "lists/show": {method: "get"},
      "lists/subscriptions": {method: "get"},
      "lists/members/destroy_all": {method: "post"},
      "lists/ownerships": {method: "get"},

      // Saved Searches
      "saved_searches/list": {method: "get"},
      "saved_searches/show": {method: "get", endpoint: "saved_searches/show/:id"},
      "saved_searches/create": {method: "post"},
      "saved_searches/destroy": {method: "post", endpoint: "saved_searches/destroy/:id"},

      // Places & Geo
      "geo/id": {method: "get", extname: "geo/id/:place_id"},
      "geo/reverse_geocode": {method: "get"},
      "geo/search": {method: "get"},
      "geo/similar_places": {method: "get"},
      "geo/place": {method: "post"},

      // Trends
      "trends/place": {method: "get"},
      "trends/available": {method: "get"},
      "trends/closest": {method: "get"},

      // Spam Reporting
      "users/report_spam": {method: "post"},

      // Help
      "help/configuration": {method: "get"},
      "help/languages": {method: "get"},
      "help/privacy": {method: "get"},
      "help/tos": {method: "get"},
      "application/rate_limit_status": {method: "get"}
    },

    stream: {
      // Streaming
      "statuses/filter": {method: "get"},
      "statuses/sample": {method: "get"},
      "statuses/firehose": {method: "get"}
    },

    userstream: {
      "user": {method: "get"}
    },

    sitestream: {
      "site": {method: "get"}
    }
  }
};


for (var path in endpoints) {
  if(endpoints.hasOwnProperty(path)){
    for(var subdomain in endpoints[path]){
      if(endpoints[path].hasOwnProperty(subdomain)){
        var current = endpoints[path][subdomain];
        for (var endpoint in current) {
          if (current.hasOwnProperty(endpoint)){
            current[endpoint].ext = (current[endpoint].ext === undefined ? '.json' : current[endpoint].ext);

            var pathname = urlPattern
              .replace('%subdomain%', subdomain)
              .replace('%path%', path)
              .replace('%endpoint%', current[endpoint].endpoint || endpoint)
              .replace('%ext%', current[endpoint].ext);

            module.exports[endpoint] = {
              method: current[endpoint].method,
              url: pathname
            };
          }
        }
      }
    }
  }
}