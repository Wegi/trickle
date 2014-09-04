Twitter Request
====================

Twitter-Request is a module to make easy authentificated request to the Twitter API.
(Only user-authentification is supported for now)

## How can i install it
    npm install --save twitter-request

  	
## How can i use it

    var TwitterRequest = require('TwitterRequest');

    var oauth = {
		// Mandatory
		consumer_key: "CONSUMER_KEY",
		consumer_secret: "CONSUMER_SECRET",
		
		// Optional
		token: "USER_TOKEN",
		token_secret: "USER_SECRET_TOKEN"
    };

    var treq = new TwitterRequest(oauth);

    // Go to https://dev.twitter.com/docs/api/1.1 to have endpoints documentation
    treq.request('statuses/update', {
    	// Add query to the url 
		query: {
			'status': 'Hello Twitter ! I will destroy this tweet in 5 seconds c:'
		}
	}, function(err, res, body){
		// err => ERROR
		// res => ServerResponse
		// body => Body of the response

		if(err) throw err;

		if(res.statusCode !== 200)
			throw new Error('For some reason, Twitter reject the request D:\n\rMore information:\n\r' + JSON.parse(body));

		setTimeout(function(){
			treq.request('statuses/destroy', {
				// Replace url parameters (statuses/destroy => https://api.twitter.com/1.1/statuses/destroy/:id.json [here, we replace the id parameters])
				params: {
					// Use id_str instead of id ! id may be to long for an integer 
					id: JSON.parse(body).id_str
				}
			});
		}, 5000);
	});


	// Support of streaming api
	var req = treq.request('statuses/filter', {
		// Add data to the body
		body: {
			'track': 'nodejs'
		}
	});

	req.on('data', function(data){
		console.log(data.toString());
	});

	
	// You can find and rewrite oauth data here (This object is passed to the request oauth function)
	console.log(treq.oauth);
	treq.oauth.consumer_key = "NEW_CONSUMER_KEY";