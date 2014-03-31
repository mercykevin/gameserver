require File.expand_path("../../test_helper" ,__FILE__)

class AopRetryTest < Minitest::Test
	def test_aop
		Const::Rediskeys.getPlayerKey(1) 
	end
end