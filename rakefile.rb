require "sinatra/activerecord/rake"
require "./app"

namespace :db do
  task :load_config do
    require_relative "app"
  end
end
