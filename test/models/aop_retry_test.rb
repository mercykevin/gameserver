require File.expand_path("../../test_helper" ,__FILE__)

class AopRetryTest < Test::Unit::TestCase
	def test_aop
		Const::Rediskeys.getPlayerKey(1) 
	end
end