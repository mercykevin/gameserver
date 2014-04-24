# Set application dependencies
ENV['RACK_ENV'] = "production"
require File.expand_path("../boot", __FILE__)

# release thread current connection return to connection pool in multi-thread mode
#use ActiveRecord::ConnectionAdapters::ConnectionManagement

# Boot application
run Sinatra::Application
