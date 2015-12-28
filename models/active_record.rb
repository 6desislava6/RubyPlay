require "sinatra/activerecord"

set :database, {adapter: "sqlite3", database: "foo.sqlite3"}
register Sinatra::ActiveRecordExtension
