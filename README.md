NoidsClient
===========

NoidsClient provides a wrapper around the [noids server](https://github.com/dbrower/noids) REST API.
This is the thinnest wrapper possible. Don't expect any sophisticated behavior. Nothing is cached.

# Usage

```ruby
require 'noids_client'

noids = NoidsClient::Connection.new("localhost:13001")
mypool = noids.new_pool("mypool", ".zdddk")
mypool.mint
p = noids.get_pool("production")
p.name     # = "mypool"
p.info     # = {"Name"=>"sdfg", "Template"=>".zeeek+24457", "Used"=>24457, "Max"=>-1, "Closed"=>false, "LastMint"=>"2014-06-16T14:27:19.022553001-04:00"}
p.mint     # = ["102bm"]
p.mint(50) # = ["102cr", "102dw", ..., "1042q"]
p.close    # = true
p.open
p.advance_past('zzzs')
```

# Notes

* `mint` will only take an argument between 1 and 1000, inclusive. Other values will cause an exception.
This limitation is imposed by the server.

In the case of connection issues, exceptions are raised.
