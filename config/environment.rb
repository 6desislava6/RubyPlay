require "rubygems"
require "bundler"
require 'sinatra'

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems

set :database, "sqlite3:ruby_play.sqlite3" #{adapter: "sqlite3", database: 'ruby_play.sqlite3'}

require "active_support/deprecation"
require "active_support/all"

$db = [] # a fake database
