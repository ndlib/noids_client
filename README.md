NoidsClient
===========

NoidsClient provides a wrapper around the [noids server](https://github.com/dbrower/noids) REST API.
This is the thinnest wrapper possible. Don't expect any sophisticated behavior.

# Usage

```ruby
require 'noids_client'

noids = NoidsClient::Connection.new("localhost:13001")
noids.pool_list      # = ["sdfg"]
noids.server_version # = "1.0.1"
mypool = noids.new_pool("mypool", ".zdddk")
mypool.mint # = ["0000"]
p = noids.get_pool("sdfg")  # load a pool which has already been created
p.name     # = "sdfg"
p.closed?  # = false
p.last_mint_date # = #<DateTime: 2014-06-16T14:27:19-04:00 ((2456825j,66439s,22553001n),-14400s,2299161j)>
p.template # = ".zeeek+24457"
p.ids_used # = 24457
p.max_ids  # = Float::INFINITY
p.mint     # = ["102bm"]
p.mint(50) # = ["102cr", "102dw", ..., "1042q"]
p.close    # closes the pool to new minting
p.closed?  # = true
p.open     # opens the pool to new minting (provided there are more ids available for minting)
p.advance_past('zzzs')
p.update   # reloads ids_used and last_mint_date from the server
```

# Notes

* `mint` will only take an argument between 1 and 1000, inclusive. Other values will cause an exception.
This limitation is imposed by the server.
* In the case of connection issues, exceptions are raised.

# Setting up a noids server

Follow the instructions at https://github.com/ndlib/noids

# Running tests

You can run the test suite by `bundle exec rspec`.

## Testing Noids::Client against a live noid server

Open two terminals.

In the **first** terminal, start a noids server (as per https://github.com/ndlib/noids).
I have found that once I've built my noids binary, I use the following to get
a clean state: `rm -rf ~/noid_pool; mkdir ~/noid_pool; $GOPATH/bin/noids --storage ~/noid_pool`

In the **second** terminal, run `bundle exec rake test_client_against_server`.
Each time you run the rake task, it should be against a clean noids server
instance.
