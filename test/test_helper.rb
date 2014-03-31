#set rake env 
ENV["RACK_ENV"] = "test"
require File.expand_path('../../boot', __FILE__)
#clean all redis data
flushRet = RedisClient.flushall
puts "flush redis data is #{flushRet}"

require "minitest/autorun"

# require 'active_support/test_case'
# require 'active_record/test_case'
# 
# class ActiveSupport::TestCase
#   setup do
#     ActiveRecord::IdentityMap.clear
#   end
#   
# end
