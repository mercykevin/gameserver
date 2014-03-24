require File.expand_path("../../test_helper",__FILE__)
require 'json'
class UserTest < Test::Unit::TestCase
	def test_register
		Model::Player.register("kevin","image")
		playerId = RedisClient.get(Const::Rediskeys.getPlayerNameKey("kevin"))
		assert_not_nil(playerId,"player info got from the redis is not exist,the player name is kevin")
		player = RedisClient.get(Const::Rediskeys.getPlayerKey(playerId))
		player = JSON.parse(player, {:symbolize_names => true})
		assert_equal("kevin",player[:playerName])
		assert_equal(0,player[:level],"the player level is not init value 0")
	end

	def test_getByName
		Model::Player.register("kevin1","image")
		player = Model::Player.getByName("kevin1")
		assert_not_nil(player)
		assert_equal("kevin1",player[:playerName])
		assert_equal(0,player[:level],"the player level is not init value 0")
	end

	def test_randName
		names = []
		10.times do
			names << Model::Player.randomName("male")
		end
		newnames = names.uniq
		assert_equal(names.length, newnames.length)
	end
end