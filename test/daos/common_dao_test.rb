require File.expand_path("../../test_helper" ,__FILE__)

class CommonDaoTest < Minitest::Test
	# def test_update
	# 	commonDao = CommonDao.new
	# 	value = {}
	# 	value["test1"] = "abc"
	# 	value["test2"] = "bcd"
	# 	commonDao.update(value)
	# 	assert_equal("abc",RedisClient.get("test1"))
	# end


	def test_update_set
		commonDao = CommonDao.new
		value = {}
		value["a1"] = 1
		value["a2"] = 2
		commonDao.update(value)

		value = {}
		value["a1"] = 1
		value["a2"] = 2
		commonDao.updateWithSort({"string" => value})

		
		value = {}
		value["a1"] = 11
		value["a2"] = 22
		value["a3"] = 33

	
		set = {}
		set["1"] = 10 
		set["2"] = 20
		set["3"] = 30
	

		commonDao.updateWithSort({"string" => value , "zset" => {"sorts" => set}})

		set = {}
		set["3"] = 3 
		commonDao.updateWithSort({"string" => value , "zset" => {"sorts" => set}})



		



	end
end