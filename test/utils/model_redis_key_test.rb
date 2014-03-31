require File.expand_path("../../test_helper", __FILE__)

class RedisKeyTest <  Minitest::Test
	def test_getPlayerKey
		assert_equal("player:[1]",Const::Rediskeys.getPlayerKey(1))
	end

	def test_getPlayerIdAutoIncKey
		assert_equal("player_id_inc",Const::Rediskeys.getPlayerIdAutoIncKey)
	end

	def test_getCityKey
		assert_equal("city:[1]",Const::Rediskeys.getCityKey(1))
	end

	def test_getBuildingKey
		assert_equal("city_building:[1]:[bank]",Const::Rediskeys.getBuildingKey(1,"bank"))
	end

	def test_getHeroKey
		assert_equal("hero:[1]:[2]",Const::Rediskeys.getHeroKey(1,2))
	end

	def test_getItemKey
		assert_equal("item:[1]:[2]",Const::Rediskeys.getItemKey(1,2))
	end

	def test_getHeroIdAutoIncKey
		assert_equal("hero_id_inc:[1]",Const::Rediskeys.getHeroIdAutoIncKey(1))
	end

	def test_getItemIdAutoIncKey
		assert_equal("item_id_inc:[1]",Const::Rediskeys.getItemIdAutoIncKey(1))
	end

	def test_getPlayerNameKey
		assert_equal("player_name:[kevin]",Const::Rediskeys.getPlayerNameKey('kevin'))
	end

end