# How's Business?

A look at the Chicago economy, based on open data.

## Installation

```console
git clone git@github.com:open-city/hows-business.git
cd hows-business
gem install bundler
bundle
unicorn
```
  navigate to http://localhost:8080/

## Dependencies

* [Ruby 1.9.3](http://www.ruby-lang.org/en/downloads)
* [Sinatra](http://www.sinatrarb.com)
* [Heroku](http://www.heroku.com)
* [Twitter Bootstrap](http://twitter.github.com/bootstrap)

## Raw data

The data used for this project all come from [open sources](http://howsbusinesschicago.org/about#what-were-measuring). 

You can [download all of our raw data](http://bunkum.us/hb_data/), including the trends we're calculating in JSON format.

## Errors / Bugs

If something is not behaving intuitively, it is a bug, and should be reported.
[Report it here](https://github.com/open-city/hows-business/issues).


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Commit and send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2013 Daniel Morton, Derek Eder, Forest Gregg and Matt Gee. Released under the [MIT License](https://github.com/open-city/hows-business/wiki/License).