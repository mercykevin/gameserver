require File.expand_path("../test_helper",__FILE__)
require 'json'
class UserTest < Test::Unit::TestCase
	def test_register
		Model::Player.register("kevin")
		playerId = RedisClient.get(Const::Rediskeys.getPlayerNameKey("kevin"))
		assert_not_nil(playerId,"player info got from the redis is not exist,the player name is kevin")
		player = RedisClient.get(Const::Rediskeys.getPlayerKey(playerId))
		player = JSON.parse(player)
		assert_equal("kevin",player["playerName"])
		assert_equal(0,player["level"],"the player level is not init value 0")
	end

	def test_getByName
		Model::Player.register("kevin1")
		player = Model::Player.getByName("kevin1")
		assert_not_nil(player)
		assert_equal("kevin1",player["playerName"])
		assert_equal(0,player["level"],"the player level is not init value 0")
	end

	def test_randName
		names = ["kevin1","kevin2","kevin3","kevin4","kevin5"]
		RedisClient.set(Const::Rediskeys.getRandomListKey,names.to_json)
		playerName = Model::Player.randomName()
		assert_not_nil(names.index(playerName))
	end
end