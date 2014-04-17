require 'rubygems'

# Set rack environment
ENV['RACK_ENV'] ||= "development"

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['RACK_ENV'])

require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/reloader' if development?

#if development?
#	also_reload './lib/*.rb'
#	also_reload './exception/*.rb'
#	also_reload './utils/*.rb'
#	also_reload './daos/*.rb'
#	also_reload './models/*.rb'
#end

# Set project configuration
require File.expand_path("../application", __FILE__)