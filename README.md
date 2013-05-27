jsbin-client
============

[![Build Status](https://travis-ci.org/mattheworiordan/jsbin-client.png)](https://travis-ci.org/mattheworiordan/jsbin-client)

jsbin-client is a simple Ruby client for JSBin [http://jsbin.com/](http://jsbin.com/).  It provides basic CRUD methods to retrieve a bin, create a bin, and create a revision for an existing bin.

The library supports anonymous or token authentication if required by the server.

Please see [https://github.com/remy/jsbin/pull/605](https://github.com/remy/jsbin/pull/605) for more information on JSBin's support API requests

Installation
------------

Using Bundler, add the following to your Gemfile

    gem 'jsbin-client'

or install manually using Ruby Gems:

    gem install jsbin-client


Code example
------------

```ruby
client = JsBinClient.new(host: 'jsbin.com', port: 80, ssl: false)

bin = client.create(html: '<html><body></body></html>', javascript: 'console.log("init");', css: 'body { color: red }')
# => {
#   "html"=>"<html><body></body></html>",
#   "javascript": "console.log(\"init\");",
#   "css": "body { color: red }'",
#   "settings": "{ processors: {} }",
#   "url": "[unique-id]",
#   "revision": 1,
#   "streamingKey": "[key]",
#   "id": 7
# }

bin.get(bin[:url])
# returns JSON representation of bin

bin.create_revision(bin[:url], html: 'updated html')
# returns JSON representation of new bin revision

bin.url_for(bin[:url])
# => 'http://jsbin.com:80/[unique-id]/edit'

bin.url_for(bin[:url], preview: true)
# => 'http://jsbin.com:80/[unique-id]'

bin.url_for(bin[:url], embed: true, panels: ['javascript', 'live'])
# => 'http://jsbin.com:80/[unique-id]/embed?javascript,live'
```

Repository
----------

Please fork, submit patches or feedback at [https://github.com/mattheworiordan/jsbin-client](https://github.com/mattheworiordan/jsbin-client)

The gem details on RubyGems.org can be found at [https://rubygems.org/gems/jsbin-client](https://rubygems.org/gems/jsbin-client)

About
-----

This gem was written by **Matthew O'Riordan**

 - [http://mattheworiordan.com](http://mattheworiordan.com)
 - [@mattheworiordan](http://twitter.com/#!/mattheworiordan)
 - [Linked In](http://www.linkedin.com/in/lemon)

License
-------

Copyright © 2013 Matthew O'Riordan, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
