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

A noids server is not provided by this repository.
However, for testing or experimentation it is convinent to set up a noids server, which is not difficult.

## On a Mac with homebrew

First install a golang environment.

    brew install go
    mkdir ~/gocode
    export GOPATH=~/gocode
    export PATH=$GOPATH/bin:$PATH

Install the noids server:

    go get https://github.com/dbrower/noids

Start it, and have it keep pools in memory.

    noids

These pools will be lost when the server is restarted.
To save the pools to disk use

    noids -storage directory/to/use

There are other options, including saving the pools to a database.
See the documentation on the [noids server](https://github.com/dbrower/noids) page.

You can test the server using `curl`.
Note that the default port for the server to listen on is 13001.
These commands will create a pool named 'test' which will generate ids using the template `.sddd`.
Then 50 ids are minted, and the pool is advanced past the id `432`, so that `432` will never be minted by this pool.

    curl 'http://localhost:13001/pools' -F 'name=test' -F 'template=.sddd'
    curl 'http://localhost:13001/pools/test/mint' -F 'n=50'
    curl 'http://localhost:13001/pools/test/advancePast' -F 'id=432'


## On Linux

Install a golang envrionment. This should be done using your package management system.
e.g. `yum install golang`.
Then follow the remaining steps above.

