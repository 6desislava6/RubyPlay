require 'sinatra'

set :database, "sqlite3:ruby_play.sqlite3" #{adapter: "sqlite3", database: 'ruby_play.sqlite3'}

# These Heroku setup instructions can be at: https://devcenter.heroku.com/articles/rack

