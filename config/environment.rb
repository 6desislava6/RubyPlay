require "rubygems"
require "bundler"
require 'sinatra'
require "active_support/deprecation"
require "active_support/all"



set :database, "sqlite3:ruby_play.sqlite3" #{adapter: "sqlite3", database: 'ruby_play.sqlite3'}



