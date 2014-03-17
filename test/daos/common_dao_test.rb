require File.expand_path("../../test_helper" ,__FILE__)

class CommonDaoTest < Test::Unit::TestCase
	def test_update
		value = {}
		value["test1"] = "abc"
		value["test2"] = "bcd"
		CommonDao.update(value)
		assert_equal("abc",RedisClient.get("test1"))
	end
end